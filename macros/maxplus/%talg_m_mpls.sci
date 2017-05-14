//
//=======================================
//MULTIPLICATION PAR UNE MATRICE A GAUCHE
//=======================================
//
function [s]=%talg_m_mpls(m,s)
//
// computes m*S in state-space form.
//
[a,b,c,d,x]=s(2:6);
s=tlist(['mpls','A','B','C','D','X0'],a,b,m*c,d,x);
endfunction
