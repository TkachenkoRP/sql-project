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
       ROUND(avg_stay_duration, 2) AS avg_stay_duration_days
FROM customer_stats
WHERE total_bookings > 2
  AND unique_hotels > 1
ORDER BY total_bookings DESC;