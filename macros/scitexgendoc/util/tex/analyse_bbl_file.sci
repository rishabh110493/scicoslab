//analyse_bbl_file
//fonction qui modifie un fichier bbl
//produit par bibtex avec IEETransBST
//pour pouvoir correctement etre compiler
//par latex2html
//
//Entrée : name : nom du fichier à analyser.

function analyse_bbl_file(name)
 if fileinfo(name)<>[] then
  tt=mgetl(name);
  a=[];
  b=[];
  for i=1:size(tt,1)
   if strindex(tt(i),'\csname url@rmstyle\endcsname')<>[] then
    a=i;
   end
   if strindex(tt(i),'\bibitem{')<>[] then
    b=i;
    break;
   end
  end
  if a<>[] & b<>[] then
   new_tt=[tt(1:a-1);tt(b:size(tt,1))];
   mputl(new_tt,name);
  end
 end
 
endfunction 
