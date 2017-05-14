function tt_param=conv2tex_param_in(txt_list,typdoc)

  rhs=argn(2)
  if rhs<2 then
    typdoc='html'
  end

  tt_param=[]

  if txt_list<>[] then
     tt_param=[];
     pre_i=0; //indentation précédente
     for i=1:size(txt_list(1),1)
        dif_i=txt_list(2)(i)-pre_i;
        if dif_i<>0 then
          if dif_i>0 then
            for j=1:dif_i
              tt_param=[tt_param;'\begin{itemize}'];
            end
          elseif dif_i<0 then
            for j=-1:-1:dif_i
              tt_param=[tt_param;'\end{itemize}'];
            end
          end
        end
        pre_i=txt_list(1)(i);
        titlep=retrieve_xml_char(txt_list(3)(i,1));
//        descp=retrieve_xml_char(txt_list(3)(i,2));
//         if flag=='block' then
//            tt_param=[tt_param;
//                      '  \item{\textbf{'+...
//                         latexsubst(titlep)+...
//                         ' :}}\linebreak';
//                      latexsubst(descp);];
//         else
        tt_param=[tt_param;
                  '\item{\textbf{'+...
                      latexsubst(titlep)+...
                  ' :}}';]
        //disp('ici');pause
        for j=1:size(txt_list(4)(i))
          if j<>1 then
            tt_param($)=tt_param($)+'\\';
          end
          tt_param=[tt_param;
                    '   '+..
                   latexsubst(retrieve_xml_char(txt_list(4)(i)(j)));];
        end
     end

     dif_i=-pre_i;
     if dif_i<0 then
       for j=-1:-1:dif_i
         tt_param=[tt_param;'\end{itemize}'];
       end
     end

     if typdoc=='guide' then
      tt_param=strsubst(tt_param,'\linebreak','\\');
     end
  end

endfunction