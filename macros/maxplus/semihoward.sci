function [chi,v,pi,N,N2]=semihoward(B,w)
//howard semimarkov algorithm 
// computes the max average weigh |c|_b / |c|_w
// see Howard.help for more info
// syntax : semihoward(B: max plus matrix, w: max plus matrix)
// matrices can be full or sparse 
// the two matrices must have the same set of %0 entries
if type(B)==257 then
	[ij,a,s]=spget(sparse(B))
elseif type(B)==261 then
	[ij,a,s]=spget(B)
else
	error('first argument must be a max-plus (full or sparse) matrix')
end
if type(w)==257 then
	[ij2,t,s2]=spget(sparse(w))
elseif type(w)==261 then
	[ij2,t,s2]=spget(w)
else
	error('second argument must be a max-plus (full or sparse) matrix')
end
if a==#([])
	error('zero matrix in HOWARD')
end
if ij<>ij2 
	error('the max-plus matrix and the weight matrix do not have the same ppattern')
end
[chi1,v1,pi,N,N2]=hsemihoward(ij',tropical(a,0),s(1),tropical(t,0))
chi=#(chi1)
v=#(v1)
pi=pi+1
endfunction
