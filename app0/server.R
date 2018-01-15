library(shiny)

server <- function(input, output) {
    output$distPlot <- renderPlot({
    hist(rnorm(input$x))
    })
  }