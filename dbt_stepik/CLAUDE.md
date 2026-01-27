# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a dbt (data build tool) project for a Stepik course focused on building a data warehouse for flight data. The project transforms flight booking data from PostgreSQL foreign data wrapper sources into staging and intermediate fact tables.

### Data Source Architecture

The project uses PostgreSQL Foreign Data Wrapper (postgres_fdw) to access source data:
- Source database: `demo` (external PostgreSQL database on port 5432)
- Target database: `dwh_flight` (data warehouse on port 4001)
- Source schema: `demo_src` (foreign schema imported from `bookings` schema)
- Target schemas: `intermediate` (default dev schema)

The foreign data wrapper setup is defined in `source_data_preparation.sql` and must be configured before running dbt models.

### Model Layer Architecture

The project follows a two-layer dbt architecture:

1. **Staging Layer** (`models/staging/flights/`):
   - Prefix: `stg_flights__*`
   - Purpose: Direct 1:1 mappings from source tables with minimal transformation
   - Materialization: `table`
   - Source definition: `_flights__sources.yml`
   - Tables: bookings, tickets, ticket_flights, flights, boarding_passes, seats, aircrafts, airports

2. **Intermediate/Fact Layer** (`models/intermediete/flights/`):
   - Prefix: `fct_*`
   - Purpose: Business fact tables built from staging models
   - Materialization: `table`
   - Model definition: `_int_flights__models.yml`
   - Current fact tables: fct_bookings, fct_tickets, fct_ticket_flights

Note: The directory is named `intermediete` (typo in original structure).

## Common dbt Commands

### Development Workflow
```bash
# Run all models
dbt run

# Run specific model
dbt run --select stg_flights__bookings
dbt run --select fct_bookings

# Run models in a specific directory
dbt run --select staging.flights.*
dbt run --select intermediete.flights.*

# Run models with dependencies
dbt run --select +fct_bookings  # includes upstream dependencies
dbt run --select fct_bookings+  # includes downstream dependencies

# Run tests
dbt test

# Run tests for specific model
dbt test --select stg_flights__bookings
dbt test --select fct_bookings

# Check source freshness (configured for bookings and flights tables)
dbt source freshness

# Generate and serve documentation
dbt docs generate
dbt docs serve

# Compile models without running
dbt compile

# Debug connection and configuration
dbt debug

# Clean target and dbt_packages directories
dbt clean
```

### Project Configuration

- **Project name**: `dbt_stepik`
- **Profile name**: `dbt_stepik` (defined in `~/.dbt/profiles.yml`)
- **Target database**: `dwh_flight`
- **Default schema**: `intermediate`
- **Connection**: PostgreSQL on localhost:4001
- **Threads**: 2

## Model Configuration Patterns

### Contracts and Data Types

Fact models use dbt contracts to enforce schema:
- `config: {contract: {enforced: true}}` in model YAML
- Explicit `data_type` specifications for all columns
- Column-level constraints (not_null, check, unique)

Example from `fct_bookings`:
```yaml
columns:
  - name: book_ref
    data_type: bpchar(8)
    constraints:
      - type: not_null
```

### Data Quality Tests

The project uses both built-in and dbt_utils tests:
- Standard tests: `not_null`, `unique`
- dbt_utils tests: `dbt_utils.equal_rowcount` (comparing row counts between models)
- Custom check constraints in model definitions

### Source Freshness Monitoring

Configured for critical tables (bookings, flights) in `_flights__sources.yml`:
- `loaded_at_field`: Timestamp column to check freshness
- `warn_after`: Threshold for warnings (6000000 hours)
- `error_after`: Threshold for errors (1000000 days)
- `filter`: Custom filter expression for freshness checks

### Metadata Configuration

Models include metadata annotations:
- `owner`: Email contact for model ownership
- `contact_tg`: Telegram handle
- `status`: Development status (e.g., `in_dev`)
- Column-level meta (e.g., `owner: finance_team` for `total_amount`)

## Working with this Project

### Adding New Models

1. Staging models go in `models/staging/flights/` with prefix `stg_flights__`
2. Fact models go in `models/intermediete/flights/` with prefix `fct_`
3. Always materialize as `table` (not view) per project standards
4. Update corresponding YAML files with schema definitions and tests

### Database Setup

Before running dbt models, ensure the foreign data wrapper is configured:
1. Create `dwh_flight` database
2. Install `postgres_fdw` extension
3. Run SQL in `source_data_preparation.sql` to set up foreign server and schema

### Version Information

The project includes dbt versioning for models:
- `fct_bookings` has versioning configured (`latest_version: 1`)
- Supports model version evolution through `versions` key in YAML
