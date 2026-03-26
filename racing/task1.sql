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
SELECT cs.name                   AS car_name,
       cs.class                  AS car_class,
       ROUND(cs.avg_position, 4) AS average_position,
       cs.race_count
FROM CarStats cs
         INNER JOIN ClassMinAvg cma
                    ON cs.class = cma.class
                        AND cs.avg_position = cma.min_avg_position
ORDER BY cs.avg_position;