library(shellpipes)
library(dplyr)
library(ggplot2); theme_set(theme_bw())

startGraphics(height=3) 
loadEnvironments()

label_wrap <- function(wrap_level) {
  sapply(wrap_level,function(x){
    paste("R0 =",x)
  })}

cPlot <- ( 
          ggplot(IBM_v1_results_rep) +
	 aes(num_cases, after_stat(prop))
	+ geom_bar()
	+ xlab("Secondary cases per infector")
	+ ylab("Density")
	+ facet_wrap(~beta ,labeller = labeller(beta = function(x){
	  label_wrap(x)}))
)
rcHistplot<- cPlot
print(cPlot)

rdsSave(rcHistplot)
