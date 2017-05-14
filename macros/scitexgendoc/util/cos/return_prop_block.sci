//return_prop_block
//fonction qui retourne les propriétés par default
//d'une fonction d'interface d'un bloc scicos
//
//Entrée : name : le nom de la fonction d'interface sans extension
//        lang :  (optionel) 'fr' pour du francais
//                           'eng' et autres pour de l'anglais
//Sortie : txt : liste de texte des propriétés par défaults
function txt=return_prop_block(name,lang)

 //verify the lang parameter
 [lsh,rsh]=argn(0)
 if rsh<2 then
   lang='eng'
 end

 //load scicos libraries 
 load SCI/macros/scicos/lib
 
 //execute define case
 ierror=execstr('blk='+name+'(''define'')','errcatch')
 if ierror<>0 then
    x_message(['Error in case define of GUI function';lasterror()] )
    disp(name)
    fct=[]
    return
 end

 prop=[]
 deput=blk.model.dep_ut

 //Tests for scicos version
 ierr = execstr('scicos_ver=get_scicos_version()','errcatch')
 if ierr==0 then //scilab > 4.1x

    // prop(1)  : toujours actif
    // prop(2)  : direct-feedthrough
    // prop(3)  : détection de passage à zéro
    // prop(4)  : mode
    // prop(5)  : nombre/taille/type des entrées régulières
    // prop(6)  : nombre/taille/type des sorties sorties régulières
    // prop(7)  : nombre/taille des entrées évènementielles
    // prop(8)  : nombre/taille des sorties évènementielles
    // prop(9)  : possède un état continu
    // prop(10) : possède un état discret
    // prop(11) : nom de la fonction d'interface
    // prop(12) : nom de la fonction modelica/de calcul
    // prop(13) : type de la fonction de calcul
    // prop(14) : possède un état objet

   if lang=='fr' then
      if deput(2) then prop(1)='oui', else prop(1)='non', end
      if deput(1) then prop(2)='oui', else prop(2)='non', end
      if blk.model.nzcross<>0 then  prop(3)='oui', else prop(3)='non', end
      if blk.model.nmode<>0 then  prop(4)='oui', else prop(4)='non', end
      if blk.model.state<>[] then prop(9)='oui', else prop(9)='non', end
      if blk.model.dstate<>[] then prop(10)='oui', else prop(10)='non', end
      if blk.model.odstate<>list() then prop(14)='oui', else prop(14)='non', end
   else
      if deput(2) then prop(1)='yes', else prop(1)='no', end
      if deput(1) then prop(2)='yes', else prop(2)='no', end
      if blk.model.nzcross<>0 then  prop(3)='yes', else prop(3)='no', end
      if blk.model.nmode<>0 then  prop(4)='yes', else prop(4)='no', end
      if blk.model.state<>[] then prop(9)='yes', else prop(9)='no', end
      if blk.model.dstate<>[] then prop(10)='yes', else prop(10)='no', end
      if blk.model.odstate<>list() then prop(14)='yes', else prop(14)='no', end
   end

   prop(5)=string(size(blk.model.in,'*'))+' / '+...
           strcat('['+string(blk.model.in(:))+','+string(blk.model.in2(:))+']',' ')+' / '+...
           strcat(string(blk.model.intyp),'  ')
   prop(6)=string(size(blk.model.out,'*'))+' / '+...
           strcat('['+string(blk.model.out(:))+','+string(blk.model.out2(:))+']',' ')+' / '+...
           strcat(string(blk.model.outtyp),'  ')
   prop(7)=string(size(blk.model.evtin,'*'))
   prop(8)=string(size(blk.model.evtout,'*'))
   prop(11)=name+'.sci'
   if typeof(blk.model.sim)=='list' then
      prop(12)=string(blk.model.sim(1))
      prop(13)=string(blk.model.sim(2))
   else
      prop(12)=string(blk.model.sim(1))
      prop(13)=""
   end

 else //code for scilab 3.0-4.1x

    // prop(1)  : toujours actif
    // prop(2)  : direct-feedthrough
    // prop(3)  : détection de passage à zéro
    // prop(4)  : mode
    // prop(5)  : nombre/taille des entrées régulières
    // prop(6)  : nombre/taille des sorties sorties régulières
    // prop(7)  : nombre/taille des entrées évènementielles
    // prop(8)  : nombre/taille des sorties évènementielles
    // prop(9)  : possède un état continu
    // prop(10) : possède un état discret
    // prop(11) : nom de la fonction d'interface
    // prop(12) : nom de la fonction modelica/de calcul
    // prop(13) : type de la fonction de calcul

   if lang=='fr' then
      if deput(2) then prop(1)='oui', else prop(1)='non', end
      if deput(1) then prop(2)='oui', else prop(2)='non', end
      if blk.model.nzcross<>0 then  prop(3)='oui', else prop(3)='non', end
      if blk.model.nmode<>0 then  prop(4)='oui', else prop(4)='non', end
      if blk.model.state<>[] then prop(9)='oui', else prop(9)='non', end
      if blk.model.dstate<>[] then prop(10)='oui', else prop(10)='non', end
   else
      if deput(2) then prop(1)='yes', else prop(1)='no', end
      if deput(1) then prop(2)='yes', else prop(2)='no', end
      if blk.model.nzcross<>0 then  prop(3)='yes', else prop(3)='no', end
      if blk.model.nmode<>0 then  prop(4)='yes', else prop(4)='no', end
      if blk.model.state<>[] then prop(9)='yes', else prop(9)='no', end
      if blk.model.dstate<>[] then prop(10)='yes', else prop(10)='no', end
   end

   prop(5)=string(size(blk.model.in,'*'))+' / '+strcat(string(blk.model.in),'  ')
   prop(6)=string(size(blk.model.out,'*'))+' / '+strcat(string(blk.model.out),'  ')
   prop(7)=string(size(blk.model.evtin,'*'))+' / '+strcat(string(blk.model.evtin),'  ')
   prop(8)=string(size(blk.model.evtout,'*'))+' / '+strcat(string(blk.model.evtout),'  ')
   prop(11)=name+'.sci'
   if typeof(blk.model.sim)=='list' then
      prop(12)=string(blk.model.sim(1))
      prop(13)=string(blk.model.sim(2))
   else
      prop(12)=string(blk.model.sim(1))
      prop(13)=""
   end
 end


 txt=prop

endfunction