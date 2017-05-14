//change_level_bib
//fonction qui change le niveau du paragraphe
//bibliographie dans la table des matières
//d'un fichier html produit par latex2html
//
//Entrée : name : nom du fichier html
//Sortie : txt : texte du nouveau fichier html
//
function txt=change_level_bib(name,%gd)
 if fileinfo(name)<>[] then
   tt=mgetl(name);
   if tt<>[] then
     gendoc_printf(%gd,"\tChange level of bibliography... ")
     a=[];
     b=[];
     for i=1:size(tt,1)
       if strindex(tt(i),'>Bibliography</A>')<>[] then
         a=i;
         if strindex(tt(a-2),'</UL><BR>')<>[] then
           b=a-2;
           break;
         end
       end
     end
     if a<>[] & b<>[] then
      txt=[tt(1:b-1);tt(b+1:a+1);tt(b);tt(a+2:size(tt,1))];
     else
      txt=[];
     end
     gendoc_printf(%gd,"Done\n");
   else
    txt=[];
   end
 else
  txt=[];
 end
endfunction
