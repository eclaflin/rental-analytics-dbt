with source as (
    select *
    from {{ source('raw','amenities_changelog') }}
),

renamed as (
    select
        listing_id::integer as listing_id,
        -- maintaining timestamp to protect intra-day ordering
        change_at::timestamp as changed_at,
        amenities::text as amenities
    from
        source
    where
        /*
            rows with null listing_ids cannot join to listings and are excluded here;
            see stg_raw__listings.sql
        */
        listing_id is not null
        /*
            rows whose listing_id has no matching listing are also excluded;
            an orphaned listing_id is unresolvable downstream just as a null one is
        */
        and listing_id::integer in (
            select listing_id from {{ ref('stg_raw__listings') }}
        )
)

select *
from renamed