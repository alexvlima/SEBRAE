#################
### LIBRARIES ###
#################

library(rpivotTable)
library(shiny)

###########
### APP ###
###########

load("base_pnadc.RData")

ui = fluidPage(
      rpivotTableOutput("tabela_dinamica")
)



server = function(input, output) {
  output$tabela_dinamica <- rpivotTable::renderRpivotTable({
    change_locale(
      rpivotTable(
        data = base_pnadc, 
        rows = "UF",
        cols="trimestre_ano",
        vals = "V1028", 
        aggregatorName = "Soma como Fra\u00e7\u00e3o da Coluna", 
        rendererName = "Tabela",
        width="100%", 
        height="100%"),
      "pt")
  })
}


shinyApp(ui = ui, server = server)

