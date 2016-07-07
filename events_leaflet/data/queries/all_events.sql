select 
e.event_id, e.venue_id, e.name as title, e.popularity, e. date, e.datetime, 
v.name as venue, v.city, v.neighborhood, v.zip_code, v.lat, v.lng, 
a.artist_id, a.name as artist, a.genre1, a.genre2, a.term1, a.term2, 
a.familiarity, a.hotttnesss, a.discovery,
p.billing_index

from event e
join performance p 
on e.event_id = p.event_id

join artist a
on a.artist_id = p.artist_id

join venue v
on e.venue_id = v.venue_id;


