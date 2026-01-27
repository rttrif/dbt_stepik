{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['flight_id', 'flight_no', 'aircraft_code'],
        tags = ['flights'],
        merge_exclude_columns=['scheduled_departure'],
        on_schema_change = 'sync_all_columns'
    )
}}

select
    flight_id,
    flight_no,
    scheduled_departure,
    scheduled_arrival,
    departure_airport,
    arrival_airport,
    status,
    aircraft_code,
    actual_departure,
    actual_arrival
from {{ source('demo_src', 'flights') }}
{% if is_incremental() %}
WHERE 
    scheduled_departure > (SELECT MAX(scheduled_departure) FROM {{ this }}) - interval '100 day'
{% endif %}
