.libPaths("/home/aghaeian/R/library")
library(dplyr)
library(purrr)
#library(tidyr)
library(deSolve)
#library(shellpipes)
#An attempt to implement V1 of Roswell's manuscript using a deterministic framework
#loadEnvironments()
source("funs.R")
source("params.R")
timeStep <- 0.0002
min_cutoff <- 0.1
max_cutoff <- 1.5
cutoff_increment<- 0.1
cutoffTime<- seq(from = min_cutoff, to = max_cutoff, by = cutoff_increment)
 res_mat <- map_dfr(betaList, function(x){v1Stats_tpeak(B0 = x
                                              ,cars=cars
                                              ,cohortProp=cohortProp
                                              ,timeStep=timeStep*peakAssigner(x)
                                              ,tpeak=peakAssigner(x)
                                              ,y0=y0
                                              ,cutoffTime = cutoffTime
                                              ,finTime = finTime
                                              ,t0=t0)
})

straightSim <- map_dfr(betaList, function(B0){
   return(data.frame(sim_and_inc( B0=B0
                          ,cars = cars
                          ,t0 = t0
                          ,timeStep=timeStep*peakAssigner(B0)
                          ,finTime=max_cutoff*peakAssigner(B0)
                          ,y0 = y0
   ), B0 = B0, tpeak =peakAssigner(B0) ))
 }
 )
save.image(file = "RcTimePlotVaryingPeakSimServer.RData")

#saveEnvironment()
