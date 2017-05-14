//return_xml_type
//fonction qui retourne le texte placé entre
//les drapeaux <TYPE>
//et </TYPE> trouvés dans le fichier fname.xml
//ex : txt=return_xml_type(SCI+'/man/eng/nonlinear/intc.xml')
//Entrée fname : chemin+nom du fichier xml
//Sortie txt : tableau de chaines de caractères
function txt=return_xml_type(fname)

 txt=[]
 j=1
 a=[]

 if fileinfo(fname)<>[] then
   txt_temp=mgetl(fname);
 else
   printf("%s : xml file not found in %s\n",...
          'return_xml_type',...
          fname);
   return
 end

 for i=1:size(txt_temp,'*')
   if strindex(txt_temp(i),'<TYPE>')<>[] then
     a(j,1)=i;
   end
   if strindex(txt_temp(i),'</TYPE>')<>[] then
     a(j,2)=i;
     j=j+1;
   end
 end

 if a<>[] then
   for i=1:size(a,'r')
     for j=a(i,1):a(i,2)
       txt(i)=txt(i)+txt_temp(j)
     end
   end
   txt=strsubst(txt,'<TYPE>',"");
   txt=strsubst(txt,'</TYPE>',"");
   txt=stripblanks_begin(txt);
   txt=stripblanks_end(txt);
   txt=retrieve_xml_char(txt)
 end

endfunction
