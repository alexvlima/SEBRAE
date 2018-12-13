##################
### BIBLIOTECA ###
##################

library(leaflet)
library(tidyverse)
library(shiny)

###############
### DATASET ###
###############

rm(list = ls())

base_alto_impacto <- read.table('20180910-Empresas-Alto-Impacto-Geo.txt',
                                sep = '\t', dec = '.', header = TRUE, na.strings='',quote='')

###################
### MANIPULACAO ###
###################

options(scipen = 14)
glimpse(base_alto_impacto)

base_alto_impacto$Longitude <- gsub(",", "\\.", base_alto_impacto$Longitude)
base_alto_impacto$Latitude <- gsub(",", "\\.", base_alto_impacto$Latitude)

base_alto_impacto$Longitude <- as.numeric(base_alto_impacto$Longitude)
base_alto_impacto$Latitude <- as.numeric(base_alto_impacto$Latitude)


temp <- 
  base_alto_impacto %>%
  filter(is.na(Latitude) == FALSE) %>%
  select(CNPJ_e, razaoSocial, cnaeDescricao, setorIbgeDescricao, municipioNome, uf.x,
         crescMedio, porte2013, CEP, Longitude, Latitude) %>%
  mutate(label = paste("CNPJ:",CNPJ_e,"Razão Social:",razaoSocial,"Porte:",porte2013,"CNAE:",
                       cnaeDescricao,"Setor Econômico:",setorIbgeDescricao, "Município:",
                       municipioNome, "UF:", uf.x, "CEP:", CEP, sep = "\n"))

temp$label <- as.factor(temp$label)

base_geo <- temp

#######################
### MAPA DE CLUSTER ###
#######################

base_geo %>% 
  leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = ~Longitude, lat = ~Latitude, popup = ~label,
             clusterOptions = markerClusterOptions())



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


