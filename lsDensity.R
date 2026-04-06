## 2025 Nov 19 (Wed) Copied from overleaf/codes/plotPMF_PDF_ineq.R
## ls for Lloyd-Smith

library(shellpipes)
loadEnvironments()
library(ggplot2);theme_set( theme(axis.title.x = element_text(size = xlabelFontSize)
                                  ,axis.title.y = element_text(size = ylabelFontSize))
)
library(dplyr)
library(tidyr)
library(patchwork)
startGraphics(height = 5, width = 4)

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
	|> densHist(colorVar = "distParms"
		, colorVals = betaList, colorLab = bquote(R[0]) , groupVar = "distr"
	)
)

print(fancyHist)

rdsSave(fancyHist)

