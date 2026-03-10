library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
#An attempt to implement V1 of Roswell's manuscript using a deterministic framework
loadEnvironments()
timeStep <- 0.0002
min_cutoff <- 0.1
max_cutoff <- 1.5
cutoff_increment<- 0.1
cutoffTime<- seq(from = min_cutoff, to = max_cutoff, by = cutoff_increment)
gr<- expand.grid(B0 = betaList, cutoffTime = cutoffTime)
res_mat <- map2_dfr(.x = gr$B0, .y = gr$cutoffTime,
                    .f = function(x,y){v1Stats_trunc(B0 = x
                                              ,cars=cars
                                              ,timeStep=timeStep*peakAssigner(x)
                                              ,y0=y0
                                              ,cutoffTime = y*peakAssigner(x)
                    													,tpeak = peakAssigner(x)
                                              ,finTime =max_cutoff*peakAssigner(x)
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
saveEnvironment()
