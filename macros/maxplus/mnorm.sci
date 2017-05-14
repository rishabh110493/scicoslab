
function [W]=mnorm(A)
B=tropical(A,0)
W=max(B)-min(B)
endfunction
