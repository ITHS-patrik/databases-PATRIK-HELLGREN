-- Generera random data
select 
	value,
	rand(value) as 'Random',
	newid() as 'GUID',
	rand(checksum(newid())) * 10 - 5 as 'Random float',
	abs(checksum(newid())) % 5 as 'Random int',
	char(65 + abs(checksum(newid())) % 26) as 'Random Letter',
	choose(Rand3, 'Red', 'Green', 'Blue') as 'Random color'
from 
(
	select
		value,
		abs(checksum(newid())) % 3 + 1 as 'Rand3'
	from generate_series(1, 100000)
) subquery

-- Skriva ut random namn
declare @randomName nvarchar(max) = (select top 1 FirstName from users order by newid());
print @randomName;

-- Skapa random användare
select
	Id,
	concat(FirstName, ' ', LastName) as 'Name',
	translate(lower(concat(FirstName, '.', LastName, '@gmail.com')), 'åäö', 'aao') as 'Email'
from
(
	select
		concat(format(dateadd(day, abs(checksum(newid())) % 36500,'1900-01-01'), 'yymmdd'), '-', format(abs(checksum(newid())) % 10000, '0000')) as 'Id',
		(select top 1 FirstName from users where g.value = g.value order by newid()) as 'FirstName',
		(select top 1 LastName from users where g.value = g.value order by newid()) as 'LastName'
	from
		generate_series(1, 10000) g
) subquery

