#-----------------------------------------------------------
#  PharmacoMetrica France
#====================================================================
library(deSolve)
library(doBy)
library(shiny)
library(devtools)
#====================================================================

#.... sumfun .... compute median and percentiles
  sumfun <- function(x, ...){
    c(m=median(x, ...), q= quantile(x,c(0.025,0.975)))}
 sumfun1 <- function(x, ...){
    c(m=max(x, ...))}    
shinyServer(function(input,output){
  
output$xyplot = renderPlot({
#====================================================================
#....................................................................
#.............. Population PK/PD model ..............................
#....................................................................

model <- function(t, Y, parameters) {
   with (as.list(parameters),{
     kel = cl/v
     dy1 = -ka*Y[1]
     dy2 = ka*Y[1]-kel*Y[2]
     cp = Y[2]/v
     dy3= ke0*(cp-Y[3])
     list(c(dy1, dy2, dy3))
     })}


#====================================================================
#.... Simulation parameter setting ..................................

#.... number of simulated subjects
   nsim = 20
#.....  treatment effect ................................................
   delta=-15
#.....  safety margin ...................................................
   cp_max = 100

#====================================================================
#.... define the dosage regimen ....
   ndose = 12      #.... number of doses
   follow = 4      #.... number of tau time-intervals after the last dose
   tau = input$tau        #.... dosing interval

    ndose[tau==24]=10
    ndose[tau==12]=20
    ndose[tau==36]=7
    ndose[tau==48]=5
    maxt=ndose*tau+follow*tau
    lastt=tau*(ndose-1)

  #.... define the times of dose eadmin & dose values (dos_time & dos_val) ....
   dos_time =seq(0, tau*(ndose-1), by = tau)
   ldose=input$ldose
   mdose=input$mdose
   dos_val=c(ldose,rep(mdose,ndose-1))
 #  dos_val=c(rep(150,6),rep(0,2),rep(150,ndose-8))

  tit=toString(dos_val)

#====================================================================
#------ PK parameter distributions ----------------
   ka = input$ka
     ka_s = input$ska
   cl = input$cl
     cl_s = input$scl
   v = input$v
     v_s = input$sv
#------ PD parameter distributions ----------------
   ke0 = input$ke0
     ke0_s = input$ske0
   emax = input$emax
     emax_s =input$semax
   ec50 = input$ec50
     ec50_s = input$sec50
   bas = 30
     bas_s = 0.2
#..................................................
#--------Estimate the peak time ---------------------
        
   ke <- cl/v
   tmax <- round(log(ka/ke)/(ka-ke))

#====================================================================
#-------- Define the sampling times ------------------
#  a1 = c(seq(0,2*tmax,by=3.5),seq(2*tmax,tau,by=4))
#  aa1 = c(seq(0,tau,by=1))
#  times=a1
#  for (i in 1:(ndose+follow-1))
#   {
#   times <-c(times,aa1+tau*i)
#   }
   times=seq(0,maxt,1)
#====================================================================
#---------- Generate log-normally distributed parameter values ------
#--------------------------------------------------------------------
  set.seed(183456)
  ss<-data.frame(id=1:nsim,ka=1,cl=1,v=1,ke0=1,emax=0,ec50=0)
  k<-0
  for (i in 1:nsim)
  {
    k<-k+1
    #------ PK -------------------------
    ss$ka[k] = ka*exp(rnorm(1,0,ka_s))
    ss$cl[k] = cl*exp(rnorm(1,0,cl_s))
    ss$v[k] = v*exp(rnorm(1,0,v_s))
    ss$ke0[k] = ke0*exp(rnorm(1,0,ke0_s))
    #------ PD -------------------------
    ss$emax[k] = emax*exp(rnorm(1,0,emax_s))
    ss$ec50[k] = ec50*exp(rnorm(1,0,ec50_s))
    ss$bas[k] = bas*exp(rnorm(1,0,bas_s))
  }


#====================================================================
#--------------------------------------------------------------------
   ni <- length(times)
   ntot <- ni*nsim
#--------------------------------------------------------------------
   eventdat <- data.frame(
       var=rep("X",ndose),      #-- doses are applied to variable X
       time =dos_time,          #-- time of doses
       value=dos_val,           #-- values of doses
       method=rep("add",ndose)) #-- superposition

  d<-NULL
  for (i in 1:nsim)
  {
   dd <- data.frame(time=times,y=1,id=i,ce=0,eff=0)
   
   vol = ss$v[i]
   cle = ss$cl[i]
   ke = ss$ke0[i]
   kab = ss$ka[i]
   emax= ss$emax[i]
   ec50= ss$ec50[i]
   bas = ss$bas[i]
 
   yini <- c(X=0,Y=0,Z=0)
   parameters <- c(ka=kab, cl=cle ,v=vol,ke0=ke)

   out <- ode(y = yini, times = times, func = model,
             parms = parameters,method="lsoda",
             event=list(data=eventdat))
    
   dd$y    <- out[,3] /vol
   dd$ce   <- out[,4]
   dd$eff  <- bas - emax*dd$ce /(ec50+dd$ce)
   d <-rbind(d,dd)
   }


#---- Compute median and perentiles of the simulated PK and PD values ----
  med<-summaryBy(y+eff~time ,data=d,FUN=sumfun)
  colnames(med)<-c("TIME","Cp_med","Cp_p5","Cp_p95","Eff_med","Eff_p5","Eff_p95")

  
  xxl <- c(0,max(med$TIME))
  yyl <- c(0,max(med$Cp_p95))
     lw <- 2
 #    cs <- .9
     cx <- 1.8
     cla=1.6
#--  plots  --------------------
   par(mfrow=c(1,3))
   tit1 <-"PK/PD Monte Carlo Simulation"
  plot(med$TIME,med$Cp_med,
    ylim=yyl,xlim=xxl, xlab="Time (hr)",ylab="Conc. (g/mL)",type="l",
     cex.axis=cx,cex.lab=cla,col="blue",lwd=lw,lty=1,pch=15,cex=cx)
   xx1<-med$TIME
   yy1<-(med$Cp_p5)
   yy2<-(med$Cp_p95)
   yy3<-(med$Cp_med)
   cl<-"#BEBEBE60"  #"yellow"
   polygon(c(xx1,rev(xx1)), c(yy1,rev(yy2)),col = cl,border=cl)
   lines (xx1,yy3, col="blue",lwd=lw,lty=1)
   title(tit1,cex.main=1.5,font.main=1)
   
   par(new=T)
   plot(med$TIME,med$Eff_med,
     ylim=yyl,xlim=xxl, xlab="",ylab="",type="l",
     cex.axis=cx,cex.lab=cla,col="blue",lwd=lw,lty=1,pch=15,cex=cx)
   axis(4, pretty(c(0, max(med$Eff_p95))), col='red',ylab="Effect",
   cex.axis=cx,cex.lab=cla)
   xx1<-med$TIME
   yy1<-(med$Eff_p5)
   yy2<-(med$Eff_p95)
   yy3<-(med$Eff_med)
   cl<-'#EEAAAB40'
   polygon(c(xx1,rev(xx1)), c(yy1,rev(yy2)),col = cl,border=cl)
   lines (xx1,yy3, col="red",lwd=lw,lty=1)

   m0=subset(med,TIME==0)
   p5=m0$Eff_p5
   p95=m0$Eff_p95
   pmed=m0$Eff_med
   abline(h=c(p5,pmed,p95),lty=2,col="black",lwd=2)
   grid(NULL, NULL, lwd = 1)
#----------------------------------------------------
#------  Compute clinical response ------------------
   d_plac=subset(d,time==0)
   d_plac=subset(d_plac,select=c("id","eff"))
   d_eff=subset(d,time==240)
   d_eff=subset(d_eff,select=c("id","eff"))
   d_res= merge(d_plac ,d_eff, by=c("id"),all=F)
   d_res$effect=d_res$eff.y-d_res$eff.x

#..... test treatment response .................................
    tr_resp=d_res$effect-delta
    t1 = t.test(tr_resp,var.equal=TRUE, paired=FALSE)
    tval=formatC(t1$statistic,digits=1,format="f")
    tp=formatC(t1$p.value,digits=4,format="f")
    m=formatC(mean(d_res$effect),digits=2,format="f")
    sd=formatC(sd(d_res$effect),digits=2,format="f")
    mt=formatC(mean(tr_resp),digits=2,format="f")
    sdt=formatC(sd(tr_resp),digits=2,format="f")
    stat1=paste("Mean effect[sd]: ",m,"[",sd,"]",sep="")
    stat2=paste("Mean diference from delta[sd]: ",
     mt,"[",sdt,"],t=",tval,", P<",tp,sep="")

#............ compute the probabity of achieving a given effect ................
    prop=subset(d_res,effect<=delta)
    prob=100*nrow(prop)/nrow(d_res)
    prob =formatC(prob,digits=1,format="f")
    text=paste("Prob of reaching efficacy = ",
     prob,"%  \n [Delta <=",delta," at day 10]",sep="")
    
    par(new=F)
    hist( d_res$effect, breaks=5,
      col = "#BEBEBE60",
      probability = "TRUE", cex.axis=cx,
      xlab="Treatment Effect", main=text, cex.lab=cla, cex.main=1.5,font.main=1,
      ylim = c(0, 1.4*max(density(d_res$effect)$y)))
    lines(density(d_res$effect),
      col = "red",
      lwd = 3)
      abline(v=delta,lty=2,col="blue",lwd=4)
    grid()
   
#.............................................................................
#............ Estimate safety risk .................................................
   saf=subset(d,time>lastt)
   cmx<-summaryBy(y~id ,data=saf,FUN=sumfun1)
#............ Compute the probability of exceeding the safety margin  ..................
   prop=subset(cmx,y.m>cp_max)
   prob=100*nrow(prop)/nsim
   prob =formatC(prob,digits=1,format="f")
   text=paste("Prob > safety margin = ",
    prob,"%  \n [Cp_max =",cp_max,"]",sep="")
   par(new=F)
    hist( cmx$y.m, breaks=5,
      col = "yellow",
      probability = "TRUE", cex.axis=cx,
      xlab="Max conc (ng/mL)", main=text, cex.lab=cla, cex.main=1.5,font.main=1,
      ylim = c(0, 1.4*max(density(cmx$y.m)$y)))
    lines(density(cmx$y.m),
      col = "blue",
      lwd = 3)
      abline(v=cp_max,lty=2,col="blue",lwd=4)
    grid()
    
    
   })
})