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
    remotes::install_github("dushoff/shellpipes)
    ```
    
4. Clone this repository by opening a terminal window and typing the following command: 

    ```bash
    git clone git@github.com:dushoff/kappaCode.git
    ```
    
    and then navigate to the root directory of your local repository
    
    ```bash
    cd kappaCode
    ```
    
    If you're not using *Git*, you can instead click the *Code* button at the top right of the repository's main page and then click *Download ZIP*. Unpack the *ZIP* file
and then open a terminal in the extracted folder. If you can see the *Code* button above this README, you're already on the right page.

5. Recreating Figures
    To recreate each figure, you just need to run the command listed below it in a terminal 
    from the root directory of your local repository. 

    You might see some errors the first time you run the command. 
    That's because the *Makefile* requires some scripts hosted in the
    [makestuff repository](https://github.com/dushoff/makestuff). 
    Rerunning the same command should download the required scripts and resolve the issue.

    Figure 1:

    ```bash
    make lsFig.Rout 
    ```
---

    Figure 2: 
    
    ```bash
    make rcHist.Rout
    ```
    <details>
    <summary>R session information for simulation that produced Figure 2 </summary>

    ```text
    R version 4.5.0 (2025-04-11)
    Platform: x86_64-pc-linux-gnu
    Running under: AlmaLinux 9.7 (Moss Jungle Cat)
    
    Matrix products: default
    BLAS/LAPACK: FlexiBLAS AOCL;  LAPACK version 3.11.0
    
    locale:
     [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
     [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
     [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
     [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
     [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    
    time zone: America/Vancouver
    tzcode source: system (glibc)
    
    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     
    
    other attached packages:
    [1] pracma_2.4.6     tidyr_1.3.2      ggplot2_3.5.1    purrr_1.2.1     
    [5] dplyr_1.2.0      shellpipes_0.1.0
    
    loaded via a namespace (and not attached):
     [1] R6_2.6.1         tidyselect_1.2.1 magrittr_2.0.5   gtable_0.3.6    
     [5] glue_1.8.1       tibble_3.3.1     pkgconfig_2.0.3  generics_0.1.4  
     [9] lifecycle_1.0.5  cli_3.6.6        scales_1.3.0     grid_4.5.0      
    [13] vctrs_0.7.3      withr_3.0.3      compiler_4.5.0   munsell_0.5.1   
    [17] pillar_1.11.1    colorspace_2.1-1 rlang_1.3.0   
    ```
    
    </details>
    
    ---
    
    Figure 3:
    ```bash
    make TimeEvolutionStack.Rout
    ```
    <details>
    <summary>R session information for simulation that produced  Figure 3 </summary>
    ```text
    R version 4.5.0 (2025-04-11)
    Platform: x86_64-pc-linux-gnu
    Running under: AlmaLinux 9.7 (Moss Jungle Cat)
    
    Matrix products: default
    BLAS/LAPACK: FlexiBLAS AOCL;  LAPACK version 3.11.0
    
    locale:
     [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
     [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
     [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
     [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
     [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    
    time zone: America/Vancouver
    tzcode source: system (glibc)
    
    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     
    
    other attached packages:
    [1] shellpipes_0.1.0 deSolve_1.42     tidyr_1.3.2      purrr_1.2.1     
    [5] dplyr_1.2.0     
    
    loaded via a namespace (and not attached):
     [1] R6_2.6.1         tidyselect_1.2.1 magrittr_2.0.5   glue_1.8.1      
     [5] tibble_3.3.1     pkgconfig_2.0.3  generics_0.1.4   lifecycle_1.0.5 
     [9] cli_3.6.6        vctrs_0.7.3      compiler_4.5.0   pillar_1.11.1   
    [13] rlang_1.3.0 
    ```
    </details>
    
    ---
    
    Figure 4:
    ```bash
    make CohortPlot.Rout
    ```
    
    ---


Other than Figure 1, the figures are reproduced using the corresponding *RData* files in  *slow* directory.
The simulations can be rerun, though, by appending *.final* to the commands listed above, for example, type the following command in the terminal to reproduce 
Figure 2 by running a new simulation: 
```bash
make rcHist.Rout.final
```
Be aware that the simulation for Figure 4 might take a couple of days to complete. 

