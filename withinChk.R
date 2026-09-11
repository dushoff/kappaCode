library(shellpipes)
library(ggplot2);sourceFiles()
library(dplyr)
library(deSolve)
library(purrr)
library(tidyr)
library(patchwork)
loadEnvironments()
startGraphics()

fr.8 <-read.csv("slow/B0_1.5frack_0.8.csv")
fr.9 <- read.csv("slow/B0_1.5frack_0.9.csv")
fr1 <- read.csv("slow/B0_1.5frack_1.csv")
fr1.1 <- read.csv("slow/B0_1.5frack_1.1.csv")

fr.8$frc <- 0.8
fr.9$frc <- 0.9
fr1$frc <- 1
fr1.1$frc <- 1.1

df <- bind_rows(fr.8, fr.9, fr1, fr1.1) |> mutate(frc = as.factor(frc))

B0 <- 1.5
max_cutoff <- 1.1
nCohortPerIp <- 10000
y0 <- 1e-9

tpeak <-peakAssigner(B0)
df$tpeak <- tpeak
mySim <- data.frame(sim( B0=B0
                ,timeStep=tpeak/nCohortPerIp
                ,finTime=max_cutoff*tpeak
                ,y0 = y0
  ), B0 = B0, tpeak = tpeak )


incidence <- (mySim |>
                          mutate(tscale = mid_time) |>
                          ggplot(aes(tscale, instantaneous_inc, color = as.factor(B0)))
                        + geom_line()
                        + geom_vline(xintercept = tpeak*c(0.8,0.9,1,1.1))
                        + labs(x = NULL
                        , y = "Cohort size"
                        , color = bquote(R[0])
                        )
#                                + scale_y_log10()
             )

varR <- (df |> ggplot(aes(x = cohort, y = varRc, color = frc))
              + geom_line()
              + geom_vline(xintercept = tpeak*c(0.7,0.8,0.9,1,1.1))
              )
cohortFig <- (incidence / varR)

print(cohortFig
        + plot_annotation(tag_levels ="a", tag_suffix  = ")")
        + plot_layout(guides = "collect")
     )
