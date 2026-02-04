{{
  config(
    materialized = 'table',
    )
}}

select
    ticket_no,
    flight_id,
    fare_conditions,
    amount
from {{ source('demo_src', 'ticket_flights') }}
{%- if target.name == 'dev'%}
limit 100000
{%- endif %}
-- Пример удаления пробелов в начале и конце строки
-- trim(fare_conditions) as fare_conditions