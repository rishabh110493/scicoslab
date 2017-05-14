function tt_ex=conv2tex_ex(txt,typdoc)

  rhs=argn(2)
  if rhs<2 then
    typdoc='html'
  end

  tt_ex=[]

  if txt<>[] then
     tt_ex=['\begin{verbatim}';
            txt
            '\end{verbatim}'];
  end

endfunction