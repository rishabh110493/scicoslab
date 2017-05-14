//
function import_data_to_file(flag,%gd)

 //Verifie cohérence des  paramètres
 flag=flag(:)
 for i=1:size(flag,1)
   flg=flag(i)
   if find(flag==[%gd.fdata(1)';'all'])==[] then
     gendoc_printf(%gd,"%s : Bad flag parameter : %s\n",...
            'import_data_to_file',flg);
     return
   end
 end
 if find(flag=='all')<>[] then
   flag=[%gd.fdata(1)']
   flag=flag(2:$)
 end

 //définition fonctions handler
 deff('[data]=start_handl(data,el,attr)',...
     [' if el==data.tag then'
      '   data.a=data.i+1'
      '   if size(attr,1)<>0 then'
      '     if attr(1,1)==''name'' then'
      '        data.name=attr(2,1)'
      '     end'
      '     if attr(1,2)==''type'' then'
      '        data.type=attr(2,2)'
      '     end'
      '   end'
      ' end'
      ' if data.type==''LATEX'' then'
      '   XML_StopParser(%ptr,%t)'
      '   data.suspended=%t'
      ' elseif data.type==''SPECIALDESC'' then'
      '   XML_StopParser(%ptr,%t)'
      '   data.suspended=%t'
      ' elseif data.type==''FIG'' then'
      '   XML_StopParser(%ptr,%t)'
      '   data.suspended=%t'
      ' end'])

 deff('[data]=end_handl(data,el)',...
     [' if el==data.tag then'
      '   data.b=data.i-1'
      ' end'])

 deff('[data2]=start_handl2(data2,el,attr)',...
     [' if el==data2.tag then'
      '   data2.a=data2.i'
      ' end'])

 deff('[data2]=end_handl2(data2,el)',...
     [' if el==data2.tag then'
      '   data2.b=data2.i'
      ' end'])

 //pour FIG
 deff('[data]=start_handl3(data,el,attr)',...
     [' if el==data.tag then'
      '   data.a=data.i+1'
      '   if attr(1,1)==''name'' then'
      '      data.name=attr(1,2)'
      '   end'
      '   XML_StopParser(%ptr2,%t)'
      '   data.suspended=%t'
      ' end'])

 //boucle sur le nbr de repétertoire data
 for i=1:size(%gd.mpath.data,1)

   //boucle sur le nbr de flag
   for j=1:size(flag,1)

      //def compteur de fichiers
      xml_f=0;
      tex_f=0;
      spc_f=0;
      fig_f=0;

      flg=flag(j)

      ind=find(flg==%gd.fdata(1))

      //test présence du fichier data
      if fileinfo(%gd.mpath.data(i)+%gd.fdata(ind))==[] then

         gendoc_printf(%gd,"%s : No data files found in %s\n"+...
                "     for %s\n",...
                'import_data_to_file',...
                %gd.mpath.data(i),...
                %gd.fdata(ind));

      //Parse
      else
        //flag eps
        //decompresse archive tar.gz
        if flag(j)=='eps' then
          //A REVOIR
          cmd='tar xzf '+%gd.mpath.data(i)+%gd.fdata(ind)
          rep=pwd();
          chdir(%gd.mpath.tex(i));
          unix_g(cmd);
          chdir(rep);
        else
          //charge fichier de donnée dans tt
          tt=mgetl(%gd.mpath.data(i)+%gd.fdata(ind));

          //initalise parser fichier de donnée
          %ptr=XML_ParserCreate("ISO-8859-1");
          XML_SetUserData(%ptr,'data');
          XML_SetElementHandler(%ptr,'start_handl','end_handl');

          data = struct('a',0,'b',0,'i',0,'tag',"FILE",...
                        'name',"",'type',"",'suspended',%f);

          //pour toutes les lignes du fichier
          for k=1:size(tt,1)
             //recherche les indices des tags FILE
             data.i=k;

             if ~(data.suspended) then
                XML_Parse(%ptr, tt(k),k==size(tt,1));
             else
               if strindex(tt(k),'</'+data.tag+'>') <> [] then
                 XML_ResumeParser(%ptr);
                 data.suspended=%t;
                 XML_Parse(%ptr, tt(k),k==size(tt,1));
               end
             end

             //Si les indices sont trouvés
             if (data.a<>0&data.b<>0) then

               select data.type

                 //cas XML
                 case 'XML' then
                   bsnam=%gd.mpath.xml(i)+...
                                 data.name+'.xml'

                   if fileinfo(bsnam)<>[] then
                      xml_f=xml_f+1;
                      tic;

                      gendoc_printf(%gd,"Processing file %s ... ",...
                             basename(bsnam)+'.xml');
//                        if (flg=='ufunc') then pause, end
                      ierr=execstr('tag=%gd.tag.'+flg,'errcatch')

                      tt2=mgetl(bsnam)

                      %ptr2=XML_ParserCreate();
                      XML_SetUserData(%ptr2,'data2');
                      XML_SetElementHandler(%ptr2,'start_handl2','end_handl2');

                      data2 = struct('a',0,'b',0,'i',0,'tag',tag);

                      for l=1:size(tt2,1)
                        data2.i=l;
                        XML_Parse(%ptr2, tt2(l),l==size(tt2,1));

                        //Si les indices sont trouvés
                        if (data2.a<>0&data2.b<>0) then

                          XML_ParserFree(%ptr2);

                          newtt=[tt2(1:data2.a-1)
                                 tt(data.a:data.b)
                                 tt2(data2.b+1:size(tt2,1))
                                ]

                          mputl(newtt,bsnam);

                          gendoc_printf(%gd," (%s s) Done !\n",string(toc()));

                          break;
                        end
                      end
                      if l==(size(tt2,1)) then
                        gendoc_printf(%gd," (%s s) Done !\n",string(toc()));
                      end

                   else
                     gendoc_printf(%gd,"%s : %s doesn''t exists."+...
                            " Please generate it.\n",...
                            'import_data_to_file',data.name+'.xml');
                   end

                 //cas FIG
                 case 'FIG' then

                   tic;

                   //def du tag pour les fichiers fig
                   ierr=execstr('tag=%gd.tag.'+flg,'errcatch')

                   gendoc_printf(%gd,"Processing fig file(s) of %s ... \n",...
                           data.name);

                   //vérifie l'existance du répertoire tex
                   if fileinfo(%gd.mpath.tex(i)+data.name)==[] then
                     mkdir(%gd.mpath.tex(i),data.name)
                   end

                   //vérifie l'existance du répertoire tex/fig
                   if fileinfo(%gd.mpath.tex(i)+data.name+'/fig')==[] then
                     mkdir(%gd.mpath.tex(i)+data.name,'fig')
                   end

                   //nouveau texte à parser
                   tt2=tt(data.a:data.b)

                   //initalise parser fichier de donnée
                   %ptr2=XML_ParserCreate("ISO-8859-1");
                   XML_SetUserData(%ptr2,'data2');
                   XML_SetElementHandler(%ptr2,'start_handl3','end_handl');

                   data2 = struct('a',0,'b',0,'i',0,'tag',tag,...
                                  'name',"",'suspended',%f);

                   for l=1:size(tt2,1)
                     data2.i=l;
                     if ~(data2.suspended) then
                       XML_Parse(%ptr2, tt2(l),l==size(tt2,1));
                     else
                       if strindex(tt2(l),'</'+data2.tag+'>') <> [] then
                         XML_ResumeParser(%ptr2);
                         XML_Parse(%ptr2, tt2(l),l==size(tt2,1));
                       end
                     end

                     //Si les indices sont trouvés
                     if (data2.a<>0&data2.b<>0) then

                        fig_f=fig_f+1;

                        gendoc_printf(%gd,"   Processing %s ... ",...
                                      data2.name+'.fig');
                        //TODO
                        mputl(tt2(data2.a:data2.b),...
                              %gd.mpath.tex(i)+data.name+'/fig/'+...
                              data2.name+'.fig');

                        gendoc_printf(%gd," Done !\n");

                        if l<>size(tt2,1)
                          XML_ParserFree(%ptr2);

                          //initalise parser fichier de donnée
                          %ptr2=XML_ParserCreate("ISO-8859-1");
                          XML_SetUserData(%ptr2,'data2');
                          XML_SetElementHandler(%ptr2,'start_handl3','end_handl');

                          data2 = struct('a',0,'b',0,'i',0,'tag',tag,...
                                         'name',"",'suspended',%f);
                        end
                     end
                   end

                   gendoc_printf(%gd,"   Processing Makefile of fig file(s) for %s ... ",...
                           data.name);
                   //TODO
                   //Makefile pour fig
                   newtt=get_makefile_fig();
                   mputl(newtt,...
                         %gd.mpath.tex(i)+data.name+'/fig/'+...
                         'Makefile')
                   gendoc_printf(%gd," Done !\n");

                   gendoc_printf(%gd," (%s s) Done !\n",string(toc()));

                 //cas LATEX
                 case 'LATEX' then

                   tex_f=tex_f+1;
                   tic;

                   ierr=execstr('ext=%gd.exttex.'+flg,'errcatch')

                   bsnam=%gd.mpath.tex(i)+...
                         data.name+'/'+data.name+ext+'.tex'

                   gendoc_printf(%gd,"Processing file %s ... ",...
                           basename(bsnam)+'.tex');

                   //vérifie l'existance du répertoire tex
                   if fileinfo(%gd.mpath.tex(i)+data.name)==[] then
                     mkdir(%gd.mpath.tex(i),data.name)
                   end

                   //enregistre le fichier tex
                   mputl(tt(data.a:data.b),bsnam)

                   gendoc_printf(%gd," (%s s) Done !\n",string(toc()));


                 //cas SPECIALDESC
                 case 'SPECIALDESC' then

                   spc_f=spc_f+1;
                   tic

                   bsnam=%gd.mpath.tex(i)+...
                         data.name+'/'+'SPECIALDESC'

                   gendoc_printf(%gd,"Processing SPECIALDESC file of %s ... ",...
                           data.name);

                   //vérifie l'existance du répertoire tex
                   if fileinfo(%gd.mpath.tex(i)+data.name)==[] then
                     mkdir(%gd.mpath.tex(i),data.name)
                   end

                   //enregistre le fichier SPECIALDESC
                   mputl(tt(data.a:data.b),bsnam)

                   gendoc_printf(%gd," (%s s) Done !\n",string(toc()));

               end //select

               data = struct('a',0,'b',0,'i',0,'tag',"FILE",...
                             'name',"",'type',"",'suspended',%f);

             end //if
          end //for
        end
      end

      if flag(j)<>'eps' then
        if spc_f<>0 then
          gendoc_printf(%gd," %s : \n Processed %d files\n",...
                 %gd.mpath.data(i)+%gd.fdata(ind),...
                 spc_f);
        elseif fig_f<>0 then
          gendoc_printf(%gd," %s : \n Processed %d files\n",...
                 %gd.mpath.data(i)+%gd.fdata(ind),...
                 fig_f);
        else
          gendoc_printf(%gd," %s : \n Processed %d files (%d XML, %d LATEX)\n",...
                 %gd.mpath.data(i)+%gd.fdata(ind),...
                 tex_f+xml_f,xml_f,tex_f);
        end
      else
        gendoc_printf(%gd," Processed %s\n",...
               %gd.mpath.data(i)+%gd.fdata(ind));
      end

   end

 end

endfunction