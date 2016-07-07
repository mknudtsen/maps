

select 
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

where v.city = 'San Francisco'



