//Fonction qui retourne les noms des blocks de la libraire
//libn présent dans une liste scs_m
//Entrée libn un identifiant de libraire
//       dbl drapeau pour éliminer les doublons
//si libn est absent retourne la liste de tous les blocks
//si dbl==1 alors élimine les doublons

function txt=return_block_name(scs_m,libn,dbl)
 txt=[]
 [%lhs,%rhs]=argn(0)
 n=lstsize(scs_m.objs) //nbr d'objet dans scs_m
 for i=1:n
  if execstr('scs_m.objs(i).gui','errcatch')==0 then
    if %rhs>1 then
     if exists('libn')&libn<>'' then
     ///////Doit faire pour chaque libn
      ww=whereis(scs_m.objs(i).gui)
      if strindex(ww,libn)<>[]
        txt=[txt;scs_m.objs(i).gui]
      end
      /////////
     else
      txt=[txt;scs_m.objs(i).gui]
     end
    else
     txt=[txt;scs_m.objs(i).gui]
    end
  end
 end

 if %rhs>=3 then
  if exists('dbl') then
   if dbl==1 then //Trouve les doublons
    if txt<>[] then
     tt=txt(1)
     for i=1:size(txt,1)
         ok=%t
         for j=1:size(tt,1)
           if tt(j,1)==txt(i,1) then
            ok=%f
           end
         end
         if ok then tt=[tt;txt(i,1)], end
     end
     txt=tt
    end
   end
  end
 end
endfunction
