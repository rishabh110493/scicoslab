function tt_desc=conv2tex_desc(txt_list,typdoc)

  rhs=argn(2)
  if rhs<2 then
    typdoc='html'
  end

  tt_desc=[]

  if txt_list<>[] then

    n=1; //profondeur d'indentation

    for i=1:size(txt_list(2),1)
      if txt_list(2)(i)>n then
        for j=1:txt_list(2)(i)-n
          tt_desc=[tt_desc;'\begin{quotation}'}
        end
        n=txt_list(2)(i);
      end

      if i>1 & txt_list(2)(i)<n then
        for j=1:n-txt_list(2)(i)
          tt_desc=[tt_desc;'\end{quotation}'}
        end
        n=txt_list(2)(i);
      end

      if txt_list(3)(i,1)<>"" then
        tt_desc=[tt_desc;'\textbf{'+...
                 latexsubst(txt_list(3)(i,1))+' }'+...
                 latexsubst(txt_list(3)(i,2));'']
      else
        if txt_list(3)(i,2)<>"" then
          tt_desc=[tt_desc;
                   latexsubst(txt_list(3)(i,2));'']
        end
      end
    end

    if n>1 then
      for j=1:(n-1)
        tt_desc=[tt_desc;
                 '\end{quotation}']
      end
    end

  end

endfunction