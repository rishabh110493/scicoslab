SHELL=/bin/sh

SCIDIR=../../

include $(SCIDIR)/Makefile.incl

all	:: builder.sce 
	@echo "running builder (be patient)"
	@$(SCIDIR)/bin/scilab -nw -e "exec('builder.sce');quit"  ; 	
	@echo "At prompt, enter:";
	@echo "-->exec loader.sce";
	@echo "----------------------------------------------------";

clean	::
	cd macros ; make clean 

distclean:: clean 
	cd macros ; make distclean 




