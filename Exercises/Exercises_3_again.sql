USE everyloop;

-- COMPANY
-- 1
SELECT 
    ShipCity,
    COUNT(DISTINCT od.ProductId) AS UniqueProductsSold
FROM company.orders o
JOIN company.order_details od
    ON o.Id = od.OrderId
WHERE ShipCity = 'London'
GROUP BY ShipCity;

-- 2
SELECT TOP 1
    ShipCity,
    COUNT(DISTINCT od.ProductId) AS UniqueProductsSold
FROM company.orders o
JOIN company.order_details od
    ON o.Id = od.OrderId
GROUP BY ShipCity
ORDER BY UniqueProductsSold DESC;

-- 3
SELECT
    o.ShipCountry,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSalesDiscontinued
FROM company.products p
JOIN company.order_details od
    ON p.Id = od.ProductId
JOIN company.orders o
    ON o.Id = od.OrderId
WHERE p.Discontinued = 1 AND o.ShipCountry = 'Germany'
GROUP BY o.ShipCountry;

-- 4
SELECT TOP 1
    CategoryName,
    ROUND(SUM(p.UnitPrice * p.UnitsInStock), 0) AS StockValue
FROM company.categories c
JOIN company.products p
    ON p.CategoryId = c.Id
GROUP BY CategoryName
ORDER BY StockValue DESC;

-- 5
SELECT TOP 1
    CompanyName,
    SUM(od.Quantity) AS TotalQuantitySoldSummer2013
FROM company.suppliers s
JOIN company.products p
    ON s.Id = p.SupplierId
JOIN company.order_details od
    ON p.Id = od.ProductId
JOIN company.orders o
    ON od.OrderId = o.Id
WHERE CAST(o.OrderDate AS DATE) BETWEEN '2013-06-01' AND '2013-08-31'
GROUP BY CompanyName
ORDER BY TotalQuantitySoldSummer2013 DESC;

-- MUSIC
DECLARE @playlist nvarchar(max) = 'Heavy Metal Classic'
-- 1
SELECT
    g.Name AS Genre,
    art.Name AS Artist,
    alb.Title AS Album,
    t.Name AS Track,
    RIGHT('00' + CAST(Milliseconds / 1000 / 60 AS NVARCHAR(2)), 2) + ':' + RIGHT('00' + CAST((Milliseconds / 1000) % 60 AS NVARCHAR(2)), 2) AS Length,
    CAST(CAST(Bytes / 1048576 AS DECIMAL(5,2)) AS NVARCHAR(10)) + ' MiB' AS Size,
    Composer
FROM music.tracks t
JOIN music.albums alb
    ON t.AlbumId = alb.AlbumId
JOIN music.artists art
    ON art.ArtistId = alb.ArtistId
JOIN music.genres g
    ON t.GenreId = g.GenreId
JOIN music.playlist_track pt
    ON pt.TrackId = t.TrackId
JOIN music.playlists p
    ON pt.PlaylistId = p.PlaylistId
WHERE p.Name = @playlist
ORDER BY Artist, Album, Track;

-- 2
SELECT TOP 1
    art.Name,
    RIGHT('00' + CAST(SUM(Milliseconds) / 1000 / 60 AS NVARCHAR(5)), 2) + ':' + RIGHT('00' + CAST((SUM(Milliseconds) / 1000) % 60 AS NVARCHAR(5)), 2) AS TotalPlayTime
FROM music.tracks t
JOIN music.albums alb
    ON alb.AlbumId = t.AlbumId
JOIN music.artists art
    ON art.ArtistId = alb.ArtistId
JOIN music.media_types mt
    ON mt.MediaTypeId = t.MediaTypeId
WHERE mt.MediaTypeId != 3
GROUP BY art.Name
ORDER BY TotalPlayTime DESC;

-- 3
SELECT
    mt.Name AS MediaType,
    CAST(CAST(SUM(CAST(t.Bytes AS BIGINT)) / 1048576.0 / 1024.0 AS DECIMAL(5,2)) AS NVARCHAR(10)) + ' GiB' AS TotalVideoSize
FROM music.tracks t
JOIN music.media_types mt
    ON t.MediaTypeId = mt.MediaTypeId
WHERE mt.MediaTypeId = 3
GROUP BY mt.Name;

-- 4
SELECT TOP 15 -- Lägg till WITH TIES för att visa alla listor som har lika många unika artister (om delad förstaplats d.v.s.).
    p.Name AS PlaylistName,
    COUNT(DISTINCT art.Name) AS NumberOfArtists
FROM music.playlists p
JOIN music.playlist_track pt
    ON p.PlaylistId = pt.PlaylistId
JOIN music.tracks t
    ON t.TrackId = pt.TrackId
JOIN music.albums alb
    ON alb.AlbumId = t.AlbumId
JOIN music.artists art
    ON art.ArtistId = alb.ArtistId
GROUP BY p.Name
ORDER BY NumberOfArtists DESC;

-- 5
SELECT
    AVG(subquery.NumberOfArtists) AS AverageArtistsPerPlaylist
FROM (
    SELECT
        p.Name AS PlaylistName,
        COUNT(DISTINCT art.Name) AS NumberOfArtists
    FROM music.playlists p
    JOIN music.playlist_track pt
        ON p.PlaylistId = pt.PlaylistId
    JOIN music.tracks t
        ON t.TrackId = pt.TrackId
    JOIN music.albums alb
        ON alb.AlbumId = t.AlbumId
    JOIN music.artists art
        ON art.ArtistId = alb.ArtistId
    GROUP BY p.Name
) subquery;
