library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
loadEnvironments()
finTime2Ipeak <- 1.5
straightSim <- map_dfr(betaList, function(B0){
   return(data.frame(sim( B0=B0
                          ,cars = cars
                          ,t0 = t0
                          ,timeStep=1e-3
                          ,finTime=peakAssigner(min(betaList))*finTime2Ipeak
                          ,y0 = y0
   ), B0 = B0, tpeak =peakAssigner(B0) ))
 }
 )

saveEnvironment()
