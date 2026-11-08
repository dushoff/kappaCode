# Emergent heterogeneity in compartmental disease models

Secondary-case distributions are widely used to quantify transmission heterogeneity. Here we use analysis and simulation to examine dispersion in secondary case counts across time in the deterministic SIR model and their stochastic realizations using cohorts of infectious individuals. This repository contains R code to reproduce findings in the following manuscript:

> Roswell M., Aghaeeyan A., Goel T., Beckett S.J., Weitz J.S., Dushoff J. Emergent heterogeneity in compartmental disease models.

This code base should be cited as:
> Roswell M., Aghaeeyan A., Goel T., Beckett S.J., Weitz J.S., Dushoff J. Code for investigating emergent heterogeneity in compartmental disease models. Zenodo.

## Software details

The code is written in R v4.5.0; and was developed using libraries  *deSolve*, *dplyr*, *ggplot2*, *patchwork*, *pracma*, *purrr*, *tidyr*, *shellpipes*.
*shellpipes* is an R package that facilitates simulations in R using *Makefiles*. Users can define dependencies between scripts, files, etc. As a result, changes in dependencies are automatically tracked, and the code is rerun only when necessary. The package can be installed in R from GitHub using the *remotes* library:

```R
library(remotes)
remotes::install_github(“dushoff/shellpipes”)
```

The code is run using  *makefile*. Ensure you have a recent version of gnu make utility installed on your device. 

## Recreating analysis of Roswell et al:
To create the figures, you just need to run the command(s) listed below each figure from the local repository root 
Figure 1:
> make lsFig.Rout 
Figure 2: 
> make rcHist.Rout
Figure 3:
> make TimeEvolutionStack.Rout
Figure 4:
> make CohortPlot.Rout

