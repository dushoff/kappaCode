library(dplyr)
library(tidyr)
library(ggplot2); theme_set(theme_bw())
library(shellpipes)

loadEnvironments()

startGraphics(width=7, height=5)


plotFile <- (cohorts
             |> pivot_longer(cols = c(between, within)
                             , names_to = "source"
                             , values_to = "RcVariance")
             |>  mutate(B0=as.factor(B0)) |> ggplot() 
             + aes(x = B0, y = RcVariance
                   , fill = source)
             + geom_bar(stat = "identity"
                        , position = "stack")
             + ylab("Variance in Rc") 
             + xlab(bquote(R[0]))
             + theme(axis.title.y = element_text(size = legendFontSize)
             ))

print(plotFile)

