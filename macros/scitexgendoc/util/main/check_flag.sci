//check_flag v�rifie si le flag
//est un �l�ment retourn� par 
//get_sup_flag()
//
//iout : - retourne la taille de flag
//         si les valeurs sont bonnes
//       - retourne une valeur n�gative
//         dont la valeur absolue correspond
//         � l'indice de l'�l�ment d�fectueux.
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