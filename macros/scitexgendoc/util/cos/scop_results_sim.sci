//Fonction qui execute une un script de simulation
//scilab et exporte les fenetres graphiques résultantes
//dans des fichiers eps
//Entrée sim_name : path+nom du fichier script
function i=scop_results_sim(sim_name)

 //erase all graphics
 del_all_graphics()

 //define base name of the simulation script
 titlef=basename(sim_name);

 //Tests for scicos version
 ierr_sav = execstr('current_version=get_scicos_version()','errcatch')
 if ierr_sav<>0 then //scilab < 4.1x
   //Switch to old_mode
   bak=get('figure_style');
   set("figure_style","old");
 end

 //run simulation script
 str='exec('''+sim_name+''',-1);';
 ierror=execstr(str,'errcatch');
 if ierror<>0 then
     printf("\n******* Simulation problem *******\n");
 end
 i=0

 if ierr_sav==0 then //scilab > 4.1x

   while %t
     gh = gcf();
     win_id = gh.figure_id;
     if win_id <> 0 then
       i=i+1;
       xbasimp(win_id,titlef+'_scope_'+string(i))
       unix_g(SCI+'/bin/BEpsf '+titlef+'_scope_'+string(i)+'.'+string(win_id))
       delete(gh);
     else
       delete(gh);
       break
     end
   end

 else
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
     i=i+1;
     //xbasimp(win,titlef+'_scope_'+string(i)+'.ps')
     xbasimp(win,titlef+'_scope_'+string(i))
     //unix_g(SCI+'/bin/BEpsf '+titlef+'_scope_'+string(i)+'.ps'+'.'+string(win))
     unix_g(SCI+'/bin/BEpsf '+titlef+'_scope_'+string(i)+'.'+string(win))
     xdel(win);
    end
   end

   //Retrieve figure_style
   gg=xget('window')  // for bug in figure_style and winsid
   xset('window',0) // for bug in figure_style and winsid
   set('figure_style',bak)
   xset('window',gg) // for bug in figure_style and winsid
 end
endfunction