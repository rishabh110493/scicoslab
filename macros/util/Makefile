SHELL = /bin/sh

include ../../Path.incl
include ../../Makefile.incl

all:: 
	@echo -n Building macros
	@../../bin/scilab -nwni -ns -nb -e "exec('buildmacros.sce');quit;"
	@echo "... done"

release :: all

distclean::
	$(RM) *.bin

