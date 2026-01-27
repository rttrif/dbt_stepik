{{
  config(
    materialized = 'ephemeral',
    )
}}

select
    passenger_id,
    passenger_name
from {{ ref('passenger_employee') }}