library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
#An attempt to implement V1 of Roswell's manuscript using a deterministic framework
loadEnvironments()
finTime2Ipeak <- 8
nCohortPerIp <- 10000
min_cutoff <- 0.1
max_cutoff <- 1.5
cutoff_increment<- 0.1
cutoffTime<- seq(from = min_cutoff, to = max_cutoff, by = cutoff_increment)
 res_mat <- map_dfr(betaList, function(x){forcst(B0 = x
                                              ,cars=cars
                                              ,finTime2Ipeak=finTime2Ipeak
                                              ,nCohortPerIp=nCohortPerIp
                                              ,y0=y0
                                              ,frcIpeak = cutoffTime
                                              )
})

straightSim <- map_dfr(betaList, function(B0){
  tpeak <-peakAssigner(B0)
  return(data.frame(sim( B0=B0
                         ,timeStep=tpeak/nCohortPerIp
                         ,finTime=max_cutoff*tpeak
                         ,y0 = y0
  ), B0 = B0, tpeak = tpeak ))
}
)



saveEnvironment()
