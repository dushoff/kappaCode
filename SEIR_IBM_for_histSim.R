library(shellpipes)
library(dplyr)
library(purrr)
library(ggplot2)
library(tidyr)
library(pracma)
loadEnvironments()
options(warn = 1)
## how long to run
tMax <- 2e3
# epidemic parameters
setGamma <- 1 # because we can rescale time if needed
LambdaVec <- setGamma*c(0.1, 0.5, 1, 2, 10) #latency  rate
tProb <- 1 ## could fiddle with transmission probabilities, but that might be equivalent to another time rescaling
popSize <- 1e4## popSize is a parameter, and belongs here
seed <- 955
prmt <- expand.grid(lambda = LambdaVec, beta = c(betaList, 15))
#run the IBM_for_v1.R for each values in setBeta
IBM_v1_results <- map2(prmt$beta, prmt$lambda, function(x, y) {
  out<-IBM_hist_SEIR(setBeta = x, seed = seed, popSize = popSize, tProb = tProb
         ,tMax = tMax
         , setLambda = y)
    do.call(rbind, list(out$df))
  }) |> list_rbind()


#repeat each row n times where n is the corresponding value in count column
IBM_v1_results_rep <- IBM_v1_results |> uncount(weights = count,
                                                .remove = TRUE) |>
  mutate(num_cases = as.numeric(as.character(num_cases))
        )


saveEnvironment()
