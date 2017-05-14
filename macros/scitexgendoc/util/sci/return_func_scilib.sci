//return func scilab
//
//fonction qui retourne les noms des
//macros scilab présentent dans la
//librairie name
//
//Entrée : name :  le nom de la librairie
//
//Sortie : tt(1) : 
//          tt(2..) : la liste des macros
function tt=return_func_scilib(name)
 tt=[]
 if exists(name) then
  ierr=execstr('tt=string(evstr(name))','errcatch');
 end
endfunction