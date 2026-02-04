{% set aircraft_query %}
select distinct
    aircraft_code 
from {{ ref('fct_flights') }}
{% endset %}

{% set aircraft_query_result = run_query(aircraft_query) %}

{% if execute%}
    {% set aircraft_codes = aircraft_query_result.columns[0].values() %}
{% else %}
    {% set aircraft_codes = [] %}
{% endif %}

select 
    {%- for aircraft_code in aircraft_codes %}
        sum(case when aircraft_code = '{{ aircraft_code }}' then 1 else 0 end) as flights_{{ aircraft_code }}
            {%- if not loop.last %},{% endif %}
    {%- endfor %}
from {{ ref('fct_flights') }}