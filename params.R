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

xpos <- 0.85; ypos <- 0.25
stdvShape <- 19; muRcShape <-8
kwithShape <- 0; kbetShape <- 17
legendFontSize <- 8; legendTitleFontSize <- 9
xlabelFontSize <- 10; ylabelFontSize <- 10

saveEnvironment()

