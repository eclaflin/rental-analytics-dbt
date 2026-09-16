# rental-arr-analytics-engineering

Analytics engineering project (dbt/SQL) modeling rental listing data for revenue, occupancy, and amenity analysis.

## Development Setup

Requires Docker.

1. Copy `.env.example` to `.env`
2. `docker compose up -d --build`
3. `docker compose exec dbt bash`
4. `dbt debug` to confirm the connection

Postgres runs on `localhost:5432` if you need to connect directly (e.g. via `psql` or a GUI client).

## Data Loading

Source CSVs are loaded into a `raw` schema automatically on first container start (see `docker/initdb/`), rather than via `dbt seed`. 

All raw columns are loaded as `TEXT` with no casting or cleanup at load time. This is an explicit decision to manage type casting, null handling, and other cleanup steps via dbt in the staging layer