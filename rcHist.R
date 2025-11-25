library(shellpipes)
library(dplyr)
library(ggplot2); theme_set(theme_bw())

startGraphics(height=3) 
loadEnvironments()

label_wrap <- function(wrap_level) {
  sapply(wrap_level,function(x){
    paste("R0 =",x)
  })}

cPlot <- ( IBM_v1_results_rep |> mutate(beta = factor(beta)) |>
          ggplot() +
	 aes(num_cases, after_stat(prop), fill=beta)
	+ geom_bar()
	+ xlab("Secondary cases per infector")
	+ ylab("Proportion")
	+ facet_wrap(~beta ,labeller = labeller(beta = function(x){
	  label_wrap(x)}))
+ scale_fill_brewer(palette = "Dark2")
+ guides(fill= "none")
)
rcHistplot<- cPlot
print(cPlot)

rdsSave(rcHistplot)
