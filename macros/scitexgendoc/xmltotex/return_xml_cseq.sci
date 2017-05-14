//return_xml_call_seq
//
//fonction qui retourne le texte placé entre
//les deux premiers drapeaux <CALLING_SEQUENCE>
//et </CALLING_SEQUENCE> trouvés dans le fichier fname
//compatille avec help_skeleton
//ex : txt=return_xml_call_seq(SCI+'/man/eng/nonlinear/intc.xml')
//
//Entrée fname : chemin+nom du fichier xml
//
function txt=return_xml_cseq(fname)
 txt=[]
 j=1;
 a=[];

 if fileinfo(fname)<>[] then
   txt_temp=mgetl(fname);
 else
   printf("%s : xml file not found in %s\n",...
          'return_xml_cseq',...
          fname);
   return
 end

 for i=1:size(txt_temp,'*')
   if strindex(txt_temp(i),'<CALLING_SEQUENCE_ITEM>')<>[] then
     a(j,1)=i;
   end
   if strindex(txt_temp(i),'</CALLING_SEQUENCE_ITEM>')<>[] then
     a(j,2)=i;
     j=j+1;
   end
 end

 if a<>[] then
   for i=1:size(a,'r')
     txt(i)="";
     //pour chaque bloc
     for j=a(i,1):a(i,2)
       txt(i)=txt(i)+txt_temp(j)
     end
   end

   txt=strsubst(txt,'<CALLING_SEQUENCE_ITEM>',"");
   txt=strsubst(txt,'</CALLING_SEQUENCE_ITEM>',"");
   txt=retrieve_xml_char(txt);
   txt=stripblanks_begin(txt);
   txt=stripblanks_end(txt);
   if txt=="" then txt=[], end;
 end

endfunction
