//generate_html_file

function generate_html_file(lisf,%gd)

 //typdoc='html'
 //generate_aux_tex_file(lisf,typdoc,%gd)

 name=get_extname(lisf,%gd)

 sav_rep=pwd()

 for i=1:size(%gd.lang,1)

    for j=1:size(lisf,1)

       //
       gendoc_printf(%gd,"(%s) **Html generation of %s**\n",%gd.lang(i),name(j));

       rep=%gd.lang(i)+'/'+...
               name(j)

       ierr=execstr('chdir(rep)','errcatch')
       if ierr==0 then

         if lisf(j,3)=='block'|...
             lisf(j,3)=='mblock'|...
              lisf(j,3)=='sci' then

           %gdd=%gd;
           %gdd.lang=%gd.lang(i);
           %gdd.mpath.data=%gd.mpath.data(i);
           %gdd.mpath.xml=%gd.mpath.xml(i);
           %gdd.mpath.tex=%gd.mpath.tex(i);
           %gdd.mpath.html=%gd.mpath.html(i);
           %gdd.opt.clean_html=%f;

           chdir(sav_rep)

           //Add a test for generation of routines of scicos block
           if fileinfo(%gd.lang(i)+'/'+basename(lisf(j,2))+'/'+...
                      basename(lisf(j,2))+'_comput_lisf')<>[] then
             txt=mgetl(%gd.lang(i)+'/'+basename(lisf(j,2))+'/'+...
                      basename(lisf(j,2))+'_comput_lisf');
             txt=matrix(txt,3,-1)'

             gendoc_printf(%gd,"\n\t ****************************************\n")
             gendoc_printf(%gd,"\t ** Generation for computational func. **\n")
             gendoc_printf(%gd,"\t ****************************************\n")

             //call generate_html_file
             for ij=1:size(txt,1)
               generate_html_file(txt(ij,:),%gdd)
             end

             gendoc_printf(%gd,"\t ****************************************\n\n")

           end

           //for interfacing function
           if fileinfo(%gd.lang(i)+'/'+basename(lisf(j,2))+'_intfunc')<>[] then

             gendoc_printf(%gd,"\n\t **************************************\n")
             gendoc_printf(%gd,"\t ** Generation for interfacing func. **\n")
             gendoc_printf(%gd,"\t **************************************\n")

             //call generate_html_file
             generate_html_file([lisf(j,1) lisf(j,2) 'intfunc'],%gdd)

             gendoc_printf(%gd,"\t **************************************\n\n")

           end

           //for scilab function
           if fileinfo(%gd.lang(i)+'/'+basename(lisf(j,2))+'_scifunc')<>[] then

             gendoc_printf(%gd,"\n\t *******************************\n")
             gendoc_printf(%gd,"\t ** Generation for scilab func. **\n")
             gendoc_printf(%gd,"\t *********************************\n")

             //call generate_html_file
             generate_html_file([lisf(j,1) lisf(j,2) 'scifunc'],%gdd)

             gendoc_printf(%gd,"\t *********************************\n\n")

           end
           chdir(rep)

         end

         //run LaTeX for cross-reference
         gendoc_printf(%gd,"\tRun latex for cross reference... ")
         [ret,stat]=unix_g(%gd.cmd.latex+name(j)+'.tex');
         if stat<>0 then
            gendoc_printf(%gd,"\n\t   ** Warning : an error is reported\n\t")
         end
         gendoc_printf(%gd,"Done\n")

         //run LaTeX for bibliography
         flg_bib=%f;
         if fileinfo(name(j)+'_bib.tex')<>[] then //bibliography
           gendoc_printf(%gd,"\tBibliography file found. Run latex... ")
           [ret,stat]=unix_g(%gd.cmd.latex+name(j)+'.tex');
           if stat<>0 then
              gendoc_printf(%gd,"\n\t   ** Warning : an error is reported\n\t")
           end
           gendoc_printf(%gd,"Done\n")
           flg_bib=%t; //flag bib
         end

         //analyze tex files
         gendoc_printf(%gd,"\tAnalyzing tex file... ")
         analyse_tex_file();
         gendoc_printf(%gd,"Done\n")

         //conversion latex2html
         gendoc_printf(%gd,"\tConvert tex file in html... ");
         [ret,stat]=unix_g(%gd.cmd.convtex+name(j)+'_ '+name(j));
         if stat<>0 then
            gendoc_printf(%gd,"\n\t   ** Warning : an error is reported\n\t")
         end
         gendoc_printf(%gd,"Done\n");

         //change color subtitle
         html_txt=change_color_subtitle('./'+name(j)+'/'+name(j)+'.htm',%gd);
         if html_txt<>[] then mputl(html_txt,'./'+name(j)+'/'+name(j)+'.htm'); end;

         //change font
         html_txt=change_font('./'+name(j)+'/'+name(j)+'.htm',lisf(j,3),%gd);
         if html_txt<>[] then mputl(html_txt,'./'+name(j)+'/'+name(j)+'.htm'); end;

         //change bibliography level
         if flg_bib then
           html_txt=change_level_bib('./'+name(j)+'/'+name(j)+'.htm',%gd);
           if html_txt<>[] then mputl(html_txt,'./'+name(j)+'/'+name(j)+'.htm'); end;
         end

         //change 'Contents' and 'Bibliography' line
         if %gd.lang(i)<>'eng' then
           html_txt=change_contents_line('./'+name(j)+'/'+name(j)+'.htm',i,%gd);
           if html_txt<>[] then mputl(html_txt,'./'+name(j)+'/'+name(j)+'.htm'); end;
         end

         //Rename bibliography title
         //if %gd.lang(i)<>'eng' then
         html_txt=change_biblio_line('./'+name(j)+'/'+name(j)+'.htm',i,%gd);
         if html_txt<>[] then mputl(html_txt,'./'+name(j)+'/'+name(j)+'.htm'); end;
         //end

         //Parse html file to change directory and names of images
         if %gd.mpath.html_img<>'' then
           html_txt=change_img_path('./'+name(j)+'/'+name(j)+'.htm',i,%gd);
           if html_txt<>[] then mputl(html_txt,'./'+name(j)+'/'+name(j)+'.htm'); end;
         end

         //Report previous gif files if any
         if fileinfo('./'+name(j)+'_gui.gif')<>[] then
           [ret,stat]=unix_g(%gd.cmd.cp+'./'+name(j)+'*_gui.gif ./'+name(j));
         end

         if fileinfo('./'+name(j)+'.gif')<>[] then
           [ret,stat]=unix_g(%gd.cmd.cp+'./'+name(j)+'*.gif ./'+name(j));
         end

         //Analyze created files
         tt=listfiles("./"+name(j)+"/");
         htm_f=%f;gif_f=%f;
         for k=1:size(tt,1)
           if strindex(tt(k),'.htm')<>[] then htm_f=%t, end;
           if strindex(tt(k),'.gif')<>[] then gif_f=%t, end;
         end

         //move htm files
         if htm_f then
           gendoc_printf(%gd,"\tMove html files... ");
           [ret,stat]=unix_g(%gd.cmd.cpf+'./'+name(j)+'/'+name(j)+'.htm '+%gd.mpath.html(i))
           if stat<>0 then
              gendoc_printf(%gd,"\n\t   ** Warning : an error is reported\n\t")
           end
           gendoc_printf(%gd,"Done\n");
         end

         //move gif files
         if gif_f then
           gendoc_printf(%gd,"\tMove gif files... ");
           if %gd.mpath.html_img<>'' then
             [ret,stat]=unix_g(%gd.cmd.cpf+'./'+name(j)+...
                               '/*.gif '+%gd.mpath.html(i)+%gd.mpath.html_img);
             if stat<>0 then
                gendoc_printf(%gd,"\n\t   ** Warning : an error is reported\n\t")
             end
           else
             [ret,stat]=unix_g(%gd.cmd.cpf+'./'+name(j)+...
                               '/*.gif '+%gd.mpath.html(i));
             if stat<>0 then
                gendoc_printf(%gd,"\n\t   ** Warning : an error is reported\n\t")
             end
           end
           gendoc_printf(%gd,"Done\n");
         end

         //clean temporary files
         chdir(sav_rep)
         if %gd.opt.clean_html then
           gendoc_printf(%gd,"\tClean temporary files... ");
           rmdir(rep,'s')
           gendoc_printf(%gd,"Done\n");
         end

      end

    end

    if %gd.opt.clean_html then
      //clean temp. directory
      rmdir(%gd.lang(i),'s')
    end
 end

endfunction 
