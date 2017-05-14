//change_font_subtitle_color
//Fonction qui change la couleur des sous-titres
//d'une page d'aide html
//Entrée : htmf  : un nom de fichier à modifier
//         colorn : chaine de caractère la couleur à appliquer
//Sortie : tt le texte du fichier htm
function tt=change_color_subtitle(htmf,%gd)
 if fileinfo(htmf(1,1))<>[] then
  tt=mgetl(htmf(1,1));
  if tt<>[] then
   flagb='<H2>';
   flage='</H2>';
   gendoc_printf(%gd,"\tChange color of subtitles... ")
   colorn=%gd.htmlopt.subtle_clr
   for i=1:size(tt,1)
    a=strindex(tt(i),flagb);

    if a<>[] then
     for j=1:size(a,1)

      tt(i)=strsubst(tt(i),flagb,flagb+'<font color="""+colorn+""">')

     end
    end
    b=strindex(tt(i),flage);
    if b<>[] then
     for j=1:size(b,1)
      tt(i)=strsubst(tt(i),flage,'</font>'+flage)
     end
    end
   end
   gendoc_printf(%gd,"Done\n");
  end
 else
  tt=[]
 end
endfunction