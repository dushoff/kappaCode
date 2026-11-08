# retrieve and store the session_info for slow simulations
#session_info corresponding to CohortSim.rda wasn't  saved but it was run using the same R version and the same R packages on the same cluster 

library(shellpipes)
loadEnvironments()
slowFile <- as.character(pipeStar())
warning(slowFile)

fileDir <- paste0("sessionInfo/")
capture.output(s_info, file = paste0(fileDir, slowFile, ".txt") )
