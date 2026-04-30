/*


select * from music.playlists
select * from music.genres
select * from music.albums
select * from music.artists
select * from music.tracks
*/

declare @playlist varchar(max) = 'Heavy Metal Classic'; -- ID = 17

select
	--newid() as 'GUID',
	--p.Name as 'Playlist',
	g.Name as 'Genre',
	ar.Name as 'Artist',
	al.Title as 'Album',
	t.Name as 'Track',
	FORMAT(DATEADD(ms, t.Milliseconds, '00:00'), 'mm:ss') AS 'Length',
	--concat(t.Milliseconds / 1000 / 60 % 60, ':', t.Milliseconds / 1000 % 60) as 'Length2'
	CONCAT(format(t.Bytes / power(1024.0, 2), '#.0'), ' MiB') as 'Size',
	isnull(Composer, '-') as 'Composer'
from 
	music.tracks t
	join music.genres g on g.GenreId = t.GenreId
	join music.albums al on al.AlbumId = t.AlbumId
	join music.artists ar on ar.ArtistId = al.ArtistId
	join music.playlist_track pt on pt.TrackId = t.TrackId
	join music.playlists p on p.PlaylistId = pt.PlaylistId
where 
	p.Name = @playlist
order by
	newid()
	--Artist, Album, Track


--select * from music.playlist_track


