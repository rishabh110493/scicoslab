//latexsubst
//Fonction qui effectue la convertion
//de caractères speciaux d'un tableau
//de chaîne de caractères pour un texte latex
//Entrée fields : tableau de chaîne de caractères
//Sortie fields : tableau de chaîne de caractères
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

  fields=strsubst(fields,'ö','\""o')
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
