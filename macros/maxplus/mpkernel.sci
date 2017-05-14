
//latest version ok.

function [W1,W2]=mpkernel(A)
s=size(A)
Z=full(%zeros(s(1),s(2)))
AA=[A,Z]
BB=[Z,A]
W=mpsolve(AA,BB)
W1=W(1:s(2),:)
W2=W((s(2)+1):(2*s(2)),:)
endfunction
