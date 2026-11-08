# Emergent heterogeneity in compartmental disease models

Secondary-case distributions are widely used to quantify transmission heterogeneity. Here we use analysis and simulation to examine dispersion in secondary case counts across time in the deterministic SIR model and their stochastic realizations using cohorts of infectious individuals. This repository contains R code to reproduce findings in the following manuscript:

> Roswell M., Aghaeeyan A., Goel T., Beckett S.J., Weitz J.S., Dushoff J. Emergent heterogeneity in compartmental disease models.

This code base should be cited as:
> Roswell M., Aghaeeyan A., Goel T., Beckett S.J., Weitz J.S., Dushoff J. Code for investigating emergent heterogeneity in compartmental disease models. Zenodo.

## Software details

The code is written in R v4.5.0; and was developed using libraries  *deSolve*, *dplyr*, *ggplot2*, *patchwork*, *pracma*, *purrr*, *tidyr*, *shellpipes*.

*shellpipes* is an R package that facilitates simulations in R using *Makefiles*. Users can define dependencies between scripts, files, etc. As a result, changes in dependencies are automatically tracked, and the code is rerun only when necessary.

The code is run using  *makefile*. Ensure you have a recent version of gnu make utility installed on your device. 
The *Makefile* workflow works smoothly on Mac and Linux machines,
but not on Windows machine. WSL can be a workaround for Windows users.
We are unsure whether the following steps will work on a Windows machine.

## Recreating analysis of Roswell et al:

To create the figures, you need to follow these steps:

1. Install R:
    Based on the operating system of your device, select and download the
    appropriate R installer from the Comprehensive R Archive Network
    [(CRAN)](https://cran.r-project.org/).
    Then follow the instructions to complete the installation 
2. Open a terminal and type *R* to launch an interactive R session:
```bash
R
```
3. Install required R packages:
```R
 install.packages(c("deSolve", "dplyr", "ggplot2", "patchwork", "pracma", "purrr", "tidyr", "remotes"))
```
The R package *remotes* is required to install *shellpipes* package from GitHub:

```R
library(remotes)
remotes::install_github(“dushoff/shellpipes”)
```
4. Clone this repository:
```bash
git clone git@github.com:dushoff/kappaCode.git
cd KappaCode
```
If you're not familiar with *Git*, you can instead click the *Code* button at the top right of the repository's main page and the click *Download ZIP*. Unpack the *ZIP* file and then open a terminal in the extracted folder. If see the *Code* button at the top right of this README, you're already on the right page.

5. Recreating Figures
You just need to run the command listed below each figure from the local repository root. 
You might see some errors the first time you run the command. 
That's because the *Makefile* requires some scripts hosted in the
[makestuff repository](https://github.com/dushoff/makestuff). 
Rerunning the same command should download the required scripts and resolve the issue.

Figure 1:
```bash
make lsFig.Rout 
```
Figure 2: 
```bash
make rcHist.Rout
```
Figure 3:
```bash
make TimeEvolutionStack.Rout
```
Figure 4:
```bash
make CohortPlot.Rout
```
Other than Figure 1, the figures are reproduced using the corresponding *RData* files in  *slow* directory.
The simulations can be rerun, though, by appending *.final* to the commands listed above, for example,
Figure 2: 
```bash
make rcHist.Rout.final
```
Be aware that the simulation for Figure 4 might take a couple of days to complete. 
