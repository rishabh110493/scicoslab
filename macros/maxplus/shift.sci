//
//======
// SHIFT
//======
//
function [s]=shift(n,t)
//
// system : n-shift in event numbers  and t-shift in dates
//
if n<1 then error( "shift: n must be larger or equal to 1") 
end  
a=sparse(diag(%ones(1,n),1));
b=[%zeros(n,1);sparse(%1)];
c=[sparse(#(t)),%zeros(1,n)];
s=mpsyslin(a,b,c);
endfunction
