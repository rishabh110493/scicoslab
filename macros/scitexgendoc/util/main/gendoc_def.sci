//initialisation de la liste typée tl_doc
function tl_doc=gendoc_def(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,...
                           v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,...
                           v23,v24,v25,v26,v27,v28,v29,v30,v31,v32,...
                           v33,v34,v35,v36,v37,v38,v39,v40,v41,v42)
 //lang
 if ~exists('lang','local') then
   if ~exists('LANGUAGE') then
     global LANGUAGE;lang=LANGUAGE;clear LANGUAGE;
   else
    lang=LANGUAGE;
   end
   if ~or(lang==get_sup_lang()) then
     printf("language %s is not supported, switch to ''eng''\n",lang);
     lang='eng';
   end
 else
   lang=lang(:);
   for i=1:size(lang,1)
     if ~or(lang(i)==get_sup_lang()) then
       printf("language ''%s'' is not supported"+...
              ", switch to ''eng''.\n",lang(i));
       lang='eng';
       break;
     end
   end
 end

 //chemins du répertoire man
 if ~exists('man_path','local') then
  man_path = pwd()+'/man/';
 end
 if ~exists('data_path','local') then
  data_path = man_path+'data/';
 end
 if ~exists('xml_path','local') then
  xml_path  = man_path+'xml/';
 end
 if ~exists('tex_path','local') then
  tex_path  = man_path+'tex/';
 end
//N'EXISTE PAS (IMPLICITE AVEc tex/)
//  if ~exists('bib_path','local') then
//   bib_path  = man_path+'tex/bib/';
//  end
 if ~exists('html_path','local') then
  html_path = man_path+'htm/';
 end
 if ~exists('html_img_path','local') then
  html_img_path = '';
 end
 if ~exists('pdf_path','local') then
  pdf_path  = man_path+'pdf/';
 end
 if ~exists('web_path','local') then
  web_path  = man_path+'web/';
 end

 mpath=tlist(['mpath','man','data','xml',...
              'tex','html','html_img','pdf','web'],...
              man_path,data_path,xml_path,...
              tex_path,html_path,html_img_path,...
              pdf_path,web_path);

 //object path
 //les chemins peuvent-être multiples
 if ~exists('sbeq_path','local') then
  sbeq_path = "";
 end
 if ~exists('rout_path','local') then
  rout_path = "";
 end
 if ~exists('pal_path','local') then
  pal_path = "";
 end

 opath=tlist(['opath','sbeq','rout','pal'],...
              sbeq_path,rout_path,pal_path);

 //cmd
 if ~exists('latex_cmd','local') then
  latex_cmd = "latex -interaction=nonstopmode ";
 end
 if ~exists('dvips_cmd1','local') then
  dvips_cmd1 = "dvips -E ";
 end
 if ~exists('dvips_cmd2','local') then
  dvips_cmd2 = "dvips -o ";
 end
 if ~exists('convtex_cmd','local') then
  convtex_cmd = "latex2html -white -info """" -no_navigation"+..
                " -link 0 -split 3 -short_extn -image_type gif -prefix ";
 end
 if ~exists('bibtex_cmd','local') then
   bibtex_cmd = "bibtex ";
 end
 if ~exists('wbr_cmd','local') then
   wbr_cmd = "mozilla ";
 end
//  if ~exists('xwd_cmd','local') then
//    xwd_cmd = "xwd -name ''Set Block properties'' | convert - ";
//  end
 if ~exists('xwd_cmd','local') then
   xwd_cmd = "import -frame -window ''Set Block properties'' ";
 end
 if ~exists('dir_cmd','local') then
   dir_cmd = "ls ";
 end
 if ~exists('mkdir_cmd','local') then
   mkdir_cmd = "mkdir ";
 end
 if ~exists('mv_cmd','local') then
   mv_cmd = "mv -f ";
 end
 if ~exists('rm_cmd','local') then
   rm_cmd = "rm -fr ";
 end
 if ~exists('cp_cmd','local') then
   cp_cmd = "cp -fr ";
 end
 //for file(s) only
 if ~exists('cpf_cmd','local') then
   cpf_cmd = "cp ";
 end
 if ~exists('make_all_cmd','local') then
   make_all_cmd = "make all ";
 end
 if ~exists('make_clean_cmd','local') then
   make_clean_cmd = "make clean ";
 end
 if ~exists('ps2pdf_cmd','local') then
   ps2pdf_cmd = "ps2pdf14 ";
 end
 if ~exists('export_cmd','local') then
   export_cmd = "export ";
 end
 if ~exists('gv_cmd','local') then
   gv_cmd = "gv ";
 end
 if ~exists('convert_cmd','local') then
   convert_cmd = "convert ";
 end
 if ~exists('identify_cmd','local') then
   identify_cmd = "identify ";
 end

 cmd=tlist(['cmd','latex','dvips1','dvips2','convtex','bibtex',...
            'wbr','xwd','dir','mk','mv','rm','cp','cpf',...
            'make_all','make_clean','ps2pdf','export',...
            'gv','convert','identify'],...
            latex_cmd,dvips_cmd1,dvips_cmd2,convtex_cmd,bibtex_cmd,wbr_cmd,...
            xwd_cmd,dir_cmd,mkdir_cmd,mv_cmd,rm_cmd,cp_cmd,cpf_cmd,...
            make_all_cmd,make_clean_cmd,ps2pdf_cmd,export_cmd,...
            gv_cmd,convert_cmd,identify_cmd);

 //option
 if ~exists('with_sim','local') then with_sim=%t, end
 if ~exists('with_gui','local') then with_gui=%t, end
 if ~exists('with_gimp','local') then with_gimp=%t, end
 if ~exists('with_TOC','local') then with_TOC=%t, end
 if ~exists('sci_browser','local') then sci_browser=%t, end
 if ~exists('verbose','local') then verbose=%t, end
 if ~exists('with_log','local') then with_log=%f, end
 if ~exists('name_log','local') then
   name_log=TMPDIR+'/scitexgendoc.log'
 end
 if ~exists('fd_log','local') then fd_log=-1, end
 //initialisation of file of log
 if with_log then
   if fd_log<0 then
     [fd_log,err]=mopen(name_log,'a+');
     mfprintf(fd_log,"\n**** %s : gendoc_def **** \n",...
              get_tdate());
   end
 end
 if ~exists('clean_html','local') then clean_html=%t, end
 if ~exists('clean_guide','local') then clean_guide=%t, end

 opt=tlist(['opt','sim','gui','gimp','toc',...
            'sci_browser','verbose',...
            'with_log','name_log','fd_log',...
            'clean_html','clean_guide'],...
            with_sim,with_gui,with_gimp,with_TOC,...
            sci_browser,verbose,...
            with_log,name_log,fd_log,...
            clean_html,clean_guide);

 //Nom des types d'objets documentables
 if ~exists('mblock_nam','local') then
    mblock_nam='mblock'
 end
 if ~exists('block_nam','local') then
    block_nam='block'
 end
 if ~exists('diagr_nam','local') then
    diagr_nam='diagr'
 end
 if ~exists('pal_nam','local') then
    pal_nam='pal'
 end
 if ~exists('scilib_nam','local') then
    scilib_nam='scilib'
 end
 if ~exists('sci_nam','local') then
    sci_nam='sci'
 end
 if ~exists('sim_nam','local') then
    sim_nam='sim'
 end
 if ~exists('sce_nam','local') then
    sce_nam='sce'
 end
 if ~exists('rout_nam','local') then
    rout_nam='rout'
 end
 if ~exists('routcos_nam','local') then
    routcos_nam='routcos'
 end
 if ~exists('intfunc_nam','local') then
    intfunc_nam='intfunc'
 end
 if ~exists('scifunc_nam','local') then
    scifunc_nam='scifunc'
 end
 if ~exists('sbeq_nam','local') then
    sbeq_nam='sbeq'
 end

 typobj=tlist(['typobj','mblock','block','diagr',...
               'pal','scilib','sci','sim','sce','rout',...
               'routcos','intfunc','scifunc','sbeq'],...
               mblock_nam,block_nam,diagr_nam,...
               pal_nam,scilib_nam,sci_nam,sim_nam,sce_nam,rout_nam,...
               routcos_nam,intfunc_nam,scifunc_nam,sbeq_nam)

 //extension
 if ~exists('ext_block','local') then ext_block='blk', end
 if ~exists('ext_mblock','local') then ext_mblock='blk', end
 if ~exists('ext_diagr','local') then ext_diagr='diagr', end
 if ~exists('ext_pal','local') then ext_pal='pal', end
 if ~exists('ext_scilib','local') then ext_scilib='scilib', end
 if ~exists('ext_sci','local') then ext_sci='sci', end
 if ~exists('ext_sim','local') then ext_sim='sim', end
 if ~exists('ext_sce','local') then ext_sce='sce', end
 if ~exists('ext_rout','local') then ext_rout='rout', end
 if ~exists('ext_routcos','local') then ext_routcos='routcos', end
 if ~exists('ext_intfunc','local') then ext_intfunc='intfunc', end
 if ~exists('ext_scifunc','local') then ext_scifunc='scifunc', end
 if ~exists('ext_sbeq','local') then ext_sbeq='sbeq', end

 ext=tlist(['ext',mblock_nam,block_nam,diagr_nam,pal_nam,...
            scilib_nam,sci_nam,sim_nam,sce_nam,rout_nam,...
            routcos_nam,intfunc_nam,scifunc_nam,sbeq_nam],...
            ext_mblock,ext_block,ext_diagr,ext_pal,...
            ext_scilib,ext_sci,ext_sim,...
            ext_sce,ext_rout,ext_routcos,ext_intfunc,...
            ext_scifunc,ext_sbeq);

 //extension fichier tex
 if ~exists('exttex_sdesc','local') then exttex_sdesc='_sdesc', end
 if ~exists('exttex_cseq','local') then exttex_cseq='_call_seq', end
 if ~exists('exttex_desc','local') then exttex_desc='_long', end
 if ~exists('exttex_rmk','local') then exttex_rmk='_rmk', end
 if ~exists('exttex_ex','local') then exttex_ex='_ex', end
 if ~exists('exttex_param','local') then exttex_param='_param', end
 if ~exists('exttex_ufunc','local') then exttex_ufunc='_used_func', end
 if ~exists('exttex_salso','local') then exttex_salso='_see_also', end
 if ~exists('exttex_bib','local') then exttex_bib='_bib', end
 if ~exists('exttex_auth','local') then exttex_auth='_authors', end
 if ~exists('exttex_spdesc','local') then
    exttex_spdesc='SPECIALDESC',
 end

 exttex=tlist(['exttex','sdesc','cseq','desc',...
               'rmk','ex','param','ufunc','salso',...
               'bib','auth','spdesc'],...
               exttex_sdesc,exttex_cseq,exttex_desc,...
               exttex_rmk,exttex_ex,exttex_param,...
               exttex_ufunc,exttex_salso,exttex_bib,...
               exttex_auth,exttex_spdesc);

 //generate xml option
//  if ~exists('gxml_blk_param','local') then
//   gxml_blk_param="%t"
//  end
//  if ~exists('gxml_pal_also','local') then
//   gxml_pal_also="%t"
//  end
//  if ~exists('gxml_scilib_also','local') then
//   gxml_scilib_also="%t"
//  end
//  if ~exists('gxml_diagr_also','local') then
//   gxml_diagr_also="%t"
//  end
//
//  if ~exists('gxml_blk_des','local') then
//   gxml_blk_des="%t"
//  end
//  if ~exists('gxml_blk_gui_des','local') then
//   gxml_blk_gui_des="%t"
//  end
//  if ~exists('gxml_pal_des','local') then
//   gxml_pal_des="%t"
//  end
//  if ~exists('gxml_diagr_des','local') then 
//   gxml_diagr_des="%t"
//  end
//  if ~exists('gxml_sim_des','local') then 
//   gxml_sim_des="%t"
//  end

 //fichiers de données
 if ~exists('file_sdesc','local') then
    file_sdesc='data_sdesc.xml'
 end
 if ~exists('file_cseq','local') then
    file_cseq='data_call_seq.xml'
 end
 if ~exists('file_desc','local') then
    file_desc='data_desc.xml'
 end
 if ~exists('file_rmk','local') then
    file_rmk='data_rmk.xml'
 end
 if ~exists('file_ex','local') then
    file_ex='data_ex.xml'
 end
 if ~exists('file_param','local') then
    file_param='data_param.xml'
 end
 if ~exists('file_ufunc','local') then
    file_ufunc='data_used_func.xml'
 end
 if ~exists('file_salso','local') then
    file_salso='data_see_also.xml'
 end
 if ~exists('file_bib','local') then
    file_bib='data_bib.xml'
 end
 if ~exists('file_auth','local') then
    file_auth='data_authors.xml'
 end
 if ~exists('file_spdesc','local') then
    file_spdesc='data_specdesc.xml'
 end
 if ~exists('file_fig','local') then
    file_fig='data_fig.xml'
 end
 if ~exists('file_eps','local') then
    file_eps='data_eps.tar.gz'
 end

 fdata=tlist(['fdata','sdesc','cseq','desc','rmk',...
              'ex','param','ufunc','salso','bib',...
              'auth','spdesc','fig','eps'],...
              file_sdesc,file_cseq,file_desc,...
              file_rmk,file_ex,file_param,file_ufunc,...
              file_salso,file_bib,file_auth,...
              file_spdesc,file_fig,file_eps);

 //tag XML
 if ~exists('tag_sdesc','local') then
    tag_sdesc='SHORT_DESCRIPTION'
 end
 if ~exists('tag_cseq','local') then
    tag_cseq='CALLING_SEQUENCE'
 end
 if ~exists('tag_desc','local') then
    tag_desc='DESCRIPTION'
 end
 if ~exists('tag_rmk','local') then
    tag_rmk=''
 end
 if ~exists('tag_ex','local') then
    tag_ex='EXAMPLE'
 end
 if ~exists('tag_param','local') then
    tag_param='PARAM'
 end
 if ~exists('tag_ufunc','local') then
    tag_ufunc='USED_FUNCTIONS'
 end
 if ~exists('tag_salso','local') then
    tag_salso='SEE_ALSO'
 end
 if ~exists('tag_bib','local') then
    tag_bib='BIBLIO'
 end
 if ~exists('tag_auth','local') then
    tag_auth='AUTHORS'
 end
 if ~exists('tag_spdesc','local') then
    tag_spdesc='SPECIALDESC'
 end
 if ~exists('tag_fig','local') then
    tag_fig='FIGFILE'
 end

 tag=tlist(['tag','sdesc','cseq','desc','rmk',...
            'ex','param','ufunc','salso','bib',...
            'auth','spdesc','fig'],...
            tag_sdesc,tag_cseq,tag_desc,...
            tag_rmk,tag_ex,tag_param,tag_ufunc,...
            tag_salso,tag_bib,tag_auth,tag_spdesc,...
            tag_fig);

 //tex option
 if ~exists('block_flag','local') then
    block_flag=''
 end
 if ~exists('lib_flag','local') then
    lib_flag=''
 end
 if ~exists('mod_flag','local') then
    mod_flag=''
 end
 if ~exists('path_flag','local') then
    path_flag=''
 end

 texopt=tlist(['texopt','blkflg','libflg','modflg','pathflg'],...
              block_flag,lib_flag,mod_flag,path_flag);

 //html option
 if ~exists('html_subtitle_color','local') then
   html_subtitle_color='red'
 end
 if ~exists('whatis_name','local') then
   whatis_name='whatis.htm'
 end

 htmlopt=tlist(['htmlopt','subtle_clr','what_nam'],...
                html_subtitle_color,whatis_name);

 //Type de documentation
 if ~exists('typdoc','local') then
    typdoc='html'
 end

 tl_doc=tlist(['gendoc','lang','mpath','opath'...
               'cmd','opt','texopt','htmlopt',...
               'ext','exttex','fdata',...
               'typdoc','tag','typobj'],..
                lang,mpath,opath,cmd,opt,texopt,...
                htmlopt,ext,...
                exttex,fdata,typdoc,tag,typobj)
endfunction
