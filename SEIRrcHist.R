library(shellpipes)
library(dplyr)
loadEnvironments()
library(ggplot2); theme_set(theme_bw()
                            + theme(
                            axis.title.x = element_text(size = xlabelFontSize)
                            , axis.title.y = element_text(size = ylabelFontSize))
)

startGraphics() 

label_wrap_beta <- function(x) {
    paste("R0 =",x)
  }

label_wrap_lambda <- function(x) {
    paste("lambda ==", x)}

smrRes<- IBM_v1_results_rep |> 
   group_by(beta, lambda) |> 
    summarise(mean = mean(num_cases, na.rm = TRUE),
              variance = var(num_cases, na.rm = TRUE),
              .groups = "drop"
               ) |>
                 mutate(beta = factor(beta),
                        lambda = factor(lambda))
print(smrRes)
cPlot <- ( IBM_v1_results_rep |> mutate(beta = factor(beta),
                                        lambda = factor(lambda)) |>  ggplot() +
	 aes(num_cases, after_stat(prop), fill=beta)
	+ geom_bar()
	+ xlab("Secondary cases")
	+ ylab("Proportion")
	+ facet_grid(beta~lambda , scales = "free",
	             labeller = labeller(
	  beta = as_labeller(label_wrap_beta),
	  lambda = as_labeller(label_wrap_lambda, default = label_parsed)
	)
	  )
		+ geom_text(data = smrRes,
	            aes(x = Inf, y = Inf,
	             label = sprintf("atop(sigma^2==%.2f)",variance)
	             ),
	            parse = TRUE,
	            inherit.aes = FALSE,
	            hjust = 1,
	            vjust = 1)
+ scale_fill_viridis_d(option = "D")
+ guides(fill= "none")
)
rcHistplot<- cPlot
print(cPlot)

rdsSave(rcHistplot)
