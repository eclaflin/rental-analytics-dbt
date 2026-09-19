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
)

select *
from renamed