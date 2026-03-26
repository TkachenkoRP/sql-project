# База данных: Бронирование отелей

## Структура базы данных

### Таблицы:
- **Hotel** - отели
  - `ID_hotel` - идентификатор отеля (SERIAL PRIMARY KEY)
  - `name` - название отеля
  - `location` - расположение отеля

- **Room** - номера
  - `ID_room` - идентификатор номера (SERIAL PRIMARY KEY)
  - `ID_hotel` - идентификатор отеля (FOREIGN KEY → Hotel.ID_hotel)
  - `room_type` - тип номера ('Single', 'Double', 'Suite')
  - `price` - цена за ночь
  - `capacity` - вместимость

- **Customer** - клиенты
  - `ID_customer` - идентификатор клиента (SERIAL PRIMARY KEY)
  - `name` - имя клиента
  - `email` - email (UNIQUE)
  - `phone` - телефон

- **Booking** - бронирования
  - `ID_booking` - идентификатор бронирования (SERIAL PRIMARY KEY)
  - `ID_room` - идентификатор номера (FOREIGN KEY → Room.ID_room)
  - `ID_customer` - идентификатор клиента (FOREIGN KEY → Customer.ID_customer)
  - `check_in_date` - дата заезда
  - `check_out_date` - дата выезда

### Связи:
- Room связан с Hotel через `ID_hotel`
- Booking связан с Room через `ID_room` и с Customer через `ID_customer`

---

## Задача 1

**Условие:**
Определить, какие клиенты сделали более двух бронирований в разных отелях, и вывести информацию о каждом таком клиенте, включая его имя, электронную почту, телефон, общее количество бронирований, а также список отелей, в которых они бронировали номера (объединенные в одно поле через запятую). Также подсчитать среднюю длительность их пребывания (в днях) по всем бронированиям. Отсортировать результаты по количеству бронирований в порядке убывания.

**Решение:**

[task1.sql](task1.sql)

```sql
WITH customer_bookings AS (SELECT c.ID_customer,
                                  c.name,
                                  c.email,
                                  c.phone,
                                  b.ID_booking,
                                  r.ID_hotel,
                                  h.name                               AS hotel_name,
                                  (b.check_out_date - b.check_in_date) AS stay_duration
                           FROM Customer c
                                    JOIN Booking b ON c.ID_customer = b.ID_customer
                                    JOIN Room r ON b.ID_room = r.ID_room
                                    JOIN Hotel h ON r.ID_hotel = h.ID_hotel),
     customer_stats AS (SELECT ID_customer,
                               name,
                               email,
                               phone,
                               COUNT(ID_booking)                                         AS total_bookings,
                               COUNT(DISTINCT ID_hotel)                                  AS unique_hotels,
                               STRING_AGG(DISTINCT hotel_name, ', ' ORDER BY hotel_name) AS hotels_list,
                               AVG(stay_duration)                                        AS avg_stay_duration
                        FROM customer_bookings
                        GROUP BY ID_customer, name, email, phone)
SELECT name,
       email,
       phone,
       total_bookings,
       hotels_list,
       avg_stay_duration AS avg_stay_duration_days
FROM customer_stats
WHERE total_bookings > 2
  AND unique_hotels > 1
ORDER BY total_bookings DESC;
```

**Пояснение:**
- CTE `customer_bookings` собирает данные о бронированиях с информацией об отелях и длительности пребывания
- CTE `customer_stats` агрегирует данные: общее количество бронирований, количество уникальных отелей, список отелей и среднюю длительность
- Фильтруем клиентов с >2 бронированиями и >1 уникальным отелем
- Сортируем по количеству бронирований в порядке убывания

---

## Задача 2

**Условие:**
Необходимо провести анализ клиентов, которые сделали более двух бронирований в разных отелях и потратили более 500 долларов на свои бронирования.

Шаги:
1. Определить клиентов, которые сделали более двух бронирований и забронировали номера в более чем одном отеле. Вывести: ID_customer, имя, общее количество бронирований, общее количество уникальных отелей, общую сумму.
2. Определить клиентов, которые потратили более 500 долларов. Вывести: ID_customer, имя, общую сумму, общее количество бронирований.
3. Объединить данные из первых двух пунктов, чтобы получить клиентов, соответствующих обоим условиям. Вывести: ID_customer, имя, общее количество бронирований, общую сумму, количество уникальных отелей.
4. Отсортировать по общей сумме в порядке возрастания.

**Решение:**

[task2.sql](task2.sql)

```sql
WITH customer_booking_details AS (SELECT c.ID_customer,
                                         c.name,
                                         b.ID_booking,
                                         r.ID_hotel,
                                         r.price,
                                         (b.check_out_date - b.check_in_date)           AS stay_duration,
                                         r.price * (b.check_out_date - b.check_in_date) AS total_cost
                                  FROM Customer c
                                           JOIN Booking b ON c.ID_customer = b.ID_customer
                                           JOIN Room r ON b.ID_room = r.ID_room),
     customer_aggregates AS (SELECT ID_customer,
                                    name,
                                    COUNT(ID_booking)        AS total_bookings,
                                    COUNT(DISTINCT ID_hotel) AS unique_hotels,
                                    SUM(total_cost)          AS total_spent
                             FROM customer_booking_details
                             GROUP BY ID_customer, name),
     condition1 AS (SELECT ID_customer,
                           name,
                           total_bookings,
                           unique_hotels,
                           total_spent
                    FROM customer_aggregates
                    WHERE total_bookings > 2
                      AND unique_hotels > 1),
     condition2 AS (SELECT ID_customer,
                           name,
                           total_bookings,
                           total_spent
                    FROM customer_aggregates
                    WHERE total_spent > 500)
SELECT c1.ID_customer,
       c1.name,
       c1.total_bookings,
       c1.total_spent,
       c1.unique_hotels
FROM condition1 c1
         INNER JOIN condition2 c2 ON c1.ID_customer = c2.ID_customer
ORDER BY c1.total_spent;
```

**Пояснение:**
- CTE `customer_booking_details` рассчитывает стоимость каждого бронирования (цена × количество дней)
- CTE `customer_aggregates` агрегирует данные по клиентам
- CTE `condition1` - клиенты с >2 бронированиями и >1 отелем
- CTE `condition2` - клиенты с тратами >500
- Финальный запрос объединяет оба условия через INNER JOIN
- Сортируем по общей сумме трат

---

## Задача 3

**Условие:**
Провести анализ данных о бронированиях в отелях и определить предпочтения клиентов по типу отелей.

Шаги:
1. **Категоризация отелей:**
   - «Дешевый»: средняя стоимость номера менее 175 долларов
   - «Средний»: средняя стоимость от 175 до 300 долларов
   - «Дорогой»: средняя стоимость более 300 долларов

2. **Анализ предпочтений клиентов:**
   - Если у клиента есть хотя бы один «дорогой» отель → категория «дорогой»
   - Если нет «дорогих», но есть «средний» → категория «средний»
   - Если нет «дорогих» и «средних», но есть «дешевые» → категория «дешевый»

3. **Вывод информации:**
   - ID_customer, name, preferred_hotel_type, visited_hotels (список уникальных отелей)

4. **Сортировка:** сначала «дешевые», затем «средние», затем «дорогие»

**Решение:**

[task3.sql](task3.sql)

```sql
WITH hotel_categories AS (SELECT h.ID_hotel,
                                 h.name       AS hotel_name,
                                 AVG(r.price) AS avg_price,
                                 CASE
                                     WHEN AVG(r.price) < 175 THEN 'Дешевый'
                                     WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
                                     ELSE 'Дорогой'
                                     END      AS hotel_category
                          FROM Hotel h
                                   JOIN Room r ON h.ID_hotel = r.ID_hotel
                          GROUP BY h.ID_hotel, h.name),
     customer_hotels AS (SELECT DISTINCT c.ID_customer,
                                         c.name,
                                         hc.ID_hotel,
                                         hc.hotel_name,
                                         hc.hotel_category
                         FROM Customer c
                                  JOIN Booking b ON c.ID_customer = b.ID_customer
                                  JOIN Room r ON b.ID_room = r.ID_room
                                  JOIN hotel_categories hc ON r.ID_hotel = hc.ID_hotel),
     customer_preferences AS (SELECT ID_customer,
                                     name,
                                     STRING_AGG(DISTINCT hotel_name, ', ' ORDER BY hotel_name) AS visited_hotels,
                                     CASE
                                         WHEN COUNT(CASE WHEN hotel_category = 'Дорогой' THEN 1 END) > 0 THEN 'Дорогой'
                                         WHEN COUNT(CASE WHEN hotel_category = 'Средний' THEN 1 END) > 0 THEN 'Средний'
                                         WHEN COUNT(CASE WHEN hotel_category = 'Дешевый' THEN 1 END) > 0 THEN 'Дешевый'
                                         END                                                   AS preferred_hotel_type
                              FROM customer_hotels
                              GROUP BY ID_customer, name)
SELECT ID_customer,
       name,
       preferred_hotel_type,
       visited_hotels
FROM customer_preferences
ORDER BY CASE preferred_hotel_type
             WHEN 'Дешевый' THEN 1
             WHEN 'Средний' THEN 2
             WHEN 'Дорогой' THEN 3
             ELSE 4
             END;
```

**Пояснение:**
- CTE `hotel_categories` рассчитывает среднюю цену каждого отеля и присваивает категорию
- CTE `customer_hotels` собирает уникальные пары клиент-отель с категорией отеля
- CTE `customer_preferences` для каждого клиента:
  - формирует список посещенных отелей
  - определяет предпочитаемый тип по приоритету (дорогой > средний > дешевый)
- Финальная сортировка через CASE для порядка категорий

---

## Примечания:
- Для расчета стоимости бронирования используется `price * (check_out_date - check_in_date)`
- Разница дат в PostgreSQL возвращает количество дней как целое число
- `STRING_AGG` используется для объединения названий отелей в одну строку с разделителем
- Для определения категории отеля используется `CASE` с условиями по средней цене
- Приоритет категорий клиента реализован через вложенные `CASE` с подсчетом `COUNT`
- Сортировка категорий выполнена через `CASE` в `ORDER BY`