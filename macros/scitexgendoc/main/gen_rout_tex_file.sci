//gen_rout_tex_file

function txt=gen_rout_tex_file(lisf,typdoc,lind,%gd)

 bsnam=get_extname(lisf,%gd)
 bsrep=%gd.lang(lind)+'/'+bsnam

  //tt1  : header
  //tt2  : Module
  //tt3  : library
  //tt4  : calling Sequence
  //tt5  : parameters
  //tt6  : description
  //tt7  : example
  //tt8  : text of function
  //tt9  : used functions
  //tt10 : see also
  //tt11 : Authors
  //tt12 : Bibliography
  //tt13 : end of tex file

  //define title of paragraph
  tt_title=[
           ''                  //tt1  : header du fichier tex
           'Module'            //tt2  : Module
           'Library'           //tt3  : library
           'Calling Sequence'  //tt4  : calling sequence
           'Parameters'        //tt5  : parameters
           'Description'       //tt6  : Description (_long)
           'Example'           //tt7  : Example (_ex)
           'File content'      //tt8  : text of funtion
           'Used function(s)'  //tt9  : Used functions (_used_func)
           'See Also'          //tt10 : See Also (_see_also)
           'Authors'           //tt11 : Authors (_authors)
           ''                  //tt12 : Bibliography (_bib)
           ''                  //tt13 : End of tex file
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

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_call_seq.tex')<>[] then
      tt4=[tex_title(4) //Calling sequence
           '\input{'+bsnam(i)+'_call_seq}']
   end

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_param.tex')<>[] then
      tt5=[tex_title(5) //parameters
           '\input{'+bsnam(i)+'_param}']
   end

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_long.tex')<>[] then
      tt6=[tex_title(6) //description
           ''
           '\input{'+bsnam(i)+'_long}']
   end

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_ex.tex')<>[] then
      tt7=[tex_title(7) //Example
           '\input{'+bsnam(i)+'_ex}']
   end

   tt8=[tex_title(8) //file content
        '{\tiny'
        '\verbatiminput{'+lisf(1,1)+lisf(1,2)+'}'
        '}']

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_used_func.tex')<>[] then
      tt9=[tex_title(9) //Used function
           '\input{'+bsnam(i)+'_used_func}']
   end

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_see_also.tex')<>[] then
      tt10=[tex_title(10) //See also
           '\input{'+bsnam(i)+'_see_also}']
   end

   if fileinfo(bsrep(i)+'/'+bsnam(i)+'_bib.tex')<>[] then
      tt12=['\input{'+bsnam(i)+'_bib.tex}'] //bibliography
   end

   if typdoc=='guide' then

     newtitle=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam(i)+'.xml')
      //TO BE DONE
//      tt1=['\section{'+latexsubst(newtitle(1,1))+'\label{'+newtitle(1,1)+'}} ';
//           '\begin{itemize}';]

     tt1=[tt1;'\begin{itemize}';]

     if %gd.lang(lind)=='fr' then
          tt1=[tt1;'\item \textbf{Description courte:} '+latexsubst(newtitle(1,2))];
     else
          tt1=[tt1;'\item \textbf{Short description:} '+latexsubst(newtitle(1,2))];
     end

     tt1=[tt1;'\end{itemize}'];

   elseif typdoc=='html' then

     if fileinfo(bsrep(i)+'/'+bsnam(i)+'_mod.tex')<>[] then //module
       tt2=[tex_title(2)
            '\input{'+bsnam(i)+'_mod}']
     end

     if fileinfo(bsrep(i)+'/'+bsnam(i)+'_authors.tex')<>[] then
       tt11=[tex_title(11) //authors
             '\input{'+bsnam(i)+'_authors}']
     end

     tt13=['\htmlinfo*';'\end{document}']

   end

   //Generate the main tex file of routine
   txt=[];
   for j=1:size(tt_title,1)
     txt=[txt;evstr('tt'+string(j))]
   end
   mputl(txt,bsrep(i)+'/'+bsnam(i)+'.tex');

 end
endfunction
