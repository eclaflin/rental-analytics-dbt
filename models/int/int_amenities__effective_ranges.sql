with changelog as (
    select *
    from {{ ref('stg_raw__amenities_changelogs') }}
),

ranked as (
    select
        *,
        -- handle for potential intra-day changes by taking the latest within a single day
        row_number() over (
            partition by listing_id, change_at::date
            order by change_at desc
        ) as rn
    from changelog
),

deduped as (
    select *
    from ranked where rn = 1
),

effective_ranges as (
    select
        listing_id,
        amenities,
        change_at::date as effective_from,
        -- treat amenities as scd2 - establish from - to datee window
        lead(change_at::date) over (
            partition by listing_id
            order by change_at
        ) as effective_to
    from deduped
),

/*
    Making a design decision to parse for specifically relevant amenities here.  This will both
    prevent having to do parsing in the mart layer as well as simplify join structure to this
    scd2 table in the mart layer.  The alternative approach would be to all possible
    values fan the grain of this table out to be one row per listing *and ammenity* for a given
    effective window.  Again, this makes the join structure more complicated downstream in the mart layer.

    Another option could be looping through all possible amenity values to create a wide table
    of boolean values for each possible amenity, but this has production downsides w/r/t schema instability
*/
parsed_amenities as (
    select
        *,
        -- "Lockbox" "First aid kit"
        (amenities::jsonb) @> '["Air conditioning"]'::jsonb as has_air_conditioning,
        (amenities::jsonb) @> '["Lockbox"]'::jsonb as has_lockbox,
        (amenities::jsonb) @> '["First aid kit"]'::jsonb as has_first_aid_kit
    from
        effective_ranges
)

select *
from parsed_amenities

