//Fonction qui retourne la taille d'une fenêtre
//de dialogue spéciée dans un fichier SPECIALDESC
//Entrée name : nom du fichier (ex :'CONVOLGEN_f')
//       flag : html ou guide
//Sortie txt : nouvelle taille de la figure
function txt=return_size_dial(name,flag)
if fileinfo(name+'/SPECIALDESC')<>[] then
 txt=[];
 h=[];   //height
 w=[];   //width
 s=[];   //scale
 tt=mgetl(name+'/SPECIALDESC');
 for i=1:size(tt,1)
    if flag=='html' then
      if strindex(tt(i),'dial_width_html')<>[] then
         i_equ=strindex(tt(i),'=')
         txt='width='+part(tt(i),i_equ+1:length(tt(i)))
      end
    elseif flag=='guide' then
      if strindex(tt(i),'dial_width_guide')<>[] then
         i_equ=strindex(tt(i),'=')
         txt='[width='+part(tt(i),i_equ+1:length(tt(i)))+']'
      end
    end
 end

else
 txt=[];
end
endfunction