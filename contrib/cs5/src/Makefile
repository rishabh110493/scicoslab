ROOT_DIR=../../..

SHELL = /bin/sh
include $(ROOT_DIR)/Path.incl 

include $(SCIDIR)/Makefile.incl

all	:: Makelib job 
	make -f Makelib

Makelib : builder.sce
	@echo running builder 
	@$(SCIDIR)/bin/scilab -nw -e "exec('builder.sce');quit"

job	: 
	make -f Makelib

tests	: all
	make -f Makelib tests 

clean	::
	@echo Cleaning 
	@$(RM) -f -r *.o *.lo  *.so .libs

distclean:: clean 
	@$(RM) -f Makelib 
	@$(RM) -f *.dia  *_gateway.c 










