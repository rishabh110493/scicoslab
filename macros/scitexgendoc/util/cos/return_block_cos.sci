//return_block_cos
//Entrée name : chemin+nom du fichier cos
//              ex : name=MODNUM+'/scs_diagr/dyna/chua/chua.cos'
//      libn : un identifiant de libraire (ex 'mod_num')
//      dbl : un drapeau pour les doublons
//sortie tt : La liste des blocks
function tt=return_block_cos(name,libn,dbl)
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

     [ppath,nname,ext]=fileparts(name)
     if ext=='.cosf' then
       //load cosf file
       ierror=execstr('exec(name,-1)','errcatch');
     else
       //load cos file
       ierror=execstr('load(name)','errcatch')
     end

     //appel return_block_name
     tt=return_block_name(scs_m,libn,dbl)

     if tt<>[] then
       //tri par ordre alphabetic
       [s,k]=gsort(convstr(tt),'r','i');
       tt=[tt(k)];
     end

   else
     printf("return_block_cos : "+...
            "Unable to find cos file.\n");
     tt=[];
   end
  else
    printf("return_block_cos : "+...
           "bad rsh 1 parameter.\n");
     tt=[];
  end
endfunction
