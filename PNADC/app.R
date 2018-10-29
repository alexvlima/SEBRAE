#################
### LIBRARIES ###
#################

library(rpivotTable)
library(shiny)

# library(tidyverse) 

#####################
### DATASET PNADC ###
#####################
# 
# # PNADC DE 4/2015 ATE 2/2018 #
# 
# base_pnadc <- 
#   read.table(file="20181003-Base-Tratada-Bede-42015-22018.txt", 
#              sep = "\t", dec = ".")
# 
# 
# ##################
# ### MANIPULATE ###
# ##################
# 
# # glimpse(base_pnadc)
# 
# base_pnadc$UF <- gsub('11','RO', base_pnadc$UF)
# base_pnadc$UF <- gsub('12','AC', base_pnadc$UF)
# base_pnadc$UF <- gsub('13','AM', base_pnadc$UF)
# base_pnadc$UF <- gsub('14','RR', base_pnadc$UF)
# base_pnadc$UF <- gsub('15','PA', base_pnadc$UF)
# base_pnadc$UF <- gsub('16','AP', base_pnadc$UF)
# base_pnadc$UF <- gsub('17','TO', base_pnadc$UF)
# base_pnadc$UF <- gsub('21','MA', base_pnadc$UF)
# base_pnadc$UF <- gsub('22','PI', base_pnadc$UF)
# base_pnadc$UF <- gsub('23','CE', base_pnadc$UF)
# base_pnadc$UF <- gsub('24','RN', base_pnadc$UF)
# base_pnadc$UF <- gsub('25','PB', base_pnadc$UF)
# base_pnadc$UF <- gsub('26','PE', base_pnadc$UF)
# base_pnadc$UF <- gsub('27','AL', base_pnadc$UF)
# base_pnadc$UF <- gsub('28','SE', base_pnadc$UF)
# base_pnadc$UF <- gsub('29','BA', base_pnadc$UF)
# base_pnadc$UF <- gsub('31','MG', base_pnadc$UF)
# base_pnadc$UF <- gsub('32','ES', base_pnadc$UF)
# base_pnadc$UF <- gsub('33','RJ', base_pnadc$UF)
# base_pnadc$UF <- gsub('35','SP', base_pnadc$UF)
# base_pnadc$UF <- gsub('41','PR', base_pnadc$UF)
# base_pnadc$UF <- gsub('42','SC', base_pnadc$UF)
# base_pnadc$UF <- gsub('43','RS', base_pnadc$UF)
# base_pnadc$UF <- gsub('50','MS', base_pnadc$UF)
# base_pnadc$UF <- gsub('51','MT', base_pnadc$UF)
# base_pnadc$UF <- gsub('52','GO', base_pnadc$UF)
# base_pnadc$UF <- gsub('53','DF', base_pnadc$UF)

# save(base_pnadc, file='base_pnadc.RData')

# glimpse(base_pnadc)
# 
# base_teste <-
#   base_pnadc %>%
#   filter(UF %in% c("MA","PI","CE","RN","PB","PE","SE","AL","BA"))
# 
# #   select(trimestre_ano, UF, peso = V1028, genero, faixa_etaria, cnpj, rendimento) 
# # 
# #filter(UF %in% c("RO","RR"))
# # 
# save(base_teste, file='base_teste.RData')
# 
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
