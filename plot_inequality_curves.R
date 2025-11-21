library(shellpipes)
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)
loadEnvironments()
startGraphics(height = 6, width = 9)


#from spreadHelpers 
makeP <- function(rate){rate/(1+rate)}

# parms
beta1 <- 1.5
beta2 <- 8
gamm <- 1
act1 <- beta1/gamm
act2 <- beta2/gamm
n  <- 100
numBeta <- 2

# creating secondary distribution for inequality plot using cumulative distribution
list_df <- list()
for (l in 1:numBeta) {
  actd  <- get(paste0("act", l))
  probS <- makeP(1 / actd)
  meanP <- (1 - probS) / probS
  for ( x in -1:n){
    xs = -1:x
    j  <- sum(xs * dgeom(x =xs, prob = probS))
    val   <- 1 - j / meanP #fraction of cases due to those infecting more than x
    frac  <- 1 - pgeom(x, prob = probS) #fraction of those infecting more than x
    
    list_df[[x+2]] <- data.frame(val = val,
                                 frac = frac,
                                 distType = "secondary",
                                 distParms = as.character(l))
  }
  assign( paste0("df_",l),
          do.call(rbind,list_df))
}
df<-do.call(rbind,(mget(paste0("df_",1:numBeta))))

for (l in 1:numBeta) {
  actd  <- get(paste0("act", l))
  rate <- (1 / actd)
  xvect <- seq(from=0, to=n, by = 0.01)
  val   <- (1 + rate*xvect)* exp(-rate*xvect)
  frac  <- exp(-rate*xvect)
  df_exp <- 
    data.frame(val = val,
               frac = frac,
               distType = "activity",
               distParms = as.character(l))
  
}

df<-rbind(df,df_exp)


##### plotting section ####
ineqDeadPlot <- df |> ineq()


( ineqDeadPlot + theme(legend.position = "none")
  )  +
  plot_annotation(tag_levels = 'a', tag_suffix = ") ")

