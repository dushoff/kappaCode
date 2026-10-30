library(shellpipes)
loadEnvironments()

library(dplyr)
library(patchwork)
library(tidyr)
library(deSolve)
library(purrr)
startGraphics(width=5, height=6)
library(ggplot2); sourceFiles()
maxCohort4Plot <- 3 # to truncate the plot up to 3tpeak
res_mat <- res_mat |> mutate(across(where(is.list), unlist))
res_mat_mutated <- (res_mat|> mutate(B0 = as.factor(B0)	,
                                     stdv = sqrt(varRc),
                                     scaledCohort = cohort/tpeak
				) |> filter(scaledCohort <= maxCohort4Plot)
                   )

########### Rc and kappa_c over time #########
cohortXlabel <- bquote("Dimensionless cohort infection time, t/"~t[peak])


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
				+ labs(x = cohortXlabel
				     ,  y = "Unweighted\nwithin-cohort\ndispersion"
					)
            )

### incidence 
outbreak <- (straightSim |> group_by(B0) |> arrange(time, .by_group = TRUE)
                     |> mutate(cohortSize = lead(instantaneous_inc),
                               scaledTime = time/tpeak) |> 
                       filter(scaledTime <= maxCohort4Plot) |>
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

############### Final Plot #############
cohortFig <- (incidence   / mu_Rc / kappa_Rc)

print(cohortFig
     + plot_annotation(tag_levels ="a", tag_suffix  = ")")
     + plot_layout(guides = "collect")
     )


