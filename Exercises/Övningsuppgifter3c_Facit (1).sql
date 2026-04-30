-- Av alla audiospår, vilken artist har längst total speltid?
-- Vad är den genomsnittliga speltiden på den artistens låtar?

select * from music.media_types

select 
	art.Name as 'Artist',
	sum(t.Milliseconds) as 'Total length',
	avg(t.Milliseconds) as 'Average length'
from 
	music.tracks t
	join music.albums alb on alb.AlbumId = t.AlbumId
	join music.artists art on art.ArtistId = alb.ArtistId
where
	MediaTypeId != 3
group by
	art.Name
order by
	'Total length' desc

-- Vad är den sammanlagda filstorleken för all video?
select
	sum(cast(Bytes as bigint)) / power(1024, 3) as 'Total size (GiB)'
from 
	music.tracks
where
	MediaTypeId = 3

-- Vilket är det högsta antal artister som finns på en enskild spellista?
-- Vilket är det genomsnittliga antalet artister per spellista?

select * from music.playlists

select
	AVG(subquery.[Number of artists])
from
(
	select
		p.PlaylistId,
		p.Name as 'Playlist',
		count(distinct art.ArtistId) as 'Number of artists' 
	from
		music.playlist_track pt
		right join music.tracks t on t.TrackId = pt.TrackId
		right join music.albums alb on alb.AlbumId = t.AlbumId
		right join music.artists art on art.ArtistId = alb.ArtistId
		right join music.playlists p on p.PlaylistId = pt.PlaylistId
	group by
		p.PlaylistId, p.Name
	-- order by [Number of artists] desc
) subquery


