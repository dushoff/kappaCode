library(shellpipes)
library(ggplot2); theme_set(theme_bw())
library(patchwork)

startGraphics(height=4, width=8)

dens <- rdsRead("Density")
curve <- rdsRead("Curves")
 
print(dens + curve
	 # + theme(legend.position = "none")
	 + plot_layout(
	 ncol   = 2,         
	 widths = c(1, 1)    
)
	+ plot_annotation(tag_levels = 'a', tag_suffix = ")")
)

print(sessionInfo())

