library(shellpipes)
loadEnvironments()

library(dplyr)
library(patchwork)
library(tidyr)
library(deSolve)
library(purrr)

startGraphics(width=10, height=5)

library(ggplot2); sourceFiles()
res_mat <- res_mat |> mutate(across(where(is.list), unlist))
res_mat_mutated <- (res_mat
										|> mutate(B0 = as.factor(B0)
															,stdv = sqrt(varRc)
															,scaledCohort = cohort/tpeak
										)
)
########### Rc and kappa_c over time #########
cohortXlabel <- bquote("rescaled time (t"~"/"~t[peak]~")")


res_mat_mutated_3 <- (res_mat_mutated
											|>	pivot_longer(cols=c(Rc, stdv)
																			, names_to = "source"
																			, values_to = "quantity" )
)

mu_and_sigma_Rc <- (ggplot(res_mat_mutated_3)
										# + geom_point(aes(scaledCohort, quantity
										# 								 , color = B0
										# 								 , shape = source) )
										+ geom_line(aes(scaledCohort, quantity
																		, color = B0
																		, linetype = source))
										+ geom_hline(yintercept = 1)
										+ geom_vline(xintercept = 1)
										+ guides(color = "none") 
										+ labs(x = cohortXlabel
													 , y = "Cases per case"
										)
										# + scale_shape_manual(
										# 	values = c("Rc" = muRcShape, "stdv" = stdvShape)
										# 	, labels = c("Rc" = bquote(mu), "stdv" = bquote(sigma))
										# 	, name = "statistics"
										# )
										+ scale_linetype_manual(
											values = c("Rc" = "solid", "stdv" = "dashed")
											, labels = c("Rc" = bquote(mu), "stdv" = bquote(sigma))
											, name = "statistics"
										)
)

### incidence 
incidence <- (straightSim |> drop_na() |> mutate(scaledTime = mid_time/tpeak) |>
								ggplot(aes(scaledTime, inc, color = as.factor(B0)))
							+ geom_line()
							+ geom_vline(xintercept = 1)
							+ labs(x = cohortXlabel
										 , y = "Incidence"
										 , color = bquote(R[0])
							)
)

############### Final Plot #############
cohortFig <- (incidence + mu_and_sigma_Rc
)

print(cohortFig 
			+ plot_annotation(tag_levels ="a", tag_suffix  = ")")
			 + plot_layout(guides = "collect")
)

#saveEnvironment()
