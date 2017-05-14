function tt_cseq=conv2tex_cseq(txt,typdoc)

  rhs=argn(2)
  if rhs<2 then
    typdoc='html'
  end

  tt_cseq=[]

  if txt<>[] then
     tt_cseq=['\begin{verbatim}';
              txt
              '\end{verbatim}'];
  end

endfunction