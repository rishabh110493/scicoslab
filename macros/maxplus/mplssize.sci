//
//========================================
//TAILLE SIZE D'UN SYST. MAX-PLUS LINEAIRE
//========================================
// pas de surcharge a cause de la presence d'un bug
//
function [nx,nu,ny]=mplssize(x)
//
[b,c]=x(3:4);[nx,nu]=size(b);[ny,nx]=size(c);
endfunction
