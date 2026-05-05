-- ISO-SQL
select cast(5.6 as int)

-- Convert är specifikt för T-SQL
select convert(int, 5.6);
select convert(nvarchar, getdate(), 121)

-- Vill man konvertera numerics eller datetime till strängar av ett visst format används funktionen format()
select format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff');

