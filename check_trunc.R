library(dplyr)
library(purrr)
#library(tidyr)
library(deSolve)
library(shellpipes)

loadEnvironments()

nCohortPerIpeak  <- 5000
betaList <- c(1.5, 8)
y0 <- 1e-9
frcIpeak <- 0.1

res_mat <- map_dfr(betaList,
	function(x){truncSim(B0=x
		, nCohortPerIp=nCohortPerIpeak
		, frcIpeak=frcIpeak
		, y0=y0
		)
	} 
)

saveEnvironment()
