//Fonction qui charge un fichier scicos
//dans une liste scs_m et qui execute la simulation 
//et exporte les fenetres graphiques résultantes
//dans des fichiers eps grâce à scop_results
//Entrée name : chemin+nom du fichier cos
//              ex : name=MODNUM+'/scs_diagr/dyna/chua/chua.cos'
//Sortie num_cos : nombre de scope eporter
function number_scop=scop_results_cos(name)
 if fileinfo(name)<>[] then
     [ppath,nname,ext]=fileparts(name)
     if ext=='.cosf' then
       //load cosf file
       ierror=execstr('exec(name,-1)','errcatch');
     else
       //load cos file
       ierror=execstr('load(name)','errcatch')
     end

//   load(name)

   //Tests for scicos version
   ierr = execstr('current_version=get_scicos_version()','errcatch')
   if ierr==0 then //scilab > 4.1x
     //check version
     if type(scs_m)==17 then
       if find(getfield(1,scs_m)=='version')<>[] then
         if scs_m.version<>'' then
           scicos_ver=scs_m.version
         end
       end
     end
     if current_version<>scicos_ver then
       scs_m=do_version(scs_m,scicos_ver)
     end
   end
   number_scop=scop_results(scs_m)
 else
   printf("Unable to find %s file\n",name);
   number_scop=[];
 end

endfunction