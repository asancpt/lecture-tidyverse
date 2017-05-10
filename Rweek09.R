# R programming Week 9
# Sungpil Han

Week09 <- c("tidyverse", "shiny", "dplyr", "ggplot2", "rmarkdown", "knitr", "flexdashboard")
#install.packages(Week09)
LibraryWeek09 <- lapply(Week09, library, character.only = TRUE)

#get help with a function
?c

#assign data to a variable
x <- c(77, 66, 88)
mean(x)
max(x)

#charts
plot(x)
barplot(x)
pie(x)

#' Plot navigation
#' export to the clipboard
#' Publish to http://rpubs.com/

# Demo: RStudio

#' - History
#' - Run from the beginneing
#' - Run to the end
#' - Plot
#' 


# Create Shiny Web App

## Examples: shiny

shiny::runApp("Shiny")
shiny::runApp("app0")
shiny::runApp("app1")
shiny::runApp("app2") # install.packages("deSolve")
shiny::runApp("pk_pd") # PMx_2016



## Examples: ggplot2

library(ggplot2)
qplot(displ, hwy, data = mpg)
qplot(displ, hwy, data = mpg, color = drv)
qplot(displ, hwy, data = mpg, geom = c("point", "smooth"))
qplot(hwy, data = mpg, fill = drv)
qplot(displ, hwy, data = mpg, facets = . ~ drv)
qplot(hwy, data = mpg, facets = drv ~ ., binwidth = 2)

maacs <- read.csv("maacs.csv", as.is = TRUE)
str(maacs)

# examples of qplot
qplot(log(eno), data = maacs)
qplot(log(eno), data = maacs, fill = mopos)
qplot(log(eno), data = maacs, geom = "density")
qplot(log(eno), data = maacs, geom = "density", color = mopos)
qplot(log(pm25), log(eno), data = maacs)
qplot(log(pm25), log(eno), data = maacs, shape = mopos)
qplot(log(pm25), log(eno), data = maacs, color = mopos)
qplot(log(pm25), log(eno), data = maacs, color = mopos, geom = c("point", "smooth"), method = "lm")
qplot(log(pm25), log(eno), data = maacs, geom = c("point", "smooth"), method = "lm", facets = . ~ mopos)

# qplot(logpm25, NocturnalSympt, data = maacs, facets = . ~ bmicat, geom = c("point", "smooth"), method = "lm”)


