//return_xml_ex
//fonction qui retourne les exemples
//d'aide scilab construit avec help_skeleton
//ex : return_xml_ex(SCI+'/man/fr/nonlinear/ode.xml')
//Entrée fname : chemin+nom du fichier xml
//Sortie txt : tableau de chaines de caractères de taille n,2
//             colonne 1 : nom du paramètre
function txt=return_xml_ex(fname)

 txt=[]
 j=1
 a=[]
 b=[]

 if fileinfo(fname)<>[] then
   txt_temp=mgetl(fname);
 else
   printf("%s : xml file not found in %s\n",...
          'return_xml_ex',...
          fname);
   return
 end

 //Cherche les bornes <EXAMPLE> et </EXAMPLE>
 for i=1:size(txt_temp,'*')
   if strindex(txt_temp(i),'<EXAMPLE>')<>[] then
     a=i;
   end;
   if strindex(txt_temp(i),'</EXAMPLE>')<>[] then
     b=i;
     break
   end
 end

 if a<>[] & b<>[] then
   txt=txt_temp(a:b)
   txt=strsubst(txt,'<EXAMPLE>',"")
   txt=strsubst(txt,'<P>',"")
   txt=strsubst(txt,'<![CDATA[',"")
   txt=strsubst(txt,']]>',"")
   txt=strsubst(txt,'</P>',"")
   txt=strsubst(txt,'</EXAMPLE>',"")
   //Enlève les blancs du début
   txt=stripblanks_begin(txt);
   //Nettoie les lignes vides
   tt=[]
   k=1;
   emptyf=%t; //Empty flag
   for i=1:size(txt,1)
     if length(txt(i))<>0 then
       tt(k)=txt(i);
       k=k+1;
       emptyf=%f;
     end
   end

   if emptyf then txt=[];
   else txt=tt;
   end
 end

endfunction
