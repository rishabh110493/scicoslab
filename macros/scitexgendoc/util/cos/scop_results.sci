//Fonction qui execute une liste scs_m
//et exporte les fenetres graphiques résultantes
//dans des fichiers eps
function i=scop_results(scs_m)

 //erase all graphics
 del_all_graphics()
 titlef=scs_m.props("title")(1);
 context=scs_m.props("context");
 execstr(context); //c'est dangereux cela
 scs_m.props.tf=Tfin;
 ctxt=struct()
 //scs_m.props.context=[];
 Info=list();

 //Tests for scicos version
 ierr = execstr('current_version=get_scicos_version()','errcatch')
 if ierr<>0 then //scilab < 4.1x
   //Switch to old_mode
   bak=get('figure_style');
   set("figure_style","old");

 end
 //02/12/07,Alan : enlève affich dans la simulation batch, sinon
 //cela ne fonctionne pas avec scilab4.1.2
 //str='Info=scicos_simulate(scs_m,Info,ctxt)';
 str='Info=scicos_simulate(scs_m,Info,ctxt,'''',''affich'')';

 ierror=execstr(str,'errcatch');
 if ierror<>0 then 
   printf("\n******* Simulation problem *******\n")
 end

 i=0

 if ierr==0 then //scilab > 4.1x
   win_n=winsid();
   for ii=1:size(win_n,2)
     gh = scf(win_n(ii));
     if (win_n(ii))<>0 then
       win_id = win_n(ii);
       i=i+1;
       nbaxe=0
       for ijkl=1:size(gh.children,1)
         if ~isempty(gh.children(ijkl).children) then
           nbaxe=nbaxe+1
         end
       end
       if nbaxe<>0 & nbaxe<>1 then
         gh.figure_size=[600 400]
         gh.figure_size(2)=gh.figure_size(2)*nbaxe*75/100
       end
       //gh.figure_size=[600 400]

       set_posfig_dim(gh.figure_size(1),gh.figure_size(2))
       drawlater();
       for jj=1:size(gh.children,1)
         if gh.children(jj).children <> [] then
           for kk=1:size(gh.children(jj).children,1)
             if gh.children(jj).children(kk).type=='Polyline' then
               if gh.children(jj).children(kk).line_mode=='off' then
                 if gh.children(jj).children(kk).mark_mode=='on' then
                   if gh.children(jj).children(kk).mark_style==0 | ...
                      gh.children(jj).children(kk).mark_style==11 then
                     if gh.children(jj).children(kk).mark_size==0 then
                          gh.children(jj).children(kk).mark_size=2
                     end
                   end
                 end
               end
             end
           end
           gh.children(jj).font_style=2
           if strindex(gh.children(jj).title.text,'Graphic')<>[] then
             gh.children(jj).title.text=""
             gh.children(jj).title.visible="off"
             //gh.children(jj).title.foreground=-2
             for iii=1:size(gh.children(jj).x_ticks.labels,'*')
               for kkk=1:8
                 gh.children(jj).x_ticks.labels(iii)=strsubst(gh.children(jj).x_ticks.labels(iii),...
                        'e+0'+string(kkk),'e+'+string(kkk));
                 gh.children(jj).x_ticks.labels(iii)=strsubst(gh.children(jj).x_ticks.labels(iii),...
                        'e-0'+string(kkk),'e-'+string(kkk));
               end
             end
             for iii=1:size(gh.children(jj).y_ticks.labels,'*')
               for kkk=1:8
                 gh.children(jj).y_ticks.labels(iii)=strsubst(gh.children(jj).y_ticks.labels(iii),...
                        'e+0'+string(kkk),'e+'+string(kkk));
                 gh.children(jj).y_ticks.labels(iii)=strsubst(gh.children(jj).y_ticks.labels(iii),...
                        'e-0'+string(kkk),'e-'+string(kkk));
               end
             end
           end
         end
       end
       drawnow();
       xbasimp(win_id,titlef+'_scope_'+string(i))
       unix_g(SCI+'/bin/BEpsf '+titlef+'_scope_'+string(i)+'.'+string(win_id))
       delete(gh);
     else
       delete(gh);
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
