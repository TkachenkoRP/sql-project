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