
select * from music.genres;
select * from music.albums;
select * from music.artists;

select * from music.playlists;
select * from music.tracks;
select * from music.playlist_track;


declare @playlist varchar(max) = 'Heavy Metal Classic';

select 
	g.Name as 'Genre',
	ar.Name as 'Artist',
	al.Title as 'Album',
	t.Name as 'Track',
	--Milliseconds as 'Lenghth',
	--DATEADD(MILLISECOND,t.milliseconds,0),
	--RIGHT(CONVERT(CHAR(8),DATEADD(MILLISECOND,t.milliseconds,0), 108),5) as 'Duration',
	format(DATEADD(MILLISECOND,t.milliseconds,0), 'mm:ss') as 'Duration',
	concat(format(Bytes / power(1024.0, 2), 'N1'), ' MiB') as 'Size',
	isnull(Composer, '-') as 'Composer'
	--p.Name as 'Playlist'
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
	g.Name, ar.Name, al.Title, t.Name







