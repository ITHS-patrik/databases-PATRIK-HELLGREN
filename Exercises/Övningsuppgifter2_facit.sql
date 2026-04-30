-- Ta ut (select) en rad för varje (unik) period i tabellen ”Elements” med
-- följande kolumner: ”period”, ”from” med lägsta atomnumret i perioden,
-- ”to” med högsta atomnumret i perioden, ”average isotopes” med
-- genomsnittligt antal isotoper visat med 2 decimaler, ”symbols” med en
-- kommaseparerad lista av alla ämnen i perioden. 
-- 

select * from Elements

select
	Period,
	min(Number) as 'from',
	max(Number) as 'to',
	format(avg(convert(float, Stableisotopes)), 'N2') as 'average isotopes', -- formaterar som nummer med 2 decimaler
	string_agg(Symbol,',')
from
	Elements
group by
	Period;

-- SQL har inte // operatorn (floor division), utan gör den automatisk om både nämnare och täljare är heltal (integers)
select 
	5 / 2, 
	5 % 2,
	5.0 / 2.0


-- För varje stad som har 2 eller fler kunder i tabellen Customers, ta ut
-- (select) följande kolumner: ”Region”, ”Country”, ”City”, samt
-- ”Customers” som anger hur många kunder som finns i staden. 

select * from company.customers

select
    Region,
    Country,
    City,
    count(*) as 'Number of Customers'
from
    company.customers
group by
    Region,
    Country,
    City
having
    count(*) > 1
order by
	count(*);


-- Skapa en varchar-variabel och skriv en select-sats som sätter värdet: ”Säsong 1 sändes från april till juni 2011. Totalt
-- sändes 10 avsnitt, som i genomsnitt sågs av 2.5 miljoner människor i USA.”, följt av radbyte/char(13), följt av
-- ”Säsong 2 sändes …” osv. När du sedan skriver (print) variabeln till messages ska du alltså få en rad
-- för varje säsong enligt ovan, med data sammanställt från tabellen GameOfThrones.
-- Tips: Ange ’sv’ som tredje parameter i format() för svenska månader

select * from GameOfThrones

DECLARE @report NVARCHAR(MAX) = '';
 
WITH SeasonSummary AS (
    SELECT
        Season,
        MIN([Original air date]) AS StartDate, -- Hämtar det tidigaste datumet för säsongen
        MAX([Original air date]) AS EndDate, -- Hämtar det senaste datumet för säsongen
        COUNT(*) AS EpisodeCount,
        CAST(AVG(CAST([U.S. viewers(millions)] AS FLOAT)) AS DECIMAL(10,2)) AS AvgViewers -- Beräknar genomsnittet och formaterar till två decimaler
    FROM
        GameOfThrones
    GROUP BY
        Season
)

SELECT @report = @report +
    'Säsong ' + CAST(Season AS VARCHAR) + ' sändes från ' +
    FORMAT(StartDate, 'MMMM', 'sv') + ' till ' +
    FORMAT(EndDate, 'Y', 'sv') + '. Totalt sändes ' +
    CAST(EpisodeCount AS VARCHAR) + ' avsnitt, som i genomsnitt sågs av ' +
    CAST(AvgViewers AS VARCHAR) + ' miljoner människor i USA.' + CHAR(13) + CHAR(10)
FROM
    SeasonSummary
ORDER BY
    Season;
 
PRINT @report;


-- Ta ut (select) alla användare i tabellen ”Users” så du får tre kolumner:
-- ”Namn” som har fulla namnet; ”Ålder” som visar hur många år personen
-- är idag (ex. ’45 år’); ”Kön” som visar om det är en man eller kvinna.
-- Sortera raderna efter för- och efternamn. 

select
	concat(FirstName, ' ', LastName) as 'Namn',
	id, 
	left(ID, 6),
	convert(date, left(ID, 6)),
	floor((datediff(day, convert(date, left(ID, 6)), getdate())) / 365.25) as 'Ålder',
	case
		when substring(right(ID,2), 1, 1) % 2 = 0 then 'Kvinna'
		else 'Man'
	end as 'Kön'
from
	Users
order by
	FirstName,
	LastName;


-- Ta ut en lista över regioner i tabellen ”Countries” där det för varje region
-- framgår regionens namn, antal länder i regionen, totalt antal invånare,
-- total area, befolkningstätheten med 2 decimaler, samt
-- spädbarnsdödligheten per 100.000 födslar avrundat till heltal. 

select * from Countries;

SELECT
    [Region],
    count([Country]) as 'Number of Countries',
    SUM(convert(bigint, [Population])) as 'Total Population',
    sum([Area (sq# mi#)]) as 'Total Area',
    sum(convert(bigint, [Population]))/sum([Area (sq# mi#)]) as 'Population Density',
    round(avg(convert(float, replace([Infant mortality (per 1000 births)], ',', '.'))), 2) as 'Average Infant Mortality'
from
    countries
group by
    [Region];



-- Från tabellen ”Airports”, gruppera per land och ta ut kolumner som visar:
-- land, antal flygplatser (IATA-koder), antal som saknar ICAO-kod, samt hur
-- många procent av flygplatserna i varje land som saknar ICAO-kod.

select * from Airports


select
--	[Location served],
--	charindex(',', [Location served]),
--	reverse(rtrim([Location served]))+',',
--	charindex(',', reverse(rtrim([Location served]))+',')-1,
	right(rtrim([Location served]), charindex(',', reverse(rtrim([Location served]))+',')-1) as Country,
	count(IATA) as 'number of airports',
	sum(case when ICAO is null then 1 else 0 end) as 'number of ICAO nulls',
	format(sum(case when ICAO is null then 1 else 0 end) / cast(count(IATA) as float), 'p') as 'Percentage of ICAO'
from
	Airports
group by
	right(rtrim([Location served]), charindex(',', reverse(rtrim([Location served]))+',')-1)

