library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
#An attempt to implement V1 of Roswell's manuscript using a deterministic framework
loadEnvironments()
cutoffTime <- c(0.01, 0.02, 0.5,seq(from=0.1, to = 3.5, by=0.1))
 res_mat <- map_dfr(betaList, function(x){return(data.frame(cohortStatsRcPlot(B0 = x
                                              ,cars=cars
                                              ,cohortProp=cohortProp
                                              ,steps=steps
                                              ,y0=y0
                                              ,finTime=finTime
                                              ,stopTime=peakAssigner(x)*max(cutoffTime) 
                                              ,t0=t0)
                                              ,tpeak = peakAssigner(x)
                                              ,B0 = x
 )
 )
})

straightSim <- map_dfr(betaList, function(B0){
   return(data.frame(sim_and_inc( B0=B0,
                          cars = cars,
                          t0 = t0,
                          timeStep=peakAssigner(B0)*max(cutoffTime)/steps,
                          finTime=peakAssigner(B0)*max(cutoffTime),
                          y0 = y0
   ), B0 = B0, tpeak =peakAssigner(B0) ))
 }
 )

saveEnvironment()
