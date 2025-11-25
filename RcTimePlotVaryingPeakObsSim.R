library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
#An attempt to implement V1 of Roswell's manuscript using a deterministic framework
loadEnvironments()
cutoffTime <- c(0.05, 0.5, 1, 2) 
gr<- expand.grid(B0 = betaList, cutoffTime = cutoffTime)
res_mat <- map2_dfr(.x = gr$B0, .y = gr$cutoffTime,
                    .f = function(x,y){v1Stats_tpeak_obs(B0 = x
                                               ,cars=cars
                                               ,steps=steps
                                              ,y0=y0
                                              ,cutoffTime = y*peakAssigner(x)
                                              ,finTime = finTime
                                              ,t0=t0)
})

straightSim <- map_dfr(betaList, function(B0){
  return(data.frame(sim( B0=B0,
                         cars = cars,
                         t0 = t0,
                         timeStep=peakAssigner(B0)*max(cutoffTime)/steps,
                         finTime=peakAssigner(B0)*max(cutoffTime),
                         y0 = y0
  ), B0 = B0, tpeak =peakAssigner(B0) ))
}
)
saveEnvironment()
