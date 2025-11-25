library(shellpipes)
loadEnvironments()
library(ggplot2); theme_set(theme_bw() + theme(
  plot.background = element_blank(),
  panel.grid = element_blank(),
  axis.title.x = element_text(size = xlabelFontSize),
  axis.title.y = element_text(size = ylabelFontSize)
) )
library(dplyr)
library(patchwork)
library(tidyr)
library(deSolve)
library(purrr)

startGraphics(width=10, height=5)
update_geom_defaults("line", list(
  linewidth = 1     
))
update_geom_defaults("vline", list(
  linewidth = 0.5
  ,linetype = "dotted"
))
update_geom_defaults("hline", list(
  linewidth = 0.5
  ,linetype = "dotted"
))
update_geom_defaults("point", list(
  size = 1.5
))
scale_colour_discrete <- function(...) {
  ggplot2::scale_colour_brewer(palette = "Dark2", ...)
}

scale_fill_discrete <- function(...) {
  ggplot2::scale_fill_brewer(palette = "Dark2", ...)
}############### Time Plot ########################
res_mat_mutated_2 <- res_mat |> mutate(
  B0 = as.factor(B0) )
########### Rc and kappa_c over time #########
cohortXlabel <- bquote("rescaled time (t"~"/"~t[peak]~")")
mu_Rc <- (res_mat_mutated_2 |> ggplot(aes(cutoffTime, muRc
                                          , color = as.factor(B0))) 
          + geom_point()
          + geom_line() 
          + geom_hline(yintercept = 1)
          + geom_vline(xintercept = 1)
          + guides(color = "none") 
          + labs(x = cohortXlabel
                 , y = bquote(mu)
                 , color = bquote(beta)))


var_Rc<- (res_mat_mutated_2 |> ggplot(aes(cutoffTime, totalVRc
                                          , color = as.factor(B0))) 
          + geom_point()
          + geom_line() 
          + geom_hline(yintercept = 1)
          + geom_vline(xintercept = 1)
          + guides(color = "none") 
          + labs(x = cohortXlabel
                 , y = bquote(sigma^2)
                 , color = bquote(beta)))

var_Rc_bet<- (res_mat_mutated_2 |> ggplot(aes(cutoffTime, between
                                              , color = as.factor(B0)))
              + geom_point()
              + geom_line() 
              + geom_hline(yintercept = 1)
              + geom_vline(xintercept = 1)
              + guides(color = "none") 
              + labs(x = cohortXlabel
                     , y = bquote(sigma["bet"]^2)
                     , color = bquote(beta)))

var_Rc_with<- (res_mat_mutated_2 |> ggplot(aes(cutoffTime, within
                                               , color = as.factor(B0)))
               + geom_point()
               + geom_line() 
               + geom_hline(yintercept = 1)
               + geom_vline(xintercept = 1)
               + guides(color = "none") 
               + labs(x = cohortXlabel
                      , y = bquote(sigma["with"]^2)
                      , color = bquote(beta)))
####
scale_with2bet <- max(res_mat_mutated_2$within)/max(res_mat_mutated_2$between)
var_Rc<- (res_mat_mutated_2 |> ggplot(aes(x=cutoffTime, color = as.factor(B0)))
          + geom_point(aes(y = within), size = 0.75)
          + geom_line(aes(y = within), linetype = "dotted")
          + geom_point(aes(y = scale_with2bet* between))
          + geom_line(aes(y = scale_with2bet* between))
          + scale_y_continuous(name = bquote(sigma["with"]^2)
                               , sec.axis = sec_axis(~./scale_with2bet
                                                     , name=bquote(sigma["bet"]^2)))
          + geom_vline(xintercept = 1)
          + guides(color = "none")
          + labs(x = cohortXlabel
                 , y = bquote(sigma^2)
          ))


####


kappa_Rc<- (res_mat_mutated_2 
            |> ggplot(aes(cutoffTime, totalKRc, color = as.factor(B0))) 
            + geom_point()
            + geom_line() 
            + geom_hline(yintercept = 1)
            + geom_vline(xintercept = 1)
            + labs(x = cohortXlabel
                   , y = bquote(kappa)
                   , color = bquote(R[0]))
            +  theme(legend.position = c(0.75, 0.25)
                     , legend.justification = c("left", "bottom")
                     , legend.title = element_text(size = legendTitleFontSize)
                     , legend.text  = element_text(size = legendFontSize))
)

### incidence 
incidence <- (straightSim  |> mutate(scaledTime = time/tpeak) |>
                ggplot(aes(scaledTime, inc, color = as.factor(B0)))
              + geom_line()
              + geom_vline(xintercept = 1)
              + labs(x = cohortXlabel
                     , y = "Incidence"
              )
              + guides(color="none") )

############### Final Plot #############
cohortFig <- incidence + mu_Rc + var_Rc + kappa_Rc

print(cohortFig 
      + plot_annotation(tag_levels ="a", tag_suffix  = ")")
)


#saveEnvironment()
