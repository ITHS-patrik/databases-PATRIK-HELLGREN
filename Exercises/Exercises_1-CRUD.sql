-- ÖVNINGSUPPGIFTER 1 - CRUD

USE everyloop;

-- Uppgift A
/*
SELECT 
    Title, 
    'S' + FORMAT(Season, '00') + 'E' + FORMAT(EpisodeInSeason, '00') AS 'Episode'
FROM GameOfThrones;
*/

-- Uppgift B
/*
--SELECT * INTO users2 FROM users;
UPDATE users2 SET UserName = LOWER(SUBSTRING(FirstName, 1, 2) + SUBSTRING(LastName, 1, 2));

SELECT TOP 5 * FROM users2;
*/

-- Uppgift C
/*
--SELECT * INTO Airports2 FROM Airports;

UPDATE Airports2 
SET Time = ISNULL(Time, '-'),
    DST = ISNULL(DST, '-');

SELECT * FROM Airports2 WHERE Time = '-' OR DST = '-';
*/

-- Uppgift D
/*
--SELECT * INTO Elements2 FROM Elements;
DELETE FROM Elements2 WHERE Name IN ('Erbium', 'Helium', 'Nitrogen', 'Platinum', 'Selenium') OR Name LIKE '[dkmou]%';
SELECT TOP 20 * FROM Elements2;
*/

-- Uppgift E
/*
--SELECT Symbol, Name INTO Elements3 FROM Elements;

ALTER TABLE Elements3
    ADD LeadingShort VARCHAR(3);

UPDATE Elements3 
SET LeadingShort = 
    CASE
        WHEN LEFT(Name, 2) = Symbol THEN 'Yes'
        ELSE 'No'
    END;

SELECT TOP 10 * FROM Elements3
*/

-- Uppgift F
/*
--SELECT Name, Red, Green, Blue INTO Colors2 FROM Colors;

SELECT 
    *,
    '#' +
    RIGHT('0' + CONVERT(VARCHAR(2), CONVERT(VARBINARY(1), Red), 2), 2) +
    RIGHT('0' + CONVERT(VARCHAR(2), CONVERT(VARBINARY(1), Green), 2), 2) +
    RIGHT('0' + CONVERT(VARCHAR(2), CONVERT(VARBINARY(1), Blue), 2), 2)
    AS Code
FROM Colors2;
*/

-- Uppgift G
/*
SELECT TOP 5 * FROM Types;

--SELECT Integer, String INTO Types2 FROM Types;

SELECT Integer, String,
    CAST(Integer / 100.0 AS DECIMAL(3, 2)) AS Float,
    
    '2019-01-' + RIGHT('0' + CAST(Integer AS VARCHAR(2)), 2) + ' 09:' + RIGHT('0' + CAST(Integer AS VARCHAR(2)), 2) + ':00.0000000' AS DateTime,

    CASE
        WHEN Integer % 2 = 1 THEN 1
        ELSE 0
    END AS Bool

FROM Types2;
*/