WITH RECURSIVE EmployeeHierarchy AS (SELECT EmployeeID,
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
                                              INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID)
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
        WHERE t.AssignedTo = eh.EmployeeID)     AS TaskNames
FROM EmployeeHierarchy eh
         LEFT JOIN Departments d ON eh.DepartmentID = d.DepartmentID
         LEFT JOIN Roles r ON eh.RoleID = r.RoleID
ORDER BY eh.Name;