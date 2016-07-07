
select neighborhood, term1
from
	(select neighborhood, term1, ROW_NUMBER() OVER (PARTITION BY neighborhood ORDER BY freq DESC) as rn
	from
		(select neighborhood, term1, count(*) as freq
		from
			(select 
			e.event_id, e.venue_id, e.name as event_name, e.popularity, e.datetime,
			v.name as venue, v.city, v.neighborhood, v.zip_code, v.lat, v.lng,
			a.*

			from event e
			join performance p
			on e.event_id = p.event_id

			join artist a
			on p.artist_id = a.artist_id

			join venue v
			on e.venue_id = v.venue_id

			where a.term1 is not null
			and v.city = 'San Francisco') sub
		group by 1, 2) genre_freq) ranked_genre
where rn = 1;