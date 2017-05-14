//return_xml_bib
//fonction qui retourne le texte placé entre
//les drapeaux <BIBLIO> et </BIBLIO> trouvés dans 
//le fichier fname
//compatible help skeleton
//ex : txt=return_xml_biblio(MODNUM+'/man/xml/CAN_f.xml')
//Entrée fname : chemin+nom du fichier xml
//Sortie txt : tableau de chaines de caractères de taile n,1
//             txt(1,n) : chaine de la biblio

function txt=return_xml_bib(fname)
 txt_temp=mgetl(fname);
 txt=[]
 j=1;
 a=[];
 if txt_temp<>[] then
   for i=1:size(txt_temp,'*')
     if strindex(txt_temp(i),'<BIBLIO>')<>[] then
       a(j,1)=i;
     end
     if strindex(txt_temp(i),'</BIBLIO>')<>[] then
       a(j,2)=i;
       j=j+1;
     end
   end 

   for i=1:size(a,'r')
     for j=a(i,1):a(i,2)
       txt(i)=txt(i)+stripblanks_begin(txt_temp(j))+" "
     end
     txt(i)=strsubst(txt(i),('<BIBLIO>'),'')
     txt(i)=strsubst(txt(i),('</BIBLIO>'),'')
     txt(i)=strsubst(txt(i),('<SP>'),'')
     txt(i)=strsubst(txt(i),('</SP>'),'')
     //Enlève les blancs du début
     txt(i)=stripblanks_begin(txt(i));
     //Enlève les blancs placés à la fin
     txt(i)=stripblanks_end(txt(i));
   end
   txt=striplines(txt);
   if txt=="" then txt=[], end
 else
   disp(fname+" not found.")
   txt=[];
 end
endfunction
