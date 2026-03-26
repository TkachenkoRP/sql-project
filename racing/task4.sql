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
       ROUND(cs.avg_position, 4) AS average_position,
       cs.race_count,
       cs.country                AS car_country
FROM CarStats cs
         INNER JOIN ClassStats cls ON cs.class = cls.class
WHERE cs.avg_position < cls.class_avg_position
ORDER BY cs.class, cs.avg_position;