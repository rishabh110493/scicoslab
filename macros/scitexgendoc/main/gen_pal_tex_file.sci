//gen_pals_tex_file
//
//Fonction qui genere le fichier tex principal
//d'une palette scicos

function txt=gen_pal_tex_file(lisf,typdoc,lind,%gd)

  bsnam=get_extname(lisf,%gd)
  bsrep=%gd.lang(lind)+'/'+bsnam

  //define title of paragraph
  tt_title=[
            ''             //tt1  : header du fichier tex
            ''             //tt2  : figure de la palette (.eps)
            'Module'       //tt3  : Module
            'Description'  //tt4  : Description (_long)
            'Blocks'       //tt5  : Block contents
            'Palettes'     //tt6  : Palettes contents
            'See Also'     //tt7  : See Also (_see_also)
            'Authors'      //tt8  : Authors (_authors)
            ''             //tt9  : End of tex file
           ]

  //change language of title
//   if %gd.lang(lind)=='fr' then
  tt_title=change_lang_title(%gd.lang(lind),tt_title);
//   end

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

    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_pals.tex')<>[] then //figure of palette
       tt2=['\input{'+bsnam(i)+'_pals}']
    end 
    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_long.tex')<>[] then //Description
       tt4=[tex_title(4)
            ''
            '\input{'+bsnam(i)+'_long}']
    end
    if fileinfo(bsrep(i)+'/'+bsnam(i)+'_see_also.tex')<>[] then //see also
       tt7=[tex_title(7)
            '\input{'+bsnam(i)+'_see_also}']
    end

//     if typdoc=='guide' then
//        PalName=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam(i)+'.xml');
//        //Header of tex file
//        tt1=['\chapter{'+...
//             latexsubst(PalName(1,2))+'}\label{'+PalName(1,1)+'}']

    if typdoc=='html' then

       if fileinfo(bsrep(i)+'/'+bsnam(i)+'_mod.tex')<>[] then //module
         tt3=[tex_title(3)
              '\input{'+bsnam(i)+'_mod}']
       end

       if fileinfo(bsrep(i)+'/'+bsnam(i)+'_blocks.tex')<>[] then //blocks
         tt5=[tex_title(5)
              '\input{'+bsnam(i)+'_blocks}']
       end

       if fileinfo(bsrep(i)+'/'+bsnam(i)+'_pal.tex')<>[] then //palettes
         tt6=[tex_title(6)
              '\input{'+bsnam(i)+'_pal}']
       end

       if fileinfo(bsrep(i)+'/'+bsnam(i)+'_authors.tex')<>[] then //authors
          tt8=[tex_title(8)
               '\input{'+bsnam(i)+'_authors}']
       end

       tt9=['\htmlinfo*';'\end{document}']
    end

    //Generate the main tex file of block
    txt=[]
    for j=1:size(tt_title,1)
      txt=[txt;evstr('tt'+string(j))] 
    end

    mputl(txt,bsrep(i)+'/'+bsnam(i)+'.tex');
  end

endfunction
