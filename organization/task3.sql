WITH RECURSIVE
    SubordinatesHierarchy AS (SELECT EmployeeID AS ManagerID,
                                     EmployeeID AS SubordinateID,
                                     1          AS Level
                              FROM Employees

                              UNION ALL

                              SELECT sh.ManagerID,
                                     e.EmployeeID AS SubordinateID,
                                     sh.Level + 1
                              FROM SubordinatesHierarchy sh
                                       INNER JOIN Employees e ON e.ManagerID = sh.SubordinateID),
    TotalSubordinates AS (SELECT ManagerID,
                                 COUNT(DISTINCT SubordinateID) AS TotalSubordinateCount
                          FROM SubordinatesHierarchy
                          WHERE ManagerID != SubordinateID
                          GROUP BY ManagerID),
    ManagersWithSubordinates AS (SELECT DISTINCT e.EmployeeID,
                                                 e.Name,
                                                 e.ManagerID,
                                                 e.DepartmentID,
                                                 e.RoleID
                                 FROM Employees e
                                 WHERE EXISTS (SELECT 1
                                               FROM Employees sub
                                               WHERE sub.ManagerID = e.EmployeeID))
SELECT mws.EmployeeID,
       mws.Name                                  AS EmployeeName,
       mws.ManagerID,
       d.DepartmentName,
       r.RoleName,
       (SELECT STRING_AGG(p.ProjectName, ', ' ORDER BY p.ProjectName)
        FROM Projects p
        WHERE p.DepartmentID = mws.DepartmentID) AS ProjectNames,
       (SELECT STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName)
        FROM Tasks t
        WHERE t.AssignedTo = mws.EmployeeID)     AS TaskNames,
       COALESCE(ts.TotalSubordinateCount, 0)     AS TotalSubordinateCount
FROM ManagersWithSubordinates mws
         LEFT JOIN Departments d ON mws.DepartmentID = d.DepartmentID
         LEFT JOIN Roles r ON mws.RoleID = r.RoleID
         LEFT JOIN TotalSubordinates ts ON mws.EmployeeID = ts.ManagerID
ORDER BY mws.Name;