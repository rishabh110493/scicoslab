//get_make_file_fig
//
//fonction qui retourne le texte pour compiler tous
//les fichiers .fig présent dans le répertoire courant
//en fichiers pstex/pstex_t
//
function txt=get_makefile_fig()

  txt=['FILEPSTEXT= $(patsubst %.fig,%.pstex_t,$(wildcard *.fig))'
       ''
       'all: $(FILEPSTEXT)'
       ''
       '$(FILEPSTEXT) : %.pstex_t : %.fig'
       ascii(9)+'fig2dev -L pstex $< $(patsubst %.fig,%.pstex,$<)'
       ascii(9)+'fig2dev -L pstex_t -p $(patsubst %.fig,%.pstex,$<) $< $@']

endfunction
