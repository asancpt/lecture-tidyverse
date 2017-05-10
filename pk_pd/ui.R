library(shiny)
library(ggplot2)

shinyUI(
  fluidPage(
    h2("PharmacoMetrica: Trial Simulator"),
    fluidRow(
      hr(""),
   p("Define the mixed-effect model parameters")  , 
  column(2,
    sliderInput("ka", label ="Ka", value=0.4,min=0.2,max=1.5,step=0.1),
    sliderInput("cl", label ="CL", value=0.08,min=0.02,max=0.2,step=0.01), 
    sliderInput("v", label ="V", value=3,min=0.5,max=5.5,step=0.5)   
    ),
    
column(2,
    sliderInput("ska", label ="Sd(Ka)", value=0.2,min=0.1,max=0.5,step=0.1),
    sliderInput("scl", label ="Sd(CL)", value=0.2,min=0.1,max=0.5,step=0.1), 
    sliderInput("sv", label ="Sd(V)", value=0.2,min=0.1,max=0.5,step=0.1)   
    ),
        
 column(2,
    sliderInput("ke0", label ="ke0", value=0.05,min=0.01,max=0.08,step=0.01),
    sliderInput("emax", label ="emax", value=30,min=20,max=40,step=2), 
    sliderInput("ec50", label ="ec50", value=55,min=25,max=85,step=5)   
    ),
    
 column(2,
    sliderInput("ske0", label ="Sd(ke0)", value=0.2,min=0.1,max=0.4,step=0.1),
    sliderInput("semax", label ="Sd(emax)", value=0.2,min=0.1,max=0.4,step=0.1), 
    sliderInput("sec50", label ="Sd(ec50)", value=0.2,min=0.1,max=0.4,step=0.1)   
    ),                          

      hr("")
             ),
                                                                                 
    fluidRow(plotOutput("xyplot")) ,
    p("Define the dosage regimen"),
  column(2,sliderInput("ldose", label ="Loading dose", value=150,min=0,max=400,step=10)) ,
  column(2,sliderInput("mdose", label ="Maintenance dose", value=150,min=0,max=300,step=10)),    
   column(2,sliderInput("tau", label ="Dosing interval", value=24,min=12,max=48,step=12))  
        
        ))