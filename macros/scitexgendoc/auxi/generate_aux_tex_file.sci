//generate_aux_tex_file
//
function []=generate_aux_tex_file(lisf,typdoc,%gd)

 //Check rhs
 rhs=argn(2)
 if rhs==2 then
   %gd=typdoc
   typdoc='html'
 end

 if ~(typdoc=='html'|typdoc=='guide') then
   gendoc_printf(%gd,"%s : bad ''typdoc'' parameter : %s\n",...
          'generate_aux_tex_file',...
          typdoc);
   return
 end

 //generate empty xml file(s)
 generate_xml_file(lisf,%gd);

 for j=1:size(%gd.lang,1)
   name=get_extname(lisf,%gd)

   //create lang directory
   if fileinfo(%gd.lang(j)+'/')==[] then
     mkdir(%gd.lang(j))
   end

   for i=1:size(lisf,1)

     //
     gendoc_printf(%gd,"(%s) **Tex generation of %s**\n",%gd.lang(j),name(i));

     //check type of object
     for k=1:size(%gd.ext(1),2)-1
       ko=%f;
       if lisf(i,3)==%gd.ext(1)(k+1) then
          ko=%t;
          break;
       end
     end
     if ~ko then
       gendoc_printf(%gd,"%s : bad scilab object : %s (%s)\n",...
              'generate_aux_tex_file',...
              lisf(i,1),...
              lisf(i,3))
       break
     end
     ext_ind=k

     //create object directory for
     //tex compilation
     if fileinfo(%gd.lang(j)+'/'+...
                   name(i))==[] then
       mkdir(%gd.lang(j)+'/'+name(i))
     end

     //call the good scilab function
     //for auxiliary tex file generation
     prot=funcprot()
     funcprot(0)
     ierr=execstr("func=gen_aux_"+%gd.ext(1)(ext_ind+1),'errcatch');
     funcprot(prot)
     if ierr==0 then
       func(lisf(i,:),typdoc,j,%gd)
     else
       gendoc_printf(%gd,"%s : error while running : %s (%s)\n",...
              'generate_aux_tex_file',...
              'gen_aux_'+%gd.ext(1)(ext_ind+1),...
              lisf(i,2));
     end

     //test tex directory
     if fileinfo(%gd.mpath.tex(j)+name(i))<>[] then
        gendoc_printf(%gd,"\tTex directory "+name(i)+" found.\n")
//         if fileinfo(%gd.mpath.tex(j)+name(i)+'/Makefile')<>[] then
//            gendoc_printf(%gd,"\tMakefile in Tex directory found :"+...
//                      " process all+clean... ")
        repi=pwd()
        chdir(%gd.mpath.tex(j)+name(i))
        gendoc_printf(%gd,"\tGenerate a Makefile in Tex directory ... ")
        txt = get_makefile_tex();
        mputl(txt,...
              'Makefile')
        gendoc_printf(%gd,"Done\n")
        gendoc_printf(%gd,"\tProcessing Makefile (all+clean) ... ")
        unix_g(%gd.cmd.make_all)
        fc=unix_g(%gd.cmd.cp+'* '+repi+...
                     '/'+%gd.lang(j)+'/'+name(i));
        unix_g(%gd.cmd.make_clean)
        chdir(repi)
        gendoc_printf(%gd,"Done\n")
//         else
//            fc=unix_g(%gd.cmd.cp+%gd.mpath.tex(j)+...
//                      name(i)+'/* '+%gd.lang(j)+'/'+name(i));
//         end
     end

     //switch conv2tex_param function
     //for rout/sce/sci
     if lisf(i,3)==%gendoc.typobj.sci|...
          lisf(i,3)==%gendoc.typobj.sce|...
           lisf(i,3)==%gendoc.typobj.rout then
          prot=funcprot()
          funcprot(0)
          conv2tex_param=conv2tex_param_in
          funcprot(prot)
     end

     //xml2tex convertion
     gendoc_printf(%gd,"\tConvert xml file in tex... ");
     ierr=execstr('texlist=xml2tex(%gd.mpath.xml(j)+name(i)+''.xml'')','errcatch');
     if ierr<>0 then
       gendoc_printf(%gd,"%s : error while running : %s (%s)\n",...
              'generate_aux_tex_file',...
              'xml2tex',...
              name(i)+'.xml');
              error(10000)
              return
     end
     gendoc_printf(%gd,"Done\n");

     clear conv2tex_param

     for k=2:size(texlist(2)(1),2)
        ext=[];
        for l=2:size(%gd.exttex(1),2)
          if (texlist(2)(1)(k)==%gd.exttex(1)(l)) then
            ext=%gd.exttex(l)
            break
          end
        end

        if ext<>[] then
           if fileinfo(%gd.lang(j)+...
                       '/'+name(i)+...
                       '/'+name(i)+ext+'.tex')==[] then
//               if (texlist(2)(k)<>[]&texlist(2)(k)<>"") then
                ko=isemptystr(texlist(2)(k));
                if ~ko then
                  gendoc_printf(%gd,"\tWrite a "+ext+".tex file... ");
                  mputl(texlist(2)(k),%gd.lang(j)+...
                        '/'+name(i)+...
                        '/'+name(i)+ext+'.tex');
                  gendoc_printf(%gd,"Done\n");
               end
           end
        end
     end

     //call the good scilab function
     //for main tex file generation
     prot=funcprot()
     funcprot(0)
     ierr=execstr("func=gen_"+%gd.ext(1)(ext_ind+1)+"_tex_file",'errcatch');
     funcprot(prot)
     if ierr==0 then
        func(lisf(i,:),typdoc,j,%gd)
     else
        gendoc_printf(%gd,"%s : error while running : %s (%s)\n",...
               'generate_aux_tex_file',...
               'gen_'+%gd.ext(1)(ext_ind+1)+"_tex_file",...
               lisf(i,2));
     end

   end

 end

endfunction