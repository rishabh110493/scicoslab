//get_make_file_tex
//
//fonction qui retourne le texte pour
//le makefile d'un répertoire tex
//
function txt=get_makefile_tex()

  txt=['FILES_TO_CLEAN = *~ *.bak *.backup *.pstex '+...
         '*tex~ *.pstex_t *.aux *.bbl *.blg *.dvi *.log *.toc'
       'SUBDIRS = fig'
       ''
       'fig::'
       ascii(9)+'@if test -d fig; then \'
       ascii(9)+ascii(9)+'cd fig; $(MAKE) all; \'
       ascii(9)+'fi'
       ''
       'all::'
       ascii(9)+'@for i in $(SUBDIRS) ;\'
       ascii(9)+'do \'
       ascii(9)+ascii(9)+'(if test -d $${i}; then \'
       ascii(9)+ascii(9)+ascii(9)+'cd $$i ; $(MAKE) $(MFLAGS) all; \'
       ascii(9)+ascii(9)+'fi);\'
       ascii(9)+'done'
       ''
       ascii(9)+'@if test -d fig; then \'
       ascii(9)+ascii(9)+'mv ./fig/*.pstex .; \'
       ascii(9)+ascii(9)+'mv ./fig/*.pstex_t .; \'
       ascii(9)+'fi'
       ''
       ascii(9)+'@if test -d eps; then \'
       ascii(9)+ascii(9)+'cp ./eps/*.eps .; \'
       ascii(9)+ascii(9)+'cp ./eps/*.gif .; \'
       ascii(9)+'fi'
       ''
       'clean::'
       ascii(9)+'@for i in $(SUBDIRS) ;\'
       ascii(9)+'do \'
       ascii(9)+ascii(9)+'(if test -d $${i}; then \'
       ascii(9)+ascii(9)+ascii(9)+'cd $$i ; $(RM) $(FILES_TO_CLEAN); \'
       ascii(9)+ascii(9)+'fi);\'
       ascii(9)+'done'
       ascii(9)+'@$(RM) $(FILES_TO_CLEAN)'
       '']

endfunction
