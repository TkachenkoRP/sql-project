WITH RECURSIVE
    EmployeeHierarchy AS (SELECT EmployeeID,
                                 Name,
                                 ManagerID,
                                 DepartmentID,
                                 RoleID
                          FROM Employees
                          WHERE EmployeeID = 1

                          UNION ALL

                          SELECT e.EmployeeID,
                                 e.Name,
                                 e.ManagerID,
                                 e.DepartmentID,
                                 e.RoleID
                          FROM Employees e
                                   INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID),
    DirectSubordinates AS (SELECT ManagerID,
                                  COUNT(*) AS SubordinateCount
                           FROM Employees
                           WHERE ManagerID IS NOT NULL
                           GROUP BY ManagerID)
SELECT eh.EmployeeID,
       eh.Name                                  AS EmployeeName,
       eh.ManagerID,
       d.DepartmentName,
       r.RoleName,
       (SELECT STRING_AGG(p.ProjectName, ', ' ORDER BY p.ProjectName)
        FROM Projects p
        WHERE p.DepartmentID = eh.DepartmentID) AS ProjectNames,
       (SELECT STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName)
        FROM Tasks t
        WHERE t.AssignedTo = eh.EmployeeID)     AS TaskNames,
       (SELECT COUNT(*)
        FROM Tasks t
        WHERE t.AssignedTo = eh.EmployeeID)     AS TotalTasks,
       COALESCE(ds.SubordinateCount, 0)         AS TotalSubordinates
FROM EmployeeHierarchy eh
         LEFT JOIN Departments d ON eh.DepartmentID = d.DepartmentID
         LEFT JOIN Roles r ON eh.RoleID = r.RoleID
         LEFT JOIN DirectSubordinates ds ON eh.EmployeeID = ds.ManagerID
ORDER BY eh.Name;