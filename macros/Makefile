SHELL = /bin/sh

include ../Path.incl
include ../Makefile.incl

CFLAGS = $(CC_OPTIONS) 

all:: Progs 
	../bin/scilab -nwni -ns -f buildmacros.sce


release : Progs
	../bin/scilab -nwni -ns -f buildmacros.sce

distclean::
	@$(RM) Lib Name Gengatsce Gensosce Gensomex Tomake Forwin
	@$(RM) Lib.o Name.o Gengatsce.o Gensosce.o Gesomex.o Tomake.o Forwin.o
	@find . -name '*.bin' -exec rm -f {} \;
	@find . -name '*.moc' -exec rm -f {} \;

Progs : Lib Name Gengatsce Gensosce Gensomex Tomake Forwin

Lib:  Lib.c 
	@$(RM) $@
	@echo compiling $?
	@$(CC) $(CFLAGS) -o $@ $?  $(CC_LDFLAGS) 

Name:  Name.c 
	@$(RM) $@
	@echo compiling $?
	@$(CC) $(CFLAGS) -o $@ $?  $(CC_LDFLAGS) 

Gengatsce:  Gengatsce.c 
	@$(RM) $@
	@echo compiling $?
	@$(CC) $(CFLAGS) -o $@ $?  $(CC_LDFLAGS) 

Gensosce:  Gensosce.c 
	@$(RM) $@
	@echo compiling $?
	@$(CC) $(CFLAGS) -o $@ $?  $(CC_LDFLAGS) 

Gensomex:  Gensomex.c 
	@$(RM) $@
	@echo compiling $?
	@$(CC) $(CFLAGS) -o $@ $?  $(CC_LDFLAGS) 

Tomake:  Tomake.c 
	@$(RM) $@
	@echo compiling $?
	@$(CC) $(CFLAGS) -o $@ $?  $(CC_LDFLAGS) 

Forwin:  Forwin.c 
	@$(RM) $@
	@echo compiling $?
	@$(CC) $(CFLAGS) -o $@ $?  $(CC_LDFLAGS) 





