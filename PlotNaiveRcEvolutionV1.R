library(shellpipes)
loadEnvironments()

library(dplyr)
library(patchwork)
library(tidyr)
library(deSolve)
library(purrr)

startGraphics(width=10, height=5)

library(ggplot2); sourceFiles()
############### Time Plot ########################
res_mat_mutated <- (res_mat
										|> mutate( B0 = as.factor(B0)
															 , KRc_within = within/muRc^2
															 , KRc_bet = between/muRc^2
															 , stdv = sqrt(totalVRc)
										)
)
########### Rc and kappa_c over time #########
cohortXlabel <- bquote("rescaled time (t"~"/"~t[peak]~")")

res_mat_mutated_2 <- (res_mat_mutated
											|>	pivot_longer(cols=c(KRc_within, KRc_bet
																						 # ,total_KRc
											)
											, names_to = "source"
											, values_to = "KRc_splitted" )
)


kappa_Rc <- (ggplot(res_mat_mutated_2)
						 + geom_point(aes(cutoffTime, KRc_splitted, color = B0
						 								 , shape = source) )
						 + geom_line(aes(cutoffTime, KRc_splitted, color = B0
						 								, linetype = source  ))
						 + geom_vline(xintercept = 1)
						 + geom_hline(yintercept = 1)
						 + guides(color = "none") 
						 + labs(x = cohortXlabel
						 			 , y = bquote(kappa)
						 )
						 + scale_shape_manual(
						 	values = c("KRc_bet" = kbetShape, "KRc_within" = kwithShape)
						 	, labels = c("KRc_bet" = bquote(kappa["bet"])
						 							 ,"KRc_within" = bquote(kappa["with"])
						 							 # , "totalKRc" = bquote(kappa)
						 							 
						 	)
						 	, name = "source"
						 )
						 + scale_linetype_manual(
						 	values = c("KRc_bet" = "solid", "KRc_within" = "dashed")
						 	, labels = c("KRc_bet" = bquote(kappa["bet"])
						 							 ,"KRc_within" = bquote(kappa["with"])
						 )
						 , name = "source")
						
)

res_mat_mutated_3 <- (res_mat_mutated
											|>	pivot_longer(cols=c(muRc, stdv)
																			, names_to = "source"
																			, values_to = "quantity" )
)

mu_and_sigma_Rc <- (ggplot(res_mat_mutated_3)
										+ geom_point(aes(cutoffTime, quantity
																		 , color = B0
																		 , shape = source) )
										+ geom_line(aes(cutoffTime, quantity
																		, color = B0
																		, linetype = source))
										+ geom_hline(yintercept = 1)
										+ geom_vline(xintercept = 1)
										+ guides(color = "none") 
										+ labs(x = cohortXlabel
													 , y = "Cases per case"
										)
										+ scale_shape_manual(
											values = c("muRc" = muRcShape, "stdv" = stdvShape)
											, labels = c("muRc" = bquote(mu), "stdv" = bquote(sigma))
											, name = "statistics"
										)
										+ scale_linetype_manual(
											values = c("muRc" = "solid", "stdv" = "dashed")
											, labels = c("muRc" = bquote(mu), "stdv" = bquote(sigma))
											, name = "statistics"
										)
)

### incidence 
incidence <- (straightSim  |> mutate(scaledTime = time/tpeak) |>
								ggplot(aes(scaledTime, inc, color = as.factor(B0)))
							+ geom_line()
							+ geom_vline(xintercept = 1)
							+ labs(x = cohortXlabel
										 , y = "Incidence"
										 , color = bquote(R[0])
							)
)

############### Final Plot #############
cohortFig <- (incidence + mu_and_sigma_Rc + kappa_Rc
)

print(cohortFig 
			+ plot_annotation(tag_levels ="a", tag_suffix  = ")")
			 + plot_layout(guides = "collect")
)

#saveEnvironment()
