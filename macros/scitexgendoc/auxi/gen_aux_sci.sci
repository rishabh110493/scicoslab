//1 - create _head.tex
//2 - create _lib.tex or _mod.tex
//3 - create _scifunc.tex
function []=gen_aux_sci(lisf,typdoc,lind,%gd)

  bsnam=get_extname(lisf,%gd)
  bsrep=%gd.lang(lind)+'/'+bsnam

  ////////////////////////
  //1 - create _head.tex
  ////////////////////////
  gendoc_printf(%gd,"\tWrite a _head.tex file... ")
  txt=get_head_tex(lisf,typdoc,lind,%gd)
  mputl(txt,'./'+bsrep+'/'+bsnam+'_head.tex');
  gendoc_printf(%gd,"Done\n");

  /////////////////////////////////
  //2 - create _lib.tex or _mod.tex
  /////////////////////////////////

  if typdoc=='html' then
   LibName = whereis(basename(lisf(:,2)));
   tta=[];
   if LibName<>[] then
     tta=return_xml_sdesc(%gd.mpath.xml(lind)+...
                           LibName+'_'+%gd.ext.scilib+'.xml')
   end

   if tta<>[] then
     gendoc_printf(%gd,"\tWrite a _lib.tex file... ")
     txt=['\begin{itemize}';
          '\item{\htmladdnormallink{'+...
                  latexsubst(LibName)+...
                   ' - '+latexsubst(tta(1,2))+...
                    '}{'+LibName+'_'+%gd.ext.scilib+'.htm}}';
          '\end{itemize}']
     mputl(txt,'./'+bsrep+'/'+bsnam+'_lib.tex');
     gendoc_printf(%gd,"Done\n");

   else
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
  end

  ///////////////////////////
  //3 - create _scifunc.tex
  ///////////////////////////
  if fileinfo(lisf(1,1)+lisf(1,2))<>[]
     scifunc=lisf(1,1)+lisf(1,2)

     stars='*';
     gendoc_printf(%gd,"\n\t *********************"+...
                    strcat(stars(ones(1,length(basename(scifunc)))),"")+...
                     "****\n")
     gendoc_printf(%gd,"\t ** Write tex files of %s **\n",basename(scifunc))
     gendoc_printf(%gd,"\t *********************"+...
                    strcat(stars(ones(1,length(basename(scifunc)))),"")+...
                     "****\n")

     [path,fname,extension]=fileparts(scifunc)
     newlisf=[path fname+extension 'scifunc']

     //change path of gd for current language
     %gdd=%gd;
     %gdd.lang=%gd.lang(lind);
     %gdd.mpath.data=%gd.mpath.data(lind);
     %gdd.mpath.xml=%gd.mpath.xml(lind);
     %gdd.mpath.tex=%gd.mpath.tex(lind);
     //call generate_aux_tex_file
     generate_aux_tex_file(newlisf,typdoc,%gdd)

     gendoc_printf(%gd,"\t *********************"+...
                   strcat(stars(ones(1,length(basename(scifunc)))),"")+...
                    "****\n\n")

     if %gd.texopt.pathflg<>'' then
         execstr('scifunc_sub=strsubst(scifunc,'+%gd.texopt.pathflg+...
                  ','''+%gd.texopt.pathflg+''')')
     end

     if %gd.lang(lind) == 'fr' then
        ttxt='voir'
     else
        ttxt='view'
     end

     txt=[latexsubst(scifunc_sub+' '+...
              '\htmladdnormallink{['+ttxt+' code]}{')+...
               fname+'_scifunc.htm}']
     //newlisff=[newlisf(:)];

     txt=['\begin{itemize}'
          '  \item '+txt
          '\end{itemize}']

    //mputl(newlisff,'./'+bsrep+'/'+bsnam+'_scifunc_lisf');

    gendoc_printf(%gd,"\tWrite a _scifunc.tex file... ")
    mputl(txt,'./'+bsrep+'/'+bsnam+'_scifunc.tex')
    gendoc_printf(%gd,"Done\n")

  end

endfunction
