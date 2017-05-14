//return_capt
//Fonction qui recherche la présence d'un fichier SPECIALDESC
//dans tex_path et qui retourne le titre des figures

function txt=return_capt(namef)
if fileinfo(namef+'/SPECIALDESC')<>[] then
 txt=[];
 i_equ1=0;i_equ2=0;
 tt=mgetl(namef+'/SPECIALDESC');
 for i=1:size(tt,1)
   if strindex(tt(i),'scope_caption')<>[] then
    i_equ1=i;//strindex(tt(i),'=');
   end
   if (i_equ1<>0 & i>=i_equ1) then
    if strindex(tt(i),']')<>[] then
      i_equ2=i;
      break
    end
   end
 end
 if i_equ1<>0 then
 for i=i_equ1:i_equ2
  txt=txt+tt(i);
 end
 if strindex(txt,'scope_caption')<>[] then
   txt=part(txt,strindex(txt,'=')+1:length(txt));
 end
 txt=evstr(txt);
 end
else
txt=[]
end
endfunction