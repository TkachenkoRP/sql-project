WITH CarStats AS (SELECT c.name,
                         c.class,
                         cl.country,
                         AVG(r.position) AS avg_position,
                         COUNT(r.race)   AS race_count
                  FROM Cars c
                           INNER JOIN Results r ON c.name = r.car
                           INNER JOIN Classes cl ON c.class = cl.class
                  GROUP BY c.name, c.class, cl.country)
SELECT name                   AS car_name,
       class                  AS car_class,
       ROUND(avg_position, 4) AS average_position,
       race_count,
       country                AS car_country
FROM CarStats
ORDER BY avg_position, name
LIMIT 1;