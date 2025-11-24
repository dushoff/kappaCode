library(shellpipes)
library(ggplot2)
library(dplyr)
library(purrr)
library(patchwork)
library(deSolve)
library(tidyr)
library(shellpipes)
loadEnvironments()


cohorts <- map_dfr(betaList, function(B0){
                              RcStats(B0=B0
                                    , steps=steps
                                    , cars = cars
                                    , finTime = finTime
                                    , y0 = y0
                                    , t0=t0
                                    , cohortProp = cohortProp
  )
}
)



saveEnvironment()
