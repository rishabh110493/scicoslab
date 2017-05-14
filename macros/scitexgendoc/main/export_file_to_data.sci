//export_file_to_data : exporte des paragraphes balisés
//                     de fichier xml (ou bien des fichers)
//                    tex dans des fichiers de données
//
//entrée  : flag : un vecteur de chaîne de caractères
//                 dont les valeurs sont définies par
//                 %gd.fdata(1) :
//                'sdesc'
//                'cseq'
//                'desc'
//                'rmk'
//                'ex'
//                'param'
//                'ufunc'
//                'salso'
//                'bib'
//                'auth'
//                'spdesc'
//                'fig'
//                'all'
//
//          %gd : une liste de définition du générateur
//                de documentation.
//
function export_file_to_data(flag,%gd)

 //vérifie cohérence flag
 flag=flag(:)
 for i=1:size(flag,1)
   flg=flag(i)
   if find(flag==[%gd.fdata(1)';'all'])==[] then
     gendoc_printf(%gd,"%s : Bad flag parameter : %s\n",...
            'export_file_to_data',flg);
     return
   end
 end
 if find(flag=='all')<>[] then
   flag=[%gd.fdata(1)']
   flag=flag(2:$)
 end

 //boucle sur le nbr de repertoire xml
 for npath=1:size(%gd.mpath.xml,1)

   //cherche tous les fichiers xml présents
   //dans %gd.mpath.xml(npath)
   lisf=listfiles(%gd.mpath.xml(npath)+'*.xml');
   if lisf<>[] then
     lisf=gsort(basename(lisf),'r','i')+'.xml';
   else
     gendoc_printf(%gd,"%s : No xml files found in %s\n",...
            'export_file_to_data',...
            %gd.mpath.xml(npath));
     break
   end

   //boucle sur le nombre de flag
   for z=1:size(flag,1)
     flg=flag(z);
     tt = [];
     data_file=evstr('%gd.fdata.'+flg');

     //boucle sur le nombre de fichiers xml
     for ij=1:size(lisf,1)
//***----------------------------------------------------------***///
//***----------------------------------------------------------***///

       //evalue le possible nom du répertoire LaTeX
       tex_path=evstr('%gd.mpath.tex(npath)+'+...
                      'basename(lisf(ij,1))+'+...
                      '''/''');
       //test flag=='spdesc'
       if flg=='spdesc' then
         //evalue le possible nom du fichier LaTeX spdesc
         tex_file=tex_path+%gd.exttex.spdesc;

         //test la présence d'un fichier SPECIALDESC
         if fileinfo(tex_file)<>[] then
           txt=mgetl(tex_file);
           if txt<>[] then
              tt=[tt;'<FILE name='''+basename(lisf(ij,1))+''''+...
                             ' type=''SPECIALDESC''>'];
              tt=[tt;txt];
              tt=[tt;'</FILE>';''];
           end
         end

       //test flag=='fig'
       elseif flg=='fig' then
         //test la présence d'un répertoire fig
         fig_path=tex_path+'fig/'
         if fileinfo(fig_path)<>[] then

           //test présence fichiers .fig
           S=dir(fig_path+'*.fig')
           if S.name<>[] then
             tt=[tt;'<FILE name='''+basename(lisf(ij,1))+''''+...
                             ' type=''FIG''>'];
             lisffig=basename(S.name)+'.fig'
             //encapsule fichiers fig dans du xml
             for w=1:size(lisffig,1)
                txt=mgetl(fig_path+lisffig(w));
                tt=[tt;'<FIGFILE name='''+basename(lisffig(w))+'''>'];
                tt=[tt;txt];
                tt=[tt;'</FIGFILE>'];
             end

             tt=[tt;'</FILE>';'']
           end

         end

       //test flag=='eps'
       elseif flg=='eps' then
         //test la présence d'un répertoire fig
         eps_path=tex_path+'eps/'
         if fileinfo(eps_path)<>[] then

           //test présence fichiers .eps
           S=dir(eps_path+'*.eps')
           if S.name<>[] then
             tt=[tt;
                 S.name]
           end
           //test présence fichiers .gif
           S=dir(eps_path+'*.gif')
           if S.name<>[] then
             tt=[tt;
                 S.name]
           end

         end

       else //tous les autres flag

         //evalue le possible nom du fichier LaTeX
         tex_file=evstr('tex_path+basename(lisf(ij,1))'+...
                        '+%gd.exttex.'+flg+'+''.tex''')

         //test la présence d'un fichier tex
         if fileinfo(tex_file)<>[] then
           txt=mgetl(tex_file);
           if txt<>[] then
              tt=[tt;'<FILE name='''+basename(lisf(ij,1))+''''+...
                             ' type=''LATEX''>'];
              tt=[tt;txt];
              tt=[tt;'</FILE>';''];
           end

         //cas XML
         else
           //retourne le texte XML associé au flag
           ierr=execstr('txt=return_xml('+...
                        '%gd.mpath.xml(npath)+'+...
                        'lisf(ij,1),flg);','errcatch');

           if ierr==0 then
             if txt<>[] then
                tt=[tt;'<FILE name='''+basename(lisf(ij,1))+''''+...
                             ' type=''XML''>'];
                tt=[tt;txt];
                tt=[tt;'</FILE>';''];
             end
           else
             gendoc_printf(%gd,"%s : Error when calling of %s\n",...
                    'export_file_to_data',...
                    'return_xml(..,'+flg+')')
             return
           end
         end
       end

       //Mise à jour du 28/04/07
       //remplace directement dans le fichier de données
       if tt<>[] then
         //test présence du fichier data
         if fileinfo(%gd.mpath.data(npath)+...
                      data_file)<>[] then

           gendoc_printf(%gd,"\tPush %s of %s ("+...
                  %gd.lang(npath)+")\n\t"+...
                    "in %s... ",evstr('%gd.tag.'+flg),...
                     lisf(ij),data_file);

           //charge le texte du fichier data
           tt_data = mgetl(%gd.mpath.data(npath)+...
                            data_file);

           //recherche balise du texte à placer
           a = find(tt_data==tt(1));

           //Remplacement uniquement si une seule balise est trouvée
           if size(a,'*')==1 then
             //recherche balise </FILE>
             b = [];
             for w=a:size(tt_data,1)
                if strindex(tt_data(w),'</FILE>')<> [] then
                  b=w;
                  break
                end
             end
             //remplacement
             tt_data = [tt_data(1:a-1);
                        tt(1:$-1);
                        tt_data(b+1:$);]

           else //sinon met tout à la fin
            if size(a,'*')>=1 then
              gendoc_printf(%gd,"\n\t  Warning :\n\t  "+...
                     "Duplicated tags found in %s for %s\n",...
                        data_file,lisf(ij));
            end
            a = find(tt_data=='<DATA flag=""'+flg+'"">');
            a = a(1)
            b = find(tt_data=='</DATA>');
            b = b($)

            tt_data = ['<DATA flag=""'+flg+'"">';
                       tt_data(a+1:b-1);
                       tt;
                       '</DATA>']
           end
           //ecrit les données
           ierr=execstr('mputl(tt_data,%gd.mpath.data(npath)+'+...
                        '%gd.fdata.'+flg+');','errcatch')
           if ierr==0 then
             gendoc_printf(%gd,"Done\n")
           else
             gendoc_printf(%gd,"\n%s : Error when writting %s\n",...
                      'export_file_to_data',...
                    evstr('%gd.fdata.'+flg))
             return
           end
           tt=[];
           clear tt_data;
         end
       end
     end

     //écrit un fichier de données
     if tt<>[] then
       //flag eps
       //cree une archive tar.gz
       if flg=='eps' then
         //A REVOIR
         tt=strsubst(tt,%gd.mpath.tex(npath),'./')
         cmd='tar czf '+%gd.fdata.eps+' '+strcat(tt,' ');
         rep=pwd();
         chdir(%gd.mpath.tex(npath));
         unix_g(cmd);
         cmd='mv '+%gd.fdata.eps+' '+%gd.mpath.data(npath);
         unix_g(cmd);
         chdir(rep);
       else
         gendoc_printf(%gd,"Export xml %s ("+...
                %gd.lang(npath)+")... ",flg);

         if %gd.lang(npath)=='fr' & ...
            (flg=='sdesc' | flg=='desc' | flg=='ex' | flg=='param') then

           tt=['<?xml version=""1.0"" encoding=""ISO-8859-1"" standalone=""no""?>'
               '<DATA flag=""'+flg+'"">';
               ''
               tt
               ''
               '</DATA>']

         else

           tt=['<DATA flag=""'+flg+'"">';
               ''
               tt
               ''
               '</DATA>']

         end

         //ecrit les données
         ierr=execstr('mputl(tt,%gd.mpath.data(npath)+'+...
                      '%gd.fdata.'+flg+');','errcatch')
         if ierr==0 then
           gendoc_printf(%gd,"Done\n")
         else
           gendoc_printf(%gd,"\n%s : Error when writting %s\n",...
                  'export_file_to_data',...
                  evstr('%gd.fdata.'+flg))
           return
         end
       end
     else
       if fileinfo(%gd.mpath.data(npath)+...
                     data_file)==[] then
         gendoc_printf(%gd,"No files found for flag %s\n",...
                flg)
       else
         gendoc_printf(%gd,"Done\n")
       end
//***----------------------------------------------------------***///
//***----------------------------------------------------------***///

     end
   end
 end

endfunction
