//gene_sci_tex_file

function txt=gen_sci_tex_file(lisf,typdoc,lind,%gd)

 bsnam=get_extname(lisf,%gd)
 bsrep=%gd.lang(lind)+'/'+bsnam

 //define title of paragraph
 tt_title=[
           ''                  //tt1  : header du fichier tex
           'Module'            //tt2  : module
           'Library'           //tt3  : library
           'Calling Sequence'  //tt4  : calling sequence
           'Parameters'        //tt5  : parameters
           'Description'       //tt6  : Description (_long)
           'Remarks'           //tt7  : Remarks 
           'Example'           //tt8  : Example (_ex)
           'Algorithm'         //tt9  : Algorithm (_algo)
           'File content'      //tt10 : text of function
           'Used function(s)'  //tt11 : Used functions (_used_func)
           'See Also'          //tt12 : See Also (_see_also)
           'Authors'           //tt13 : Authors (_authors)
           'Bibliography'      //tt14 : Bibliography (_bib)
           ''                  //tt15 : End of tex file
          ]

 //change language of title
//  if %gd.lang(lind)=='fr' then
 tt_title=change_lang_title(%gd.lang(lind),tt_title);
//  end

 //define level of paragraph
 if typdoc=='html' then
  tex_title='\subsection{'+tt_title+'}'
 else
  tex_title='\subsection{'+tt_title+'}'
 end

 for i=1:size(lisf,1) //for each file

    for j=1:size(tt_title,1) //for each paragraph
      execstr('tt'+string(j)+'=[]')
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_head.tex')<>[] then //header
      tt1=['\input{'+bsnam(i)+'_head}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_long.tex')<>[] then
      tt4=[tex_title(6) //description
           ''
           '\input{'+bsnam(i)+'_long}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_call_seq.tex')<>[] then
      tt5=[tex_title(4) //Calling sequence
           '\input{'+bsnam(i)+'_call_seq}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_param.tex')<>[] then
      tt6=[tex_title(5) //parameters
           '\input{'+bsnam(i)+'_param}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_rmk.tex')<>[] then
      tt7=[tex_title(7) //Remarks
           '\input{'+bsnam(i)+'_rmk}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_ex.tex')<>[] then
      tt8=[tex_title(8) //Example
           '\input{'+bsnam(i)+'_ex}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_algo.tex')<>[] then //Algorithm
      tt9=[tex_title(9)
           '\input{'+bsnam(i)+'_algo}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+...
                 '_scifunc.tex')<>[] then //scilab Function
      tt10=[tex_title(10) //file content
              '\input{'+bsnam(i)+'_scifunc}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_used_func.tex')<>[] then
      tt11=[tex_title(11) //Used function
            '\input{'+bsnam(i)+'_used_func}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_see_also.tex')<>[] then
      tt12=[tex_title(12) //See also
           '\input{'+bsnam(i)+'_see_also}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_bib.tex')<>[] then
      tt14=['\input{'+bsnam(i)+'_bib}']; //bibliography
    end

  ////////////////////
  ///paper
  ////////////////////
  if typdoc=='guide' then

    newtitle=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam(i)+'.xml');
    newtitle(1,2)=convstr(part(newtitle(1,2),1),'u')+...
                   part(newtitle(1,2),2:length(newtitle(1,2)));

//     tt1=['\section{'+latexsubst(newtitle(1,2))+...
//                 '\label{'+newtitle(1,1)+'}} ';
//          '\begin{itemize}';]

    tt1=[tt1;'\begin{itemize}';]

    if %gd.lang(lind)=='fr' then
       tt1=[tt1;'\item \textbf{Nom:} '+latexsubst(newtitle(1,1))];
    else
       tt1=[tt1;'\item \textbf{Name:} '+latexsubst(newtitle(1,1))];
    end

    LibName = whereis(newtitle(1,1));
    if LibName<>[] then
        tta=return_xml_sdesc(%gd.mpath.xml(lind)+...
                               LibName+'_'+%gd.ext.scilib+'.xml')
        if tta<>[] then
           tt1=[tt1;'\item \textbf{'+tex_title(2)+':} '+...
                    latexsubst(LibName)+' - '+latexsubst(tta)]
        else
           tt1=[tt1;'\item \textbf{'+tex_title(2)+':} '+...
                    latexsubst(LibName)]
        end

    end

    tt1=[tt1;'\end{itemize}'];


  ////////////////////
  ///html
  ////////////////////
  elseif typdoc=='html' then

    newtitle=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam(i)+'.xml');

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_lib.tex')<>[] then //librray
       tt3=[tex_title(3)
            '\input{'+bsnam(i)+'_lib}']
    else
       if fileinfo(bsrep(i)+'/'+bsnam(i)+'_mod.tex')<>[] then //module
         tt2=[tex_title(2)
              '\input{'+bsnam(i)+'_mod}']
       end
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_authors.tex')<>[] then
      tt13=[tex_title(13) //authors
            '\input{'+bsnam(i)+'_authors}']
    end
    tt15=['\htmlinfo*';'\end{document}']
  end

  //Write the main tex file of scilab macro
  txt=[];
  for j=1:size(tt_title,1)
     txt=[txt;evstr('tt'+string(j))]
  end
  mputl(txt,bsrep(i)+'/'+bsnam(i)+'.tex');

 end
endfunction
