
function txt=gen_sce_tex_file(lisf,typdoc,lind,%gd)

 bsnam=get_extname(lisf,%gd)
 bsrep=%gd.lang(lind)+'/'+bsnam

 //define title of paragraph
 tt_title=[
            ''                  //tt1  : header du fichier tex
           'Library'           //tt2  : library
           'Calling Sequence'  //tt3  : calling sequence
           'Parameters'        //tt4  : parameters
           'Description'       //tt5  : Description (_long)
           'Remarks'           //tt6  : Remarks 
           'Example'           //tt7  : Example (_ex)
           'Algorithm'         //tt8  : Algorithm (_algo)
           'File content'      //tt9  : text of funtion
           'Used function(s)'  //tt10 : Used functions (_used_func)
           'See Also'          //tt11 : See Also (_see_also)
           'Authors'           //tt12 : Authors (_authors)
           'Bibliography'      //tt13 : Bibliography (_bib)
           ''                  //tt14 : End of tex file
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

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_call_seq.tex')<>[] then
      tt3=[tex_title(3) //Calling sequence
           '\input{'+bsnam(i)+'_call_seq}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_param.tex')<>[] then
      tt4=[tex_title(4) //parameters
           '\input{'+bsnam(i)+'_param}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_long.tex')<>[] then
      tt5=[tex_title(5) //description
           ''
           '\input{'+bsnam(i)+'_long}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_rmk.tex')<>[] then
      tt6=[tex_title(6) //Remarks
           '\input{'+bsnam(i)+'_rmk}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_ex.tex')<>[] then
      tt7=[tex_title(7) //Example
           '\input{'+bsnam(i)+'_ex}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_algo.tex')<>[] then //Algorithm
      tt8=[tex_title(8)
           '\input{'+bsnam(i)+'_algo}']
    end

    tt9=[tex_title(9) //file content
         '{\tiny'
         '\verbatiminput{'+lisf(i,1)+lisf(i,2)+'}'
         '}']

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_used_func.tex')<>[] then
      tt10=[tex_title(10) //Used function
            '\input{'+bsnam(i)+'_used_func}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_see_also.tex')<>[] then
      tt11=[tex_title(11) //See also
           '\input{'+bsnam(i)+'_see_also}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_bib.tex')<>[] then
      tt13=['\input{'+bsnam(i)+'_bib}']; //bibliography
    end

  ////////////////////
  ///paper
  ////////////////////
  if typdoc=='guide' then
    //TO BE DONE
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

    tt1=[tt1;'\end{itemize}'];


  ////////////////////
  ///html
  ////////////////////
  elseif typdoc=='html' then

//     if %gd.lang(lind)=='fr' then //Header of tex file
//       tt1=['\documentclass[11pt,frenchb]{article}']
//     else
//       tt1=['\documentclass[11pt]{article}']
//     end

//     tt1=[tt1;
//          '\usepackage{makeidx,graphics,fullpage}'
//          '\usepackage{verbatim,times,amsmath,amssymb,epsfig,color}'
//          '\usepackage{html}'
//          ''
//          '\begin{document}'
//          ''
//          ' \begin{center}'
//          '   '+return_xml_type(%gd.mpath.xml(lind)+bsnam(i)+'.xml')+'\\';
//          '   \htmladdnormallink{eng}{../eng/'+bsnam(i)+'.htm}\hspace{2mm}-'+...
//          '   \hspace{2mm}\htmladdnormallink{fr}{../fr/'+bsnam(i)+'.htm}'
//          ' \end{center}'];
// 
//     newtitle=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam(i)+'.xml');
// 
//     tt1=[tt1;' \section{\textbf{'+latexsubst(newtitle(1,1))+...
//              '} - '+latexsubst(newtitle(1,2))+'}\label{'+newtitle(1,2)+'}'
//              ''];

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_authors.tex')<>[] then
      tt12=[tex_title(12) //authors
            '\input{'+bsnam(i)+'_authors}']
    end
    tt14=['\htmlinfo*';'\end{document}']
  end

  //Write the main tex file of scilab macro
  txt=[];
  for j=1:size(tt_title,1)
     txt=[txt;evstr('tt'+string(j))]
  end
  mputl(txt,bsrep(i)+'/'+bsnam(i)+'.tex');

 end

endfunction
