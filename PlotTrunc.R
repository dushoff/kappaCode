library(shellpipes)
loadEnvironments()

library(dplyr)
library(patchwork)
library(tidyr)
library(deSolve)
library(purrr)

startGraphics(width=5, height=5)

library(ggplot2); sourceFiles()
############### Time Plot ########################
print(res_mat)
res_mat_mutated <- (res_mat |> mutate( B0 = as.factor(B0)
			, KRc_within = within/muRc^2    #uncomment this
			, stdv = sqrt(totalVRc)
			, frcIpeak = if("frcIpeak" %in% names(res_mat)){ frcIpeak 
                                     }else{cutoffTime}
			)
                    )
########### Rc and kappa_c over time #########
cohortXlabel <- bquote("Rescaled time (t"~"/"~t[peak]~")")

res_mat_mutated_2 <- (res_mat_mutated |>
                       pivot_longer(cols=c(totalKRc, KRc_within
					  )
                                  , names_to = "source"
                                  , values_to = "KRc_splitted" 
                                   )
                     )


kappa_Rc <- (res_mat_mutated_2 |> 
       ggplot(aes(frcIpeak, KRc_splitted, color = B0))
     + geom_point(aes(shape = source))
     + geom_line(aes(linetype = source))
     + geom_vline(xintercept = 1)
     + geom_hline(yintercept = 1)
     + guides(color = "none") 
     + labs( x =  cohortXlabel
           , y = bquote(kappa)
            )
     + scale_shape_manual(	
            values = c("totalKRc" = kbetShape, "KRc_within" = kwithShape)
          , labels = c("KRc_within" = bquote(kappa["with"])
				# ,"KRc_within" = bquote(kappa["with"])
		     , "totalKRc" = bquote(kappa))
          , name = "source"
                      )
    + scale_linetype_manual(
           values = c("KRc_within" = "solid", "totalKRc" = "dashed")
         , labels = c("KRc_within" = bquote(kappa["with"])
       # ,"KRc_within" = bquote(kappa["with"])
         , "totalKRc" = bquote(kappa))
         , name = "source"
                                )
						
          )

res_mat_mutated_3 <- (res_mat_mutated |>
                       pivot_longer(cols=c(muRc, stdv)
				  , names_to = "source"
				  , values_to = "quantity" 
                                   )
                     )

mu_and_sigma_Rc <- (res_mat_mutated_3 |>
                          ggplot(aes(frcIpeak, quantity, color = B0))
			+ geom_point(aes( shape = source))
			+ geom_line(aes(linetype = source))
			+ geom_hline(yintercept = 1)
			+ geom_vline(xintercept = 1)
			+ guides(color = "none") 
			+ labs(
                               x = NULL
			      ,y = "Expected\ninfectiousness"
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
incidence <- (straightSim |> 
                          mutate(tscale = mid_time/tpeak) |>
                          filter(tscale >= min_cutoff) |>
                          ggplot(aes(tscale, instantaneous_inc, color = as.factor(B0)))
			+ geom_point(size = 0.5)
                        + geom_vline(xintercept = 1)
			+ labs(x = NULL
			, y = "Cohort size"
			, color = bquote(R[0])
			)
#                                + scale_y_log10()
             )

############### Final Plot #############
cohortFig <- (incidence / mu_and_sigma_Rc / kappa_Rc)

print(cohortFig 
	+ plot_annotation(tag_levels ="a", tag_suffix  = ")")
	+ plot_layout(guides = "collect")
     )

#saveEnvironment()
