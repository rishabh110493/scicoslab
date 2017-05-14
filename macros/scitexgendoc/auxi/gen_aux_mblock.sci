//1 - create _head.tex
//2 - create _blocks.tex
//4 - create _dial_box.tex
//4 - create _param.tex file
//5 - create _def_prop.tex
//6 - create _sbeq.tex
//7 - create _comput.tex
//8 - create _int_func.tex
//9 - create _foot.tex

function []=gen_aux_mblock(lisf,typdoc,lind,%gd)

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

  //importe hateur/alrgeur de la figure du bloc à partir
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
  unix_g(%gd.cmd.mv+bsnam+'/'+bsnam+'.eps '+bsrep)
  rmdir(bsnam,'s');
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

  //do a capture of gui of block
  gendoc_printf(%gd,"\tCapture the gui of block... ")
  load SCI/macros/scicos/lib
  exec(loadpallibs,-1)
  %scicos_prob=%f;
  alreadyran=%f
  needcompile=4
  prot=funcprot();
  funcprot(0);

  if %gd.opt.gui then
   getvalue=mtk_getvalue
   if fileinfo('SCI/macros/scicos/ttk_getvalue.sci') <> [] then
     if with_ttk() then
       mttk_getvalue=mttk_getvalue
       getvalue=mttk_getvalue
     end
   end
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
        gendoc_printf(%gd,"\tExport gui eps file in gif file... ");
        cfil=bsrep+'/'+bsnam+'_gui.eps';
        unix_g(%gendoc.cmd.convert+cfil+' '+strsubst(cfil,'.eps','.gif'));
        gendoc_printf(%gd,"Done\n");
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
    gendoc_printf(%gd,"\tCapture gui(s) of block... ")
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
      end
    end
    gendoc_printf(%gd,"Done\n")

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
            lables=return_lables_block2(basename(lisf(1,2)),txt_spec_param(j)(3));
            lables=latexsubst(lables);
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
  [txt_model,txt_in,txt_out,txt_param]=return_prop_mblock(basename(lisf(1,2)),%gd.lang(lind));

  txt=[];

  if txt_in<>[] then
     if %gd.lang(lind)=='fr' then
       txt=[txt
            '\item {\bf Entrées :}'];
     else
       txt=[txt
            '\item {\bf Inputs :}'];
     end
     txt=[txt
          '\begin{itemize}'
          txt_in
          '\end{itemize}'];
  end

  if txt_out<>[] then
     if %gd.lang(lind)=='fr' then
       txt=[txt
            '\item {\bf Sorties :}'];
     else
       txt=[txt
            '\item {\bf Outputs :}'];
     end
     txt=[txt
          '\begin{itemize}'
          txt_out
          '\end{itemize}'];
  end

  if txt_param<>[] then
     if %gd.lang(lind)=='fr' then
       txt=[txt
            '\item {\bf Paramètres :}'];
     else
       txt=[txt
            '\item {\bf Parameters :}'];
     end
     txt=[txt
          '\begin{itemize}'
          txt_param
          '\end{itemize}'];
  end

  if txt_model<>[] then
     if %gd.lang(lind)=='fr' then
       txt=[txt
            '\item {\bf Nom du fichier model :} '];
     else
       txt=[txt
            '\item {\bf File name of the model :} '];
     end
     txt($) = txt($) + latexsubst(txt_model);
  end

  if txt<>[] then
   txt=['\begin{itemize}'
        '  '+txt
        '\end{itemize}']
    mputl(txt,'./'+bsrep+'/'+bsnam+'_def_prop.tex');
  end

  gendoc_printf(%gd,"Done\n")

  ///////////////////////
  //6 - create _sbeq.tex
  ///////////////////////
  for j=1:size(%gd.opath.sbeq,'*')
    if fileinfo(%gd.opath.sbeq(j)+...
                bsnam+'_'+%gd.ext.sbeq+'.cos')<>[] then
      gendoc_printf(%gd,"\tSuper block "+...
             bsnam+'_'+%gd.ext.sbeq+'.cos'+" found...\n")

      export_diagr(%gd.opath.sbeq(j),...
                   bsnam+'_'+%gd.ext.sbeq+'.cos',typdoc);

      unix_g(%gd.cmd.cp+bsnam+'_'+%gd.ext.sbeq+'/'+bsnam+...
             '_'+%gd.ext.sbeq+'.eps '+bsrep+'/'+bsnam+'_sbeq.eps')

      rmdir(bsnam+'_'+%gd.ext.sbeq,'s');

      txt=['\begin{center}'
           '  \epsfig{file='+bsnam+'_sbeq.eps,width=400.00pt}'
           '\end{center}']
      //SPECIALDESC
      size_diagr=return_size_scs_diagr(%gd.mpath.tex(lind)+...
                                  bsnam,...
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
  //prop=return_prop_block(basename(lisf(1,2)));
  func=txt_model;

  if fileinfo(lisf(1,1)+func+'.mo')<>[] then
       comput=lisf(1,1)+func+'.mo';

  //##Ajout special cas Scicos
  //##les fichiers .mo individuel n'existe plus. Ils sont
  //##regroupés dans un seul et même fichier (librairie)
  elseif(lisf(1,1)==SCI+"/macros/scicos_blocks/ModElectrical/")
    comput=lisf(1,1)+'Electrical.mo';
  elseif(lisf(1,1)==SCI+"/macros/scicos_blocks/ModHydraulics/")
    comput=lisf(1,1)+'Hydraulics.mo';
  elseif(lisf(1,1)==SCI+"/macros/scicos_blocks/ModLinear/")
    comput=lisf(1,1)+'Linear.mo';
  end

  if comput<>[] then
    stars='*';
    gendoc_printf(%gd,"\n\t *********************"+...
                  strcat(stars(ones(1,length(basename(comput)))),"")+...
                  "****\n")
    gendoc_printf(%gd,"\t ** Write tex files of %s **\n",basename(comput))
    gendoc_printf(%gd,"\t *********************"+...
                  strcat(stars(ones(1,length(basename(comput)))),"")+...
                  "****\n")

    [path,fname,extension]=fileparts(comput)
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
                  strcat(stars(ones(1,length(basename(comput)))),"")+...
                  "****\n\n")

    if %gd.texopt.pathflg<>'' then
       execstr('comput_sub=strsubst(comput,'+%gd.texopt.pathflg+...
               ','''+%gd.texopt.pathflg+''')')
    else
      comput_sub=''
    end

    if %gd.lang(lind) == 'fr' then
       ttxt='voir'
    else
       ttxt='view'
    end

    txt=[latexsubst(comput_sub+' '+...
          '\htmladdnormallink{['+ttxt+' code]}{')+...
             fname+'_routcos.htm}']
          newlisff=[newlisf(:)];

    txt=['\begin{itemize}'
         '  \item '+txt
         '\end{itemize}']

    mputl(newlisff,'./'+bsrep+'/'+bsnam+'_comput_lisf');

//     txt=['{ \tiny'
//          '  \verbatiminput{'+comput+'}'
//          '}']

    gendoc_printf(%gd,"\tWrite a _comput.tex file... ")
    mputl(txt,'./'+bsrep+'/'+bsnam+'_comput.tex')
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

