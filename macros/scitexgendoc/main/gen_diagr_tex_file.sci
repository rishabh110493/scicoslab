//gen_diagr
//Fonction qui génère le fichier tex principal
//d'une page de documentation d'un diagramme
//scicos.

function gen_diagr_tex_file(lisf,typdoc,lind,%gd)

 bsnam=get_extname(lisf,%gd)
 bsrep=%gd.lang(lind)+'/'+bsnam

 //define title of paragraph
 tt_title=[
           ''                //tt1  : header du fichier tex
           ''                //tt2  : Diagram (_diagr)
           'Module'          //tt3  : Module
           'Description'     //tt4  : Description (_long)
           'Context'         //tt5  : context (_ctxt)
           'Scope Results'   //tt6  : Scope results (_scop)
           ''                //tt7  : scilab script file (not programmed)
           'Used blocks'     //tt8  : Used blocks (_block)
           'See Also'        //tt9  : See Also (_see_also)
           'Authors'         //tt10 : Authors (_authors)
           'Bibliography'    //tt11 : Bibliography (_bib)
           ''                //tt12 : End of tex file
          ]

 //change language of title
//  if %gd.lang(lind)=='fr' then
 tt_title=change_lang_title(%gd.lang(lind),tt_title);
//  end

 //define level of paragraph
 tex_title='\subsection{'+tt_title+'}';

 for i=1:size(lisf,1)

    for j=1:size(tt_title,1)
      execstr('tt'+string(j)+'=[]')
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_head.tex')<>[] then //header
      tt1=['\input{'+bsnam(i)+'_head}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_diagrs.tex')<>[] then //figure
      tt2=['\input{'+bsnam(i)+'_diagrs}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_long.tex')<>[] then //Description
      tt4=[tex_title(4)
           ''
           '\input{'+bsnam(i)+'_long}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_ctxt.tex')<>[] then //context
      tt5=[tex_title(5)
          '{\tiny'
          '\verbatiminput{'+bsnam(i)+'_ctxt}'
         '}'] 
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_scop.tex')<>[] then //scop
      tt6=[tex_title(6)
           '\input{'+bsnam(i)+'_scop}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_block.tex')<>[] then //mod_num block
      tt8=[tex_title(8)
           '\input{'+bsnam(i)+'_block}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_see_also.tex')<>[] then //see also
      tt9=[tex_title(9)
           '\input{'+bsnam(i)+'_see_also}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_bib.tex')<>[] then //bibliography
     tt11=['\input{'+bsnam(i)+'_bib.tex}']
    end

    if typdoc=='guide' then
//        newtitle=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam(i)+'.xml')
// 
//        tt1=['\section{'+latexsubst(newtitle(1,2))+...
//             '}\label{'+newtitle(1,1)+'}']

    elseif typdoc=='html' then

       if fileinfo(bsrep(i)+'/'+bsnam(i)+'_mod.tex')<>[] then //module
         tt3=[tex_title(3)
              '\input{'+bsnam(i)+'_mod}']
       end

       if fileinfo(bsrep(i)+'/'+bsnam(i)+'_authors.tex')<>[] then //authors
         tt10=[tex_title(10)
               '\input{'+bsnam(i)+'_authors}']
       end

       tt12=['\htmlinfo*';'\end{document}']
    end

    //Generate the main tex file of block
    txt=[]
    for j=1:size(tt_title,1)
       txt=[txt;evstr('tt'+string(j))]
    end

    mputl(txt,bsrep(i)+'/'+bsnam(i)+'.tex')
 end

endfunction
