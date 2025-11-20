## This is kappaCode created 2025 Nov 19 (Wed)
## Some of the code for Roswell-Weitz heterogeneity exploration
## Revisit what belongs here and what to do with it (e.g., R package?)

current: target
-include target.mk
Ignore = target.mk

vim_session:
	bash -cl "vmt"

## -include makestuff/perl.def

######################################################################

Sources += $(wildcard *.R)

lsCurves.Rout: lsCurves.R realAct.rda
	$(pipeR)

realAct.Rout: realAct.R funs.rda
	$(pipeR)

funs.Rout: funs.R
	$(pipeR)

densHist.Rout: densHist.R
	$(pipeR)

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
