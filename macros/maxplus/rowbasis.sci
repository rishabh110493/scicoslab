
function [k]=rowbasis(A,B)
precision=0.0000000001*abs(mnorm(A))
k=hrowbasis(A,B,precision)
endfunction
