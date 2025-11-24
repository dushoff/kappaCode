library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
#An attempt to implement V1 of Roswell's manuscript using a deterministic framework
loadEnvironments()
 res_mat <- map_dfr(betaList, function(x){v1Stats_tpeak(B0 = x
                                               ,cars=cars
                                               ,cohortProp=cohortProp
                                               ,steps=steps
                                               ,tpeak=peakAssigner(x)
                                              ,y0=y0
                                              ,cutoffTime = cutoffTime
                                              ,finTime = finTime
                                              ,t0=t0)
})

straightSim <- map_dfr(betaList, function(B0){
   return(data.frame(sim( B0=B0,
                          cars = cars,
                          t0 = t0,
                          timeStep=finTime/steps,
                          finTime=finTime,
                          y0 = y0
   ), B0 = B0))
 }
 )

saveEnvironment()
