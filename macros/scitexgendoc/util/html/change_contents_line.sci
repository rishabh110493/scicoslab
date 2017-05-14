//change_contents_line
//Fonction qui change le texte "contents"
//d'une page d'aide html
//Entrée : htmf  : un nom de fichier à modifier
//         lang : langue
//Sortie : tt le texte du fichier htm
function tt=change_contents_line(htmf,lind,%gd)
 if fileinfo(htmf(1,1))<>[] then
  tt=mgetl(htmf(1,1));
  if tt<>[] then
   gendoc_printf(%gd,"\tChange contents line... ")
   for i=1:size(tt,1)
    a=strindex(tt(i),"Contents</A>");
    if a<>[] then
      if %gd.lang(lind)=='fr' then
       tt(i)=strsubst(tt(i),"Contents</A>","Contenu</A>")
      end
    end
   end
   gendoc_printf(%gd,"Done\n")
  end
 else
  tt=[]
 end
endfunction