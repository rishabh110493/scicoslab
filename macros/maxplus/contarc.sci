
function [B]=contarc(X,eps)
// Pour compter choses different de zero dans un ensemble periodique (per=1)
[l1,l2]=argn(0);
if l2==1 then eps=0.0000000001; end;
B1=contar(X);
if abs(B1(1,1)-B1($,1)-1)<eps then
	B=B1(1:$-1,:);B(1,2)=B(1,2)+B1($,2);
else B=B1;
end;
endfunction
