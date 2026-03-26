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