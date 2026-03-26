select v.maker, c.model, c.horsepower, c.engine_capacity, v.type as vehicle_type
from car c
         inner join vehicle v on v.model = c.model
where c.horsepower > 150
  and c.engine_capacity < 3
  and c.price < 35000

union all

select v.maker, m.model, m.horsepower, m.engine_capacity, v.type as vehicle_type
from motorcycle m
         inner join vehicle v on v.model = m.model
where m.horsepower > 150
  and m.engine_capacity < 1.5
  and m.price < 20000

union all

select v.maker, b.model, NULL AS horsepower, NULL AS engine_capacity, v.type as vehicle_type
from bicycle b
         inner join vehicle v on v.model = b.model
where b.gear_count > 18
  and b.price < 4000

ORDER BY horsepower desc nulls last;