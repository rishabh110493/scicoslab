//Fonction qui retourne la taille d'un diagramme
//scicos spéciée dans un fichier SPECIALDESC
//Entrée name : nom du fichier (ex :'CONVOLGEN_f')
//       flag : html ou guide
//       flag2 : 'sbeq' pour un super bloc équivalent
//               'lr_margin' pour des marges horizontales
//               'ud_margin' pour des marges verticales
//Sortie txt : nouvelle taille de la figure
function txt=return_size_scs_diagr(name,flag,flag2)

if fileinfo(name+'/SPECIALDESC')<>[] then
 //verifie la présence du paramètre flag2
 [lsh,rsh]=argn(0)
 if rsh<3 then
   flag2=[];
 end

 tt_to_search='scs_diagr_height';
 if flag2=='sbeq' then
   tt_to_search=tt_to_search+'_sbeq';
 elseif flag2=='pal' then
   tt_to_search=tt_to_search+'_pal';
 elseif ~isempty(flag2) then
   tt_to_search='scs_diagr_'+flag2;
 end

 txt=[];
 h=[];   //height
 w=[];   //width
 s=[];   //scale
 
 tt=mgetl(name+'/SPECIALDESC');

 for i=1:size(tt,1)
    //html
    if flag=='html' then
      if strindex(tt(i),tt_to_search+'_html')<>[] then
          i_equ=strindex(tt(i),'=')
          if flag2=='lr_margin'| flag2=='ud_margin' | flag2=='scale_blk' then
             txt=evstr(part(tt(i),i_equ+1:length(tt(i))))
          else
             txt='height='+part(tt(i),i_equ(1)+1:length(tt(i)))
          end
      end

    //guide
    elseif flag=='guide' then

      if strindex(tt(i),tt_to_search+'_guide')<>[] then
         if flag2=='lblock' then
            txt=1;
         else
            i_equ=strindex(tt(i),'=')
            txt='[height='+part(tt(i),i_equ(1)+1:length(tt(i)))+']'
        end
      end
    end
 end

else
 txt=[];
end
endfunction
