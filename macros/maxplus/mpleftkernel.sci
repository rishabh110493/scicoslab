
function [W1,W2]=mpleftkernel(A)
s=size(A)
Z=full(%zeros(s(2),s(1)))
AA=[A',Z]
BB=[Z,A']
W=(mpsolve(AA,BB))'
W1=W(:,1:s(1))
W2=W(:,(s(1)+1):(2*s(1)))
endfunction
