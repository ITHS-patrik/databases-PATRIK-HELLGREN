USE everyloop;

-- MoonMissions
SELECT
    Spacecraft, [Launch date], [Carrier rocket], Operator, [Mission type]
INTO SuccessfulMissions
FROM MoonMissions
WHERE Outcome = 'Successful';

GO

UPDATE SuccessfulMissions
SET Operator = LTRIM(Operator);

GO

UPDATE SuccessfulMissions
SET Spacecraft = 
    CASE
        WHEN CHARINDEX('(', Spacecraft) > 0
            THEN RTRIM(LEFT(Spacecraft, CHARINDEX('(', Spacecraft) - 1))
        ELSE Spacecraft
    END;

GO

SELECT
    Operator, 
    [Mission type],
    COUNT(*) AS [Mission count]
FROM SuccessfulMissions
GROUP BY 
    Operator, 
    [Mission type]
HAVING COUNT(*) > 1
ORDER BY 
    Operator, 
    [Mission type];

GO

-- Users
SELECT
    ID,
    UserName,
    Password,
    FirstName,
    LastName,
    Firstname + ' ' + LastName AS Name,
    CASE
        WHEN SUBSTRING(ID, 10, 1) % 2 = 0 
            THEN 'Female'
        ELSE 'Male'
    END AS Gender,
    Email,
    Phone
INTO NewUsers
FROM Users;

GO

SELECT
    UserName,
    COUNT(*) AS NumberOfDuplicates
FROM NewUsers
GROUP BY UserName
HAVING COUNT(*) > 1;

GO

ALTER TABLE NewUsers
ALTER COLUMN UserName NVARCHAR(8);

WITH NumberedUserNames AS (
    SELECT
        UserName,
        ROW_NUMBER() OVER (PARTITION BY UserName ORDER BY UserName) AS RowNumber
    FROM NewUsers
)
UPDATE NumberedUserNames
SET UserName =
    CASE
        WHEN RowNumber = 1 
            THEN UserName
        ELSE UserName + CAST(RowNumber AS NVARCHAR(2))
    END;

GO

DELETE FROM NewUsers
WHERE LEFT(ID, 2) < '70' AND Gender = 'Female';

GO

/*
Rad nedan från Copilot efter prompt: "Hur genererar jag ett användarlösenord i format '2194506fc6ef7a2048f03a0f4ee7c641' till en ny användare?"
LOWER(CONVERT(NVARCHAR(32), HASHBYTES('MD5', 'mittsuperhemligalösenord'), 2))
*/
INSERT INTO NewUsers (ID, UserName, Password, FirstName, LastName, Name, Gender, Email, Phone)
VALUES (
    '880813-1234', 
    'pathel', 
    LOWER(CONVERT(NVARCHAR(32), HASHBYTES('MD5', 'mittsuperhemligalösenord'), 2)), 
    'Patrik', 
    'Hellgren', 
    'Patrik Hellgren', 
    'Male', 
    'patrik.hellgren@iths.se', 
    '0734-567890');

GO

SELECT
    Gender, 
    ROUND(AVG(
        DATEDIFF(YEAR, CONVERT(date, '19' + LEFT(ID, 6)), GETDATE())
            - CASE 
                WHEN FORMAT(GETDATE(), 'MMdd') < FORMAT(CONVERT(date, '19' + LEFT(ID, 6)), 'MMdd') 
                    THEN 1 
                ELSE 0
            END
        ), 0) AS AverageAge
FROM NewUsers
GROUP BY Gender;

GO

-- Company (joins)
SELECT
    pro.Id,
    ProductName AS Product,
    sup.CompanyName as Supplier,
    cat.CategoryName AS Category
FROM company.products pro
JOIN company.suppliers as sup
    ON sup.Id = SupplierId
JOIN company.categories as cat
    ON cat.Id = CategoryId;

GO

SELECT
    RegionDescription,
    COUNT(DISTINCT e.Id) AS NumberOfEmployees
FROM company.regions r
JOIN company.territories t
    ON r.Id = t.RegionId
JOIN company.employee_territory et
    ON t.Id = et.TerritoryId
JOIN company.employees e
    ON et.EmployeeId = e.Id
GROUP BY RegionDescription;

GO

SELECT
    e.Id,
    e.TitleOfCourtesy + ' ' + e.FirstName + ' ' + e.LastName AS Name,
    CASE
        WHEN e.ReportsTo IS NOT NULL 
            THEN m.TitleOfCourtesy + ' ' + m.FirstName + ' ' + m.LastName
        ELSE 'Nobody!'
    END AS ReportsTo
FROM company.employees e
LEFT JOIN company.employees m
    ON e.ReportsTo = m.Id;
