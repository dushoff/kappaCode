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
Sources += $(wildcard slow/*)
autopipeR = defined

## Lloyd-Smith curves linearized figure
## lsDensity.Rout: lsDensity.R lsDensity.Rlog
lsDensity.Rout: lsDensity.R realAct.rda
lsCurves.Rout: lsCurves.R params.rda funs.rda

plot_inequality_curves.R.1.prevfile:

## Realized activity 
realAct.Rout: realAct.R params.rda funs.rda

## Stack bar
slowtarget/stackbarSim.Rout: stackbarSim.R params.rda funs.rda
	$(pipeR)
stackbar.Rout: stackbar.R params.rda  slow/stackbarSim.rda


## IBM for Histplot

IBM_for_hist.Rout: IBM_for_hist.R funs.rda params.rda


slowtarget/IBM_for_histSim.Rout: IBM_for_histSim.R IBM_for_hist.rda params.rda
	$(pipeR)

rcHist.Rout: slow/IBM_for_histSim.rda params.rda


## Evolution of variance over time
slowtarget/RcTimePlotVaryingPeakSim.Rout: RcTimePlotVaryingPeakSim.R params.rda funs.rda
	$(pipeR)

slowtarget/RcTimePlotVaryingPeakObsSim.Rout: RcTimePlotVaryingPeakObsSim.R params.rda funs.rda
	$(pipeR)

RcTimePlotVaryingPeak.Rout: RcTimePlotVaryingPeak.R plotStyle.R slow/RcTimePlotVaryingPeakSim.rda params.rda
RcTimePlotVaryingPeakObs.Rout: RcTimePlotVaryingPeakObs.R plotStyle.R slow/RcTimePlotVaryingPeakObsSim.rda params.rda

## Some helper functions
funs.Rout: funs.R

## Setting parameters
params.Rout: params.R
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
-include makestuff/slowtarget.mk
-include makestuff/git.mk
-include makestuff/visual.mk
