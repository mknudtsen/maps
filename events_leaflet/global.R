library(dplyr)
source("data.R")


# read in rds data (queried from postgres and then saved)
all_events <- readRDS("data/all_events.rds")
sfspatial <- readRDS("data/master.rds")
venues <- readRDS("data/venues.rds")

# clean and transform variables for all_events
all_events$date <- as.Date(all_events$date, "%Y-%m-%d")

venues$venue <- ifelse(venues$venue == 'Bill Graham Civic Auditorium', "Bill Graham", venues$venue)
venues$venue <- ifelse(venues$venue == 'Great American Music Hall', "Great American", venues$venue)
venues$venue <- ifelse(venues$venue == 'Safehouse for the Performing Arts', "Safehouse", venues$venue)
venues$venue <- ifelse(venues$venue == 'California Academy of Sciences', "Academy of Sciences", venues$venue)
venues$venue <- ifelse(venues$venue == 'Brick & Mortar Music Hall', "Brick & Mortar", venues$venue)
venues$venue <- ifelse(venues$venue == 'Gray Area Art & Technology Theater', "Gray Area", venues$venue)

all_events$venue <- ifelse(all_events$venue == 'Bill Graham Civic Auditorium', "Bill Graham", all_events$venue)
all_events$venue <- ifelse(all_events$venue == 'Great American Music Hall', "Great American", all_events$venue)
all_events$venue <- ifelse(all_events$venue == 'Safehouse for the Performing Arts', "Safehouse", all_events$venue)
all_events$venue <- ifelse(all_events$venue == 'California Academy of Sciences', "Academy of Sciences", all_events$venue)
all_events$venue <- ifelse(all_events$venue == 'Brick & Mortar Music Hall', "Brick & Mortar", all_events$venue)
all_events$venue <- ifelse(all_events$venue == 'Gray Area Art & Technology Theater', "Gray Area", all_events$venue)
all_events$venue <- ifelse(all_events$venue == 'Miner Auditorium, SFJAZZ Center', "Miner Auditorium", all_events$venue)

all_events$city <- as.factor(all_events$city)
all_events$zip_code <- as.integer(all_events$zip_code)
all_events$neighborhood <- as.factor(all_events$neighborhood)
all_events$familiarity <- as.numeric(all_events$familiarity)
all_events$hotttnesss <- as.numeric(all_events$hotttnesss)
all_events$discovery <- as.numeric(all_events$discovery)
all_events$genre <- ifelse(is.na(all_events$genre1), all_events$genre2, all_events$genre1)
all_events$term <- ifelse(is.na(all_events$term1), all_events$term2, all_events$term1)
all_events <- tbl_df(all_events)

