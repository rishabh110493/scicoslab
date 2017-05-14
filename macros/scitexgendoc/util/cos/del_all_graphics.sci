//Fonction qui ferme toutes les fenetres
//graphiques ouvertes (old_style)
function del_all_graphics()
while %t
  win=xget("window");
  if win==0 then 
    xdel(win);
    win=xget("window");
    if win==0 then 
      xdel(win);
      break 
    end
  else
  xdel(win)
  end
end
endfunction
 
