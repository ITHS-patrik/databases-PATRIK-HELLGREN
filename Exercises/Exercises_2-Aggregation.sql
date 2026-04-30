-- ÖVNINGSUPPGIFTER 2 - Aggregation of data

USE everyloop;

-- Uppgift A
/*
SELECT 
    Period,
    MIN(Number) AS [From], 
    MAX(Number) AS [To], 
    CAST(AVG(CAST(Stableisotopes AS DECIMAL(5,2))) AS DECIMAL(5,2)) AS [AverageIsotopes], 
    STRING_AGG(Symbol, ', ') AS [Symbols]
FROM Elements
GROUP BY Period;
*/

-- Uppgift B
/*
SELECT * FROM company.customers;

SELECT 
    Region, 
    Country, 
    City, 
    COUNT(*) AS Customers 
FROM company.customers 
GROUP BY Region, Country, City
HAVING COUNT(*) >= 2;
*/

-- Uppgift C
/*
SELECT TOP 10 * FROM GameOfThrones;

DECLARE @info VARCHAR(MAX) = '';
SELECT @info = @info + 
    'Säsong ' + 
    CAST(Season AS varchar(2)) + 
    ' sändes från ' + 
    FORMAT(
        DATEFROMPARTS(2000, MONTH(MIN([Original air date])), 1), 'MMMM', 'sv-SE') + 
    ' till ' + 
    FORMAT(
        DATEFROMPARTS(2000, MONTH(MAX([Original air date])), 1), 'MMMM', 'sv-SE') + 
    ' ' + 
    CAST(YEAR(MAX([Original air date])) AS VARCHAR(4)) + 
    '. Totalt sändes ' + 
    CAST(COUNT(EpisodeInSeason) AS varchar(2)) + 
    ' avsnitt, som i genomsnitt sågs av ' + 
    CAST(ROUND(AVG([U.S. viewers(millions)]), 1) AS VARCHAR(4)) + 
    ' miljoner människor i USA.' + 
    CHAR(13) + CHAR(10)
FROM GameOfThrones
GROUP BY Season;

PRINT @info;
*/

-- Uppgift D
/*
SELECT
    FirstName + ' ' + LastName AS Namn,

    CAST(DATEDIFF(YEAR, 
        CONVERT(date, '19' + SUBSTRING([ID], 1, 6)), 
        GETDATE())
    - CASE
        WHEN FORMAT(GETDATE(), 'MMdd') < SUBSTRING([ID], 3, 4)
            THEN 1
            ELSE 0
        END
    AS VARCHAR(3)) + ' år' AS Ålder,

    CASE
        WHEN CAST(SUBSTRING(ID, 10, 1) AS INT) % 2 = 0
            THEN 'Kvinna'
        ELSE 'Man'
    END AS Kön
FROM Users
ORDER BY FirstName, LastName;
*/

-- Uppgift E
/*
SELECT 
    Region, 
    COUNT(Country) AS NumCountries, 
    SUM(CAST(Population AS BIGINT)) AS TotalPopulation, 
    SUM(CAST([Area (sq# mi#)] AS BIGINT)) AS TotalArea, 
    CAST(AVG(CAST(REPLACE([Pop# Density (per sq# mi#)], ',', '.') AS DECIMAL(10,2))) AS DECIMAL(38,2)) AS PopulationDensity, 
    CAST(ROUND(AVG(CAST(REPLACE([Infant mortality (per 1000 births)], ',', '.') AS DECIMAL(10,2))) * 100, 0) AS INT) AS InfantMortalityPer100k 
FROM Countries
GROUP BY Region;
*/

-- Uppgift F
SELECT
    TRIM(REPLACE(PARSENAME(REPLACE([Location served], ',', '.'), 1), CHAR(160), ' ')) AS Country,
    COUNT(IATA) AS NumberOfAirports,
    SUM(CASE WHEN ICAO IS NULL THEN 1 ELSE 0 END) AS MissingICAO,
    CAST(100.0 * SUM(CASE WHEN ICAO IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5, 2)) AS PercentMissingICAO
FROM Airports2
GROUP BY TRIM(REPLACE(PARSENAME(REPLACE([Location served], ',', '.'), 1), CHAR(160), ' '))
ORDER BY PercentMissingICAO desc;