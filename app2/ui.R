library(shiny)

shinyUI(
  fluidPage(
    h2("App 2"),
    fluidRow(
  p(" ...   Dosage regimen parameters")  , 
  column(2,
    sliderInput("nd", label ="Number of doses", value=4,min=1,max=10,step=1),
    sliderInput("tau", label ="Dosing interval (hr)", value=24,min=8,max=48,step=8)  
    )  ,
       fluidRow(
        plotOutput("xyplot") )
 ))       )