//
//==================
// FULLIFY  A SYSTEM
//==================
// usage full(s)
//
function [sp]=%mpls_full(s)
[l,a,b,c,d,x]=s(1:6)
sp=tlist(l,full(a),full(b),full(c),full(d),full(x));
endfunction
