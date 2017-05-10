library(shiny)
 
shinyUI(fluidPage(
hr("My first app"),
   numericInput(inputId = "x","Sample size", value = 25),
   plotOutput("distPlot")
) )