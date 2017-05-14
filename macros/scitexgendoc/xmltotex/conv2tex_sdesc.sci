function tt_sdesc=conv2tex_sdesc(txt,typdoc)

  rhs=argn(2)
  if rhs<2 then
    typdoc='html'
  end

  tt_sdesc=[]

  if txt<>[] then
   tt_sdesc=latexsubst(txt)
  end

endfunction