-- Подсчёт количества мест по типам самолётов
select
    aircraft_code,
    count(*) as seat_count

from {{ ref('stg_flights__seats') }}

group by aircraft_code
order by aircraft_code
