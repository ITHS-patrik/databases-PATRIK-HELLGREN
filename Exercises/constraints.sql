drop table constraintsdemo;

create table constraintsdemo (
	id int primary key identity(1, 1),
--	allowsNull nvarchar(10) null,
--	noNull nvarchar(10) not null,
--	defaultWithNull nvarchar(10) null default('HELLO'),
--	defaultWithNoNull nvarchar(10) not null default('WORLD'),
--	uniqueValue nvarchar(10) unique,
--	personnummer nvarchar(10) check(len(personnummer) = 10)
	personnummer nvarchar(11) check(personnummer like concat('20', replicate('[0-9]', 4), '-', replicate('[0-9]', 4))) unique not null
)

--insert into constraintsdemo (id, noNull, defaultWithNoNull, uniqueValue, personnummer) values(5, 'world', 'NULL', 'HEJSAN', 'sadjfhsdkjfhdsjkfhdsf');

insert into constraintsdemo values(NULL);

select * from constraintsdemo;

select concat('20', replicate('[0-9]', 4), '-', replicate('[0-9]', 4))
