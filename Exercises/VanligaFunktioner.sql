-- Datatype
select len(firstname), firstname from users;
select len(firstname), DATALENGTH(firstname), firstname from users; -- stränglängd och datalängd
select IDENTITY(int, 1, 1) as Ident, * into users2 from users; -- skapa identitykolumn med select into

-- Datetime
select getdate(); -- Dagens datum och tid
select getUTCdate(); -- Dagens datum och tid UTC (GMT)
select dateadd(year, 3, dateadd(hour, 2, getdate())); -- addera på tid
select dateadd(year, -5, '2018-10-12 15:10:00.13'); -- ett exempel till..
select datediff(year, '1981-02-04', getdate()); -- diff mellan två datum
select DATEFROMPARTS(1981, 2, 4);
select isdate('2018-13-12 15:10:00.13'); -- Korrekt datum?
set datefirst 1;
select datepart(WEEKDAY, getdate()); -- Ta ut del av datetime som int
select datetrunc(MINUTE, getdate()); -- Trunkerar med angiven precision
--year, month, week, day, hour, minute, second, millisecond
--dayofyear, quarter, weekday

-- Math function
select abs(-5);
select sin(1), sin(1 + 2 * pi()), cos(1), tan(1);
select DEGREES(pi()); -- omvandla radianer till grader.
select Radians(180.0); -- omvandla grader till radianer.
select FLOOR(4.7), CEILING(4.7), ROUND(4.743534, 2); -- avrunda nedåt, uppåt, närmsta
select power(10, 3); -- Upphöjt
select rand(123), rand(), rand(); -- random värde mellan 0 och 1
select round(rand() * 4 + 3.5, 0); -- random värde mellan ?
select sign(-15), sign(0), sign(37); -- plus eller minus?
select square(3); -- Kvadrat
select sqrt(9); -- Square root
select least(4, 5, 3), greatest(4, 5, 3); -- lägsta, respektive högsta, värde

-- Logical
select choose(1, 'röd', 'grön', 'blå', 'vit'); -- välj ett värde genom index.
select iif(1=2, 'japp', 'nope'); -- if sats som funktion.

-- String
select ascii('A'); -- Ger ASCII-koden för ett tecken
select char(65); -- Ger tecknet för angiven ASCII-kod
select unicode(N'庪'); -- Ger unicode för ett tecken
select nchar(24234); -- Get tecknet för given unicode
select concat('röd', 'grön', 'blå'); -- Lägg ihop strängar .. (konvererar automatiskt andra datatyper till varchar)
select 'röd' + 'grön' + 'blå'; -- ... man kan även göra så här!
select concat_ws(', ', 'röd', 'grön', 'blå'); -- concat With Separator
select format(getdate(), 'yyyy-MM-dd'); -- formatera till nvarchar med c# formats
select left('Fredrik', 3), right('Fredrik', 4); -- första X bokstäver från vänster, respektive höger.
select len('Fredrik'); -- längd på sträng
select lower('Fredrik'), upper('Fredrik'); -- lower och uppercase
select '-' + ltrim('   X    ') + '-', '-' + trim('    X    ') + '-', '-' + rtrim('   X    ') + '-'; -- ta bort inledande och avslutande spaces
select trim('x' from 'xxxyyxxxzzzxxx'); -- som trim fast med annat tecken än space
select replace('Hello world!', 'world', 'there'); -- byt ut alla förekomster av sökord i sträng.
select translate('Får är söta!', 'åäö', 'aao'); -- byter ut angivna tecken i en sträng
select reverse('Fredrik'); -- Vänd bakochfram.
select replicate('hej', 5); -- upprepar en sträng x antal gånger
select '-' + space(5) + '-'; -- ger en sträng med x antal space/mellanslag
select stuff('Hello world!', 3, 5, 'xxx'); -- klipp in en sträng i en annan.
select substring('Hello world!', 2, 3); -- del av sträng
select charindex('or', 'Hello world!'); -- få ett index på första träffen på en sökning i sträng

-- Table value functions (funktioner som returnerar en tabell istället för en skalär (enskilt värde)
select * from string_split('red;blue;green;yellow;purple', ';', 1); -- sista parametern anger om ordinalkolumnen ska med.
select * from generate_series(10, 20, 2); -- start, end, step

-- Övrigt
select isnull(null, 'hej');
select isnull(dst, '-') from Airports; -- ge ett alternativt värde om första är null
select coalesce(null, null, null, 'test', null, 'hej'); -- ge första värdet som inte är null
select coalesce(dst, time, ICAO, IATA) from Airports; -- exempel på coalesce med flera kolumner
select newid(); -- generar ett GUID
select top 10 * from users order by newid(); -- trick för att sortera i random ording

















