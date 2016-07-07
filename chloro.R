library(rgdal)
library(ggplot2)
library(tmap)
library(leaflet)
library(dplyr)
library(RPostgreSQL)

# connect to postgres to query event and artist data
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "songkick2", host = "localhost", port = 5432, user = "mark")
dbExistsTable(con, "event")
query1 <- paste(readLines("data/queries/neighbor_master.sql"), collapse = "\n")
query1
sapply(query1, function(x) dbGetQuery(con, x))
dbGetQuery(con, query1)

# neighborhoods <- readOGR(dsn = ".", layer = "geo_export_6f0779db-f6c3-4307-beba-ef2f9265b77f")
# neighborhoods2 <- spTransform(neighborhoods, CRS("+proj=longlat +datum=WGS84"))

# qtm(shp = sf_plan, text = "neighborho")
# qtm(shp = sf_analysis, text = "nhood")
# qtm(shp = sf_neighbor, text = "neighborho")

qtm(shp = sf_plan, fill = "genre1")


sf_plan <- readOGR(dsn = "shapefiles/sf_planning", layer = "planning_neighborhoods")
sf_analysis <- readOGR(dsn = "sf_analysis", layer = "geo_export_ab474caf-43cf-4b23-b57a-d3312b48d848")
sf_neighbor <- readOGR(dsn = "sf_neighborhoods", layer = "geo_export_6f0779db-f6c3-4307-beba-ef2f9265b77f")

sf_plan <- spTransform(sf_plan, CRS("+proj=longlat +datum=WGS84"))
sf_plan@data <- rename(sf_plan@data, neighborhood = neighborho)

by_neighborhood <- read.csv("data/neighbor_master")
terms <- read.csv("data/neighbor_terms")
genres <- read.csv("data/neighbor_genre")

venues <- read.csv("venues_coord")
venues <- as.data.frame(venues)
head(venues)

sf_plan@data <- left_join(sf_plan@data, genres)
sf_plan@data$neighborhood <- factor(sf_plan@data$neighborhood)

oakland <- readOGR(dsn = "data/oakland", layer = "geo_export_9e48ecdc-29b0-47d7-b740-ba5ef0d08fe2")
plot(oakland)
summary(oakland)


popup <- paste0(sf_plan$neighborhood)
factpal <- colorFactor(
  palette = topo.colors(13),
  domain = sf_plan$term1
)

map <- leaflet() %>%
  addProviderTiles("Stamen.TonerLite") %>%
  addPolygons(data = sf_plan,
              fillColor = ~factpal(term1),
              color = "#b2aeae",
              fillOpacity = 0.5,
              weight = 1,
              smoothFactor = 0.2,
              popup = popup) %>%
  addCircleMarkers(data = venues, 
                   lat = ~ lat, 
                   lng = ~ lng,
                   popup = ~ venue,
                   radius = ~ ifelse(count > 8, 10, 6), 
                   stroke = FALSE, fillOpacity = 0.5)
  # addLegend(pal = pal, 
  #           values = sf_plan$num_events, 
  #           position = "bottomright",
  #           title = "Number of Live Events by Neighborhood") 
map

