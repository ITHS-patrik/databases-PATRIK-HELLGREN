drop table countries;

create table countries (
	id int,
	name nvarchar(max)
);

insert into countries values (1, 'Sweden');
insert into countries values (2, 'Norway');
insert into countries values (3, 'Denmark');
insert into countries values (4, 'Finland');


drop table cities;

create table cities (
	id int,
	name nvarchar(max),
	countryId int
)

insert into cities values (1, 'Stockholm', 1);
insert into cities values (2, 'Gothenburg', 1);
insert into cities values (3, 'Malmö', 1);
insert into cities values (4, 'Oslo', 2);
insert into cities values (5, 'Bergen', 2);
insert into cities values (6, 'Copenhagen', 3);
insert into cities values (7, 'London', 5);




select 
	cities.id,
	countries. id,
	countryid,
	cities.*,
	*
from 
	countries 
	cross join cities;


select * from countries;
select * from cities;

select 
	ci.id,
	ci.name as 'City',
	co.name as 'Country',
	co.id,
	ci.countryId
from 
	countries co
	right join cities ci on co.id = ci.countryId;


-- Uppgift 1
-- Ta ut alla länder med en kolumn för namn på landet, en kolumn med antal städer, och en kolumn med kommaseparerad lista med namnen på städerna.

select
    countries.name as 'Country',
    count(cities.id) as 'Number of cities',
    isnull(string_agg(cities.name, ', '), '-') as 'Cities'
from
    countries
    full outer join cities on countries.id = cities.countryId
group BY countries.name;


-- Gammalt sätt att joina innan JOIN keyword infördes på 90-talet
select * from countries, cities where countries.id = cities.countryId


