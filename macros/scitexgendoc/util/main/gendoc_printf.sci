//gendoc_printf
//fonction qui affiche les messages du g�n�rateur de documentation
//en accord avec les options de la liste %gendoc
//Entr�e : %gd liste de d�finition du g�n�rateur de documentation
//         txt un texte � afficher (format� suivant les fonctions
//                                  printf, fprintf,...)
//         v1,v2,v3,... : les variables � afficher
function gendoc_printf(%gd,txt,...
                       v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11)
  rhs=argn(2)

  str="";
  for i=1:rhs-2
    str=str+',v'+string(i);
  end

  //printf
  if %gd.opt.verbose then
    tt='printf('+sci2exp(txt)+str+')';
    [ierr]=execstr(tt,'errcatch');
  end

  //mfprintf
  if %gd.opt.with_log then
    tt='mfprintf('+string(%gd.opt.fd_log)+...
                 ','+sci2exp(txt)+str+')';
    [ierr]=execstr(tt,'errcatch');
  end

endfunction
