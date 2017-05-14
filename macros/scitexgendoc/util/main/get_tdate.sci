//get_tdate
//retourne une chaîne de caractères contenant
//la date et l'heure sous la forme
//jj-mmm-aaaa,hh:mm
function txt=get_tdate()
  w=getdate();
  txt=date()+','+string(w(7))+':'+string(w(8));
endfunction
