# make Lloyd-Smith simple activity and realized distributions
# copied from overleaf/codes/deadSimple.R 2025 Nov 19 (Wed)
library(shellpipes)
loadEnvironments()
library(dplyr)
library(purrr)



# slices
n <- 300
xmax <- 30.5


actDist <- function(low = 0, high = 30, n = n, act, label){
    x <- seq(low, high, length.out = n)
    d <- dexp(x, rate = 1/act)
    return(
        data.frame(x, d, distr = rep(label, length(x)))
    )
}

secDist <- function(high = 30, act, label){
    x <- 0:high
    d <- dgeom(x, prob = odds2prob(1/act))
    return(
        data.frame(x, d, distr = rep(label, length(x)))
    )
}

actHist <- function(n, act){
    rexp(n = n, rate = 1/act)
}

secHist <- function(n, act){
    rgeom(n = n, prob = odds2prob(1/act))
}

# Build distributions
deadDat <- bind_rows(
    map_dfr(seq_along(act)
        , ~ actDist(low = 0, high = xmax, n = n, act = act[.x], label = paste0("act_", .x))
    )
    , map_dfr(seq_along(act)
        , ~ secDist(high = xmax, act = act[.x], label = paste0("scnd_", .x))
    )
)

saveEnvironment()
