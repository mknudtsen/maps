library(rgdal)
library(RPostgreSQL)
library(dplyr)

# read in shapefile for san francisco neighborhoods
sf_plan <- readOGR(dsn = "data/shapefiles/sf_planning", layer = "planning_neighborhoods")
sf_plan <- spTransform(sf_plan, CRS("+proj=longlat +datum=WGS84"))
sf_plan@data <- rename(sf_plan@data, neighborhood = neighborho)

# connect to postgres to query event and artist data
driver <- dbDriver("PostgreSQL")
songkick <- dbConnect(driver, dbname = "songkick3", host = "localhost", port = 5432, user = "mark")

# read each sql query from .sql file
all_sql <- paste(readLines("data/queries/all_events.sql"), collapse = "\n")
master_sql <- paste(readLines("data/queries/neighbor_master.sql"), collapse = "\n")
genre_sql <- paste(readLines("data/queries/genre_top.sql"), collapse = "\n")
term_sql <- paste(readLines("data/queries/term_top.sql"), collapse = "\n")
venue_sql <- paste(readLines("data/queries/venues_coord.sql"), collapse = "\n")

# query db with queries defined above, save to r df
all_events <- dbGetQuery(songkick, all_sql)
by_neighborhood <- dbGetQuery(songkick, master_sql)
genres <- dbGetQuery(songkick, genre_sql)
terms <- dbGetQuery(songkick, term_sql)
venues <- dbGetQuery(songkick, venue_sql)
dbDisconnect(songkick)

# join spatial data from sf_plan with event data queried from songkick postgres db
sf_plan@data <- left_join(sf_plan@data, by_neighborhood)
sf_plan@data <- left_join(sf_plan@data, terms)
sf_plan@data <- left_join(sf_plan@data, genres)
sf_plan@data$neighborhood <- factor(sf_plan@data$neighborhood)

# output prepared data for use in global.R --> server.R and ui.R
saveRDS(all_events, file = "data/all_events.rds")
saveRDS(sf_plan, file = "data/master.rds")
saveRDS(venues, file = "data/venues.rds")