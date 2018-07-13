library(deSolve)
library(doBy)
library(shiny)


shinyServer(function(input,output){
  
output$xyplot = renderPlot({
#====================================================================
   sumfun <- function(x, ...){c(s=sum(x, ...),c(n=length(x, ...)))}
#====================================================================
#....................................................................
#...... PK model - oral dose................
#....................................................................

model <- function(t, Y, parameters) {
   with (as.list(parameters),{
     kel = cl/v
     dy1 = -ka*Y[1]
     dy2 = ka*Y[1]-kel*Y[2]
     list(c(dy1, dy2))
     })}

#====================================================================
   nd = input$nd      #.... number of doses
   tau =input$tau
   os_dose=4
   os_dosval=rep(os_dose,nd)  
   dostime=seq(0,tau*(nd-1),tau)
#====================================================================
#------ PK parameter values ----------------
   cl = 0.12
   v = 1.8
   ka=0.15
  
#====================================================================
#-------- Define the sampling times ------------------
  aa1 = c(seq(0,tau,by=0.5)); times=NULL
  for (i in 1:(nd))  {times <-c(times,aa1+tau*(i-1))  }  

#====================================================================
#--------------------------------------------------------------------
   eventdat <- data.frame(
       var=rep("X",nd),       #-- doses are applied to variable X
       time =dostime,              #-- time of doses
       value=os_dosval,              #-- values of doses
       method=rep("add",nd))  #-- superposition

   d <- data.frame(time=times,y=1,id=1)
 
   yini <- c(X=0,Y=0)
   parameters <- c(cl=cl ,v=v,ka=ka)

   out <- ode(y = yini, times = times, func = model,
             parms = parameters,method="lsoda",
             event=list(data=eventdat))
    
   d$y    <- out[,3] /v
   d$time = out[,1]  
   d$n=i
   a=subset(d,time<=max(times))   
#--  plots  --------------------     
  xxl <- c(0,max(times))
  yyl <- c(0,max(a$y))

   plot(a$time,a$y,xlim=xxl,
     xlab="Time (hr)",ylab="Conc. (g/mL)",type="l",ylim=c(0,5),
     col="blue",lwd=2,lty=1)
   grid()   
  
#=============================================================
   })
})          