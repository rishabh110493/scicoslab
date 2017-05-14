//Fonction qui génère le fichier tex principal
//d'un bloc scicos

function gen_block_tex_file(lisf,typdoc,lind,%gd)

 bsnam=get_extname(lisf,%gd)
 bsrep=%gd.lang(lind)+'/'+bsnam

 //define title of paragraph
 tt_title=[
           ''                       //tt1  : header du fichier tex
           ''                       //tt2  : figure du block (.eps)
           'Palette'                //tt3  : Palette
           'Theorical background'   //tt4  : Theorical background (_theo_bkg)
           'Technical background'   //tt5  : Technical background (_tec_bkg)
           'Description'            //tt6  : Description (_long)
           'Algorithm'              //tt7  : Algorithm (_algo)
           'Basic blocks equivalent'+...
                     ' model'       //tt8  : Figure du super block equiv. (sbeq)
           'Scilab script/function'+...
                ' equivalent Model' //tt9  : Scilab script equivalent (sci_equiv)
           'Dialog box'             //tt10 : Dialog box (_dial_box,_param)
           'Example'                //tt11 : Example (_ex)
           'Default properties'     //tt12 : Default properties (_def_prop)
           'Interfacing function'   //tt13 : Interfacing function (_int_func)
           'Computational function' //tt14 : Computational function (_comput)
           'Compiled Super Block'+...
                   ' content'       //tt15 : Compiled Super Block (_scomput)
           'Used functions'         //tt16 : Used functions (_used_func)
           'Pair Block'             //tt17 : Pair Block (_pair_blk)
           'See also'               //tt18 : See Also (_see_also)
           'Authors'                //tt19 : Authors (_authors)
           'Bibliography'           //tt20 : Bibliography (_bib)
           ''                       //tt21 : End of tex file
          ]

 //change language of title
 tt_title=change_lang_title(%gd.lang(lind),tt_title);

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

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_blocks.tex')<>[] then //figure block
      tt2=['\input{'+bsnam(i)+'_blocks}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_theo_bkg.tex')<>[] then //Theorical background
       tt4=[tex_title(4)
            '\input{'+bsnam(i)+'_theo_bkg}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_tec_bkg.tex')<>[] then //Technical backgroung
       tt5=[tex_title(5)
            '\input{'+bsnam(i)+'_tec_bkg}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_long.tex')<>[] then //Description
       tt6=[tex_title(6)
            ''
            '\input{'+bsnam(i)+'_long}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_algo.tex')<>[] then //Algorithm
       tt7=[tex_title(7)
             '\input{'+bsnam(i)+'_algo}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_sbeq.tex')<>[] then  //Super Block
       tt8=[tex_title(8)
             '\input{'+bsnam(i)+'_sbeq}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_sci_equiv.tex')<>[] then //Scilab script
       tt9=[tex_title(9)
             '\input{'+bsnam(i)+'_sci_equiv}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_dial_box.tex')<>[] then //Dialog box
       tt10=[tex_title(10)
              '\input{'+bsnam(i)+'_dial_box}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_param.tex')<>[] then //Parameters
       tt10=[tt10;'';'\input{'+bsnam(i)+'_param}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_ex.tex')<>[] then //Example
       tt11=[tex_title(11)
             '\input{'+bsnam(i)+'_ex}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_comput.tex')<>[] then //Computational Function
//        if fileinfo(bsrep(i)+'/'+bsnam(i)+'_comput_typ.tex')<>[] then
//          typb=mgetl(bsrep(i)+'/'+bsnam(i)+'_comput_typ.tex');
//          tt14=['\subsection{'+tt_title(14)+...
//                   ' (type '+typb+')}'
//                '\input{'+bsnam(i)+'_comput}'] //Warning!
//        else
         tt14=[tex_title(14)
               '\input{'+bsnam(i)+'_comput}'] //Warning!
//        end
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_scomput.tex')<>[] then //Computational Function
       tt15=[tex_title(15)
             '\input{'+bsnam(i)+'_scomput}'] //Warning!
    end

//     if fileinfo(bsrep(i)+'/'+bsnam(i)+'_used_func.tex')<>[] then //Used function
//        tt16=[tex_title(16)
//              '\input{'+bsnam(i)+'_used_func}']
//     end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_pair_blk.tex')<>[] then //Pair Block
       tt17=[tex_title(17)
             '\input{'+bsnam(i)+'_pair_blk}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_see_also.tex')<>[] then //See Also
       tt18=[tex_title(18)
             '\input{'+bsnam(i)+'_see_also}']
    end

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_bib.tex')<>[] then //bibliography
       tt20=['\input{'+bsnam(i)+'_bib.tex}']
    end

    ////////////////////
    ///paper
    ////////////////////
    if typdoc=='guide' then

      newtitle=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam(i)+'.xml');

      PalXmlName=return_pal_name(lisf,lind,%gd)

      if PalXmlName<>[] then //Palette
         tta=return_xml_sdesc(PalXmlName)
      else
         tta=[];
      end
      tt3=['\begin{itemize}';
           '\item \textbf{'+tt_title(3)+' :} '+...
                        latexsubst(tta(1,1))+'.cosf - '+...
                        latexsubst(tta(1,2));  //on peut rajouter un \ref{} ici!
           '\item \textbf{'+tt_title(13)+' :} \tt '+...
                        latexsubst(lisf(1,2))+'.sci'; //fonction d'interface
           '\end{itemize}';]

    ////////////////////
    ///html
    ////////////////////
    elseif typdoc=='html' then

      PalName=return_block_pal2(lisf,%gd)

      if PalName<>[] then //Palette
         PalXmlName=%gd.mpath.xml(lind)+...
                    PalName+'_'+%gd.ext.pal+'.xml'
         tta=return_xml_sdesc(PalXmlName)
         if tta<>[] then
           tt3=[tex_title(3)
                '\begin{itemize}'
                '\item{\htmladdnormallink{'+...
                  latexsubst(tta(1,1))+' - '+...
                  latexsubst(tta(1,2))+'}{'+..
                  basename(PalXmlName)+'.htm}}'
                '\end{itemize}']
         end
      end

      if fileinfo(bsrep(i)+'/'+bsnam(i)+...
                  '_def_prop.tex')<>[] then //Defaults Properties
        tt12=[tex_title(12)
              '\input{'+bsnam(i)+'_def_prop}']
      end

      if fileinfo(bsrep(i)+'/'+bsnam(i)+...
                  '_int_func.tex')<>[] then //Interfacing Function
        tt13=[tex_title(13)
              '\input{'+bsnam(i)+'_int_func}']
//              '{\tt '+latexsubst(lisf(1,2))+'}']
      end

      if fileinfo(bsrep(i)+'/'+bsnam(i)+'_authors.tex')<>[] then //Authors
        tt19=[tex_title(19)
              '\input{'+bsnam(i)+'_authors}']
      end

      tt21=['\htmlinfo*';'\end{document}']
  end

  //Write the main tex file of block
  txt=[]
  for j=1:size(tt_title,1)
     txt=[txt;evstr('tt'+string(j))] 
  end

  mputl(txt,bsrep(i)+'/'+bsnam(i)+'.tex');
end

endfunction