# rental-analytics-dbt

Analytics engineering project (dbt/SQL) modeling rental listing data for revenue, occupancy, and amenity analysis.

## Project Overview

Three source tables (`listings`, `calendar`, `amenities_changelog`) are loaded as raw TEXT into Postgres and modeled through three layers:

- **Staging** — casts all columns to appropriate types, renames for clarity, and filters unresolvable rows (null or orphaned `listing_id`s). One model per source table.
- **Intermediate** — handles structural transformations: deduplicates the calendar at the `listing_id + date` grain (`int_calendar__deduped`) and converts the amenities changelog into SCD2 date ranges for point-in-time joins (`int_amenities__effective_ranges`).
- **Mart** — `listings__daily_activity`: one row per listing per calendar date. Joins the deduped calendar spine to listing attributes and point-in-time amenity state. 

## Development Setup

Requires Docker.

1. Copy `.env.example` to `.env`
2. `docker compose up -d --build`
3. `docker compose exec dbt bash`
4. `dbt debug` to confirm the connection

Postgres runs on `localhost:5432` if you need to connect directly (e.g. via `psql` or a GUI client).

## Running the Project

Inside the dbt container:

```bash
dbt deps       # install packages (dbt_utils)
dbt build      # run all models and tests
```

## Data Loading

Source CSVs are loaded into a `raw` schema automatically on first container start (see `docker/initdb/`), rather than via `dbt seed`.

All raw columns are loaded as `TEXT` with no casting or cleanup at load time. Type casting, null handling, and cleanup are managed in the staging layer.