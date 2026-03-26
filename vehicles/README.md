# База данных: Транспортные средства

## Структура базы данных

### Таблицы:
- **Vehicle** - основные характеристики транспортных средств
  - `maker` - производитель
  - `model` - модель (PRIMARY KEY)
  - `type` - тип ('Car', 'Motorcycle', 'Bicycle')

- **Car** - автомобили
  - `vin` - идентификационный номер (PRIMARY KEY)
  - `model` - модель (FOREIGN KEY → Vehicle.model)
  - `engine_capacity` - объем двигателя (литры)
  - `horsepower` - мощность (л.с.)
  - `price` - цена (доллары)
  - `transmission` - тип трансмиссии ('Automatic', 'Manual')

- **Motorcycle** - мотоциклы
  - `vin` - идентификационный номер (PRIMARY KEY)
  - `model` - модель (FOREIGN KEY → Vehicle.model)
  - `engine_capacity` - объем двигателя (литры)
  - `horsepower` - мощность (л.с.)
  - `price` - цена (доллары)
  - `type` - тип мотоцикла ('Sport', 'Cruiser', 'Touring')

- **Bicycle** - велосипеды
  - `serial_number` - серийный номер (PRIMARY KEY)
  - `model` - модель (FOREIGN KEY → Vehicle.model)
  - `gear_count` - количество передач
  - `price` - цена (доллары)
  - `type` - тип велосипеда ('Mountain', 'Road', 'Hybrid')

### Связи:
- Car, Motorcycle, Bicycle связаны с Vehicle через поле `model`

---

## Задача 1

**Условие:**
Найдите производителей (maker) и модели всех мотоциклов, которые имеют мощность более 150 лошадиных сил, стоят менее 20 тысяч долларов и являются спортивными (тип Sport). Также отсортируйте результаты по мощности в порядке убывания.

**Решение:**

[task1.sql](task1.sql)

```sql
select v.maker, v.model
from vehicle v
         inner join motorcycle m on v.model = m.model
where m.horsepower > 150
  and m.price < 20000
  and m.type = 'Sport'
ORDER BY m.horsepower DESC
```

**Пояснение:**
- Используем `INNER JOIN` для объединения таблиц Vehicle и Motorcycle по модели
- Фильтруем мотоциклы по трем условиям: мощность > 150, цена < 20000, тип 'Sport'
- Сортируем результаты по мощности в порядке убывания (DESC)

---

## Задача 2

**Условие:**
Найти информацию о производителях и моделях различных типов транспортных средств (автомобили, мотоциклы и велосипеды), которые соответствуют заданным критериям.

**Автомобили:**
- Мощность двигателя более 150 лошадиных сил
- Объем двигателя менее 3 литров
- Цена менее 35 тысяч долларов

В выводе: производитель (maker), модель (model), мощность (horsepower), объем двигателя (engine_capacity) и тип транспортного средства 'Car'

**Мотоциклы:**
- Мощность двигателя более 150 лошадиных сил
- Объем двигателя менее 1,5 литров
- Цена менее 20 тысяч долларов

В выводе: производитель (maker), модель (model), мощность (horsepower), объем двигателя (engine_capacity) и тип транспортного средства 'Motorcycle'

**Велосипеды:**
- Количество передач больше 18
- Цена менее 4 тысяч долларов

В выводе: производитель (maker), модель (model), NULL для мощности, NULL для объема двигателя и тип транспортного средства 'Bicycle'

**Сортировка:** результаты должны быть объединены в один набор данных и отсортированы по мощности в порядке убывания. Для велосипедов (NULL значения) они будут располагаться внизу списка.

**Решение:**

[task2.sql](task2.sql)

```sql
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
```

**Пояснение:**
- Используем `UNION ALL` для объединения результатов трех запросов
- Для автомобилей и мотоциклов извлекаем все поля из соответствующих таблиц
- Для велосипедов явно указываем NULL для horsepower и engine_capacity
- В сортировке используем `NULLS LAST`, чтобы велосипеды были в конце списка

---

## Примечания:
- Все запросы используют `INNER JOIN`, так как нам нужны только те записи, которые есть в обеих таблицах
- В Задаче 2 используется `UNION ALL`, а не `UNION`, так как дубликатов быть не может (разные типы ТС)
- `NULLS LAST` в сортировке гарантирует, что велосипеды (без мощности) будут в конце
- Для велосипедов явно указаны NULL, чтобы структура результата была одинаковой для всех записей