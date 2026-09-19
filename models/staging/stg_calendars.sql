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
        where
            /*
                rows with null listing_ids cannot join to listings and are excluded here;
                see stg_raw__listings.sql
            */
            listing_id is not null
)

select *
from renamed