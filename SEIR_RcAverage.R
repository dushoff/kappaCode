library(shellpipes)
library(ggplot2); theme_set(theme_bw())
library(patchwork)
loadEnvironments()

startGraphics(height=5)

label_wrap <- function(wrap_level) {
  sapply(wrap_level,function(x){
    paste("R0 =",x)
  })}
#stackplot <- rdsRead("stackbar")
rcHistplot <- rdsRead("SEIRrcHist")
 
print(((rcHistplot + theme(legend.position = "none"))) +
				 plot_annotation(tag_levels = 'a', tag_suffix = ")" 
													)
			)

