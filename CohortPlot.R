library(shellpipes)
loadEnvironments()

library(dplyr)
library(patchwork)
library(tidyr)
library(deSolve)
library(purrr)
startGraphics(width=5, height=6)
library(ggplot2); sourceFiles()

res_mat <- res_mat |> mutate(across(where(is.list), unlist))
res_mat_mutated <- (res_mat|> mutate(B0 = as.factor(B0)	,
                                     stdv = sqrt(varRc),
                                     scaledCohort = cohort/tpeak
				)
                   )
########### Rc and kappa_c over time #########
cohortXlabel <- bquote("Cohort infection time (t"~"/"~t[peak]~")")


mu_Rc <- (ggplot(res_mat_mutated)
		    + geom_line(aes(scaledCohort, Rc, color = B0))
		    + geom_vline(xintercept = 1)
		    + guides(color = "none") 
		    + labs(x = NULL
			 , y = "Mean expected\ninfectiousness"
			   )
                  )

### kappa
kappa_Rc <- (res_mat_mutated
		 |>mutate(kappaRc = (varRc/Rc^2))
			|>	ggplot()
				+ geom_line(aes(scaledCohort, kappaRc, color = B0))
				+ geom_hline(yintercept = 1)
				+ geom_vline(xintercept = 1)
				+ guides(color = "none") 
				+ labs(x = NULL
				     ,  y = bquote(atop("Unweighted",kappa["within"]))
					)
            )

### incidence 
outbreak <- (straightSim |> group_by(B0) |> arrange(time, .by_group = TRUE)
                     |> mutate(cohortSize = lead(instantaneous_inc),
                               scaledTime = time/tpeak) |>
                       ungroup() |> mutate(B0 = as.factor(B0))
)
incidence <- (outbreak |> 
			ggplot(aes(scaledTime, cohortSize, color = B0))
			+ geom_line()
			+ geom_vline(xintercept = 1)
			+ labs(x = NULL
			, y = "Cohort size"
			, color = bquote(R[0])
			)
                        + scale_y_continuous(labels = scales::label_scientific())
            )
### adding panels d
merged_df <- merge(straightSim, res_mat,
                   by.x = c("time","B0", "tpeak") ,
                   by.y = c("cohort", "B0", "tpeak"))

moveup_merged_df <- (merged_df |> group_by(B0) |> arrange(time, .by_group = TRUE)
                      |> mutate(cohortSize = lead(instantaneous_inc),
                                within_kp = cohortSize*varRc/Rc^2,
                                within_var = cohortSize*varRc,
                                scaled_time = time/tpeak) |>
                         ungroup() |> mutate(B0 = as.factor(B0))
)
shortSim <- straightSim |> 
               group_by(B0) |> 
               summarise(final_size = max(cum), .groups = "drop") |> 
               mutate(B0 = as.factor(B0))
moveup_merged_df <- moveup_merged_df |> left_join(shortSim, by = "B0")
within_variance <- (moveup_merged_df |> 
                          ggplot(aes(scaled_time, within_var/final_size, color = B0))
                        + geom_line()
                        + geom_vline(xintercept = 1)
                        + labs(x = cohortXlabel,
                               y = bquote(atop("Weighted", sigma^2["within"]))
                        )
                        + guides(color = "none") 
                       )
un_within_variance <- (moveup_merged_df |> 
                          ggplot(aes(scaled_time, varRc, color = B0))
                        + geom_line()
                        + geom_vline(xintercept = 1)
                        + labs(x = cohortXlabel,
                               y = bquote(atop("UnWeighted", sigma^2["within"]))
                        )
                        + guides(color = "none") 
                        
)
############### Final Plot #############
cohortFig <- (incidence   / mu_Rc / kappa_Rc / within_variance)

print(cohortFig
     + plot_annotation(tag_levels ="a", tag_suffix  = ")")
     + plot_layout(guides = "collect")
     )


