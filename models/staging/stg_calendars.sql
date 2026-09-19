with source as (
    select *
    from {{ source('raw','calendar') }}
),

renamed as (
    select
        -- ids
        listing_id::integer as listing_id,
        nullif(reservation_id, 'NULL')::integer as reservation_id,

        -- numeric
        price::numeric as price,
        minimum_nights::numeric as minimum_nights,
        maximum_nights::numeric as maximum_nights,

        -- dates
        date::date as listing_date,

        -- boolean
        available::boolean as available
        from
            source
)

select *
from renamed