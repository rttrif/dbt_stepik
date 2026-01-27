{{
  config(
    materialized = 'table',
    )
}}

select 
    ticket_no,
    book_ref,
    passenger_id,
    passenger_name,
    contact_data
from {{ ref('stg_flights__tickets') }}
where passenger_id not in (select distinct passenger_id from {{ ref('stg_dict__passenger_employee') }})