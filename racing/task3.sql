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
       ROUND(cs.avg_position, 4)   AS average_position,
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