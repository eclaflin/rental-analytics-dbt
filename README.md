# rental-arr-analytics-engineering

Analytics engineering project (dbt/SQL) modeling rental listing data for revenue, occupancy, and amenity analysis.

## Development Setup

Requires Docker.

1. Copy `.env.example` to `.env`
2. `docker compose up -d --build`
3. `docker compose exec dbt bash`
4. `dbt debug` to confirm the connection

Postgres runs on `localhost:5432` if you need to connect directly (e.g. via `psql` or a GUI client).