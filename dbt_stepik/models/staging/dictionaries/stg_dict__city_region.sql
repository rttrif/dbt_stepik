{{
  config(
    materialized = 'table',
    )
}}

select
    city,
    region,
    updated_at    
from {{ ref('city_region') }}