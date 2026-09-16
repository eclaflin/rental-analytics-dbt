-- Loads CSVs mounted at /data (see docker-compose.yml: ./data:/data:ro)

COPY raw.listings FROM '/data/listings.csv' WITH (FORMAT csv, HEADER true);

COPY raw.calendar FROM '/data/calendar.csv' WITH (FORMAT csv, HEADER true);

COPY raw.amenities_changelog FROM '/data/amenities_changelog.csv' WITH (FORMAT csv, HEADER true);