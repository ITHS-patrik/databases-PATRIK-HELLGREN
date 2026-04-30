-- Ta ut data (select) från tabellen GameOfThrones på sådant sätt att ni får ut
-- en kolumn ’Title’ med titeln samt en kolumn ’Episode’ som visar episoder
-- och säsonger i formatet ”S01E01”, ”S01E02”, osv.
-- Tips: kolla upp funktionen format() 

select * from GameOfThrones

select 
	title,
	season,
	EpisodeInSeason,
	format(Season, 'S0#') + format(EpisodeInSeason, 'E0#') as 'Episodes',
	concat('S', format(Season, '00'), 'E', format(EpisodeInSeason, '00')) as 'Episodes'
from
	GameOfThrones

-- select format(123.456, '00.00'), format(123.456, '##.##'), format(123.456, '0000.0000'), format(123.456, '####.####')



-- Uppdatera (kopia på) tabellen user och sätt username för alla användare så
-- den blir de 2 första bokstäverna i förnamnet, och de 2 första i efternamnet
-- (istället för 3+3 som det är i orginalet). Hela användarnamnet ska vara i små
-- bokstäver. 

-- select * into users2 from users

select 
	firstname,
	lastname,
	concat(left(firstname, 2), left(lastname, 2)),
	lower(concat(left(firstname, 2), left(lastname, 2))),
	lower(left(firstname, 2)),
	concat(lower(left(firstname, 2)), left(lastname, 2))
from 
	users2

update users2 set UserName = lower(concat(left(firstname, 2), left(lastname, 2)))
update users2 set UserName = lower(left(firstname, 2) + left(lastname, 2));
UPDATE Users2 SET UserName = lower(substring (FirstName, 1, 2)) + lower(substring (LastName, 1, 2))


-- Uppdatera (kopia på) tabellen airports så att alla null-värden i kolumnerna
-- Time och DST byts ut mot ’-’ 


SELECT * INTO Airports2 FROM Airports
select * from Airports2
 
UPDATE Airports2 SET Time = '-' WHERE Time is NULL;
UPDATE Airports2 SET DST = '-' WHERE DST is NULL;

SELECT * INTO AirportsCopy FROM Airports
select * from AirportsCopy

update AirportsCopy set DST = isnull(DST, '-')
update AirportsCopy set Time = isnull(Time, '-')

update AirportsCopy set Time = coalesce(Time, '-'), DST = coalesce(DST, '-') where Time is null or DST is null;


-- Ta bort de rader från (kopia på) tabellen Elements där ”Name” är någon av
-- följande: 'Erbium', 'Helium', 'Nitrogen', 'Platinum', 'Selenium', samt alla
-- rader där ”Name” börjar på någon av bokstäverna d, k, m, o, eller u. 
select * into elements2 from [elements];

select * from elements2

delete from elements2 where name like '[dkmou]%' or name in ('Erbium', 'Helium', 'Nitrogen', 'Platinum', 'Selentium');


-- Skapa en ny tabell med alla rader från tabellen Elements. Den nya tabellen
-- ska innehålla ”Symbol” och ”Name” från orginalet, samt en tredje kolumn
-- med värdet ’Yes’ för de rader där ”Name” börjar med bokstäverna i
-- ”Symbol”, och ’No’ för de rader där de inte gör det.
-- Ex: ’He’ -> ’Helium’ -> ’Yes’, ’Mg’ -> ’Magnesium’ -> ’No’. 

drop table elements3

select 
	symbol,
	[name],
	len(symbol),
	case 
		when left(name, len(symbol)) = symbol then 'Yes'
		--when left(name, 2) = symbol then 'Yes' 
		else 'No' 
	end as 'first letter match',
	concat(Symbol, '%'),
	case
		when Name like concat(Symbol, '%') then 'Yes'
		else 'No'
	end as 'first letter match'
-- into elements3
from
	[Elements];

select * from elements3


-- Kopiera tabellen Colors till Colors2, men skippa kolumnen ”Code”. Gör
-- sedan en select från Colors2 som ger samma resultat som du skulle fått från
-- select * from Colors; (Dvs, återskapa den saknade kolumnen från RGBvärdena i resultatet). 
drop table colors2

select 
	[name], red, green, blue
into colors2
from 
	colors


select 
	*, 
	'#' + format(red, 'X2') + format(green, 'X2') + format(blue, 'X2') as 'code'
from 
colors

alter table colors2
add code as '#' + format(red, 'X2') + format(green, 'X2') + format(blue, 'X2');

select format(255, 'x4');



-- Kopiera kolumnerna ”Integer” och ”String” från tabellen ”Types” till en ny
-- tabell. Gör sedan en select från den nya tabellen som ger samma resultat
-- som du skulle fått från select * from types; 

select 
	*,
	Integer * 0.01,
	dateadd(minute, integer, dateadd(day, Integer, '2018-12-31 09:00')),
	Integer % 2

from 
	Types