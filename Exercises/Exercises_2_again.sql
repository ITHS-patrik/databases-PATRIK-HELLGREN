USE everyloop;

-- A
SELECT
    Period,
    MIN(Number) AS [From],
    MAX(Number) AS [To],
    CAST(AVG(CAST(Stableisotopes AS DECIMAL(4,2))) AS DECIMAL(4,2)) AS [Average Isotopes],
    STRING_AGG(Name, ', ') AS Symbols
FROM Elements
GROUP BY Period;


-- B
SELECT
    Region,
    Country,
    City,
    COUNT(*) AS Customers
FROM company.customers
GROUP BY City, Country, Region
HAVING COUNT(*) >= 2;


-- C
DECLARE @summary NVARCHAR(MAX) = '';

SELECT @summary = @summary +
    'Säsong ' + CAST(Season AS NVARCHAR(2)) + 
    ' sändes från ' + FORMAT(DATEFROMPARTS(2000, MONTH(MIN([Original air date])), 1), 'MMMM', 'sv-SE') +
    ' till ' + FORMAT(DATEFROMPARTS(2000, MONTH(MAX([Original air date])), 1), 'MMMM', 'sv-SE') + ' ' +
    CAST(YEAR(MAX([Original air date])) AS NVARCHAR(4)) +
    '. Totalt sändes ' +
    CAST(COUNT(Episode) AS NVARCHAR(2)) + ' avsnitt, som i genomsnitt sågs av ' + 
    CAST(ROUND(AVG([U.S. viewers(millions)]), 1) AS NVARCHAR(4)) + ' miljoner människor i USA.' + 
    CHAR(13) + CHAR(10)
FROM GameOfThrones
GROUP BY Season;

PRINT @summary


-- D
SELECT
    FirstName + ' ' + LastName AS Name,
    CAST(DATEDIFF(YEAR, CONVERT(date, '19' + SUBSTRING(ID, 1, 6)), GETDATE())
    - CASE
        WHEN FORMAT(GETDATE(), 'MMdd') < SUBSTRING(ID, 3, 4) THEN 1
        ELSE 0
    END AS NVARCHAR(3)) + ' år' AS Age,
    CASE
        WHEN SUBSTRING(ID, 10, 1) % 2 = 0 THEN 'Woman'
        ELSE 'Man'
    END AS Gender
FROM Users
ORDER BY FirstName, LastName;


-- E
SELECT
    Region,
    COUNT(*) AS NumberOfCountries,
    SUM(CONVERT(bigint, Population)) AS TotalPopulation,
    SUM([Area (sq# mi#)]) AS TotalArea,
    SUM(CONVERT(bigint, Population)) / SUM([Area (sq# mi#)]) AS PopulationDensity,
    CAST(
        SUM(
            Population * 1.0 * CAST(REPLACE(Birthrate, ',', '.') AS DECIMAL(10,4)) / 1000.0 *
            CAST(REPLACE([Infant mortality (per 1000 births)], ',', '.') AS DECIMAL(10,4)) / 1000.0) / 
        SUM(Population * 1.0 * CAST(REPLACE(Birthrate, ',', '.') AS DECIMAL(10,4)) / 1000.0) * 100000 AS INT) 
        AS InfantMortalityPer100kBirths
FROM Countries
GROUP BY Region;


-- F
WITH CleanedAirports AS (
    SELECT
        TRIM(REPLACE(PARSENAME(REPLACE([Location served], ',', '.'), 1), CHAR(160), ' ')) AS Country,
        IATA,
        ICAO
    FROM Airports
)
SELECT
    Country,
    COUNT(*) AS NumberOfAirports,
    SUM(CASE
            WHEN ICAO IS NULL THEN 1
            ELSE 0
        END) AS MissingICAO,
    FORMAT(SUM(CASE
                    WHEN ICAO IS NULL THEN 1
                    ELSE 0
                END) / CAST(COUNT(*) AS FLOAT), 'p') AS MissingICAOPercentage
FROM CleanedAirports
GROUP BY Country
ORDER BY Country;

SELECT * FROM Airports WHERE [Location served] LIKE '%[0-9]%'; 
