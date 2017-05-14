//
//==================
// SPARSIFY  A SYSTEM
//==================
//
function [sp]=%mpls_sparse(s)
[l,a,b,c,d,x]=s(1:6)
sp=tlist(l,sparse(a),sparse(b),sparse(c),sparse(d),sparse(x));
endfunction
