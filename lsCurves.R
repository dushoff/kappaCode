library(shellpipes)
loadEnvironments()
library(ggplot2);theme_set(theme(axis.title.x = element_text(size = xlabelFontSize)
                                 ,axis.title.y = element_text(size = ylabelFontSize)))
library(dplyr)
library(tidyr)
library(patchwork)
startGraphics(height = 6, width = 9)


n  <- 100
list_df <- list()

for (l in 1:numBeta) {
  # creating secondary distribution for inequality plot using cumulative distribution
  actd  <- act[l]
  probS <- odds2prob(1 / actd)
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
  # creating activity distribution for inequality plot using cumulative distribution
  rate <- (1 / actd)
  xvect <- seq(from=0, to=n, by = 0.01)
  val_exp   <- (1 + rate*xvect)* exp(-rate*xvect)
  frac_exp  <- exp(-rate*xvect)
  df_exp <- 
    data.frame(val = val_exp,
               frac = frac_exp,
               distType = "activity",
               distParms = as.character(l))
}
df<-do.call(rbind,(mget(paste0("df_",1:numBeta))))
df<-rbind(df,df_exp)



##### plotting section ####
ineqDeadPlot <- df |> ineq()

print(ineqDeadPlot 
	## + theme(legend.position = "none"))
	## + plot_annotation(tag_levels = 'a', tag_suffix = ") "
)

rdsSave(ineqDeadPlot)

