//1 - create _head.tex
//2 - create  _diagrs.tex
//3 - create  _ctxt.tex
//4 - create  _block.tex
//5 - create  _scop.tex
//6 - create _mod.tex
function []=gen_aux_diagr(lisf,typdoc,lind,%gd)

  bsnam=get_extname(lisf,%gd)
  bsrep=%gd.lang(lind)+'/'+bsnam

  ////////////////////////
  //1 - create _head.tex
  ////////////////////////
  gendoc_printf(%gd,"\tWrite a _head.tex file... ")
  txt=get_head_tex(lisf,typdoc,lind,%gd)
  mputl(txt,'./'+bsrep+'/'+bsnam+'_head.tex');
  gendoc_printf(%gd,"Done\n");

  /////////////////////////
  //2 - create  _diagrs.tex
  /////////////////////////
  gendoc_printf(%gd,"\tExport figure of diagram... ")
  export_diagr(lisf(1,1),lisf(1,2),typdoc);

  unix_g(%gd.cmd.mv+basename(lisf(1,2))+'/'+...
         basename(lisf(1,2))+'.eps '+bsrep+'/'+bsnam+'.eps ')

  rmdir(basename(lisf(1,2)),'s');
  gendoc_printf(%gd,"Done\n");

  size_diagr=return_size_scs_diagr(%gd.mpath.tex(lind)+...
                                   bsnam,...
                                   typdoc)
  if size_diagr==[] then size_diagr='width=400pt', end;
  size_diagr=strsubst(size_diagr,'[','');
  size_diagr=strsubst(size_diagr,']','');
  gendoc_printf(%gd,"\tWrite a _diagrs.tex file... ");
  if typdoc=='html' then
    txt=['\begin{center}' //figure block
         ' \epsfig{file='+bsnam+'.eps,'+size_diagr+'}'
         '\end{center}']
  else
    txt=[]; //TO BE DONE
    txt=['\begin{center}' //figure block
         '  \epsfig{file='+bsnam+'.eps,'+size_diagr+'}'
         '\end{center}']
  end
  mputl(txt,'./'+bsrep+'/'+bsnam+'_diagrs.tex');
  gendoc_printf(%gd,"Done\n")

  ///////////////////////
  //3 - create  _ctxt.tex
  ///////////////////////
  gendoc_printf(%gd,"\tExport context of diagram... ")
  context=return_context_diagr(lisf(1,1)+lisf(1,2));
  context=striplines(context)
  gendoc_printf(%gd,"Done\n")
  gendoc_printf(%gd,"\tWrite a _ctxt.tex file... ")
  mputl(context,'./'+bsrep+'/'+bsnam+'_ctxt.tex');
  gendoc_printf(%gd,"Done\n")

  ///////////////////////
  //4 - create  _block.tex
  ///////////////////////
  gendoc_printf(%gd,"\tExport list of block of diagram... ");
  if %gd.texopt.blkflg=='' then
   blk_lst=return_block_cos(lisf(1,1)+lisf(1,2),,1);
  else
   blk_lst=[]
   for j=1:size(%gd.texopt.blkflg,'*')
     blk_lst=[blk_lst;
              return_block_cos(lisf(1,1)+lisf(1,2),...
                               %gd.texopt.blkflg(j),1)];
   end
  end
  gendoc_printf(%gd,"Done\n");

  if blk_lst<>[] then
    gendoc_printf(%gd,"\tWrite a _block.tex file... ");

    txt=['\begin{itemize}']
    for g=1:size(blk_lst,1)

      ierr=execstr('txt2=return_xml_sdesc(%gd.mpath.xml(lind)+'+...
                    'get_extname(['''',blk_lst(g),''block''],%gd)+''.xml'');',...
                    'errcatch');
      if ierr==0 then
        if typdoc=='html' then
          txt=[txt;'\item{\htmladdnormallink{'+latexsubst(blk_lst(g))+...
                   ' - '+latexsubst(txt2(1,2))+'}{'+...
                   get_extname(['',blk_lst(g),'block'],%gd)+'.htm}}']
        else
          txt=[txt;'\item '+latexsubst(blk_lst(g))+' - '+latexsubst(txt2(1,2))];
        end
      else
        gendoc_printf(%gd,"\n%s : error while parsing block %s\n",...
        'gen_aux_diagr',...
        blk_lst(g));
        return
      end
    end
    txt=[txt;'\end{itemize}'];

    mputl(txt,'./'+bsrep+'/'+bsnam+'_block.tex');
    gendoc_printf(%gd,"Done\n");
  end


  ///////////////////////
  //5 - create  _scop.tex
  ///////////////////////
  gendoc_printf(%gd,"\tLaunch simulation of diagram... ")
  number_scope=scop_results_cos(lisf(1,1)+lisf(1,2))
  gendoc_printf(%gd,"Done\n")
  if number_scope<>0 then
   for k=1:number_scope
     //convert size of produced eps with gimp
     if %gd.opt.gimp then
        gendoc_printf(%gd,"\tResize figures of scope with Gimp... ");
        gimp_cmd=get_gimp_cmd(basename(lisf(1,2))+...
                              '_scope_'+string(k)+'.eps',...
                              %gd.cmd.rm);
        unix_g(gimp_cmd);
        gendoc_printf(%gd,"Done\n")
     end
     //mv eps file to documentation directory
     unix_g(%gd.cmd.mv+basename(lisf(1,2))+'_scope_'+...
            string(k)+'.eps '+bsrep);
   end

   //sort scope
   if number_scope>1 then
     gendoc_printf(%gd,"\tSort figure of scope... ");
     make_scope_order(lisf,lind,%gd)
     gendoc_printf(%gd,"Done\n");
   end

   //retrieve caption
   gendoc_printf(%gd,"\tGive caption of scope... ");
   capt=return_capt(%gd.mpath.tex(lind)+...
                    get_extname(lisf,%gd))
   if capt==[] then
     for k=1:number_scope
       if %gd.lang(lind)=='fr' then
          capt(k)='Résultats des ''scopes'''
       else
          capt(k)='Scope results'
       end
     end
   end
   //** automatically add captions for
   //** for scopes not informed in SPECIALDESC
   if size(capt,1) < number_scope then
     for k=1:number_scope-size(capt,1)
       capt($+1)='Scope results'
     end
   end
   gendoc_printf(%gd,"Done\n");

   //write _scop.tex
   gendoc_printf(%gd,"\tWrite a _scop.tex file... ");
   txt=[];
   sub_index=0;
   for k=1:number_scope
      if typdoc=='html' then
        txt=[txt;
             '\begin{figure}'
             '  \begin{center}'
             '    \epsfig{file='+basename(lisf(1,2))+...
                           '_scope_'+string(k)+'.eps,width=330.00pt}'
             '  \end{center}'
             '  \caption{'+capt(k)+'}'
             '\end{figure}'
             ''];
      else
        capt(k)=strsubst(capt(k),'\\',' ');
        if sub_index==0&k==1 then
          txt=[txt;'\begin{figure}[!h]';
                   '  \centering';]
        end
        txt=[txt;
             '  \subfigure['+capt(k)+']{\epsfig{file='+...
             basename(lisf(1,2))+'_scope_'+string(k)+'.eps,width=230.00pt}}']
        sub_index=sub_index+1;
        if sub_index==2&k<>number_scope then
           sub_index=0;
//               txt=[txt;'\end{figure}']
           txt($)=txt($)+'\\'
        elseif sub_index==2 then
           sub_index=0;
           if %gd.lang(lind)=='fr' then
             txt=[txt;
                  '  \caption{Résultats de simulation}'
                  '\end{figure}']
           elseif %gd.lang(lind)=='eng' then
             txt=[txt;
                  '  \caption{Simulation results}'
                  '\end{figure}']
           end
        else
           txt=[txt;'\goodgap']
        end
      end
   end
   if typdoc=='guide' then
      if sub_index==1 then
        if %gd.lang(lind)=='fr' then
          txt=[txt;
               '  \caption{Résultats de simulation}'
               '\end{figure}']
         elseif %gd.lang(lind)=='eng' then
          txt=[txt;
               '  \caption{Simulation results}'
               '\end{figure}']
          end
      end
   end
   mputl(txt,bsrep+'/'+bsnam+'_scop.tex');
   gendoc_printf(%gd,"Done\n");
  end

  /////////////////////
  //6 - create _mod.tex
  /////////////////////
  if typdoc=='html' then
    if %gd.texopt.modflg<>'' then
      gendoc_printf(%gd,"\tWrite a _mod.tex file... ")
      txt=['\begin{itemize}'
           '  \item{\htmladdnormallink{'+...
                %gd.texopt.modflg+'}{'+%gd.htmlopt.what_nam+'}}'
           '\end{itemize}']
      if typdoc=='html'&%gd.opt.toc then
        txt=[txt;'\tableofcontents']
      end
      mputl(txt,'./'+bsrep+'/'+bsnam+'_mod.tex')
      gendoc_printf(%gd,"Done\n");
    end
  end
endfunction
