with source as (
    select *
    from {{ source('raw','amenities_changelog') }}
),

renamed as (
    select
        listing_id::integer as listing_id,
        change_at::date as change_at,
        amenities::text as amenities
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