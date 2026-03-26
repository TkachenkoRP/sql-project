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
SELECT cs.name                   AS car_name,
       cs.class                  AS car_class,
       ROUND(cs.avg_position, 4) AS average_position,
       cs.race_count,
       cs.country                AS car_country,
       crc.total_races,
       clc.low_position_car_count
FROM CarStats cs
         INNER JOIN TargetClasses tc ON cs.class = tc.class
         INNER JOIN ClassRaceCount crc ON cs.class = crc.class
         INNER JOIN ClassLowCount clc ON cs.class = clc.class
ORDER BY clc.low_position_car_count DESC, cs.class, cs.name;