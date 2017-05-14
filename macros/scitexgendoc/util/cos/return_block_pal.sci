//return_block_pal
//Entrée name : chemin+nom de la palette
//              ex : name=MODNUM+'/macros/scicos_blocks/Tools.cosf'
//       libn : un identifiant de libraire (ex 'mod_num')
//       dbl : un drapeau pour les doublons
//sortie tt : La liste des blocks
//
//## 13/07/08, Alan ajoute l'extraction des blocs lorsque
//## la palette est composée d'un seul bloc PAL_f
function tt=return_block_pal(name,libn,dbl)
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
     tt=return_block_name(scs_m,libn,dbl)

     if size(tt,1)==1 then
       if tt=='PAL_f'
         tt=return_block_name(scs_m.objs(1).model.rpar,libn,dbl)
       end
     end

       //##special case for the block PAL_f of scicos
     if name<>SCI+'/macros/scicos/Others.cosf' then
       ntt=[]
       for i=1:size(tt,1)
         if tt(i)<>'PAL_f' then
           ntt=[ntt;tt(i)]
         end
       end
       if ntt<>[] then tt=ntt, end;
     end

   else
     printf("return_block_pal : "+...
            "Unable to find cosf file.\n");
     tt=[];
   end
 else
     printf("return_block_pal : "+...
            "bad rsh 1 parameter.\n");
     tt=[];
 end
endfunction
