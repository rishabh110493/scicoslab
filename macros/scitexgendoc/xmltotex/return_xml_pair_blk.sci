//return_xml_pair_blk
//fonction qui retourne le texte placé entre
//tous les drapeaux <PAIR_BLOCK>
//et </PAIR_BLOCK> trouvés dans le fichier fname
//ex : txt=return_pair_blk(MODNUM+'/man/xml/CNA_f.xml')
//Entrée fname : chemin+nom du fichier xml
//Sortie txt : tableau de chaines de caractères
function txt=return_xml_pair_blk(fname)
txt_temp=mgetl(fname);
txt=[]
a=[]
j=1;
if txt_temp<>[] then
 for i=1:size(txt_temp,'*')
  if strindex(txt_temp(i),'<PAIR_BLOCK_ITEM>')<>[] then
   a(j,1)=i;
  end
  if strindex(txt_temp(i),'</PAIR_BLOCK_ITEM>')<>[] then
   a(j,2)=i;
   j=j+1;
  end
 end

 for i=1:size(a,'r')
  for j=a(i,1):a(i,2)
   txt(i)=txt_temp(j)
  end
  txt(i)=strsubst(txt(i),('<PAIR_BLOCK_ITEM>'),'')
  txt(i)=strsubst(txt(i),('</PAIR_BLOCK_ITEM>'),'')
  txt(i)=strsubst(txt(i),('<LINK>'),'')
  txt(i)=strsubst(txt(i),('</LINK>'),'')
  txt(i)=stripblanks(txt(i));
 end
 ok=%t
 for i=1:size(txt,1)
     if stripblanks(txt(i))=='' then ok=%f, end
 end
 if ok==%f then txt=[], end
end
endfunction
