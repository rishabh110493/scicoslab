//latexsubst
//Fonction qui effectue la convertion
//de caract�res speciaux d'un tableau
//de cha�ne de caract�res pour un texte latex
//Entr�e fields : tableau de cha�ne de caract�res
//Sortie fields : tableau de cha�ne de caract�res
function fields=latexsubst(fields)

  fields=strsubst(fields,'<P>',' ')
  fields=strsubst(fields,'</P>',' \\')
  fields=strsubst(fields,'<VERB>','{\bf ')
  fields=strsubst(fields,'</VERB>','}')
  fields=strsubst(fields,'<LINK>','\textbf{')
  fields=strsubst(fields,'</LINK>','}')
  fields=strsubst(fields,'<VERBATIM>','\begin{verbatim}')
  fields=strsubst(fields,'</VERBATIM>','\end{verbatim}')
  fields=strsubst(fields,'<![CDATA[','')
  fields=strsubst(fields,']]>','')

  fields=strsubst(fields,'�','\""o')
  fields=strsubst(fields,'_','\_')
  fields=strsubst(fields,'%','\%')
  fields=strsubst(fields,'&','\&')
  fields=strsubst(fields,'^','\textasciicircum')
  fields=strsubst(fields,'$','\$')
  fields=strsubst(fields,'<','$<$')
  fields=strsubst(fields,'>','$>$')

  fields=strsubst(fields,'\&gt;','>')
  fields=strsubst(fields,'\&lt;','<')

endfunction
