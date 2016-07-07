library(shiny)
library(leaflet)
library(highcharter)


shinyUI(navbarPage("Live Events in San Francisco", id = "nav",
                   
  tabPanel("Interactive Map",
    div(class = "outer",
        
        tags$head(
         # include custom css
          includeCSS("styles.css"),
          #includeScript("gomap.js")
          tags$script(src="nodata.js")
        ),
        
        leafletOutput("map", width = "100%", height = "100%"),
        
        absolutePanel(id = "details", class = "panel panel-default", fixed = TRUE,
          draggable = FALSE, top = 60, left = "auto", right = 20, bottom = "auto",
          width = 360, height = "auto",
          
          uiOutput("context"),
          hr(),
          h6("Top Upcoming"),
          div(tableOutput("upcoming"), class="mytable"),
          h6("Most Popular"), 
          div(tableOutput("popular"), class="mytable"),
          highchartOutput("chart", width = "100%", height = "220px")

          
        ),
        
        tags$div(id = "cite",
          'Data from Songkick and Echonest.'
        )
    )
  ),
  
  tabPanel("Data Explorer",
    fluidRow(
      # column(3,
      #   selectInput("neighborhoods", "Neighborhoods", c("All" = ""), multiple = TRUE)
      # ),
      # column(3,
      #   conditionalPanel("input.neighborhoods",
      #     selectInput("venues", "Venues", c("All" = ""), multiple = TRUE)
      #   )
      # )
    ),

    fluidRow(
    ),

    hr(),
    DT::dataTableOutput("event_table")
  )

))
