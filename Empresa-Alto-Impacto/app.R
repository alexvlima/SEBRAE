##################
### BIBLIOTECA ###
##################

library(leaflet)
library(tidyverse)
library(shiny)

###############
### DATASET ###
###############

load("base_geo.RData")

#################
### SHINY APP ###
#################

### UI ###

ui <- fluidPage(
  leafletOutput("mymap", height = "600px"),
  p()
)

### SERVER ###

server <- function(input, output, session) {
  
  
  output$mymap <- renderLeaflet({
    base_geo %>% 
      leaflet() %>% 
      addTiles() %>% 
      addMarkers(lng = ~Longitude, lat = ~Latitude, popup = ~label,
                 clusterOptions = markerClusterOptions())
  })
}

shinyApp(ui, server)
