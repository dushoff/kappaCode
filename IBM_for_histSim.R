library(shellpipes)
library(dplyr)
library(purrr)
library(ggplot2)
library(tidyr)
library(pracma)
loadEnvironments()

## how long to run
tMax <- 2e3
# epidemic parameters
setGamma <- gamm # because we can rescale time if needed
tProb <- 1 ## could fiddle with transmission probabilities, but that might be equivalent to another time rescaling
popSize <- 1e4## popSize is a parameter, and belongs here
seed <- 240
rPar <- "exp" # sets duration distribution as exponential (base model)
days_counter <- 10
#run the IBM_for_v1.R for each values in setBeta
IBM_v1_results <- map_dfr(betaList, function(x) {
  out<-IBM_hist(setBeta = x, seed = seed, popSize = popSize, tProb = tProb
         ,tMax = tMax)
    do.call(rbind, list(out$df))
  })


#repeat each row n times where n is the corresponding value in count column
IBM_v1_results_rep <- IBM_v1_results |> uncount(weights = count,
                                                .remove = TRUE) |>
  mutate(num_cases = as.numeric(as.character(num_cases))
        )


saveEnvironment()
