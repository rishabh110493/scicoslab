function tt_bib=conv2tex_bib(txt,typdoc)

  rhs=argn(2)
  if rhs<2 then
    typdoc='html'
  end

  tt_bib=[]

  if txt<>[] then
     tt_bib=latexsubst(txt)
     tt_bib=['\begin{thebibliography}{}';
             tt_bib;
             '\end{thebibliography}']
  end

endfunction