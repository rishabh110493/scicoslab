# Makefile generate from template rtai.mak
# ========================================

all: ../semsig

RTAIDIR = $(shell rtai-config --prefix)
C_FLAGS = $(shell rtai-config --lxrt-cflags)
SCIDIR = /usr/lib/scicoslab-gtk-4.4.1
COMEDIDIR = $(shell rtai-config --comedi-dir)
ifneq ($(strip $(COMEDIDIR)),)
COMEDILIB = -lcomedi
endif 

RM = rm -f
FILES_TO_CLEAN = *.o ../semsig

CC = gcc
CC_OPTIONS = -O -DNDEBUG -Dlinux -DNARROWPROTO -D_GNU_SOURCE

MODEL = semsig
OBJSSTAN = rtmain44.o common.o semsig.o semsig_Cblocks.o

SCILIBS = $(SCIDIR)/libs/scicos.a $(SCIDIR)/libs/poly.a $(SCIDIR)/libs/calelm.a $(SCIDIR)/libs/blas.a $(SCIDIR)/libs/lapack.a $(SCIDIR)/libs/blas.a $(SCIDIR)/libs/os_specific.a
OTHERLIBS = 
ULIBRARY = $(RTAIDIR)/lib/libsciblk.a $(RTAIDIR)/lib/liblxrt.a

CFLAGS = $(CC_OPTIONS) -O2 -I$(SCIDIR)/routines -I$(SCIDIR)/routines/scicos $(C_FLAGS) -DMODEL=$(MODEL) -DMODELN=$(MODEL).c

rtmain44.c: $(RTAIDIR)/share/rtai/scicos/rtmain44.c $(MODEL).c
	cp $< .

../semsig: $(OBJSSTAN) $(ULIBRARY)
	gcc -static -o $@  $(OBJSSTAN) $(SCILIBS) $(ULIBRARY) -lpthread $(COMEDILIB) -lgfortran -lm
	@echo "### Created executable: $(MODEL) ###"

clean::
	@$(RM) $(FILES_TO_CLEAN)
