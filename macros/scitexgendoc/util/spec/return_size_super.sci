//Fonction qui retourne la taille d'une image
//d'un super bloc compilé spéciée dans un
//fichier SPECIALDESC
//Entrée name : nom du fichier (ex :'CONVOLGEN_f')
//       flag : html ou guide
//       flag2 : 'lr_margin' pour des marges horizontales
//               'ud_margin' pour des marges verticales
//Sortie txt : nouvelle taille de la figure
function txt=return_size_super(name,flag,flag2)

if fileinfo(name+'/SPECIALDESC')<>[] then

  //verifie la présence du paramètre flag2
  [lsh,rsh]=argn(0)
  if rsh<3 then
    flag2=[];
  end
 
  if flag2<>[] then
    tt_to_search='super_'+flag2;
  else
    tt_to_search='super_width';
  end
 
  txt=[];
  h=[];   //height
  w=[];   //width
  s=[];   //scale
 
  tt=mgetl(name+'/SPECIALDESC');
 
  if flag=='html' then 
    for i=1:size(tt,1)
      if strindex(tt(i),tt_to_search+'_html')<>[] then
        i_equ=strindex(tt(i),'=')
        if flag2=='lr_margin'| flag2=='ud_margin' then
          txt=evstr(part(tt(i),i_equ+1:length(tt(i))))        
        else
          txt='width='+part(tt(i),i_equ+1:length(tt(i)))
        end
      end
    end

  elseif flag=='guide' then
    for i=1:size(tt,1)
      if strindex(tt(i),tt_to_search+'_guide')<>[] then
        i_equ=strindex(tt(i),'=')
        txt='[width='+part(tt(i),i_equ+1:length(tt(i)))+']'
      end
    end
   
  end

else
  txt=[];
end

endfunction