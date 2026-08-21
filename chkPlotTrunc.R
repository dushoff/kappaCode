library(shellpipes)
loadEnvironments()

library(dplyr)
library(patchwork)
library(tidyr)
library(deSolve)
library(purrr)

startGraphics(width=5, height=5)

print(res_mat); quit()

library(ggplot2); sourceFiles()

############### Time Plot ########################
res_mat_mutated <- (res_mat |>
                     mutate( B0 = as.factor(B0)
                           , KRc_within = within/muRc^2
			   , stdv = sqrt(totalVRc)
                           )
                   )
########### Rc and kappa_c over time #########
cohortXlabel <- bquote("Rescaled time (t"~"/"~t[peak]~")")

res_mat_mutated_2 <- (res_mat_mutated	|>
                      pivot_longer(cols=c(totalKRc, KRc_within)
				  , names_to = "source"
                                  , values_to = "KRc_splitted" 
                                  )
                     )


kappa_Rc <- ( res_mat_mutated_2 |> ggplot(aes(x = frcIpeak, y = KRc_splitted, color = B0))
             + geom_point(aes( shape = source
                             )
                         )
	     + geom_hline(yintercept = 1)
	     + guides(color = "none") 
	     + labs(x = cohortXlabel
		  , y = bquote(kappa)
		    )
	     + scale_shape_manual(
		values = c("totalKRc" = kbetShape, "KRc_within" = kwithShape)
		, labels = c("KRc_within" = bquote(kappa["with"])
			    , "totalKRc" = bquote(kappa)					 
			    )
		, name = "source"
				 )
                                    )

res_mat_mutated_3 <- (res_mat_mutated |>
                     pivot_longer(cols=c(muRc, stdv)
				, names_to = "source"
				, values_to = "quantity" )
                     )

mu_and_sigma_Rc <- (res_mat_mutated_3 |> ggplot(aes(x = frcIpeak, y= quantity, color = B0))
                   + geom_point(aes(shape = source))
#		   + geom_line(aes(linetype = source)) 
		   + labs(x = cohortXlabel
			, y = "Expected\ninfectiousness"
			  )
		   + scale_shape_manual(
			values = c("muRc" = muRcShape, "stdv" = stdvShape)
		      , labels = c("muRc" = bquote(mu), "stdv" = bquote(sigma))
		      , name = "statistics"
                                        )
		)
### recovered 
############### Final Plot #############
cohortFig <- ( 
              mu_and_sigma_Rc / kappa_Rc)

print(cohortFig 
	+ plot_annotation(tag_levels ="a", tag_suffix  = ")")
	+ plot_layout(guides = "collect")
)

#saveEnvironment()
