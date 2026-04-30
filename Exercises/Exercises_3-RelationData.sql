USE everyloop;

-- SCHEMA "company"
-- 1.
-- Vilka produkt-ID:n har skickats till London?
SELECT DISTINCT od.ProductId
FROM company.orders2 o
JOIN company.order_details od
    ON od.OrderId = o.Id
WHERE o.ShipCity = 'London';

-- Hur många unika produkter har skickats till London?
SELECT 
    COUNT(DISTINCT od.ProductId) AS ProductsDeliveredToLondon
FROM company.orders2 o
JOIN company.order_details od
    ON od.OrderId = o.Id
WHERE o.ShipCity = 'London';

-- Andelen unika produkter skickade till London?
SELECT 
    CAST(COUNT(DISTINCT od.ProductId) * 100.0 / 77 AS DECIMAL(4,2)) AS PercentOfAsortmentDeliveredToLondon
FROM company.orders2 o
JOIN company.order_details od
    ON od.OrderId = o.Id
WHERE o.ShipCity = 'London';

-- 2.
SELECT TOP 1
    o.ShipCity, 
    COUNT(DISTINCT od.ProductId) AS ProductsDeliveredToCity,
    CAST(COUNT(DISTINCT od.ProductId) * 100.0 / 77 AS DECIMAL(4,2)) AS PercentOfAsortmentDeliveredToCity
FROM company.orders2 o
JOIN company.order_details od
    ON od.OrderId = o.Id
GROUP BY o.ShipCity
ORDER BY COUNT(DISTINCT od.ProductId) DESC;

-- 3.
SELECT
    o.ShipCountry,
    SUM(CAST((od.UnitPrice - (od.UnitPrice * od.Discount)) * od.Quantity AS DECIMAL(10,2))) AS NetSum
FROM company.orders2 o
JOIN company.order_details od
    ON od.OrderId = o.Id
JOIN company.products pr
    ON pr.Id = od.ProductId
WHERE pr.Discontinued = 1 AND o.ShipCountry = 'Germany'
GROUP BY o.ShipCountry;

-- 4.
SELECT --TOP 1
    cat.CategoryName,
    CAST(SUM(pr.UnitPrice * pr.UnitsInStock) AS DECIMAL(8,2)) AS StockValue
FROM company.products pr
JOIN company.categories cat
    ON pr.CategoryId = cat.Id
GROUP BY cat.CategoryName
ORDER BY StockValue DESC;

-- 5.
SELECT --TOP 1
sup.CompanyName, 
SUM(od.Quantity) AS NumberOfProducts
FROM company.suppliers sup
JOIN company.products pr
    ON pr.SupplierId = sup.Id
JOIN company.order_details od
    ON pr.Id = od.ProductId
JOIN company.orders2 o
    ON od.OrderId = o.Id
WHERE o.OrderDate BETWEEN '2013-06-01' AND '2013-08-31' 
GROUP BY sup.CompanyName
ORDER BY NumberOfProducts DESC;

-- SCHEMA "music"
DECLARE @playlist varchar(max) = 'Heavy Metal Classic';

SELECT
    ge.Name AS Genre,
    ar.Name AS Artist,
    al.Title AS Album,
    tr.Name AS Track,
    FORMAT((tr.Milliseconds / 1000) / 60, '00') + ':' + FORMAT((tr.Milliseconds / 1000) % 60, '00') AS Length,
    CAST(CAST(tr.Bytes / 1000000.0 AS DECIMAL(3,1)) AS VARCHAR(10)) + ' MiB' AS Size,
    REPLACE(tr.Composer, '/', ', ') AS Composer
FROM music.tracks tr
JOIN music.playlist_track pt
    ON tr.TrackId = pt.TrackId
JOIN music.playlists pl
    ON pt.PlaylistId = pl.PlaylistId
JOIN music.albums al
    ON tr.AlbumId = al.AlbumId
JOIN music.artists ar
    ON al.ArtistId = ar.ArtistId
JOIN music.genres ge
    ON tr.GenreId = ge.GenreId
WHERE pl.Name = @playlist
ORDER BY tr.Name;

/*
genres
    GenreId
    Name
artists
    ArtistId
    Name
albums
    AlbumId
    ArtistId
tracks
    TrackId -> playlist_track -> playlists
    Name
    AlbumId -> albums -> artists
    GenreId -> genres
playlists
    PlaylistId
    Name
playlist_track???
    PlaylistId
    TrackId
*/

-- 1. & 2.
SELECT --TOP 1
    ar.Name AS Artist,
    FORMAT((SUM(tr.Milliseconds) / 1000) / 60 / 60, '00') + ':' + FORMAT((SUM(tr.Milliseconds) / 1000) / 60 % 60, '00') + ':' + FORMAT((SUM(tr.Milliseconds) / 1000) % 60 % 60, '00') AS TotalLength,
    FORMAT((AVG(tr.Milliseconds) / 1000) / 60 / 60, '00') + ':' + FORMAT((AVG(tr.Milliseconds) / 1000) / 60 % 60, '00') + ':' + FORMAT((AVG(tr.Milliseconds) / 1000) % 60 % 60, '00') AS AverageLength
FROM music.tracks tr
JOIN music.albums al
    ON al.AlbumId = tr.AlbumId
JOIN music.artists ar
    ON ar.ArtistId = al.ArtistId
WHERE tr.MediaTypeId != 3
GROUP BY ar.Name
ORDER BY TotalLength DESC;

-- 3.
SELECT
    CAST(SUM(CAST(tr.Bytes / 1000000000.0 AS DECIMAL(6,1))) AS VARCHAR(10)) + ' GB' AS TotalVideoFileSize
FROM music.tracks tr
WHERE tr.MediaTypeId = 3;

-- 4. & 5.
SELECT
    AVG(subquery.UniqueNumberOfArtists) AS AverageNumberOfArtists
FROM (
    SELECT --TOP 1
        pl.Name AS PlaylistName,
        COUNT(DISTINCT ar.ArtistId) AS UniqueNumberOfArtists
    FROM music.playlist_track pt
    JOIN music.tracks tr
        ON pt.TrackId = tr.TrackId
    JOIN music.albums al
        ON tr.AlbumId = al.AlbumId
    JOIN music.artists ar
        ON al.ArtistId = ar.ArtistId
    JOIN music.playlists pl
        ON pl.PlaylistId = pt.PlaylistId
    GROUP BY pl.Name
    --ORDER BY COUNT(DISTINCT ar.Name) DESC;
) subquery;
