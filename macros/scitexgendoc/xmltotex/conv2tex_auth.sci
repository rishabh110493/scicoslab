function tt_auth=conv2tex_auth(txt,typdoc)

  rhs=argn(2)
  if rhs<2 then
    typdoc='html'
  end

  tt_auth=[]

  if txt<>[] then
   if size(txt,1)<>1 then //multi authors
     tt_auth=['\begin{itemize}']
     for j=1:size(txt,1)
       if txt(j,3) <> "" then //with a mailto
         tt_auth=[tt_auth;
                  '  \item '+ '\htmladdnormallink{'+ ...
                     latexsubst(txt(j,1)) + '}{' + ...
                      'mailto:' + txt(j,3) + '}' + ...
                      ' ' + latexsubst(txt(j,2))
                 ]
       else
         tt_auth=[tt_auth;
                  '  \item '+ '\textbf{'+ ...
                     latexsubst(txt(j,1)) + '}' + ...
                      ' ' + latexsubst(txt(j,2))
                 ]
       end
     end
     tt_auth=[tt_auth;'\end{itemize}']
   else //single author
    if size(txt,2)<>1 then //with authors
       if txt(1,3) <> "" then //with a mailto
        tt_auth='\htmladdnormallink{'+ ...
                     latexsubst(txt(1,1)) + '}{' + ...
                      'mailto:' + txt(1,3) + '}' + ...
                      ' ' + latexsubst(txt(1,2))
       else
        tt_auth='\textbf{'+ ...
                     latexsubst(txt(1,1)) + '}' + ...
                      ' ' + latexsubst(txt(1,2))
       end
     else
      tt_auth=latexsubst(txt)
     end
   end
  end

endfunction