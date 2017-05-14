//1 - create _head.tex
//2 - create _diagrs.tex
//3 - create _ctxt.tex
//4 - create _script.tex
//5 - create _scop.tex
//6 - create  _block.tex
//7 - create _mod.tex
function []=gen_aux_sim(lisf,typdoc,lind,%gd)

  bsnam=get_extname(lisf,%gd)
  bsrep=%gd.lang(lind)+'/'+bsnam

  ////////////////////////
  //1 - create _head.tex
  ////////////////////////
  gendoc_printf(%gd,"\tWrite a _head.tex file... ")
  txt=get_head_tex(lisf,typdoc,lind,%gd)
  if typdoc=='html'&%gd.opt.toc then
    txt=[txt;'\tableofcontents']
  end
  mputl(txt,'./'+bsrep+'/'+bsnam+'_head.tex');
  gendoc_printf(%gd,"Done\n");

  /////////////////////////
  //2 - create _diagrs.tex
  /////////////////////////
  lisf_cos=dir(lisf(1,1)+"*.cos")
  if lisf_cos.name<>[] then
    lisf_cos=basename(lisf_cos.name)+'.cos'
    gendoc_printf(%gd,"\tExport figure of diagram... ")
    for j=1:size(lisf_cos,1)
      export_diagr(lisf(1,1),lisf_cos(j,1),typdoc)
      unix_g(%gd.cmd.mv+basename(lisf_cos(j,1))+'/'+...
             basename(lisf_cos(j,1))+'.eps '+bsrep+'/'+...
             basename(lisf_cos(j,1))+'.eps ')

      rmdir(basename(lisf_cos(j,1)),'s')
    end
    gendoc_printf(%gd,"Done\n")
    size_diagr=return_size_scs_diagr2(%gd.mpath.tex(lind)+...
                                      bsnam,...
                                      typdoc)
    if size_diagr==[]|...
          (size(size_diagr,1)<>size(lisf_cos,1)) then
      for j=1:size(lisf_cos,1)
        size_diagr(j)='width=400pt'
      end
    end

    txt=[];
    gendoc_printf(%gd,"\tWrite a _diagrs.tex file... ")
    for j=1:size(lisf_cos,1)
      filef=basename(lisf_cos(j,1))
      if typdoc=='html' then
         txt=[txt;
              '\begin{center}' //figure block
              '  \epsfig{file='+filef+'.eps,'+size_diagr(j)+'}'
              '\end{center}'
              '\begin{center}'
              '  \textbf{'+latexsubst(lisf_cos(j,1))+'}'
              '\end{center}']
      else
         txt=[]; //TO BE DONE
         txt=[txt;
              '\begin{center}' //figure block
              '  \epsfig{file='+filef+'.eps,'+size_diagr(j)+'}'
              '\end{center}'
              '\begin{center}'
              '  \textbf{'+latexsubst(lisf_cos(j,1))+'}'
              '\end{center}']
      end
    end
    mputl(txt,'./'+bsrep+'/'+bsnam+'_diagrs.tex')
    gendoc_printf(%gd,"Done\n")
  end

  /////////////////////////
  //3 - create _ctxt.tex
  /////////////////////////
  gendoc_printf(%gd,"\tExport context of diagram...\n ")
  lisf_ctxt=dir(lisf(1,1)+"*_ctxt.sce");
  if lisf_ctxt.name<>[] then
    lisf_ctxt=basename(lisf_ctxt.name)+'.sce'
    gendoc_printf(%gd,"\tWrite a _ctxt.tex file... ");
    txt=[];
    for j=1:size(lisf_ctxt,1)
      if typdoc=='html' then
        txt=[txt;
             '\verbatiminput{'+...
                  lisf(1,1)+lisf_ctxt(j,1)+'}'];
      else
        txt=[txt;'\begin{small}'
                 ' \verbatiminput{'+...
                   lisf(1,1)+lisf_ctxt(j,1)+'}'
                 '\end{small}'];
      end
      txt=[txt;
           '\begin{center}'
           '  \textbf{'+latexsubst(lisf_ctxt(j,1))+'}'
           '\end{center}']
    end
    mputl(txt,'./'+bsrep+'/'+bsnam+'_ctxt.tex')
    gendoc_printf(%gd,"Done\n")
  end

  /////////////////////////
  //4 - create _script.tex
  /////////////////////////
  lisf_sce=dir(lisf(1,1)+"*.sce");
  lisf_sce=basename(lisf_sce.name)+'.sce'
  if lisf_sce<>[] then
    gendoc_printf(%gd,"\tWrite a _script.tex file... ")
    txt=[];
    for j=1:size(lisf_sce,1)
      if strindex(lisf_sce(j,1),'_ctxt.sce')==[] then
        if typdoc=='html' then
           txt=[txt;
                '\verbatiminput{'+...
                 lisf(1,1)+lisf_sce(j,1)+'}']
        else
           txt=[txt;'\begin{small}'
                    '  \verbatiminput{'+...
                       lisf(1,1)+lisf_sce(j,1)+'}'
                    '\end{small}']
        end
        txt=[txt;'\begin{center}'
                 '  \textbf{'+latexsubst(lisf_sce(j,1))+'}'
                 '\end{center}']
      end
    end
    mputl(txt,'./'+bsrep+'/'+bsnam+'_script.tex');
    gendoc_printf(%gd,"Done\n");
  end

  //////////////////////
  //5 - create _scop.tex
  //////////////////////
  if fileinfo(lisf(1,1)+lisf(1,2))<>[] then
    if %gd.opt.sim then
      gendoc_printf(%gd,"\tLaunch simulation... ")
      number_scope=scop_results_sim(lisf(1,1)+lisf(1,2))
      gendoc_printf(%gd,"Done\n")

      if number_scope<>0 then
         for k=1:number_scope
           //convert size of produced eps with gimp
           if %gd.opt.gimp then
             gendoc_printf(%gd,"\tResize figures of scope with Gimp... ");
             gimp_cmd=get_gimp_cmd(basename(lisf(1,2))+...
                                   '_scope_'+string(k)+'.eps',...
                                   %gd.cmd.rm)
             unix_g(gimp_cmd);
             gendoc_printf(%gd,"Done\n")
           end
           //mv eps file to documentation directory
           unix_g(%gd.cmd.mv+basename(lisf(1,2))+'_scope_'+...
                  string(k)+'.eps '+bsrep)
         end

         //sort scope
         if number_scope>1 then
            gendoc_printf(%gd,"\tSort figure of scope... ")
            make_scope_order(lisf,lind,%gd)
            gendoc_printf(%gd,"Done\n");
         end

         //retrieve caption
         gendoc_printf(%gd,"\tGive caption of scope... ")
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
                           '_scope_'+string(k)+'.eps,width=300.00pt}'
                  '  \end{center}'
                  '  \caption{'+capt(k)+'}'
                  '\end{figure}']
           else
             capt(k)=strsubst(capt(k),'\\',' ');
             if sub_index==0&k==1 then
               txt=[txt;'\begin{figure}[!h]';
                        '  \centering']
             end
             txt=[txt;
                  '  \subfigure['+capt(k)+']{\epsfig{file='+...
             basename(lisf(1,2))+'_scope_'+string(k)+'.eps,width=230.00pt}}']
             sub_index=sub_index+1
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
         mputl(txt,bsrep+'/'+bsnam+'_scop.tex')
         gendoc_printf(%gd,"Done\n");
      end
    end
  end

  ////////////////////////
  //6 - create  _block.tex
  ////////////////////////
  lisf_cos=dir(lisf(1,1)+"*.cos")
  lisf_cos=basename(lisf_cos.name)+'.cos'
  if lisf_cos<>[] then
    txt=[];
    for k=1:size(lisf_cos,1)
      if %gd.texopt.blkflg=='' then
        blk_lst=return_block_cos(lisf(1,1)+...
                                 lisf_cos(k),,1)
      else
        blk_lst=[]
        for j=1:size(%gd.texopt.blkflg,'*')
          blk_lst=[blk_lst;
                   return_block_cos(lisf(1,1)+...
                                    lisf_cos(k),...
                                    %gd.texopt.blkflg(j),1)]
        end
      end

      if blk_lst<>[] then
        gendoc_printf(%gd,"\tExport list of block of diagram... ")
        for g=1:size(blk_lst,1)
          txt2=return_xml_sdesc(%gd.mpath.xml(lind)+...
                                get_extname(['',blk_lst(g),'block'],%gd)+'.xml')
          if typdoc=='html' then
            txt=[txt;'\item{\htmladdnormallink{'+latexsubst(blk_lst(g))+...
                     ' - '+latexsubst(txt2(1,2))+'}{'+...
                                get_extname(['',blk_lst(g),'block'],%gd)+'.htm}}']
          else
            txt=[txt;'\item '+latexsubst(blk_lst(g))+' - '+latexsubst(txt2(1,2))]
          end
        end
        gendoc_printf(%gd,"Done\n");
      end
    end

    if txt<>[] then
      gendoc_printf(%gd,"\tWrite a _ctxt.tex file... ");
      //Elimine les doublons
      //TO BE DONE
      txt=['\begin{itemize}';'   '+txt;'\end{itemize}']
      mputl(txt,'./'+bsrep+'/'+bsnam+'_block.tex')
      gendoc_printf(%gd,"Done\n")
    end

  end

  /////////////////////
  //7 - create _mod.tex
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

