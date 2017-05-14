SHELL=/bin/sh

SCIDIR=../../

include $(SCIDIR)/Makefile.incl

all	:: builder.sce 
	@echo "running builder (be patient)"
	@$(SCIDIR)/bin/scilab -nw -e "exec('builder.sce');quit"> /dev/null
	@echo "At prompt, enter:";
	@echo "-->exec loader.sce";
	@echo "----------------------------------------------------";

clean	::
	cd src; make clean 
	cd macros ; make clean 
	cd metanet ; make clean 

distclean:: clean 
	cd src; make distclean 
	cd macros ; make distclean 
	cd metanet ; make distclean 




