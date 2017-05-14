//return_pal_pal
//Entrée name : chemin+nom de la palette
//              ex : name=MODNUM+'/macros/scicos_blocks/Tools.cosf'
//       libn : un identifiant de libraire (ex 'mod_num')
//       dbl : un drapeau pour les doublons
//sortie tt : La liste des palettes
//
//## 13/07/08, Alan ajoute l'extraction des blocs lorsque
//## la palette est composée d'un seul bloc PAL_f
function tt=return_pal_pal(name,libn,dbl)
 if exists('name') then
   if fileinfo(name)<>[] then
     //Vérifie cohérence des param
     [lsh,rsh]=argn(0)
     if rsh<3 then dbl='', end;
     if rsh<2 then libn='', end;
     if ~exists('libn') then libn='', end
     if ~exists('dbl') then dbl='', end


     //load scicos library
     load SCI/macros/scicos/lib

     exec(name,-1)
     if lstsize(scs_m.objs)==1 then
       if scs_m.objs(1).gui=='PAL_f' then
         scs_m=scs_m.objs(1).model.rpar;
       end
     end

     //##special case for the block PAL_f of scicos
//     if name<>SCI+'/macros/scicos/Others.cosf' then
     tt=[]
     for i=1:lstsize(scs_m.objs)
       if scs_m.objs(i).gui=='PAL_f' then
         if name<>SCI+'/macros/scicos/Others.cosf' then
           tt=[tt;scs_m.objs(i).model.rpar.props.title(1)]
         end
       end
     end
   else
     printf("return_pal_pal : "+...
            "Unable to find cosf file.\n");
     tt=[];
   end
 else
     printf("return_pal_pal : "+...
            "bad rsh 1 parameter.\n");
     tt=[];
 end
endfunction
