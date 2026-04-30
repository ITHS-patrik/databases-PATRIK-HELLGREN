-- select * from [Server Name].[Database name].[Schema name].[Table name]

-- radkommentar

/*
	blockkommentar
*/

-- select column names from table name

select FirstName as 'Förnamn', LastName, ID, FirstName, 'Fredrik' as 'Fredrik', FirstName + ' ' + LastName as 'Fullname' from users;

select 5 + 3 as 'Åtta', 4-2 as 'Två', 'Fredrik' + 'Johansson';
--       [ projection ]                [ selection ]
-- select column names from table name where FirstName = 'Frida';

select * from users where FirstName <> 'Frida';


-- Begränsa antal rader:
-- T-SQL skiljer sig här från ISO-SQL som använder:
select * from users limit 5;

-- T-SQL:
select top 5 * from users;			-- "Första" 5 raderna
select top 5 percent * from users;  -- 5 procent av raderna

select * from GameOfThrones;

-- Uppgift 1
-- Ta ut namnet på första avsnittet i varje säsong samt en kolumn med antalet tittare med hela siffran (t.ex 2,22 => 2220000)
select [U.S. viewers(millions)] * 1000000 as 'U.S. viewers', Title from GameOfThrones where EpisodeInSeason = 1;

-- Uppgift 2
-- Ta ut alla avsnitt (alla kolumnner) utom de i säsong 2, 5 och 7
select * from GameOfThrones where Season not in (2, 5, 7);

-- Uppgift 3
-- Ta ut "Säsong", "Avsnitt" och "Titel" (d.v.s med kolumnnamnen på svenska) för alla avsnitt som har mellan 4 och 5 miljoner tittare.
select Season as 'Säsong', Episode as 'Avsnitt', Title as 'Titel' from GameOfThrones where [U.S. viewers(millions)] between 4 and 5;
select Season as 'Säsong', Episode as 'Avsnitt', Title as 'Titel' from GameOfThrones where [U.S. viewers(millions)] >= 4 and [U.S. viewers(millions)] <= 5;


-- Pattern matching (LIKE)

-- Använd inte LIKE för att matcha exakta värden t.ex:
select * from Users where FirstName like 'Frida'; -- använd istället =

-- Uppgift 4
-- Ta ut alla användare vars förnamn börjar på A eller B from tabellen 'users'
select * from users where FirstName like '[ab]%';

-- Uppgift 5
-- Ta ut alla användare (från 'users') där andra bokstaven i förnamnet är en vokal.
select * from users where FirstName like '_[aeiouyåäö]%';

-- Uppgift 6
-- Ta ut alla användare (från 'users') där efternamnet slutar på 'son' eller förnamnet är 2 bokstäver.
select * from users where LastName like '%son' or FirstName like replicate('[a-ö]', 5);


-- Order by

-- Filtrering med where anger bara vilka rader man får ut, inte ordningen på dem.
select * from users where FirstName like '[ab]%' order by FirstName;

-- Sortering sker innan top 5 appliceras
select top 5 * from Users order by FirstName desc;

-- Sortering i första hand på lastname, andra hand på firstname. Asc och desc anges per kolumn
select * from Users order by LastName desc, FirstName desc

-- distinct
select distinct Season from GameOfThrones
select distinct [Directed by], [Written by] from GameOfThrones
select distinct [Written by] from GameOfThrones where [Written by] like 'David%'

select
	Episode, 
	Title,
	[U.S. viewers(millions)],
	case
		when [U.S. viewers(millions)] < 3 then 'Few'
		when [U.S. viewers(millions)] < 6 then 'Average'
		else 'Many'
	end as 'Viewers'
from 
	GameOfThrones
where
	Season < 5;
