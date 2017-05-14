

function [W]=msolve(A,B)
s=size(A)
Z=%eye(s(2))
W=hmsolve(A,B,Z)
endfunction
