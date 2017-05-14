//return_context_diagr
//fonction qui retourne le contexte 
//d'un diagrammme scicos contenue dans 
//le fichier 'name'
//Entrée : name le nom du fichier à éexaminer
//         ex : namef=MODNUM+'/scs_diagr/dyna/chua/chua.cos'
function txt=return_context_diagr(namef)

 txt=[]
 if fileinfo(namef)<>[] then
   [ppath,name,ext]=fileparts(namef)
   if ext=='.cosf' then
     //load cosf file
     ierror=execstr('exec(namef,-1)','errcatch');
   else
     //load cos file
     ierror=execstr('load(namef)','errcatch')
   end
   //ierror=execstr('load(namef)','errcatch')
   if ierror==0 then
      ierror2=execstr('txt=scs_m.props(""context"")','errcatch')
      if ierror2<>0 then
        printf("Error while reading context\n");
        txt=[];
      end
   else
     printf("Error while loading %s\n",namef);
   end
 else
  printf("file %s not found\n",namef);
 end

endfunction