//check_flag vérifie si le flag
//est un élément retourné par 
//get_sup_flag()
//
//iout : - retourne la taille de flag
//         si les valeurs sont bonnes
//       - retourne une valeur négative
//         dont la valeur absolue correspond
//         à l'indice de l'élément défectueux.
function [iout]=check_flag(flag)

  flag=flag(:)
  sup_flag=get_sup_flag()
  iout=size(flag,1)
  for i=1:iout
   if ~or(flag(i)==sup_flag) then
     iout=-i
     printf("unsupported flag : %s\n",flag(i));
     return
   end
  end
endfunction