with source as (
    select *
    from {{ source('raw','listings')}}
),

renamed as (
    select
        -- ids
        id::integer as listing_id,
        host_id::integer as host_id,

        -- numerics
        accommodates::integer as accommodates,
        bedrooms::integer as bedrooms,
        beds::integer as bed,
        number_of_reviews::integer as number_of_reviews,
        review_scores_rating::numeric as review_score_rating,
        -- future-proofing price field against thousands separator
        replace(replace(price, '$', ''), ',', '')::numeric as price,

        -- dates
        /*
            Though it appears to be a timestamp dt in upstream data, fact that
            time values are all zeroes implies this is semantically a date value,
            choosing to cast as a date as a more pragmatic approach acknowledging the
            potential for quiet loss if/as time values begin populating upstream
        */
        host_since::date as host_since,
        first_review::date as first_review,
        last_review::date as last_review,

        -- text
        name::text as listing_name,
        neighborhood::text as listing_neighborhood,
        property_type::text as listing_property_type,
        room_type::text as listing_room_type,
        bathrooms_text::text as listing_bathrooms_description,
        host_name::text as host_name,
        host_location::text as host_location,


        -- json arrays
        -- understood to be a point in time snapshot
        amenities::text as amenities_snapshot,
        host_verifications::text as host_verifications
    from
        source
)

select *
from renamed