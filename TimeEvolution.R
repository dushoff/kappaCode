library(shellpipes)
loadEnvironments()

library(dplyr)
library(patchwork)
library(tidyr)
library(deSolve)
library(purrr)

startGraphics(width=5, height=3)

library(ggplot2); sourceFiles()
txlabel <- "Time"
incidence <- (straightSim |> drop_na() |> 
								ggplot(aes(mid_time, inc, color = as.factor(B0)))
							+ geom_line()
							+ labs(x = txlabel
										 , y = "Incidence"
										 , color = bquote(R[0])
							)
)
susceptible <- (straightSim  |> 
								ggplot(aes(time, x, color = as.factor(B0)))
							+ geom_line()
							+ labs(x = txlabel
										 , y = "Susceptible"
										 , color = bquote(R[0])
							)
)

infectious <- (straightSim  |> 
								ggplot(aes(time, y, color = as.factor(B0)))
							+ geom_line()
							+ labs(x = txlabel
										 , y = "Infectious"
										 , color = bquote(R[0])
							)
)
############### Final Plot #############
cohortFig <- (incidence   + susceptible)

print(cohortFig 
			+ plot_annotation(tag_levels ="a", tag_suffix  = ")")
			 + plot_layout(guides = "collect")
)

#saveEnvironment()
