//gen_sim_tex_file
//
//Fonction qui génère le fichier tex principal
//d'une page de documentation d'un script de 
//simulation scilab

function txt=gen_sim_tex_file(lisf,typdoc,lind,%gd)

 bsnam=get_extname(lisf,%gd)
 bsrep=%gd.lang(lind)+'/'+bsnam

 //define title of paragraph
 tt_title=[
           ''                      //tt1  : header du fichier tex
           'Module'                //tt2  : Module
           'Description'           //tt3  : Description (_long)
           'Algorithm'             //tt4  : Algorithm (_algo)

           'Scicos diagram(s)'     //tt7 5 : scicos diagram(s) (_diagr)
           'Context file(s)'       //tt8 6: file of context(s) (_context)
           'Used blocks'           //tt9 7 : Mod num blocks (_block)

           'Simulation script(s)'  //tt5  8: simulation script(s) (_sim_script)
           'Scope results'         //tt6  9: Scope results (_scop)

           'Used function'         //tt10 : used functions (_used_func)
           'See Also'              //tt11 : See Also (_see_also)
           'Authors'               //tt12 : Authors (_authors)
           'Bibliography'          //tt13 : Bibliography (_bib)
           ''                      //tt14 : End of tex file
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

 for i=1:size(lisf,1)
    for j=1:size(tt_title,1)
      execstr('tt'+string(j)+'=[]')
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_head.tex')<>[] then //header
      tt1=['\input{'+bsnam(i)+'_head}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_long.tex')<>[] then //Description
      tt3=[tex_title(3)
           ''
           '\input{'+bsnam(i)+'_long}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_algo.tex')<>[] then //algorithm
      tt4=[tex_title(4)
           '\input{'+bsnam(i)+'_algo}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_diagrs.tex')<>[] then //Scicos diagram(s)
      tt5=[tex_title(5)
           '\input{'+bsnam(i)+'_diagrs}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_ctxt.tex')<>[] then //Context file(s)
      tt6=[tex_title(6)
           '\input{'+bsnam(i)+'_ctxt}'] 
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_block.tex')<>[] then //mod_num block
      tt7=[tex_title(7)
           '\input{'+bsnam(i)+'_block}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_script.tex')<>[] then //Simulation scripts
      tt8=[tex_title(8)
           '\input{'+bsnam(i)+'_script}'] 
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_scop.tex')<>[] then //scop
      tt9=[tex_title(9)
           '\input{'+bsnam(i)+'_scop}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_used_func.tex')<>[] then //Used function
      tt10=[tex_title(10)
            '\input{'+bsnam(i)+'_used_func}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_see_also.tex')<>[] then //see also
      tt11=[tex_title(11)
            '\input{'+bsnam(i)+'_see_also}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_bib.tex')<>[] then //bibliography
      tt13=['\input{'+bsnam(i)+'_bib.tex}']
    end

    if typdoc=='guide' then
//       newtitle=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam(i)+'.xml')
// 
//       tt1=['\section{'+latexsubst(newtitle(1,2))+...
//            '}\label{'+newtitle(1,1)+'}'];

    elseif typdoc=='html' then

      if fileinfo(bsrep(i)+'/'+bsnam(i)+'_mod.tex')<>[] then //module
        tt2=[tex_title(2)
             '\input{'+bsnam(i)+'_mod}']
      end

//       if %gd.lang(lind)=='fr' then //Header of tex file
//         tt1=['\documentclass[11pt,frenchb]{article}']
//       else
//         tt1=['\documentclass[11pt]{article}']
//       end

      if fileinfo(bsrep(i)+'/'+bsnam(i)+'_authors.tex')<>[] then //authors
         tt12=[tex_title(12)
               '\input{'+bsnam(i)+'_authors}']
      end

      tt14=['\htmlinfo*';'\end{document}']
    end

    //Generate the main tex file of simulation script
    txt=[]
    for j=1:size(tt_title,1)
       txt=[txt;evstr('tt'+string(j))]
    end

    mputl(txt,bsrep(i)+'/'+bsnam(i)+'.tex')

 end

endfunction
