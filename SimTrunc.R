library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
#An attempt to implement V1 of Roswell's manuscript using a deterministic framework
loadEnvironments()
nCohortPerIp <- 10000 #Doubling nCohortPerIp to improve numerical issues, but it'll take so long..Ended up running on server
min_cutoff <- 0.1
max_cutoff <- 1.5
cutoff_increment<- 0.1
cutoffTime<- seq(from = min_cutoff, to = max_cutoff, by = cutoff_increment)
gr<- expand.grid(B0 = betaList, cutoffTime = cutoffTime)
res_mat <- map2_dfr(.x = gr$B0, .y = gr$cutoffTime,
                    .f = function(x,y){truncSim(B0 = x,
                                          nCohortPerIp = nCohortPerIp,
                                          frcIpeak = y,
                                          y0 = y0
                                               )
})

print(res_mat)

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
