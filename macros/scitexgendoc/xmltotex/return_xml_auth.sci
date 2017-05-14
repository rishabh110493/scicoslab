//return_xml_auth
//fonction qui retourne le texte placé entre
//les deux premiers drapeaux <AUTHOR_ITEM>
//et </AUTHOR_ITEM> trouvés dans le fichier fname
//compatible help skeleton
//ex : txt=return_xml_authors2(MODNUM+'/man/xml/CAN_f.xml')
//Entrée fname : chemin+nom du fichier xml
//Sortie txt : tableau de chaines de caractères de taile n,2
//             txt(1,n) : nom des auteurs
//             txt(2,n) : références des auteurs
//             txt(3,n) : adresse email des auteurs
function txt=return_xml_auth(fname)

 txt=[]
 a=[]
 b=[]
 c=[]
 j=1

 if fileinfo(fname)<>[] then
   txt_temp=mgetl(fname);
 else
   printf("%s : xml file not found in %s\n",...
          'return_xml_auth',...
          fname);
   return
 end

 for i=1:size(txt_temp,'*')
  if strindex(txt_temp(i),'<AUTHORS>') then
   b(1,1)=i
  end
  if strindex(txt_temp(i),'<AUTHOR>') then
   c(1,1)=i
  end
  if strindex(txt_temp(i),'<AUTHORS_ITEM')<>[] then
   a(j,1)=i
  end
  if strindex(txt_temp(i),'</AUTHORS_ITEM>')<>[] then
   a(j,2)=i
   j=j+1
  end
  if strindex(txt_temp(i),'</AUTHORS>') then
   b(1,2)=i
  end
  if strindex(txt_temp(i),'</AUTHOR>') then
   c(1,2)=i
  end
 end

 if a<>[] then
   for i=1:size(a,'r')
     //pour chaque bloc
     txt(i,3)="";
     for j=a(i,1):a(i,2)
       //Trouve le nom de l'auteur
       if(strindex(txt_temp(j),...
                   '<AUTHORS_ITEM label='))<>[] then
         txt(i,1)=txt_temp(j);
         b=strindex(txt(i,1),'<AUTHORS_ITEM label=')
         c=strindex(txt(i,1),'''>')
         if c==[] then
            c=strindex(txt(i,1),'"">')
         end
         txt(i,1)=part(txt(i,1),b:c-1);
         txt(i,1)=strsubst(txt(i,1),...
                           '<AUTHORS_ITEM label=''',"");
         txt(i,1)=strsubst(txt(i,1),...
                           '<AUTHORS_ITEM label=""',"");
         txt(i,1)=strsubst(txt(i,1),'''>',"")
         //Enlève les blancs au début
         txt(i,1)=stripblanks_begin(txt(i,1));
         //Enlève les blancs de la fin
         txt(i,1)=stripblanks_end(txt(i,1));
         //Trouve le mail de l'auteur
         d=strindex(txt(i,1),'mailto=')
         if d<>[] then
           txt(i,3)=part(txt(i,1),d:length(txt(i,1)))
           txt(i,3)=strsubst(txt(i,3),'mailto=''',"")
           txt(i,3)=strsubst(txt(i,3),'mailto=""',"")
           txt(i,3)=stripblanks_begin(txt(i,3))
           txt(i,3)=stripblanks_end(txt(i,3))
           txt(i,1)=part(txt(i,1),1:d-1)
           e=strindex(txt(i,1),'''')
           txt(i,1)=part(txt(i,1),1:e($)-1)
           txt(i,1)=stripblanks_end(txt(i,1))
         end
       end
     txt(i,2)=txt(i,2)+txt_temp(j);
     end

     //Trouve les références de l'auteur
     txt(i,2)=strsubst(txt(i,2),'</AUTHORS_ITEM>',"");
     b=0;
     if strindex(txt(i,2),...
                 '<AUTHORS_ITEM label=')<>[] then
       b=strindex(txt(i,2),'<AUTHORS_ITEM label=')
     end
     c=0
     if strindex(txt(i,2),'>')<>[] then
       c=strindex(txt(i,2),'>');
     end
     if b<>0&c<>0 then
       txt(i,2)=part(txt(i,2),c+1:length(txt(i,2)))
       //Enlève les blancs au début
       txt(i,2)=stripblanks_begin(txt(i,2));
       //Enlève les blancs de la fin
       txt(i,2)=stripblanks_end(txt(i,2));
     end
     if(part(txt(i,2),1))==',' then
       txt(i,2)=part(txt(i,2),2:length(txt(i,2)));
       //Enlève les blancs au début
       txt(i,2)=stripblanks_begin(txt(i,2));
     end
   end
 elseif b<>[] then
   txt(1,1)=strcat(txt_temp(b(1,1):b(1,2)),' ');
   txt(1,1)=strsubst(txt(1,1),'<AUTHORS>',"")
   txt(1,1)=strsubst(txt(1,1),'</AUTHORS>',"")
   txt(1,1)=stripblanks_begin(txt(1,1))
   txt(1,1)=stripblanks_end(txt(1,1))
 elseif c<>[] then
   txt(1,1)=strcat(txt_temp(c(1,1):c(1,2)),' ');
   txt(1,1)=strsubst(txt(1,1),'<AUTHOR>',"")
   txt(1,1)=strsubst(txt(1,1),'</AUTHOR>',"")
   txt(1,1)=stripblanks_begin(txt(1,1))
   txt(1,1)=stripblanks_end(txt(1,1))
 end
endfunction
