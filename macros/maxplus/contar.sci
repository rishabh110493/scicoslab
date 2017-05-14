function [B]=contar(X,eps);
// Pour compter choses different de zero
if argn(0)==1 then eps=0; end;
D=find(abs([X;0]-[0;X])>eps);
D1=D(2:$)-D(1:$-1);D1=D1';
B=[X(D(1:$-1)) D1];
endfunction
