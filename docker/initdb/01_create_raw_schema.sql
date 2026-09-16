/*
Runs automatically on first container init (docker-entrypoint-initdb.d).

Columns here are loaded as TEXT: this is an explicit decision to handle type-casting
and cleanup in the staging layer in dbt
 */

CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE raw.listings (
    id TEXT,
    name TEXT,
    host_id TEXT,
    host_name TEXT,
    host_since TEXT,
    host_location TEXT,
    host_verifications TEXT,
    neighborhood TEXT,
    property_type TEXT,
    room_type TEXT,
    accommodates TEXT,
    bathrooms_text TEXT,
    bedrooms TEXT,
    beds TEXT,
    amenities TEXT,
    price TEXT,
    number_of_reviews TEXT,
    first_review TEXT,
    last_review TEXT,
    review_scores_rating TEXT
);

CREATE TABLE raw.calendar (
    listing_id TEXT,
    date TEXT,
    available TEXT,
    reservation_id TEXT,
    price TEXT,
    minimum_nights TEXT,
    maximum_nights TEXT
);

CREATE TABLE raw.amenities_changelog (
    listing_id TEXT,
    change_at TEXT,
    amenities TEXT
);