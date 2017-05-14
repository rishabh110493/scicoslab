//
//==============================
// EXPLICIT AND SIMPIFIED SYSTEM
//==============================
//
function [sn]=explicit(so)
//
sf=full(so);
[a,b,c,d]=sf(2:5);
ds=star(d); a=ds*a; b=ds*b; 
ac=[a;c]; zerocol=%ones(1,size(ac,1))*ac<>%0;
keep=find(zerocol);
sn=sparse(mpsyslin(ac(keep,keep),b(keep,:),c(:,keep)));
endfunction
