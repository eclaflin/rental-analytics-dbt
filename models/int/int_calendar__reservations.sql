/*
    Handle for duplicate records in the source table, reference
    listing_id = 1303261
*/

with ranked as (
    select
        *,
        row_number() over (
            partition by listing_id, listing_date
            order by listing_date  -- arbitrary but deterministic tiebreaker
        ) as rn
    from
        {{ ref('stg_raw__calendars') }}
),

deduped as (
    select *
    from ranked
    where
        rn = 1
),

-- anchors on reservation as the revenue generating event
reservations as (
    select
        listing_id,
        reservation_id,
        min(listing_date) as checkin_date,
        max(listing_date) as checkout_date,
        count(listing_date) as num_nights,
        sum(price) as total_revenue
    from
        deduped
    where
        reservation_id is not null
    group by
        listing_id,
        reservation_id
)

select *
from reservations