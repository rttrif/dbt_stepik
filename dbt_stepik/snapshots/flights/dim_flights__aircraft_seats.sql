{% snapshot dim_flights__aircraft_seats %}

{{
   config(
       target_schema='snapshot',
       unique_key = ['seat_no', 'fare_conditions'],

       strategy='check',
       check_cols=['seat_no', 'fare_conditions'],
   )
}}

select
    seat_no,
    fare_conditions
from {{ ref('stg_flights__seats') }}

{% endsnapshot %}