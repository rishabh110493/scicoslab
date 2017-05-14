function rho=naiveeigenv(a)
n=size(a,1)
x=a
t=mptrace(a)
for i=2:n
	x=x*a
	t=t + (mptrace(x)).^(1/i)
end
rho=t
endfunction
