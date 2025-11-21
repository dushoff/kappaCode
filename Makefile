## This is kappaCode created 2025 Nov 19 (Wed)
## Some of the code for Roswell-Weitz heterogeneity exploration
## Revisit what belongs here and what to do with it (e.g., R package?)

current: target
-include target.mk
Ignore = target.mk

vim_session:
	bash -cl "vmt todo.md"

## -include makestuff/perl.def

######################################################################

Sources += $(wildcard *.R *.md)

autopipeR = defined

## Lloyd-Smith curves linearized figure
lsDensity.Rout: lsDensity.R realAct.rda
lsCurves.Rout: lsCurves.R densHist.rda funs.rda

plot_inequality_curves.R.1.prevfile:

## Realized activity 
realAct.Rout: realAct.R funs.rda


## Some helper functions
funs.Rout: funs.R

######################################################################

### Makestuff

Sources += Makefile

Ignore += makestuff
msrepo = https://github.com/dushoff

## ln -s ../makestuff . ## Do this first if you want a linked makestuff
Makefile: makestuff/00.stamp
makestuff/%.stamp: | makestuff
	- $(RM) makestuff/*.stamp
	cd makestuff && $(MAKE) pull
	touch $@
makestuff:
	git clone --depth 1 $(msrepo)/makestuff

-include makestuff/os.mk

-include makestuff/pipeR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
