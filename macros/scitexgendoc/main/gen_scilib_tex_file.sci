function txt=gen_scilib_tex_file(lisf,typdoc,lind,%gd)

 bsnam=get_extname(lisf,%gd)
 bsrep=%gd.lang(lind)+'/'+bsnam

 //define title of paragraph
 tt_title=[
           ''                 //tt1  : header du fichier tex
           'Module'           //tt2  : Module
           'Description'      //tt3  : Description (_long)
           'Scilab functions' //tt4  : Scilab functions (_sci_func)
           'See Also'         //tt5  : See Also(_see_also)
           'Authors'          //tt6  : Authors (_authors)
           ''                 //tt7  : End of tex file
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

   for j=1:size(tt_title,1) //for each paragraph
     execstr('tt'+string(j)+'=[]')
   end

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_head.tex')<>[] then //header
     tt1=['\input{'+bsnam(i)+'_head}']
   end

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_long.tex')<>[] then
     tt3=[tex_title(3) //Description
          ''
          '\input{'+bsnam(i)+'_long}']
   end

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_sci_func.tex')<>[] then
      tt4=[tex_title(4) //scilab functions
           '\input{'+bsnam(i)+'_sci_func}']
   end

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_see_also.tex')<>[] then
      tt5=[tex_title(5) //see also
           '\input{'+bsnam(i)+'_see_also}']
   end

   if typdoc=='guide' then

     LibName=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam(i)+'.xml');

     tt1=['\chapter{'+latexsubst(LibName(1,2))+'}\label{'+LibName(1,1)+'}']

   elseif typdoc=='html' then

     if fileinfo(bsrep(i)+'/'+bsnam(i)+'_mod.tex')<>[] then //module
       tt2=[tex_title(2)
            '\input{'+bsnam(i)+'_mod}']
     end

     if fileinfo(bsrep(i)+'/'+bsnam(i)+'_authors.tex')<>[] then
       tt6=[tex_title(6)
            '\input{'+bsnam(i)+'_authors}']
     end

     tt7=['\htmlinfo*';'\end{document}']

   end
   txt=[];

   for j=1:size(tt_title,1)
     txt=[txt;evstr('tt'+string(j))]
   end

   mputl(txt,bsrep(i)+'/'+bsnam(i)+'.tex')
 end

endfunction
