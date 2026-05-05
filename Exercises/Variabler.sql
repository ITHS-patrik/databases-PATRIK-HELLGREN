-- Variabler i SQL måste deklareras innan användning

declare @name nvarchar(max) = 'Fredrik'; -- Tilldela värde vid deklaration

set @name = 'Arthur'; -- Tilldela nytt värde

select @name;

----------
-- Man kan även använda select för att tilldela värden till flera variabler samtidigt.

declare @firstname nvarchar(max);
declare @lastname nvarchar(max);

select top 1 @firstname = firstname, @lastname = lastname from users where firstname = @name order by FirstName;

select @firstname, @lastname;

-----------

declare @names nvarchar(max) = '';

-- Konkatenera alla värden i resultatet till @names.
select @names += firstname from users;

print @names

select @names 

print 'hejsan'

