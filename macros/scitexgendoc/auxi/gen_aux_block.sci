//1 - create _head.tex
//2 - create _blocks.tex
//3 - create _dial_box.tex
//4 - create _param.tex file
//    a - create _gui.eps files
//    b - create _param.tex file
//5 - create _def_prop.tex
//6 - create _sbeq.tex
//7 - create _comput.tex
//8 - create _int_func.tex
//9 - create _foot.tex

function []=gen_aux_block(lisf,typdoc,lind,%gd)

  bsnam=get_extname(lisf,%gd)
  bsrep=%gd.lang(lind)+'/'+bsnam

  ////////////////////////
  //1 - create _head.tex
  ////////////////////////
  gendoc_printf(%gd,"\tWrite a _head.tex file... ")
  txt=get_head_tex(lisf,typdoc,lind,%gd)
  mputl(txt,'./'+bsrep+'/'+bsnam+'_head.tex');
  gendoc_printf(%gd,"Done\n");

  ////////////////////////
  //2 - create _blocks.tex
  ////////////////////////
  gendoc_printf(%gd,"\tExport figure of block... ")

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

  [scale_blk]=return_size_scs_diagr(%gd.mpath.tex(lind)+...
                              bsnam,...
                              typdoc,...
                              'scale_blk')

  //
  dessin_block(basename(lisf(1,2)),typdoc,lr_margin,ud_margin)

  //
  unix_g(%gd.cmd.mv+basename(lisf(1,2))+...
               '/'+basename(lisf(1,2))+'.eps '+bsrep)
  rmdir(basename(lisf(1,2)),'s');
  gendoc_printf(%gd,"Done\n");

  gendoc_printf(%gd,"\tWrite a _blocks.tex file... ");

  //retourne la taille du bloc scicos
  sz=return_sz_block(basename(lisf(1,2)))

  if scale_blk==[] then
    scale=sz(2)/2;
    if scale > 1 then scale=(scale+1)/2, end
  else
    scale=scale_blk
  end
  txt_tmp='height='+string(90*scale)+'pt'

  if fileinfo(bsrep+...
              '/'+bsnam+'.eps')<>[] then //figure block
      txt=['\begin{center}'
           '  \epsfig{file='+bsnam+'.eps,'+txt_tmp+'}'
           '\end{center}']
  else
      txt=[];
  end
  if typdoc=='html'&%gd.opt.toc then
      txt=[txt;'\tableofcontents']
  end
  mputl(txt,'./'+bsrep+'/'+bsnam+'_blocks.tex');
  gendoc_printf(%gd,"Done\n");

  //////////////////////////
  //3 - create _dial_box.tex
  //////////////////////////

  //##13/07/08
  //## Remove PDE.sci for scicos
  if lisf(1,2)<>'PDE.sci' then
    //do a capture of gui of block
    gendoc_printf(%gd,"\tCapture the gui of block... ")
    load SCI/macros/scicos/lib
    exec(loadpallibs,-1)
    %scicos_prob=%f;
    alreadyran=%f
    needcompile=4
    prot=funcprot();
    funcprot(0);
    if ~exists('%scicos_context') then
      %scicos_context=struct();
    end
    if %gd.opt.gui then
      //redefine getvalue, edit_curv
      //SUPER_f, dialog
      getvalue=mtk_getvalue
      if fileinfo('SCI/macros/scicos/ttk_getvalue.sci') <> [] then
        if with_ttk() then
          mttk_getvalue=mttk_getvalue
          getvalue=mttk_getvalue
        end
      end
      edit_curv=medit_curv;
      SUPER_f=MSUPER_f;
      PAL_f=MPAL_f;
      dialog=mmdialog;
      TCL_EvalStr(' set title """" ')
      funcprot(prot);
      ierror=execstr('blk='+basename(lisf(1,2))+'(''define'')','errcatch')
      if ierror<>0 then
        x_message(['Error in GUI function';lasterror()] )
        disp(lisf(1,2))
        fct=[]
        return
      end
      %scs_help=basename(lisf(1,2))
      ierror=execstr('blk='+basename(lisf(1,2))+'(''set'',blk)','errcatch')
      if ierror<>0 then
        x_message(['Error in GUI function';lasterror()] )
        disp(lisf(1,2))
        fct=[]
        return
      end
      //tempo
      time1=getdate();time2=time1;
      while etime(time2,time1)<0.2, time2=getdate(); end;
      //récupère titre de la fenêtre
      ttitle=TCL_GetVar('title');
      if ttitle<>"" then
        tt=unix_g(%gd.cmd.xwd+'./'+bsrep+'/'+bsnam+'_gui.eps');
        if fileinfo('SCI/macros/scicos/ttk_getvalue.sci') <> [] then
          if with_ttk() then
            close_ttkgetvalue()
          else
            TCL_EvalStr('catch {destroy $w}')
          end
        else
          TCL_EvalStr('catch {destroy $w}')
        end
      end
      gendoc_printf(%gd,"Done\n")

      if fileinfo(bsrep+...
                  '/'+bsnam+'_gui.eps')<>[] then //dialog box
           //@@
           gendoc_printf(%gd,"\tExport gui eps file in gif file... ");
           cfil=bsrep+'/'+bsnam+'_gui.eps';
           unix_g(%gendoc.cmd.convert+cfil+' '+strsubst(cfil,'.eps','.gif'));
           gendoc_printf(%gd,"Done\n");
           //@@
           gendoc_printf(%gd,"\tWrite a _dial_box.tex file... ");
           //@@
           tt=unix_g(%gd.cmd.identify+'./'+bsrep+'/'+bsnam+'_gui.eps');
           ind=strindex(tt,'PS');siz='';
           for i=(ind($)+3):length(tt)
             if part(tt,i)==' ' then break, end
             siz=siz+part(tt,i)
           end
           ind=strindex(siz,'x');
           width=part(siz,1:ind-1);
           height=part(siz,ind+1:length(siz));
           //@@
           txt=['\begin{figure}'
	        '  \htmlimage{width='+width+',height='+height+'}'
                '  \begin{center}'
                '    \epsfig{file='+bsnam+'_gui.eps,width=300pt}'
                '  \end{center}'
                '\end{figure}']
           if typdoc=='guide' then
             txt(1)=['\begin{figure}[!h]']
           end
           //SPECIALDESC
           size_dial=return_size_dial(%gd.mpath.tex(lind)+...
                                      bsnam,typdoc)
           if size_dial<>[] then
             txt=strsubst(txt,'width=300pt',size_dial)
           end
           mputl(txt,'./'+bsrep+'/'+bsnam+'_dial_box.tex')
           gendoc_printf(%gd,"Done\n")
      end

    else
      ttitle=latexsubst(return_desc_block(basename(lisf(1,2))))
      ini=return_ini_block(basename(lisf(1,2)));
      ini=latexsubst(ini(:))
      lables=return_lables_block(basename(lisf(1,2)))
      lables=latexsubst(lables(:))
      if ini<>[]&lables<>[] then
        mat=[]
        for j=1:size(ini,1)
          mat=[mat;lables(j)+' & '+ini(j) + '\\']
        end
        txt=['\begin{center}'
             '\begin{tabular}{|c|c|}'
             '\hline'
             ttitle+' & \\'
             '\hline'
             mat
             '\hline'
             '\end{tabular}'
             '\end{center}']
        mputl(txt,'./'+bsrep+'/'+bsnam+'_dial_box.tex')
        gendoc_printf(%gd,"Done\n")
      else
        gendoc_printf(%gd,"No parameters\n")
      end
    end
  else
    //dialog box of PDE
    gendoc_printf(%gd,"\tWrite a _dial_box.tex file... ");
    txt=['\begin{figure}'
         '  \begin{center}'
         '    \epsfig{file='+bsnam+'_gui.eps,width=300pt}'
         '  \end{center}'
         '\end{figure}']
    if typdoc=='guide' then
      txt(1)=['\begin{figure}[!h]']
    end
    //SPECIALDESC
    size_dial=return_size_dial(%gd.mpath.tex(lind)+...
                                bsnam,typdoc)
    if size_dial<>[] then
         txt=strsubst(txt,'width=300pt',size_dial)
    end
    mputl(txt,'./'+bsrep+'/'+bsnam+'_dial_box.tex')
    gendoc_printf(%gd,"Done\n")
  end

  /////////////////////////////
  //4 - create _param.tex file
  /////////////////////////////

  //only if block has multiple dialog box
  txt_spec_param=return_dial_param(%gd.mpath.tex(lind)+...
                                   bsnam,typdoc)
  if txt_spec_param<>[] then
    nb_new_dial=size(txt_spec_param)

    /////////////////////////////
    // a - create _gui.eps files
    /////////////////////////////
    gendoc_printf(%gd,"\tCapture gui(s) of block...\n")
    for j=1:nb_new_dial
      //do a capture of gui of block
      load SCI/macros/scicos/lib
      exec(loadpallibs,-1)
      %scicos_prob=%f;
      alreadyran=%f
      needcompile=4
      prot=funcprot();
      funcprot(0);
      getvalue=mtk_getvalue2
      if fileinfo('SCI/macros/scicos/ttk_getvalue.sci') <> [] then
        if with_ttk() then
          getvalue=mttk_getvalue2
        end
      end
      TCL_EvalStr(' set title """" ')
      funcprot(prot);
      ierror=execstr('blk='+basename(lisf(1,2))+...
                     '(''define'')','errcatch')
      if ierror<>0 then
        x_message(['Error in GUI function';lasterror()] )
        disp(lisf(1,2))
        fct=[]
        return
      end
      global cnt
      cnt=0
      execstr(txt_spec_param(j)(3))
      %scs_help=basename(lisf(1,2))
      ierror=execstr('blk='+basename(lisf(1,2))+...
                     '(''set'',blk)','errcatch')
      if ierror <>0 then
         x_message(['Error in GUI function';lasterror()] )
         disp(lisf(1,2))
         fct=[]
         return
      end

      //tempo
      time1=getdate();time2=time1;
      while etime(time2,time1)<0.2, time2=getdate(); end;
      //récupère titre de la fenêtre
      ttitle=TCL_GetVar('title');
      if ttitle<>"" then
        name_fic_dial=bsnam+'_'+...
                      string(txt_spec_param(j)(1))+...
                      '_'+string(j);
        titi=unix_g(%gd.cmd.xwd+'./'+bsrep+'/'+...
                      name_fic_dial+'_gui.eps');
//            if titi==[] then
//            else
//            txt2=[];
//            end
        if fileinfo('SCI/macros/scicos/ttk_getvalue.sci') <> [] then
          if with_ttk() then
            close_ttkgetvalue()
          else
            TCL_EvalStr('catch {destroy $w}')
          end
        else
          TCL_EvalStr('catch {destroy $w}')
        end

        if fileinfo(bsrep+...
                    '/'+name_fic_dial+'_gui.eps')<>[] then //dialog box
          //@@
          gendoc_printf(%gd,"\tExport gui eps file in gif file... ");
          cfil=bsrep+'/'+name_fic_dial+'_gui.eps';
          unix_g(%gendoc.cmd.convert+cfil+' '+strsubst(cfil,'.eps','.gif'));
          gendoc_printf(%gd,"Done\n");
          //@@
          gendoc_printf(%gd,"\tWrite a _dial_box.tex file... ");
          //@@
          tt=unix_g(%gd.cmd.identify+'./'+bsrep+'/'+name_fic_dial+'_gui.eps');
          ind=strindex(tt,'PS');siz='';
          for i=(ind($)+3):length(tt)
            if part(tt,i)==' ' then break, end
            siz=siz+part(tt,i)
          end
          ind=strindex(siz,'x');
          width=part(siz,1:ind-1);
          height=part(siz,ind+1:length(siz));
          //@@
          txt=['\begin{figure}'
               '  \htmlimage{width='+width+',height='+height+'}'
               '  \begin{center}'
               '    \epsfig{file='+name_fic_dial+'_gui.eps,width=300pt}'
               '  \end{center}'
               '\end{figure}']
          if typdoc=='guide' then
            txt(1)=['\begin{figure}[!h]']
          end
          mputl(txt,'./'+bsrep+'/'+name_fic_dial+'_dial_box.tex')
          gendoc_printf(%gd,"Done\n")
        end

      end
    end
    gendoc_printf(%gd,"\tDone\n")

    /////////////////////////////
    // b - create _param.tex file
    /////////////////////////////

    //only if _param.tex file doesn't exist
    if fileinfo('./'+bsrep+'/'+bsnam+'_param.tex')==[] then
      gendoc_printf(%gd,"\tWrite a _param.tex file... ")
      txt=return_xml_param(%gd.mpath.xml(lind)+...
                           bsnam+'.xml')
      txt(3)=latexsubst(txt(3))
      tt=['\begin{itemize}']
      for l=1:size(txt(3),'r')
//        if typdoc=='html' then
        tt=[tt;'  \item{\textbf{'+txt(3)(l,1)+'}} '];
//        else
//          tt=[tt;'  \item{\textbf{'+txt(3)(l,1)+' :}} '];
//        end
        for ll=1:size(txt(4)(l))
          if txt(2)(l,1)==1 | ll<>1 then
            tt($)=tt($)+'\\';
          end
          tt=[tt;
              '   '+..
             latexsubst(retrieve_xml_char(txt(4)(l)(ll)));];
        end
//         tt(size(tt,1))=tt(size(tt,1))+txt(3)(l,2)
        tt=[tt;''];
        for j=1:nb_new_dial
          if l==txt_spec_param(j)(1) then
            if %gd.lang(lind)=='fr' then
              tt=[tt;'  Si mis à '+txt_spec_param(j)(2)];
            else
              tt=[tt;'  If set '+txt_spec_param(j)(2)];
            end
            name_fic_dial=bsnam+'_'+...
                          string(txt_spec_param(j)(1))+...
                                 '_'+string(j);
            if fileinfo(bsrep+...
                        '/'+name_fic_dial+'_gui.eps')<>[] then
              txt2=['  \begin{figure}'
                    '   \begin{center}'
                    '    \epsfig{file='+name_fic_dial+'_gui.eps,width=300pt}'
                    '   \end{center}'
                    '  \end{figure}']
              if typdoc=='guide' then
                txt2(1)=['\begin{figure}[!h]']
              end
              if txt_spec_param(j)(5)<>[] then
                txt2=strsubst(txt2,'width=300pt',txt_spec_param(j)(5))
              end
            else
              txt2=[];
            end
            tt=[tt;txt2]
            global cnt
            cnt=0
            lables=return_lables_block2(basename(lisf(1,2)),txt_spec_param(j)(3));
            lables=latexsubst(lables);
            global cnt
            cnt=0
            typ=return_typ_block2(basename(lisf(1,2)),txt_spec_param(j)(3));
            tt=[tt;'';'  \begin{itemize}']
            for e=1:size(lables,1)
              tt=[tt;'    \item{\textbf{'+lables(e,1)+'}} '];
              if %gd.lang(lind)=='fr' then
                tt($)=tt($)+'\\'
                tt=[tt;
                    txt_spec_param(j)(4)(e)+'\\';
                    'Propriétés : Type '+typ(e,1)+...
                                   ' de taille '+typ(e,2)+'. ']
              else
                tt($)=tt($)+'\\'
                tt=[tt;
                    txt_spec_param(j)(4)(e)+'\\';
                    'Properties : Type '+typ(e,1)+...
                                   ' of size '+typ(e,2)+'. ']
              end
              if e<>size(lables,1) then
                tt=[tt;'']
              end
            end
            tt=[tt;'  \end{itemize}';'']
          end
        end
      end
      tt=[tt;'\end{itemize}'];
      mputl(tt,'./'+bsrep+'/'+bsnam+'_param.tex')
      gendoc_printf(%gd,"Done\n")
    end
  end
  clear nb_new_dial;
  clear txt_spec_param;

  //////////////////////////
  //5 - create _def_prop.tex
  //////////////////////////
  gendoc_printf(%gd,"\tWrite a _def_prop.tex file... ")
  prop=return_prop_block(basename(lisf(1,2)),%gd.lang(lind));

  if %gd.lang(lind)=='fr' then
     //Tests for scicos version
     ierr = execstr('scicos_ver=get_scicos_version()','errcatch')
     if ierr==0 then //scilab > 4.1x
       txt=['\begin{itemize}'
            '\item \textbf{toujours actif:} '+prop(1)
            '\item \textbf{direct-feedthrough:} '+prop(2)
            '\item \textbf{détection de passage à zéro:} '+prop(3)
            '\item \textbf{mode:} '+prop(4)]

       if part(prop(5),1:1)<>'0' then
         ii=strindex(prop(5),'/')
         nu=evstr(part(prop(5),1:ii(1)-1))
         str=strsubst(part(prop(5),ii(1)+1:ii(2)-1),',]',',1]');
         str=strsubst(str,']','],');
         str='u=list('+part(str,1:length(str)-2)+')'
         execstr(str)
         ut=evstr(part(prop(5),ii(2)+1:length(prop(5))))
         if size(ut,'*')<nu then ut(nu)=1, end
         txt=[txt;
              '\item \textbf{entrée régulières:}\\']
         for i=1:nu
           txt=[txt;
                '   \textbf{   - '+...
                 'port '+string(i)+' : taille '+sci2exp(u(i))+...
                    ' / type '+string(ut(i))+'}\\'];
         end
       end
//            '\item \textbf{nombre/taille/type des entrées régulières:} '+prop(5)
//            '\item \textbf{nombre/taille/type des sorties sorties régulières:} '+prop(6)

       if part(prop(6),1:1)<>'0' then
         ii=strindex(prop(6),'/');
         ny=evstr(part(prop(6),1:ii(1)-1));
         str=strsubst(part(prop(6),ii(1)+1:ii(2)-1),',]',',1]');
         str=strsubst(str,']','],');
         str='y=list('+part(str,1:length(str)-2)+')';
         execstr(str);
         yt=evstr(part(prop(6),ii(2)+1:length(prop(6))));
         if size(yt,'*')<ny then yt(ny)=1, end
         txt=[txt;
              '\item \textbf{sorties régulières:}\\'];
         for i=1:ny
           txt=[txt;
                '   \textbf{   - port '+string(i)+' : taille '+sci2exp(y(i))+...
                  ' / type '+string(yt(i))+'}\\'];
         end
       end

       txt=[txt;
            '\item \textbf{nombre des entrées évènementielles:} '+prop(7)
            '\item \textbf{nombre des sorties évènementielles:} '+prop(8)
            '\item \textbf{possède un état continu:} '+prop(9)
            '\item \textbf{possède un état discret:} '+prop(10)
            '\item \textbf{possède un état objet:} '+prop(14)
            '\item \textbf{nom de la fonction de calcul:} {\em '+latexsubst(prop(12))+'}'
            '\end{itemize}']
     else //code for scilab 3.0-4.1x
       txt=['\begin{itemize}'
            '\item \textbf{toujours actif:} '+prop(1)
            '\item \textbf{direct-feedthrough:} '+prop(2)
            '\item \textbf{détection de passage à zéro:} '+prop(3)
            '\item \textbf{mode:} '+prop(4)
            '\item \textbf{nombre/taille des entrées régulières:} '+prop(5)
            '\item \textbf{nombre/taille des sorties sorties régulières:} '+prop(6)
            '\item \textbf{nombre/taille des entrées évènementielles:} '+prop(7)
            '\item \textbf{nombre/taille des sorties évènementielles:} '+prop(8)
            '\item \textbf{possède un état continu:} '+prop(9)
            '\item \textbf{possède un état discret:} '+prop(10)
            '\item \textbf{nom de la fonction de calcul:} {\em '+latexsubst(prop(12))+'}'
            '\end{itemize}'
           ]
     end

  else
     //Tests for scicos version
     ierr = execstr('scicos_ver=get_scicos_version()','errcatch')
     if ierr==0 then //scilab > 4.1x
       txt=['\begin{itemize}'
            '\item \textbf{always active:} '+prop(1)
            '\item \textbf{direct-feedthrough:} '+prop(2)
            '\item \textbf{zero-crossing:} '+prop(3)
            '\item \textbf{mode:} '+prop(4)]

       if part(prop(5),1:1)<>'0' then
         ii=strindex(prop(5),'/')
         nu=evstr(part(prop(5),1:ii(1)-1))
         str=strsubst(part(prop(5),ii(1)+1:ii(2)-1),',]',',1]');
         str=strsubst(str,']','],');
         str='u=list('+part(str,1:length(str)-2)+')'
         execstr(str)
         ut=evstr(part(prop(5),ii(2)+1:length(prop(5))))
         if size(ut,'*')<nu then ut(nu)=1, end
         txt=[txt;
              '\item \textbf{regular inputs:}\\']
         for i=1:nu
           txt=[txt;
                '   \textbf{   - port '+string(i)+' : size '+sci2exp(u(i))+...
                    ' / type '+string(ut(i))+'}\\'
               ]
         end
       end

//            '\item \textbf{number/sizes/type of inputs:} '+prop(5)
//            '\item \textbf{number/sizes/type of outputs:} '+prop(6)
       if part(prop(6),1:1)<>'0' then
         ii=strindex(prop(6),'/')
         ny=evstr(part(prop(6),1:ii(1)-1))
         str=strsubst(part(prop(6),ii(1)+1:ii(2)-1),',]',',1]');
         str=strsubst(str,']','],');
         str='y=list('+part(str,1:length(str)-2)+')'
         execstr(str)
         yt=evstr(part(prop(6),ii(2)+1:length(prop(6))))
         if size(yt,'*')<ny then yt(ny)=1, end
         txt=[txt;
              '\item \textbf{regular outputs:}\\']
         for i=1:ny
           txt=[txt;
                '   \textbf{   - port '+string(i)+' : size '+sci2exp(y(i))+...
                    ' / type '+string(yt(i))+'}\\'
               ]
         end
       end

       txt=[txt;
            '\item \textbf{number/sizes of activation inputs:} '+prop(7)
            '\item \textbf{number/sizes of activation outputs:} '+prop(8)
            '\item \textbf{continuous-time state:} '+prop(9)
            '\item \textbf{discrete-time state:} '+prop(10)
            '\item \textbf{object discrete-time state:} '+prop(14)
            '\item \textbf{name of computational function:} {\em '+latexsubst(prop(12))+'}'
            '\end{itemize}']
     else //code for scilab 3.0-4.1x
       txt=['\begin{itemize}'
            '\item \textbf{always active:} '+prop(1)
            '\item \textbf{direct-feedthrough:} '+prop(2)
            '\item \textbf{zero-crossing:} '+prop(3)
            '\item \textbf{mode:} '+prop(4)
            '\item \textbf{number/sizes of inputs:} '+prop(5)
            '\item \textbf{number/sizes of outputs:} '+prop(6)
            '\item \textbf{number/sizes of activation inputs:} '+prop(7)
            '\item \textbf{number/sizes of activation outputs:} '+prop(8)
            '\item \textbf{continuous-time state:} '+prop(9)
            '\item \textbf{discrete-time state:} '+prop(10)
            '\item \textbf{name of computational function:} {\em '+latexsubst(prop(12))+'}'
            '\end{itemize}'
           ]
     end
  end
  mputl(txt,'./'+bsrep+'/'+bsnam+'_def_prop.tex');
  gendoc_printf(%gd,"Done\n")

  ///////////////////////
  //6 - create _sbeq.tex
  ///////////////////////
  for j=1:size(%gd.opath.sbeq,'*')

    if fileinfo(%gd.opath.sbeq(j)+bsnam+'_'+%gd.ext.sbeq+'.cos')<>[] then

      gendoc_printf(%gd,"\tSuper block "+bsnam+'_'+%gd.ext.sbeq+'.cos'+" found...\n")

      export_diagr(%gd.opath.sbeq(j),bsnam+'_'+%gd.ext.sbeq+'.cos',typdoc);

      unix_g(%gd.cmd.cp+bsnam+'_'+%gd.ext.sbeq+'/'+bsnam+'_'+%gd.ext.sbeq+'.eps '+bsrep+'/'+bsnam+'_sbeq.eps')

      rmdir(bsnam+'_'+%gd.ext.sbeq,'s');
      txt=['\begin{center}'
           '  \epsfig{file='+bsnam+'_sbeq.eps,width=400.00pt}'
           '\end{center}']
      //SPECIALDESC
      size_diagr=return_size_scs_diagr(%gd.mpath.tex(lind)+bsnam,..
                                  typdoc,...
                                  'sbeq')

      size_diagr=strsubst(size_diagr,'[',''); //for compatibility with \includegraphics
      size_diagr=strsubst(size_diagr,']','');
      if size_diagr~=[] then
        txt=strsubst(txt,'width=400.00pt',size_diagr)
      end
      gendoc_printf(%gd,"\tWrite a _sbeq.tex file... ")
      mputl(txt,'./'+bsrep+'/'+bsnam+'_sbeq.tex')
      gendoc_printf(%gd,"Done\n")
      break
    end
  end

  ////////////////////////
  //7 - create _comput.tex
  ////////////////////////
  comput=[]
  txt=[]
  funcs=[];
  newlisff=[];
  prop=return_prop_block(basename(lisf(1,2)));
  func=prop(12)

  if func<>'csuper' then
    //for scicos doc : disable _comput for synchro blocks
    if lisf(1,2)<>'IFTHEL_f.sci' & lisf(1,2)<>'ESELECT_f.sci' then
      //**
      if %gd.ext.block<>'' then
       tt = return_xml_ufunc(%gd.mpath.xml(lind)+basename(lisf(1,2))+...
            '-'+%gd.ext.block+'.xml');
      else
       tt = return_xml_ufunc(%gd.mpath.xml(lind)+basename(lisf(1,2))+'.xml');
      end
      if tt<>[] then
        for ij=1:size(tt,1)
//           if strindex(tt(ij),'<LINK>')<>[] then
//             func2=strsubst(tt(ij),'<LINK>','');
//             func2=strsubst(func2,'</LINK>','');
//             func2=strsubst(func2,',','');
//             func2=stripblanks(func2);
//             funcs=[funcs;func2];
//           end
          funcs=[funcs;tt(ij)]
        end
        if funcs<>[] then
         func=funcs
        end
      end

      if stripblanks(func)<>'' then
        func=basename(func)
      end

      for ij=1:size(func,1)
        for j=1:size(%gd.opath.rout,'*')
          if fileinfo(%gd.opath.rout(j)+func(ij)+'.c')<>[] then
             comput=[comput;%gd.opath.rout(j)+func(ij)+'.c']
             break;
          elseif fileinfo(%gd.opath.rout(j)+func(ij)+'.f')<>[] then
             comput=[comput;%gd.opath.rout(j)+func(ij)+'.f']
             break;
          elseif prop(13)=='5' //scilab comput. func. case
            if fileinfo(%gd.opath.rout(j)+func(ij)+'.sci')<>[] then
              comput=[comput;%gd.opath.rout(j)+func(ij)+'.sci']
              break;
            end
          end
        end
      end

      if comput<>[] then
        if funcs==[] then
          if type(prop(13))<>10 then
             typb=0
          elseif prop(13)=="" then
             typb=0
          else
             typb=prop(13)
          end
        end
// 
//     disp('here');pause
        for ij=1:size(comput,1)
          stars='*';
          gendoc_printf(%gd,"\n\t *********************"+...
                        strcat(stars(ones(1,length(basename(comput(ij))))),"")+...
                         "****\n")
          gendoc_printf(%gd,"\t ** Write tex files of %s **\n",basename(comput(ij)))
          gendoc_printf(%gd,"\t *********************"+...
                        strcat(stars(ones(1,length(basename(comput(ij))))),"")+...
                         "****\n")

          [path,fname,extension]=fileparts(comput(ij))
          newlisf=[path fname+extension 'routcos']
          //change path of gd for current language
          %gdd=%gd;
          %gdd.lang=%gd.lang(lind);
          %gdd.mpath.data=%gd.mpath.data(lind);
          %gdd.mpath.xml=%gd.mpath.xml(lind);
          %gdd.mpath.tex=%gd.mpath.tex(lind);
          //call generate_aux_tex_file
          generate_aux_tex_file(newlisf,typdoc,%gdd)

          gendoc_printf(%gd,"\t *********************"+...
                        strcat(stars(ones(1,length(basename(comput(ij))))),"")+...
                         "****\n\n")

          if %gd.texopt.pathflg<>'' then
            execstr('comput_sub=strsubst(comput(ij),'+%gd.texopt.pathflg+...
                     ','''+%gd.texopt.pathflg+''')')
          else
            comput_sub=comput(ij)
          end

          if %gd.lang(lind) == 'fr' then
            ttxt='voir'
          else
            ttxt='view'
          end

          if funcs==[] then
            txt=[latexsubst(comput_sub+...
                  ' (Type '+string(typb)+') ' +...
                   '\htmladdnormallink{['+ttxt+' code]}{')+...
                    fname+'_routcos.htm}']
            newlisff=[newlisf(:)];
          else
            txt=[txt;
                 latexsubst(comput_sub+' '+...
                   '\htmladdnormallink{['+ttxt+' code]}{')+...
                    fname+'_routcos.htm}']
            newlisff=[newlisff;newlisf(:)];
          end
        end

        txt=['\begin{itemize}'
             '  \item '+txt
             '\end{itemize}']

        mputl(newlisff,'./'+bsrep+'/'+bsnam+'_comput_lisf');

      end
    end //
  else //cas super bloc
    tt=return_rpar_block(basename(lisf(1,2)))
    [ierr,scicos_ver,tt]=update_version(tt)

    //importe hauteur/largeur de la figure du super bloc
    [lr_margin]=return_size_super(%gd.mpath.tex(lind)+...
                                bsnam,...
                                typdoc,...
                                'lr_margin')

    [ud_margin]=return_size_super(%gd.mpath.tex(lind)+...
                                bsnam,...
                                typdoc,...
                                'ud_margin')

    gendoc_printf(%gd,"\tExport figure of super block... ")
  
    dessin_scs_m(tt,bsnam+'_super',typdoc,lr_margin,ud_margin)
    unix_g(%gd.cmd.mv+bsnam+'_super/'+bsnam+'_super.eps '+bsrep)
    rmdir(bsnam+'_super','s');
    gendoc_printf(%gd,"Done\n")
    txt=[' \epsfig{file='+bsnam+'_super.eps,width=150.00pt}']
    //SPECIALDESC
    size_super=return_size_super(%gd.mpath.tex(lind)+...
                                 bsnam,typdoc)
    if size_super<>[] then
        txt=strsubst(txt,'width=150.00pt',size_super)
    end
  end
  if txt<>[] then
    if func<>'csuper' then
       gendoc_printf(%gd,"\tWrite a _comput.tex file... ")
       mputl(txt,'./'+bsrep+'/'+bsnam+'_comput.tex')
    else
       gendoc_printf(%gd,"\tWrite a _scomput.tex file... ")
       mputl(txt,'./'+bsrep+'/'+bsnam+'_scomput.tex')
    end
    gendoc_printf(%gd,"Done\n")
  end

  ///////////////////////////
  //8 - create _int_func.tex
  //////////////////////////
  txt=[]
  gendoc_printf(%gd,"\tWrite a _int_func.tex file... ")

  ko = %t;
  S = whereis(basename(lisf(1,2)));

  if S==[] then
    ko=%f
  else
     ierr=execstr('S_str=string('+S+')','errcatch');
     if ierr<>0 then
       ko = %f;
     else
       if %gd.texopt.pathflg<>'' then
          execstr('intfunc=strsubst(S_str(1),'+%gd.texopt.pathflg+...
                   ','''+%gd.texopt.pathflg+''')');
          intfunc=intfunc+lisf(1,2);
       else
         intfunc=S_str(1)+lisf(1,2);
       end
     end
  end

  if ko then

    stars='*';
    gendoc_printf(%gd,"\n\t *********************"+...
                  strcat(stars(ones(1,length(lisf(1,2)))),"")+...
                   "****\n")
    gendoc_printf(%gd,"\t ** Write tex files of %s **\n",lisf(1,2))
    gendoc_printf(%gd,"\t *********************"+...
                  strcat(stars(ones(1,length(lisf(1,2)))),"")+...
                   "****\n")

    [path,fname,extension]=fileparts(S_str(1)+lisf(1,2))
    path=strsubst(path,'SCI/',SCI+'/')
    newlisf=[path fname+extension 'intfunc']
    //change path of gd for current language
    %gdd=%gd;
    %gdd.lang=%gd.lang(lind);
    %gdd.mpath.data=%gd.mpath.data(lind);
    %gdd.mpath.xml=%gd.mpath.xml(lind);
    %gdd.mpath.tex=%gd.mpath.tex(lind);
    //call generate_aux_tex_file
    generate_aux_tex_file(newlisf,typdoc,%gdd)

    gendoc_printf(%gd,"\t *********************"+...
                  strcat(stars(ones(1,length(lisf(1,2)))),"")+...
                   "****\n\n")

    if %gd.lang(lind) == 'fr' then
      ttxt='voir'
    else
      ttxt='view'
    end

    txt=[latexsubst(intfunc+' '+...
           '\htmladdnormallink{['+ttxt+' code]}{')+...
            fname+'_intfunc.htm}']

    txt=['\begin{itemize}'
         '  \item '+txt
         '\end{itemize}']

  else
    txt=['\begin{itemize}'
         '  \item {\tt '+latexsubst(lisf(1,2))+'}'
         '\end{itemize}']
  end

  mputl(txt,'./'+bsrep+'/'+bsnam+'_int_func.tex')
  gendoc_printf(%gd,"\tDone\n")

endfunction

