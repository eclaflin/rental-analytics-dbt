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
)

select *
from effective_ranges
