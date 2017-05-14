//
//===========
// EXTRACTION
//===========
//
function [s]=%mpls_e(i,j,f)
//
// s= f(i,j)
//
[l,a,b,c,d,x]=f(1:6)
s=tlist(l,a,b(:,j),c(i,:),d,x)
endfunction
