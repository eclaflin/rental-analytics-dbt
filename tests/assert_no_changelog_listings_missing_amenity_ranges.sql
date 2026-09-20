/*
    Singular test: assert that no listing with changelog entries has a null amenities_json
    in the mart.

    Context:
    mart_listings__daily_activity resolves amenity state by first attempting a range join
    to int_amenities__effective_ranges (the SCD2 changelog-derived table), then falling
    back to amenities_snapshot from stg_raw__listings for listings with no changelog
    entries.

    A warn-severity not_null test on amenities_json in the mart yml catches rows
    where both sources are null, but it cannot distinguish between two failure modes:

      1. The listing genuinely has no amenity data anywhere
            This is an "acceptable" null on the basis of flagging an upstream data-quality
            issue without failing the job outright
      2. The listing has changelog entries but the range join found no match for a given
         date
            e.g. a calendar date that precedes the listing's first changelog entry,
            causing a silent fallback to the snapshot (or null if the snapshot is also empty)

    This test targets failure mode 2 specifically.

    If a listing appears in int_amenities__effective_ranges, it has changelog data,
    so any null amenities_json in the mart for that listing indicates the range join missed.
    This is a correctness issue invisible to column-level schema tests because it requires asserting a
    relationship across two models.

    A standard dbt schema test cannot express this cross-model assertion, making this
    a good candidate for a singular test.

    Rows returned = failures.
*/

with changelog_listings as (
    select distinct listing_id
    from {{ ref('int_amenities__effective_ranges') }}
),

mart as (
    select
        listing_id,
        listing_date,
        amenities_json
    from
        {{ ref('mart_listings__daily_activity') }}
),

failures as (
    select
        mart.*
    from
        mart
            inner join
        changelog_listings on mart.listing_id = changelog_listings.listing_id
    where
        mart.amenities_json is null
)

select *
from failures
