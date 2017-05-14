//change_biblio_line
//Fonction qui change le texte "Bibliography"
//d'une page d'aide html
//Entrée : htmf  : un nom de fichier à modifier
//         lang : langue
//Sortie : tt le texte du fichier htm

function tt=change_biblio_line(htmf,lind,%gd)
if fileinfo(htmf(1,1))<>[] then
  tt=mgetl(htmf(1,1));
  if tt<>[] then
   gendoc_printf(%gd,"\tChange Bibliography line... ")
   aaa=0
   for i=1:size(tt,1)
    a=strindex(tt(i),"Bibliography</A>");
    if a<>[] then
      aaa=aaa+1
      if %gd.lang(lind)=='fr' then
        tt(i)=strsubst(tt(i),"Bibliography</A>","Bibliographie</A>")
      end
      if aaa==2 then
        for kkk=i:size(tt,1)
          tt(kkk)=strsubst(tt(kkk),"<DD>","")
          for zzz=1:10
            tt(kkk)=strsubst(tt(kkk),""">"+string(zzz)+"</A>",""">["+string(zzz)+"]</A>")
          end
        end
      end
    end
   end
   gendoc_printf(%gd,"Done\n")
  end
else
  tt=[]
end
endfunction

