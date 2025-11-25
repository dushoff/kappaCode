library(dplyr)
library(tidyr)
library(shellpipes)
loadEnvironments()
library(ggplot2); theme_set(theme_bw()+ theme(
                            axis.title.x = element_text(size = xlabelFontSize)
                            , axis.title.y = element_text(size = ylabelFontSize)
                            , legend.title = element_text(size = legendTitleFontSize)
                            , legend.text  = element_text(size = legendFontSize)))


startGraphics(width=4, height=3)


stackBarplot <- (cohorts
             |> pivot_longer(cols = c(between, within)
                             , names_to = "source"
                             , values_to = "RcVariance")
             |>  mutate(B0=as.factor(B0)) |> ggplot() 
             + aes(x = B0, y = RcVariance
                   , fill = source)
             + geom_bar(stat = "identity"
                        , position = "stack"
                        , width = 0.25)
             + ylab("Variance in cases per case") 
             + xlab(bquote(R[0]))
             )

print(stackBarplot)

rdsSave(stackBarplot)