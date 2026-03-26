# База данных: Структура организации

## Структура базы данных

### Таблицы:
- **Departments** - отделы
  - `DepartmentID` - идентификатор отдела (SERIAL PRIMARY KEY)
  - `DepartmentName` - название отдела

- **Roles** - роли
  - `RoleID` - идентификатор роли (SERIAL PRIMARY KEY)
  - `RoleName` - название роли

- **Employees** - сотрудники
  - `EmployeeID` - идентификатор сотрудника (SERIAL PRIMARY KEY)
  - `Name` - имя сотрудника
  - `Position` - должность
  - `ManagerID` - идентификатор менеджера (FOREIGN KEY → Employees.EmployeeID, ON DELETE SET NULL)
  - `DepartmentID` - идентификатор отдела (FOREIGN KEY → Departments.DepartmentID, ON DELETE CASCADE)
  - `RoleID` - идентификатор роли (FOREIGN KEY → Roles.RoleID, ON DELETE SET NULL)

- **Projects** - проекты
  - `ProjectID` - идентификатор проекта (SERIAL PRIMARY KEY)
  - `ProjectName` - название проекта
  - `StartDate` - дата начала
  - `EndDate` - дата окончания
  - `DepartmentID` - идентификатор отдела (FOREIGN KEY → Departments.DepartmentID, ON DELETE CASCADE)

- **Tasks** - задачи
  - `TaskID` - идентификатор задачи (SERIAL PRIMARY KEY)
  - `TaskName` - название задачи
  - `AssignedTo` - кому назначена (FOREIGN KEY → Employees.EmployeeID, ON DELETE SET NULL)
  - `ProjectID` - идентификатор проекта (FOREIGN KEY → Projects.ProjectID, ON DELETE CASCADE)

### Связи:
- Employees имеет самореференцию через `ManagerID`
- Employees связан с Departments и Roles
- Projects связан с Departments
- Tasks связан с Employees и Projects

---

## Задача 1

**Условие:**
Найти всех сотрудников, подчиняющихся Ивану Иванову (с EmployeeID = 1), включая их подчиненных и подчиненных подчиненных, а также самого Ивана Иванова. Для каждого сотрудника вывести следующую информацию:

- `EmployeeID`: идентификатор сотрудника
- Имя сотрудника
- `ManagerID`: идентификатор менеджера
- Название отдела, к которому он принадлежит
- Название роли, которую он занимает
- Название проектов, к которым он относится (если есть, конкатенированные через запятую)
- Название задач, назначенных этому сотруднику (если есть, конкатенированные через запятую)
- Если у сотрудника нет назначенных проектов или задач, отобразить NULL

**Требования:**
- Рекурсивно извлечь всех подчиненных
- Использовать ключевое слово `RECURSIVE`
- Результаты отсортировать по имени сотрудника

**Решение:**

[task1.sql](task1.sql)

```sql
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
```

**Пояснение:**
- CTE `EmployeeHierarchy` рекурсивно находит всех подчиненных Ивана Иванова
- Базовый запрос: сотрудник с EmployeeID = 1
- Рекурсивная часть: сотрудники, у которых ManagerID равен EmployeeID из предыдущего уровня
- Подзапросы для проектов и задач используют `STRING_AGG` для конкатенации
- `LEFT JOIN` для отделов и ролей

---

## Задача 2

**Условие:**
Найти всех сотрудников, подчиняющихся Ивану Иванову (EmployeeID = 1), включая их подчиненных и подчиненных подчиненных, а также самого Ивана Иванова. Для каждого сотрудника вывести:

- `EmployeeID`
- Имя сотрудника
- `ManagerID`
- Название отдела
- Название роли
- Название проектов (конкатенированные)
- Название задач (конкатенированные)
- Общее количество задач, назначенных этому сотруднику
- Общее количество подчиненных у каждого сотрудника (не включая подчиненных их подчиненных)
- Если нет проектов или задач — отобразить NULL

**Требования:**
- Использовать `RECURSIVE`
- Количество подчиненных — только прямые подчиненные

**Решение:**

[task2.sql](task2.sql)

```sql
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
```

**Пояснение:**
- CTE `EmployeeHierarchy` - рекурсивная иерархия подчиненных Ивана Иванова
- CTE `DirectSubordinates` - подсчет прямых подчиненных для каждого менеджера
- Для подсчета задач используем `COUNT(*)` с фильтром по `AssignedTo`
- `COALESCE` для преобразования NULL в 0 для количества подчиненных

---

## Задача 3

**Условие:**
Найти всех сотрудников, которые занимают роль менеджера и имеют подчиненных (число подчиненных > 0). Для каждого такого сотрудника вывести:

- `EmployeeID`
- Имя сотрудника
- `ManagerID`
- Название отдела
- Название роли
- Название проектов (конкатенированные)
- Название задач (конкатенированные)
- Общее количество подчиненных у каждого сотрудника (включая их подчиненных)
- Если нет проектов или задач — отобразить NULL

**Требования:**
- Использовать `RECURSIVE` для подсчета всех подчиненных (включая подчиненных подчиненных)
- Роль менеджера — RoleID = 1

**Решение:**

[task3.sql](task3.sql)

```sql
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
```

**Пояснение:**
- CTE `SubordinatesHierarchy` - рекурсивно находит всех подчиненных для каждого менеджера
- CTE `TotalSubordinates` - подсчет общего количества подчиненных (исключая самого себя)
- CTE `ManagersWithSubordinates` - фильтрация сотрудников с ролью менеджера и наличием подчиненных
- Финальный запрос объединяет все данные с `LEFT JOIN` для отделов, ролей, проектов и задач

---

## Примечания:
- Во всех запросах используются рекурсивные CTE для работы с иерархическими данными
- Для конкатенации строк используется `STRING_AGG` с сортировкой
- `LEFT JOIN` обеспечивает включение сотрудников даже при отсутствии проектов или задач
- Для подсчета всех подчиненных (включая подчиненных подчиненных) используется рекурсивный обход
- Роль менеджера определяется по `RoleID = 1` (Менеджер)