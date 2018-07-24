ui <- fluidPage(
  titlePanel("Predição da Arrecadação do Sebrae",
             windowTitle =  "UGE-Sebrae"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput(inputId = "data",
                     label = h3("Selecione o período para o modelo:"),
                     format = "mm/yyyy",
                     language="pt-BR",
                     min = "2013-01-01",
                     max = "2018-04-01",
                     start = "2013-01-01",
                     end = "2018-04-01",
                     startview = "year",
                     separator = " - "),
      numericInput("num", label = h3("Selecione a quantidade de meses de previsões"), 
                   value = 6, min = 1, max = 12),
      useShinyjs(), 
      actionButton("button", "METODOLOGIA (clique)"),
      hidden(
        div(id='text_div',
            verbatimTextOutput("text")))),
     
    mainPanel(
      plotOutput("ARIMA"),
      DT::dataTableOutput("Pred"))))



# SERVER


server <- function(input, output, session){
  
  Dates <- reactiveValues()
  observe({
    Dates$SelectedDates <- c(as.character(format(input$data[1],format = "%m/%Y")),
                             as.character(format(input$data[2],format = "%m/%Y")))
  })
  output$SliderText <- renderText({Dates$SelectedDates})
  output$ARIMA <- renderPlot({
    plot(forecast(auto.arima(ts(base$Valor, 
                                start = c(as.numeric((format(input$data[1],format = "%Y"))),
                                          as.numeric(format(input$data[1],format = "%m"))),
                                end = c(as.numeric((format(input$data[2],format = "%Y"))),
                                        as.numeric(format(input$data[2],format = "%m"))),
                                frequency = 12))
                  , h=input$num), 
         main = "Projeção da Arrecadação do Sebrae",
         xlab = "Ano",
         ylab = "Arrecadação")
  })
  
  output$Pred <- DT::renderDataTable(
    
    data.frame(predict(forecast(auto.arima(ts(base$Valor, 
                                              start = c(as.numeric((format(input$data[1],format = "%Y"))),
                                                        as.numeric(format(input$data[1],format = "%m"))),
                                              end = c(as.numeric((format(input$data[2],format = "%Y"))),
                                                      as.numeric(format(input$data[2],format = "%m"))),
                                              frequency = 12)),h=input$num))
    )
    
  )
  observeEvent(input$button, {
    toggle('text_div')
    output$text <- 
      renderText({"A previsão foi realizada a partir de um modelo auto-regressivo integrado de médias móveis (ARIMA).
Ele apresentou um menor erro quando comparado ao modelo de suavização exponencial Holt-Winters. 
O modelo captou a sazonalidade do mês de Dezembro.
        
Equipe Técnica: 
        Alexandre, 
        Aretha, 
        Luiz Hissashi, 
        Karina, 
        Pedro e 
        Tomaz"})
  })
}


# Create a Shiny app object
shinyApp(ui = ui, server = server)
