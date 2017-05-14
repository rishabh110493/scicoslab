SHELL = /bin/sh

include ../../Path.incl
include ../../Makefile.incl

all:: 
	@echo -n Building macros
	@../../bin/scilab -nwni -nb -ns -e "load('SCI/macros/util/lib');exec('buildmacros.sce');quit;"
	@echo "... done"

release :: all

distclean::
	@$(RM) *.bin lib names 


