//txt=return_typ_block(name,path)
//
//fonction qui retourne les arguments
//des paramètres de la fonction getvalue
//
//entrées : name le nom de la fonction
//          d'interface du bloc scicos
//          rmq : doit-être chargé si
//                ommission du 2eme paramètres
//
//         path : paramètre optionel qui
//                renseigne sur le chemin du
//                bloc scicos.
//
//sortie : txt : une matrice de chaîne de caractères
//               de taille mx2 donnant pour chaque
//               paramètres de la boîte de dialogue :
//               txt(,1) : le type (ex 'vec', 'mat',...)
//               txt(,2) : la taille (ex -1, 2, [3,2],...)
//
function txt=return_typ_block(name,path)

 //verification de path
 [lsh,rsh]=argn(0)
 if rsh<2 then
   path=[];
 else
   if fileinfo(path)==[] then
     path=[];
   end
 end

 //verif présence du bloc
 if ~exists(name) then
   if path<>[] then
     if fileinfo(path+name+'.sci')<>[] then
       err=execstr('getf(path+name+''.sci'');','errcatch');
       if err<>0 then
         printf("%s : GUI function not found\n",'return_typ_block');
         printf("%s\",name);
         txt(1,1)=[]
         txt(1,2)=[]
         return
       end
     else
       printf("%s : GUI function not found\n",'return_typ_block');
       printf("%s\",name);
       txt(1,1)=[]
       txt(1,2)=[]
       return
     end
   else
     printf("%s : GUI function not found\n",'return_typ_block');
     printf("%s\",name);
     txt(1,1)=[]
     txt(1,2)=[]
     return
   end
 end

 //Disable scilab function protection
 prot=funcprot();
 funcprot(0);

 //load scicos libraries 
 load SCI/macros/scicos/lib
 exec(loadpallibs,-1)
 %scicos_prob=%f;
 alreadyran=%f
 needcompile=4

 //redefine getvalue, edit_curv
 //SUPER_f, dialog
 getvalue=mgetvalue;
 edit_curv=medit_curv;
 SUPER_f=MSUPER_f;
 PAL_f=MPAL_f;
 dialog=mmdialog;

 //retrieve labels of getvalue fonction
 global mytyp

 ierror=execstr('blk='+name+'(''define'')','errcatch')
 if ierror<>0 then
      printf("%s : Error in GUI function\n",'return_typ_block');
      printf("%s\",name);
      txt(1,1)=[]
      txt(1,2)=[]
      return
 end

 ierror=execstr('blk='+name+'(''set'',blk)','errcatch')
 if ierror<>0 then
    printf("%s : Error in GUI function\n",'return_typ_block');
    printf("%s\",name);
    txt(1,1)=[]
    txt(1,2)=[]
    return
 end

 //restore function protection
 funcprot(prot);

 if mytyp<>[] then
  for i=1:(size(mytyp)/2)
   txt(i,1)=mytyp(2*i-1);
   txt(i,2)=sci2exp(mytyp(2*i));
  end
 else
  txt(1,1)=[]
  txt(1,2)=[]
 end

 clearglobal mydesc
 clearglobal mylables
 clearglobal mytyp
 clearglobal myini
endfunction