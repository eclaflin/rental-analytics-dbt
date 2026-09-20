/*
    Handle for duplicate records in the source table, reference
    listing_id = 1303261
*/

with ranked as (
    select
        *,
        row_number() over (
            partition by listing_id, listing_date
            order by reservation_id nulls last
        ) as rn
    from
        {{ ref('stg_raw__calendars') }}
),

deduped as (
    select *
    from ranked
    where
        rn = 1
)

select
    listing_id,
    reservation_id,
    price,
    minimum_nights,
    maximum_nights,
    listing_date,
    available
from deduped