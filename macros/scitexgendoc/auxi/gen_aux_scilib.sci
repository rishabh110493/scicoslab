//1 - create _head.tex
//2 - create _sci_func.tex
//3 - create _mod.tex
function []=gen_aux_scilib(lisf,typdoc,lind,%gd)

  bsnam=get_extname(lisf,%gd)
  bsrep=%gd.lang(lind)+'/'+bsnam

  ////////////////////////
  //1 - create _head.tex
  ////////////////////////
  gendoc_printf(%gd,"\tWrite a _head.tex file... ")
  txt=get_head_tex(lisf,typdoc,lind,%gd)
  mputl(txt,'./'+bsrep+'/'+bsnam+'_head.tex');
  gendoc_printf(%gd,"Done\n");

  //////////////////////////
  //2 - create _sci_func.tex
  //////////////////////////
  txt=[]
  tt=return_func_scilib(lisf(1,2))
  if tt<>[] then
    gendoc_printf(%gd,"\tWrite a _sci_func.tex file... ")
    txt=['\begin{itemize}']
    for i=2:size(tt,1)
       extname=get_extname(['',tt(i),'sci'],%gd)
       desc=return_xml_sdesc(%gd.mpath.xml(lind)+...
                             extname+...
                             '.xml')
       if desc<>[] then
         if typdoc=='html' then
           txt=[txt;
                '  \item{\htmladdnormallink{'+latexsubst(desc(1,1))+' - '+...
                    latexsubst(desc(1,2))+'}'+...
                    '{'+extname+'.htm}}'
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
    mputl(txt,'./'+bsrep+'/'+bsnam+'_sci_func.tex')
    gendoc_printf(%gd,"Done\n")
  end

  /////////////////////
  //3 - create _mod.tex
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

