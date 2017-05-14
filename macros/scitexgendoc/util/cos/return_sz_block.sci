//return_sz_block
//fonction qui retourne la taille par default
//d'un bloc scicos
//
//Entrée : name : le nom de la fonction d'interface sans extension
//
//Sortie : la taille  un vecteur de taille 2
//         la largeur,la longeur
//
function [sz]=return_sz_block(name)

 //load scicos libraries 
 load SCI/macros/scicos/lib

 //execute define case
 ierror=execstr('blk='+name+'(''define'')','errcatch')

 if ierror<>0 then
    x_message(['Error in case define of GUI function';lasterror()] )
    disp(name)
    sz=[]
    return
 else
    [sz]=blk.graphics.sz
 end

endfunction