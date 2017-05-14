//change_equa_tex_file
//fonction qui effectue les changements sur les
//equations dans un fichier tex pour rendre la page finale
//convertie en html par latex2html correctement affichable
//par le browser de scilab
//Entrée file_tex : fichier à analyser
//Sortie txt : texte du nouveau fichier tex

function txt=change_equa_tex_file2(file_tex)

 txt_tex_main=mgetl(file_tex)

 txt=[];
 for i=1:size(txt_tex_main,1)
   if strindex(txt_tex_main(i),'\begin{eqnarray}')<>[] then
     txt=[txt;txt_tex_main(i);'\htmlimage{align=left}'];
   elseif strindex(txt_tex_main(i),'\begin{equation}')<>[] then
     txt=[txt;txt_tex_main(i);'\htmlimage{align=left}'];
   else
     txt=[txt;txt_tex_main(i)];
   end
 end

endfunction