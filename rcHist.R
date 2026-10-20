library(shellpipes)
library(dplyr)
loadEnvironments()
library(ggplot2); theme_set(theme_bw()
                            + theme(
                            axis.title.x = element_text(size = xlabelFontSize)
                            , axis.title.y = element_text(size = ylabelFontSize))
)

startGraphics(height=3) 

label_wrap <- function(wrap_level) {
  sapply(wrap_level,function(x){
    paste("R0 =",x)
  })}

smrRes<- IBM_v1_results_rep |> 
  group_by(beta) |> 
  summarise(mean_cases = mean(num_cases, na.rm = TRUE),
            variance_cases = var(num_cases, na.rm = TRUE),
            .groups = "drop"
  ) |>
  mutate(beta = factor(beta),
         kpa = (variance_cases - mean_cases)/mean_cases^2
)

cPlot <- ( IBM_v1_results_rep |> mutate(beta = factor(beta)) |>
          ggplot() +
	 aes(num_cases, after_stat(prop), fill=beta)
	+ geom_bar()
	+ xlab("Secondary cases")
	+ ylab("Proportion")
	+ facet_wrap(~beta ,labeller = labeller(beta = function(x){
	  label_wrap(x)}))
	+ geom_text(data = smrRes,
	            aes(x = Inf, y = Inf - 0.1,
	                label = sprintf("atop(mu==%.2f, kappa==%.2f)",
	                                mean_cases, kpa)
	                ),
	            parse = TRUE,
	            inherit.aes = FALSE,
	            hjust = 1.1,
	            vjust = 1.15)
+ scale_fill_viridis_d(option = "D")
+ guides(fill= "none")
)
rcHistplot<- cPlot
print(cPlot)

rdsSave(rcHistplot)
