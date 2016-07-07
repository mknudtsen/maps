library(shiny)
library(leaflet)
library(RColorBrewer)
library(dplyr)
library(lubridate)
library(highcharter)

### global map settings 
# custom palette from color brewer for categorical data
brewer_light = c("#8dd3c7", "#ffffb3", "#bebada", "#fb8072", "#80b1d3", "#fdb462")
brewer_solid = c('#1b9e77','#d95f02','#7570b3','#e7298a','#66a61e','#e6ab02')

# set palette for chloropleth
factpal <- colorFactor(
  palette = brewer_solid,
  domain = sfspatial$genre1
)

### begin shiny server
shinyServer(function(input, output) {
  
  v <- reactiveValues(vid = T)
  
  venue_select <- reactive({
    id <- input$map_marker_click$id
    v$vid <- T
    return(id)
  })
  
  # details title panel (all venues or venue based on click)
  output$context <- renderUI({
    id <- venue_select()
    if(!is.null(id) && v$vid == T) {
      venue <- venues %>% filter(venue_id == id) %>% select(venue)
      tagList(
        h3(venue),
        actionLink("all", "All Venues")
      )
    } else {
      h3("All Venues")
    }
  })
  
  ### table outputs in details
  output$upcoming <- renderTable({
    print(top_upcoming())
  }, include.rownames = F, include.colnames = F)
  
  output$popular <- renderTable({
    print(most_popular())
  }, include.rownames = F, include.colnames = F)
  
  # map output -- set all options here
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.PositronNoLabels") %>%
      setView(lng = -122.417, lat = 37.7785, zoom = 13) %>%
      addPolygons(
        data = sfspatial,
        layerId = ~ neighborhood,
        # fillColor = ~ factpal(genre1), "#b2aeae"
        color = ~ factpal(genre1),
        fillOpacity = 0.5,
        weight = 1,
        smoothFactor = 1
      ) %>%
      addLegend(
        layerId = "legend",
        position = "bottomleft",
        pal = factpal,
        values = sfspatial$genre1,
        title = "Most popular genre by neighborhood",
        opacity = 0.5
      ) %>%
      addCircleMarkers(
        data = venues,
        lat = ~ lat,
        lng = ~ lng,
        radius = ~ ifelse(description == "Venue", 10, 5),
        color = "navy",
        layerId = ~ venue_id,
        popup = ~ venue,
        stroke = T
      ) 
  })
  

### Reactive functions to process events
  events_cleaned <- reactive({
    all_events %>%
      mutate(len = nchar(artist)) %>%
      filter(billing_index == 1, date >= Sys.Date(), city == 'San Francisco', len < 30) %>%
      mutate(date_format = paste0(format(date, "%d"), " ", month(date, label = T, abbr = T))) %>%
      distinct(artist) 
  })
  
  events_all <- reactive({
    all_events %>%
      filter(city == 'San Francisco')
  })
  
  top_upcoming <- reactive({
    id <- input$map_marker_click$id
    if(!is.null(id) && v$vid == T) {
      events_cleaned() %>%
        filter(venue_id == id) %>%
        arrange(date, desc(popularity)) %>%
        select(date_format, artist)  %>%
        head(6)
    } else {
      events_cleaned() %>%
        arrange(date, desc(popularity)) %>%
        mutate(text = paste0(artist, " at ", venue)) %>%
        select(date_format, text) %>%
        head(6)
    }
  })
  
  most_popular <- reactive({
    id <- input$map_marker_click$id
    if(!is.null(id) && v$vid == T) {
      events_cleaned() %>%
        filter(venue_id == id) %>%
        arrange(desc(popularity)) %>%
        select(date_format, artist) %>%
        head(3)
    } else {
      events_cleaned() %>%
        arrange(desc(popularity)) %>%
        mutate(text = paste0(artist, " at ", venue)) %>%
        select(date_format, text) %>%
        head(3)
    }
  })
  
  chart_data <- reactive({
    data <- events_all()
    id <- input$map_marker_click$id
    if(!is.null(id) && v$vid == T) { 
      data <- data %>% filter(venue_id == id) 
    }
    chart_data <- data %>%
      filter(!is.na(genre)) %>%
      count(genre) %>%
      arrange(desc(n)) %>%
      head(8)
    return(chart_data)
  })
  
  output$chart <- renderHighchart({
    data <- chart_data()
    hc <- highchart() %>%
      hc_plotOptions(
        lang = list(
          noData = T
        )
      ) %>%
      hc_chart(type = "column") %>%
      hc_title(text = "Count of artists by genre",
               verticalAlign = "top",
               style = list(
                 "fontSize" = "10px"
               )) %>%
      hc_yAxis(visible = F) %>%
      hc_legend(enabled = F) %>%
      hc_xAxis(categories = data$genre) %>%
      hc_add_series(name = "Genre", data = data$n, color = "rgb(0, 0, 128)")
    return(hc)
  })
  
  output$event_table <- DT::renderDataTable({
    df <- events_all() %>%
      filter(
        billing_index == 1,
        is.null(input$neighborhoods) | neighborhood %in% input$neighborhoods,
        is.null(input$venues) | venue %in% input$venues
      ) %>%
      select(event_id, date, venue, city, neighborhood, artist, genre, term,
             popularity, familiarity, discovery)
  })
  
  observeEvent(input$all, {
    v$vid <- F
  })
  

})
