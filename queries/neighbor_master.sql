select 
	neighborhood, 
	count(distinct venue_id) as num_venues,
	count(distinct event_id) as num_events, 
	count(distinct artist_id) as num_artists, 
	avg(popularity) as avg_pop,
	max(popularity) - min(popularity) as range_pop,
	avg(discovery) as avg_discovery,
	max(discovery) - min(discovery) as range_discovery,
	avg(familiarity) as avg_familiar, 
	max(familiarity) - min(familiarity) as range_familiar,
	avg(hotttnesss) as avg_hot,
	max(hotttnesss) - min(hotttnesss) as range_hot
from

	(select 
	e.event_id, e.venue_id, e.name as event_name, e.popularity, e.datetime,
	v.name as venue, v.city, v.neighborhood, v.zip_code, v.lat, v.lng,
	a.name, a.artist_id, a.term1, a.genre1, 
	cast(nullif(discovery, '') as float) as discovery,
	cast(nullif(familiarity, '') as float) as familiarity,
	cast(nullif(hotttnesss, '') as float) as hotttnesss

	from event e
	join performance p
	on e.event_id = p.event_id

	join artist a
	on p.artist_id = a.artist_id

	join venue v
	on e.venue_id = v.venue_id

	where v.city = 'San Francisco') sub

group by 1
order by 3 desc;