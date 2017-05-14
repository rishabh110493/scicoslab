//1 - create _head.tex
//2 - create _pals.tex
//3 - create _blocks.tex
//4 - create _pal.tex
//5 - create _mod.tex
function []=gen_aux_pal(lisf,typdoc,lind,%gd)

  bsnam=get_extname(lisf,%gd)
  bsrep=%gd.lang(lind)+'/'+bsnam
  ////////////////////////
  //1 - create _head.tex
  ////////////////////////
  gendoc_printf(%gd,"\tWrite a _head.tex file... ")
  txt=get_head_tex(lisf,typdoc,lind,%gd)
  mputl(txt,'./'+bsrep+'/'+bsnam+'_head.tex');
  gendoc_printf(%gd,"Done\n");

  //////////////////////
  //2 - create _pals.tex
  //////////////////////

  //importe hauteur/largeur de la figure du bloc à partir
  //de scitexgendoc
  [lr_margin]=return_size_scs_diagr(%gd.mpath.tex(lind)+...
                              bsnam,...
                              typdoc,...
                              'lr_margin')

  [ud_margin]=return_size_scs_diagr(%gd.mpath.tex(lind)+...
                              bsnam,...
                              typdoc,...
                              'ud_margin')

  gendoc_printf(%gd,"\tExport figure of palette... ")

  //
  dessin_pal(lisf(1,1)+lisf(1,2),typdoc,lr_margin,ud_margin)

  unix_g(%gd.cmd.mv+bsnam+'/'+bsnam+'.eps '+bsrep)
  rmdir(bsnam,'s');
  gendoc_printf(%gd,"Done\n")

  gendoc_printf(%gd,"\tExport pal eps file in gif file... ");
  cfil=bsrep+'/'+bsnam+'.eps';
  unix_g(%gendoc.cmd.convert+cfil+' '+strsubst(cfil,'.eps','.gif'));
  gendoc_printf(%gd,"Done\n");

  gendoc_printf(%gd,"\tWrite a _pals.tex file... ")

  tt=unix_g(%gd.cmd.identify+cfil);
  ind=strindex(tt,'PS');siz='';
  for i=(ind($)+3):length(tt)
    if part(tt,i)==' ' then break, end
    siz=siz+part(tt,i)
  end
  ind=strindex(siz,'x');
  width=part(siz,1:ind-1);
  height=part(siz,ind+1:length(siz));

//  txt=['\begin{center}'
//       '  \epsfig{file='+bsnam+'.eps,width=350.00pt}'
//       '\end{center}']

  //@@
  txt=['\begin{figure}'
       '  \htmlimage{width='+width+',height='+height+'}'
       '  \begin{center}'
       '    \epsfig{file='+bsnam+'.eps,width=300pt}'
       '  \end{center}'
       '\end{figure}']

  //retourne la taille de la palette
  size_diagr=return_size_scs_diagr(%gd.mpath.tex(lind)+...
                                   bsnam,...
                                   typdoc,...
                                  'pal')

  size_diagr=strsubst(size_diagr,'[',''); //for compatibility with \includegraphics
  size_diagr=strsubst(size_diagr,']','');
  if size_diagr~=[] then
    txt=strsubst(txt,'width=350.00pt',size_diagr)
  end
  mputl(txt,'./'+bsrep+'/'+bsnam+'_pals.tex')
  gendoc_printf(%gd,"Done\n")

  ////////////////////////
  //3 - create _blocks.tex
  ////////////////////////
  txt=[];
  tt=return_block_pal(lisf(1,1)+lisf(1,2),,1)
  //sort blk list
  [s,k]=gsort(convstr(tt),'r','i');
  tt=tt(k);
  if tt<>[] then
    gendoc_printf(%gd,"\tWrite a _blocks.tex file... ")
    txt=['\begin{itemize}']
    for i=1:size(tt,1)
       bs_blknm=get_extname(['',tt(i),'block'],%gd);
       desc=return_xml_sdesc(%gd.mpath.xml(lind)+...
                             bs_blknm+...
                             '.xml');
       if desc<>[] then
         if typdoc=='html' then
           txt=[txt;
               '  \item{\htmladdnormallink{'+latexsubst(desc(1,1))+' - '+...
                    latexsubst(desc(1,2))+'}'+...
                    '{'+bs_blknm+'.htm}}'
               ]
          else
           txt=[txt;
               '  \item{'+latexsubst(desc(1,1))+' - '+...
                    latexsubst(desc(1,2))+'}' //on peut mettre un ref ici
               ]
          end
       else
         txt=[txt;
              '  \item{'+latexsubst(tt(i))+'}'
             ]
       end
    end
    txt=[txt;
         '\end{itemize}']
    mputl(txt,'./'+bsrep+'/'+bsnam+'_blocks.tex')
    gendoc_printf(%gd,"Done\n")
  end

  ////////////////////////
  //4 - create _pal.tex
  ////////////////////////
  txt=[];

  tt=return_pal_pal(lisf(1,1)+lisf(1,2),,1)
  if tt<>[] then
    //sort blk list
    [s,k]=gsort(convstr(tt),'r','i');
    tt=tt(k);
    gendoc_printf(%gd,"\tWrite a _pal.tex file... ")
    txt=['\begin{itemize}']
    for i=1:size(tt,1)
       bs_palnm=get_extname(['',tt(i),'pal'],%gd);
       desc=return_xml_sdesc(%gd.mpath.xml(lind)+...
                             bs_palnm+...
                             '.xml');
       if desc<>[] then
         if typdoc=='html' then
           txt=[txt;
               '  \item{\htmladdnormallink{'+latexsubst(desc(1,1))+' - '+...
                    latexsubst(desc(1,2))+'}'+...
                    '{'+bs_palnm+'.htm}}'
               ]
          else
           txt=[txt;
               '  \item{'+latexsubst(desc(1,1))+' - '+...
                    latexsubst(desc(1,2))+'}' //on peut mettre un ref ici
               ]
          end
       else
         txt=[txt;
              '  \item{'+latexsubst(tt(i))+'}'
             ]
       end
    end
    txt=[txt;
         '\end{itemize}']
    mputl(txt,'./'+bsrep+'/'+bsnam+'_pal.tex')
    gendoc_printf(%gd,"Done\n")
  end

  /////////////////////
  //5 - create _mod.tex
  /////////////////////
  if typdoc=='html' then
    if %gd.texopt.modflg<>'' then
      gendoc_printf(%gd,"\tWrite a _mod.tex file... ")
      txt=['\begin{itemize}'
           '  \item{\htmladdnormallink{'+...
                %gd.texopt.modflg+'}{'+%gd.htmlopt.what_nam+'}}'
           '\end{itemize}']
      mputl(txt,'./'+bsrep+'/'+bsnam+'_mod.tex')
      gendoc_printf(%gd,"Done\n");
    end
  end

endfunction
