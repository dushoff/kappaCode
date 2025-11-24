library(shellpipes)

betaList <- c(1.5, 3, 8)    # extend as needed
gamm <- 1
act <- betaList/gamm
numBeta <- length(betaList)

steps<-3e3
cars<-1
finTime<-100
y0 <-1e-9
cohortProp <- 0.6
t0 <-0
# cut-off times according to which cohorts are selected
cutoffTime <- c(0.05, seq(from=0.1, to = 2, by=0.1)) 

## legend guides parameters
xpos <- 0.85; ypos <- 0.25
legendFontSize <- 8; legendTitleFontSize <- 9

saveEnvironment()

