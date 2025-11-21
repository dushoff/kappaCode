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

## Lloyd-Smith curves (first part of linearized figure)
## This is a bad name; maybe it was intended for the second part?
lsCurves.Rout: lsCurves.R realAct.rda
	$(pipeR)

## Realized activity 
realAct.Rout: realAct.R funs.rda
	$(pipeR)

## Some helper functions
funs.Rout: funs.R
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
