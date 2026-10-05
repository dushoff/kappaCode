
# load some libraries
library(shellpipes)
manageConflicts()
library(dplyr)
library(pracma)
# library(purrr)
library(tidyr)
loadEnvironments()
options(warn = 1)
IBM_hist_SEIR<- function(setBeta = 1.5, seed = 10, popSize = 1e4, tProb = 1
                  ,tMax = 2e3
                  , setLambda = 1.0){
#This script is based on IBM_for_hist.R
set.seed(seed)
results <- vector("list", 50)
comb2.int <- function(n, rep = FALSE){
  if(!rep){
    # e.g. n=3 => (1,2), (1,3), (2,3)
    x <- rep(1:n,(n:1)-1)
    i <- seq_along(x)+1
    o <- c(0,cumsum((n-2):1))
    y <- i-o[x]
  }else{
    # e.g. n=3 => (1,1), (1,2), (1,3), (2,2), (2,3), (3,3)
    x <- rep(1:n,n:1)
    i <- seq_along(x)
    o <- c(0,cumsum(n:2))
    y <- i-o[x]+x-1
  }
  return(rbind(x,y))
}
rateInds <-comb2.int(popSize)

# daily per-person interactions
dailyRate <- setBeta/tProb

# generate interaction rates by dyad
rateFrame <- rateInds |>
  rbind(dailyRate/(popSize-1)) |>
  t() |>
  data.frame()
names(rateFrame)<- c("ind1", "ind2", "mixRate")

# This is 10% more than the expected number of contacts up to tMax
toSim <- floor(0.55*dailyRate*popSize*tMax)

# make events
contTime <- cumsum(rexp(toSim,sum(rateFrame$mixRate)))
# link to contact matrix
contInd <- sample( 1:length(rateFrame$mixRate)
                            , size = toSim
                            , replace = TRUE
                            , rateFrame$mixRate)

contactOrder <- cbind(t(rateInds)[ contInd,], contTime)

# We will also pre-compute recovery times
# Default assumes an exponential duration distribution

recDelay <-  rexp(1:popSize, rate = setGamma)
 #exposed duration is also exponential with rate setLambda
exposedPeriod <-  rexp(1:popSize, rate = setLambda)
# initialize infectious time and exposed time  with  large numbers for logical testing
iTime <- rep(tMax, popSize)
exposedTime <- rep(tMax, popSize)
# map integers to infection status
Sstate <- 1
Estate <- 2
Istate <- 3
Rstate <- 4
states <- rep(Sstate, popSize)
# initialize with one random infectious individual
p0 <- sample(1:popSize, 1)
states[p0]<- Istate

# start the clock
tCur <- 0
# assuming the initial index was exposed and simultaneously infected at tCur
iTime[p0] <- tCur
exposedTime[p0] <- tCur
# keep track of cases per person and counts for each state
caseTally <- rep(0, popSize)

I <- sum(states == Istate)
S <- sum(states == Sstate)
E <- sum(states == Estate)

# Think about if this gets params as inputs too.
for(i in 1:nrow(contactOrder)){
  co <- contactOrder[i,]
# a bunch of stuff I want to do for each row...
  tCur <- co[3]
  if (tCur > tMax)
    {
    warning("time is up")
    break
  }
    # check if anyone is exposed
  exposed <- states[co[1:2]] == Estate
  if(any(exposed)){
    # see if anyone has already become infectious
    InfectiousVec <-  exposed & ((exposedTime[co[1:2]] + exposedPeriod[co[1:2]]) <= tCur)
    # count them
    E <- E - sum((InfectiousVec))
    I <- I + sum(InfectiousVec)
    inds <- co[1:2][InfectiousVec]
    states[inds] <- Istate
    iTime[inds] <- exposedTime[inds] + exposedPeriod[inds]
    
  }
  cont <- states[co[1:2]] == Istate
  if(any(cont)){
        # see if anyone has already recovered
    recVec <- (iTime[co[1:2]] +  recDelay[co[1:2]]) <= tCur
    # count them
    # if(sum(recVec>0)){cat("recovery")}
    I <- I - sum((cont) * (recVec))
    # remove them (this will needlessly update state from R to R sometimes)
    states[co[1:2]][recVec] <- Rstate
    # if one is infectious AND one is susceptible, lots to do
    if(any(states[co[1:2]] == Istate) & any(states[co[1:2]] == Sstate)){
        E <- E + 1
        S <- S - 1
        # count the win
        caseTally[co[1:2][states[co[1:2]] == Istate]] <- caseTally[co[1:2][states[co[1:2]] == Istate]] + 1

        # record the infection time
        exposedTime[co[1:2][states[co[1:2]] == Sstate]] <- tCur
        # update the states
        states[co[1:2][states[co[1:2]] == Sstate]] <- Estate
    
  }
  }

  if(S == 0 || (I == 0 && E == 0)){

warning("no one is neither infected nor exposed anymore")
   
   break}
}
df <- as.data.frame(table(caseTally[states !=Sstate]))  
names(df) <- c("num_cases", "count")
df$beta <- setBeta
df$lambda <- setLambda
# q uestionable move to save storage
rm(list= c("rateFrame", "rateInds", "contactOrder", "contInd", "contTime" ))

return(list(df = df))
}


saveEnvironment()
