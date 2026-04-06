library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
loadEnvironments()

straightSim <- map_dfr(betaList, function(B0){
   return(data.frame(sim_and_inc( B0=B0
                          ,cars = cars
                          ,t0 = t0
                          ,timeStep=0.001
                          ,finTime=peakAssigner(min(betaList))*1.5
                          ,y0 = y0
   ), B0 = B0, tpeak =peakAssigner(B0) ))
 }
 )

saveEnvironment()
