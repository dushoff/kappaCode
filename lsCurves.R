## 2025 Nov 19 (Wed) Copied from overleaf/codes/plotPMF_PDF_ineq.R
## ls for Lloyd-Smith

library(shellpipes)
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)
loadEnvironments()
startGraphics(height = 6, width = 9)

fancyHist <- (deadDat 
	|> separate(distr
		, into = c("distType", "distParms")
		, sep = "_", remove = FALSE
	)
	# create a bar widths layer that has a narrower width at x = 0
	|> mutate(barWidth = 0.5 + 0.5*(x>0))
	# double the density for halved bar
	|> mutate(d = if_else(distType == "scnd"
		, if_else(x == 0, 2*d, d)
	, d))
)
print(fancyHist 
	|> densHist(colorVar = "distParms"
		, colorVals = c(1.5, 8) , colorLab = "R_0" , groupVar = "distr"
	)
)


