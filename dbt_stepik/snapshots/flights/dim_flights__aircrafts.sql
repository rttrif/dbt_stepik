{% snapshot dim_flights__aircrafts %}

{{
   config(
       target_schema='snapshot',
       unique_key= ['aircraft_code', 'model'],

       strategy='check',
       check_cols=['aircraft_code', 'model', 'seats'],
       dbt_valid_to_current = "'9999-12-31'::date"
   )
}}

select
    aircraft_code,
    model,
    range
from {{ ref('stg_flights__aircrafts') }}

{% endsnapshot %}