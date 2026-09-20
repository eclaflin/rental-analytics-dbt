with calendar as (
    select *
    from {{ ref("int_calendar__deduped") }}
),

amenities as (
    select *
    from {{ ref("int_amenities__effective_ranges") }}
),

listings as (
    select *
    from {{ ref("stg_raw__listings") }}
),

amenity_state as (
    select
        calendar.listing_id,
        calendar.reservation_id,
        calendar.price,
        calendar.minimum_nights,
        calendar.maximum_nights,
        calendar.listing_date,
        calendar.available,
        amenities.amenities
    from
        calendar
            left join
        amenities on amenities.listing_id = calendar.listing_id
                and (
                    calendar.listing_date >= amenities.effective_from
                    and (
                        amenities.effective_to is null
                        or calendar.listing_date < amenities.effective_to
                    )
                )
),

joined as (
    select
        amenity_state.listing_date,
        -- ids
        amenity_state.listing_id,
        amenity_state.reservation_id,
        listings.host_id,

        -- listing descriptors
        listings.listing_name,
        listings.listing_neighborhood,
        listings.listing_property_type,
        listings.listing_room_type,
        listings.listing_bathrooms_description,

        -- listing numeric attrs
        listings.accommodates,
        listings.bedrooms,
        listings.beds,

        -- listing review stats
        listings.number_of_reviews,
        listings.review_score_rating,
        listings.first_review,

        -- host details
        listings.host_name,
        listings.host_location,
        listings.host_since,
        listings.host_verifications,

        -- state attributes
        amenity_state.minimum_nights,
        amenity_state.maximum_nights,
        amenity_state.available,

        -- resolved attributes
        coalesce(amenity_state.price, listings.price) as price,
        case
            when amenity_state.reservation_id is not null then amenity_state.price
        end as reservation_revenue,
        coalesce(amenity_state.amenities, listings.amenities_snapshot) as amenities_json
    from
        amenity_state
            left join
        listings on listings.listing_id = amenity_state.listing_id
),

final as (
    select
        *,
        (joined.amenities_json::jsonb) @> '["Air conditioning"]'::jsonb as has_air_conditioning,
        (joined.amenities_json::jsonb) @> '["Lockbox"]'::jsonb as has_lockbox,
        (joined.amenities_json::jsonb) @> '["First aid kit"]'::jsonb as has_first_aid_kit
    from
        joined
)

select *
from final