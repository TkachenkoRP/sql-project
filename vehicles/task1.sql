select v.maker, v.model
from vehicle v
         inner join motorcycle m on v.model = m.model
where m.horsepower > 150
  and m.price < 20000
  and m.type = 'Sport'
ORDER BY m.horsepower DESC