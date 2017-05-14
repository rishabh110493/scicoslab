//Fonction qui retourne la taille d'un diagramme
//scicos spéciée dans un fichier SPECIALDESC

//       flag : html ou guide
//Sortie txt : nouvelle taille de la figure
function txt=return_size_scs_diagr2(name,flag)
 txt=[]
 if fileinfo(name+'/SPECIALDESC')<>[] then
   tt=mgetl(name+'/SPECIALDESC')
   for i=1:size(tt,1)
     if flag=='html' then
       if strindex(tt(i),'size_scs_diagr_html')<>[] then
         i_equ=strindex(tt(i),'=')
         txt='height='+part(tt(i),i_equ(1)+1:length(tt(i)))
       end
     elseif flag=='guide' then
       if strindex(tt(i),'size_scs_diagr_guide')<>[] then
         ierror=execstr(tt(i),'errcatch')
         if ierror<>0 then
           printf("Format error in SPECIALDESC\n");
           break
         else
           txt=size_scs_diagr_guide
         end
       end
     end
   end
 end
endfunction
