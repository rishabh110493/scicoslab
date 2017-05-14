//analyse_tex_file
//fonction qui effectue les changements nécessaires
//dans des fichiers tex pour rendre la page finale
//convertie en html par latex2html correctement affichable
//par le browser de scilab
//Entrée rep : repertoire où sont les fichiers tex
//
function analyse_tex_file()

//  lisf_rep=return_fil_name(rep)
//  lisf_tex=[];
//  k=1
//  for i=1:size(lisf_rep,1)
//    if strindex(lisf_rep(i),'.tex')<>[] then
//     lisf_tex(k)=lisf_rep(i);
//     k=k+1
//    end
//  end

 list_file=dir("*.tex")
 lisf_tex=list_file.name

 if lisf_tex<>[] then
   for i=1:size(lisf_tex,1)
     txt_tex=change_capt_tex_file(lisf_tex(i))
     if txt_tex<>[] then
       mputl(txt_tex,lisf_tex(i));
     end
     txt_tex=change_equa_tex_file2(lisf_tex(i))
     if txt_tex<>[] then
       mputl(txt_tex,lisf_tex(i));
     end
   end
 end

endfunction