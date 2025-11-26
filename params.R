library(shellpipes)

betaList <- c(1.5, 3, 8)    # extend as needed
gamm <- 1
act <- betaList/gamm
numBeta <- length(betaList)

steps<-5e3
cars<-1
finTime<-130
y0 <-1e-9
cohortProp <- 0.6
t0 <-0
# cut-off times according to which cohorts are selected
cutoffTime <- seq(from=0.1, to = 2.5, by=0.1)

saveEnvironment()

