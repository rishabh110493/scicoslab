//
//=======================================
//MULTIPLICATION PAR UNE MATRICE A DROITE
//=======================================
//
function [s]=%mpls_m_talg(s,m)
//
// computes S*m in state-space form.
//
[a,b,c,d,x]=s(2:6);
s=tlist(['mpls','A','B','C','D','X0'],a,b*m,c,d,x);
endfunction
