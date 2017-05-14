
//slow scilab macro 
function [W]=MSOLVE2(A,B)
s=size(A)
U=meye(s(2))
for i=1:(s(1))
	printf("%d ",i);
	a=product(A(i,:),U)
	b=product(B(i,:),U)
	Z=ROWBASIS(a,b)
	if (Z==[])
		W=[]
		return
	else    
		V=WEAKBASIS(Z)
		UU=product(U,V)
		U=WEAKBASIS(UU)
		printf(" norm=%g\n",mnorm(U))
	end  
end
W=U
endfunction
