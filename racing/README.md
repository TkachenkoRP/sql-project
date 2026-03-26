# База данных: Автомобильные гонки

## Структура базы данных

### Таблицы:
- **Classes** - классы автомобилей
  - `class` - название класса (PRIMARY KEY)
  - `type` - тип ('Racing', 'Street')
  - `country` - страна производства
  - `numDoors` - количество дверей
  - `engineSize` - размер двигателя (литры)
  - `weight` - вес автомобиля (кг)

- **Cars** - автомобили
  - `name` - название автомобиля (PRIMARY KEY)
  - `class` - класс автомобиля (FOREIGN KEY → Classes.class)
  - `year` - год выпуска

- **Races** - гонки
  - `name` - название гонки (PRIMARY KEY)
  - `date` - дата проведения

- **Results** - результаты гонок
  - `car` - автомобиль (FOREIGN KEY → Cars.name)
  - `race` - гонка (FOREIGN KEY → Races.name)
  - `position` - позиция в гонке

### Связи:
- Cars связан с Classes через поле `class`
- Results связан с Cars через поле `car` и с Races через поле `race`

---

## Задача 1

**Условие:**
Определить, какие автомобили из каждого класса имеют наименьшую среднюю позицию в гонках, и вывести информацию о каждом таком автомобиле для данного класса, включая его класс, среднюю позицию и количество гонок, в которых он участвовал. Также отсортировать результаты по средней позиции.

**Решение:**

[task1.sql](task1.sql)

```sql
WITH CarStats AS (SELECT c.name,
                         c.class,
                         AVG(r.position) AS avg_position,
                         COUNT(r.race)   AS race_count
                  FROM Cars c
                           INNER JOIN Results r ON c.name = r.car
                  GROUP BY c.name, c.class),
     ClassMinAvg AS (SELECT class,
                            MIN(avg_position) AS min_avg_position
                     FROM CarStats
                     GROUP BY class)
SELECT cs.name         AS car_name,
       cs.class        AS car_class,
       cs.avg_position AS average_position,
       cs.race_count
FROM CarStats cs
         INNER JOIN ClassMinAvg cma
                    ON cs.class = cma.class
                        AND cs.avg_position = cma.min_avg_position
ORDER BY cs.avg_position;
```

**Пояснение:**
- Используем CTE `CarStats` для расчета средней позиции и количества гонок для каждого автомобиля
- В CTE `ClassMinAvg` находим минимальную среднюю позицию для каждого класса
- Соединяем результаты, чтобы получить автомобили с минимальной средней позицией в своем классе
- Сортируем по средней позиции

---

## Задача 2

**Условие:**
Определить автомобиль, который имеет наименьшую среднюю позицию в гонках среди всех автомобилей, и вывести информацию об этом автомобиле, включая его класс, среднюю позицию, количество гонок, в которых он участвовал, и страну производства класса автомобиля. Если несколько автомобилей имеют одинаковую наименьшую среднюю позицию, выбрать один из них по алфавиту (по имени автомобиля).

**Решение:**

[task2.sql](task2.sql)

```sql
WITH CarStats AS (SELECT c.name,
                         c.class,
                         cl.country,
                         AVG(r.position) AS avg_position,
                         COUNT(r.race)   AS race_count
                  FROM Cars c
                           INNER JOIN Results r ON c.name = r.car
                           INNER JOIN Classes cl ON c.class = cl.class
                  GROUP BY c.name, c.class, cl.country)
SELECT name         AS car_name,
       class        AS car_class,
       avg_position AS average_position,
       race_count,
       country      AS car_country
FROM CarStats
ORDER BY avg_position, name
LIMIT 1;
```

**Пояснение:**
- В CTE `CarStats` объединяем Cars, Results и Classes для получения полной информации
- Вычисляем среднюю позицию и количество гонок для каждого автомобиля
- Сортируем по средней позиции и имени автомобиля, берем первую запись с `LIMIT 1`

---

## Задача 3

**Условие:**
Определить классы автомобилей, которые имеют наименьшую среднюю позицию в гонках, и вывести информацию о каждом автомобиле из этих классов, включая его имя, среднюю позицию, количество гонок, в которых он участвовал, страну производства класса автомобиля, а также общее количество гонок, в которых участвовали автомобили этих классов. Если несколько классов имеют одинаковую среднюю позицию, выбрать все из них.

**Решение:**

[task3.sql](task3.sql)

```sql
WITH CarStats AS (SELECT c.name,
                         c.class,
                         cl.country,
                         AVG(r.position) AS avg_position,
                         COUNT(r.race)   AS race_count
                  FROM Cars c
                           INNER JOIN Results r ON c.name = r.car
                           INNER JOIN Classes cl ON c.class = cl.class
                  GROUP BY c.name, c.class, cl.country),
     ClassAvg AS (SELECT class,
                         AVG(avg_position) AS class_avg_position
                  FROM CarStats
                  GROUP BY class)
SELECT cs.name                     AS car_name,
       cs.class                    AS car_class,
       cs.avg_position             AS average_position,
       cs.race_count,
       cs.country                  AS car_country,
       (SELECT COUNT(DISTINCT r.race)
        FROM Cars c2
                 INNER JOIN Results r ON c2.name = r.car
        WHERE c2.class = cs.class) AS total_race_count
FROM CarStats cs
WHERE cs.class IN (SELECT class
                   FROM ClassAvg
                   WHERE class_avg_position = (SELECT MIN(class_avg_position) FROM ClassAvg))
ORDER BY cs.class, cs.name;
```

**Пояснение:**
- CTE `CarStats` - статистика по каждому автомобилю
- CTE `ClassAvg` - средняя позиция по каждому классу
- Находим класс(ы) с минимальной средней позицией
- Для каждого автомобиля из этих классов выводим дополнительную информацию
- Используем подзапрос для подсчета общего количества гонок для класса

---

## Задача 4

**Условие:**
Определить, какие автомобили имеют среднюю позицию лучше (меньше) средней позиции всех автомобилей в своем классе (то есть автомобилей в классе должно быть минимум два, чтобы выбрать один из них). Вывести информацию об этих автомобилях, включая их имя, класс, среднюю позицию, количество гонок, в которых они участвовали, и страну производства класса автомобиля. Также отсортировать результаты по классу и затем по средней позиции в порядке возрастания.

**Решение:**

[task4.sql](task4.sql)

```sql
WITH CarStats AS (SELECT c.name,
                         c.class,
                         cl.country,
                         AVG(r.position) AS avg_position,
                         COUNT(r.race)   AS race_count
                  FROM Cars c
                           INNER JOIN Results r ON c.name = r.car
                           INNER JOIN Classes cl ON c.class = cl.class
                  GROUP BY c.name, c.class, cl.country),
     ClassStats AS (SELECT class,
                           AVG(avg_position) AS class_avg_position,
                           COUNT(*)          AS car_count
                    FROM CarStats
                    GROUP BY class
                    HAVING COUNT(*) >= 2)
SELECT cs.name                   AS car_name,
       cs.class                  AS car_class,
       cs.avg_position           AS average_position,
       cs.race_count,
       cs.country                AS car_country
FROM CarStats cs
         INNER JOIN ClassStats cls ON cs.class = cls.class
WHERE cs.avg_position < cls.class_avg_position
ORDER BY cs.class, cs.avg_position;
```

**Пояснение:**
- CTE `CarStats` - статистика по каждому автомобилю
- CTE `ClassStats` - средняя позиция по классу и количество автомобилей в классе (только классы с ≥2 автомобилями)
- Соединяем и фильтруем автомобили, у которых средняя позиция лучше средней по классу
- Сортируем по классу и средней позиции

---

## Задача 5

**Условие:**
Определить, какие классы автомобилей имеют наибольшее количество автомобилей с низкой средней позицией (больше 3.0) и вывести информацию о каждом автомобиле из этих классов, включая его имя, класс, среднюю позицию, количество гонок, в которых он участвовал, страну производства класса автомобиля, а также общее количество гонок для каждого класса. Отсортировать результаты по количеству автомобилей с низкой средней позицией.

**Решение:**

[task5.sql](task5.sql)

```sql
WITH CarStats AS (SELECT c.name,
                         c.class,
                         cl.country,
                         AVG(r.position) AS avg_position,
                         COUNT(r.race)   AS race_count
                  FROM Cars c
                           INNER JOIN Results r ON c.name = r.car
                           INNER JOIN Classes cl ON c.class = cl.class
                  GROUP BY c.name, c.class, cl.country),
     LowPositionCars AS (SELECT name,
                                class,
                                country,
                                avg_position,
                                race_count
                         FROM CarStats
                         WHERE avg_position > 3.0),
     ClassLowCount AS (SELECT class,
                              COUNT(*) AS low_position_car_count
                       FROM LowPositionCars
                       GROUP BY class),
     MaxLowCount AS (SELECT MAX(low_position_car_count) AS max_count
                     FROM ClassLowCount),
     TargetClasses AS (SELECT class
                       FROM ClassLowCount
                       WHERE low_position_car_count = (SELECT max_count FROM MaxLowCount)),
     ClassRaceCount AS (SELECT c.class,
                               COUNT(r.race) AS total_races
                        FROM Cars c
                                 INNER JOIN Results r ON c.name = r.car
                        WHERE c.class IN (SELECT class FROM TargetClasses)
                        GROUP BY c.class)
SELECT cs.name         AS car_name,
       cs.class        AS car_class,
       cs.avg_position AS average_position,
       cs.race_count,
       cs.country      AS car_country,
       crc.total_races,
       clc.low_position_car_count
FROM CarStats cs
         INNER JOIN TargetClasses tc ON cs.class = tc.class
         INNER JOIN ClassRaceCount crc ON cs.class = crc.class
         INNER JOIN ClassLowCount clc ON cs.class = clc.class
ORDER BY clc.low_position_car_count DESC, cs.class, cs.name;
```

**Пояснение:**
- CTE `CarStats` - статистика по каждому автомобилю
- CTE `LowPositionCars` - автомобили со средней позицией > 3.0
- CTE `ClassLowCount` - подсчет таких автомобилей по классам
- CTE `MaxLowCount` - максимальное количество таких автомобилей среди классов
- CTE `TargetClasses` - классы с максимальным количеством
- CTE `ClassRaceCount` - общее количество гонок для целевых классов
- Финальная выборка с сортировкой

---

## Примечания:
- Во всех запросах используются CTE (Common Table Expressions) для улучшения читаемости
- Подзапросы используются для подсчета общего количества гонок
- Сортировка выполняется по различным критериям в зависимости от условий задач