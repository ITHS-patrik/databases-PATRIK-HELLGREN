USE everyloop;

SELECT * INTO GameOfThrones2 FROM GameOfThrones;

-- A
SELECT
    Title,
    'S' + FORMAT(Season, '00') + 'E' + FORMAT(EpisodeInSeason, '00') AS Episode
FROM GameOfThrones2;


-- B
SELECT * INTO Users2 FROM Users;

UPDATE 
    Users2
SET 
    UserName = LOWER(LEFT(FirstName, 2) + LEFT(LastName, 2));


-- C
SELECT * INTO Airports2 FROM Airports;

UPDATE 
    Airports2
SET
    Time = ISNULL(Time, '-'),
    DST = ISNULL(DST, '-');


-- D
SELECT * INTO Elements2 FROM Elements;

DELETE FROM 
    Elements2
WHERE 
    Name IN ('Erbium', 'Helium', 'Nitrogen', 'Platinum', 'Selenium')
    OR Name LIKE '[dkmou]%';


-- E
SELECT Symbol, Name INTO Elements3 FROM Elements;

ALTER TABLE Elements3
    ADD MatchingName NVARCHAR(3);

UPDATE Elements3
    SET MatchingName = 
        CASE
            WHEN LEFT(Name, LEN(Symbol)) = Symbol THEN 'Yes'
            ELSE 'No'
        END;


-- F
SELECT * INTO Colors2 FROM Colors;
ALTER TABLE Colors2
DROP COLUMN Code;

SELECT TOP 10
    Name, 
    '#' + FORMAT(Red, 'X2') + FORMAT(Green, 'X2') + FORMAT(Blue, 'X2') AS Code,
    Red,
    Green,
    Blue
FROM Colors2;


-- G
SELECT Integer, String INTO Types2 FROM Types;

SELECT
    Integer,
    CAST(FORMAT(Integer / 100.0, 'N2') AS FLOAT) AS Float,
    String,
    DATETIME2FROMPARTS(2019, 1, Integer, 9, Integer, 0, 0, 7) AS DateTime,
    CASE
        WHEN Integer % 2 = 0 THEN 0
        ELSE 1
    END AS Bool
FROM Types2;
