//get_head_tex
//fonction qui retour le préambule+
//  l'en-tête d'un fichier tex de documentation

function txt=get_head_tex(lisf,typdoc,lind,%gd)

 txt=[];
 bsnam=get_extname(lisf,%gd)

 if typdoc=='guide' then
    newtitle=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam+'.xml')

    txt=['\section{'+latexsubst(newtitle(1,2))+...
         '}\label{'+bsnam+'}'];

 elseif typdoc=='html' then

    if %gd.lang(lind)=='fr' then //Header of tex file
      txt=['\documentclass[11pt,frenchb]{article}']
    else
      txt=['\documentclass[11pt]{article}']
    end

    tt_ltitle='\htmladdnormallink{'+[%gd.lang]+'}';

    tt_ltitle(lind)=tt_ltitle(lind)+'{'+...
                  './'+bsnam+'.htm}';

    k=1;
    tt=return_relative_path(lind,%gd);
    for j=1:size(%gd.lang,'*')
      if j<>lind then
        tt_ltitle(j)=tt_ltitle(j)+'{'+...
                      tt(k)+bsnam+'.htm}';
        k=k+1;
      end
    end

    tt=[]
    for j=1:size(%gd.lang,'*')
      if j<>size(%gd.lang,'*') then
        tt = tt + tt_ltitle(j) +'\hspace{2mm}-\hspace{2mm}';
      end
    end
    tt=tt+tt_ltitle(size(%gd.lang,'*'));
    clear tt_ltitle;

    txt=[txt;
         '\usepackage{makeidx,graphics,fullpage}'
         '\usepackage{verbatim,times,amsmath,amssymb,epsfig,color}'
         '\usepackage{subfigure}'
         '\usepackage{html}'
         ''
         '\begin{document}'
         ''
         ' \begin{center}'
         '   '+return_xml_type(%gd.mpath.xml(lind)+bsnam+'.xml')+'\\'
         tt
         ' \end{center}'];

    newtitle=return_xml_sdesc(%gd.mpath.xml(lind)+bsnam+'.xml');

    if (lisf(1,3)==%gd.typobj.sci | lisf(1,3)==%gd.typobj.rout |...
        lisf(1,3)==%gd.typobj.sce)
      txt=[txt;'\section{\textbf{'+latexsubst(newtitle(1,1))+'}'+...
                         ' - '+latexsubst(newtitle(1,2))+...
                         '}\label{'+bsnam+'}'];
    else
      txt=[txt;'\section{'+latexsubst(newtitle(1,2))+...
                         '}\label{'+bsnam+'}'];
    end
//              '\tableofcontents']

//     tt13=['\htmlinfo*';'\end{document}']
 end
endfunction
