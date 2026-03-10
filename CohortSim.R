library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
loadEnvironments()
max_cutoff <- 3.5
timeStep <- 0.0002
 res_mat <- map_dfr(betaList, function(x){return(data.frame(cohortStatsRcPlot(B0 = x
                                              ,cars=cars
                                              ,cohortProp=cohortProp
                                              ,timeStep=timeStep*peakAssigner(x)
                                              ,y0=y0
                                              ,finTime=finTime
                                              ,stopTime=peakAssigner(x)*max_cutoff
                                              ,t0=t0)
                                              ,tpeak = peakAssigner(x)
                                              ,B0 = x
 )
 )
})

straightSim <- map_dfr(betaList, function(B0){
   return(data.frame(sim_and_inc( B0=B0
                          ,cars = cars
                          ,t0 = t0
                          ,timeStep=timeStep* peakAssigner(B0)
                          ,finTime=peakAssigner(B0)*max_cutoff
                          ,y0 = y0
   ), B0 = B0, tpeak =peakAssigner(B0) ))
 }
 )

saveEnvironment()
