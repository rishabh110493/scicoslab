function [B]=star(A)
if type(A)<>257 then 
	error('star requires a full max-plus matrix')
end
B=maxplus(hstar(plustimes(A)))
endfunction

//for historical compatibility
function [B]=STAR0(A)
B=star(A)
endfunction

function [B]=plus(A)
if type(A)<>257 then 
	error('plus requires a full max-plus matrix')
end
B=maxplus(hplus(plustimes(A)))
endfunction

//for historical compatibility
function [B]=PLUS0(A)
V=plus(A)
endfunction

function [chi,v,pi,N,N2]=howard(B)
//howard algorithm 
//see Howard.help for more info
if type(B)==257 then
	[ij,a,s]=spget(sparse(B))
elseif type(B)==261 then
	[ij,a,s]=spget(B)
else
	error('HOWARD requires a max-plus (full or sparse) matrix')
end
if a==#([])
	error('zero matrix in HOWARD')
end
[chi1,v1,pi,N,N2]=hhoward(ij',tropical(a,0),s(1))
chi=#(chi1)
v=#(v1)
pi=pi+1
endfunction

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


function [chi,v,pi,N,N2]=howard01(A0,A1)
//howard semimarkov algorithm 
// computes the cycle time of the system x(k)=A0*x(k)+A1*x(k-1)
// syntax : howard01(A0: max plus matrix, A1: max plus matrix)
// matrices can be full or sparse 
if type(A0)==257 then
	[ij,a0,s]=spget(sparse(A0))
elseif type(A0)==261 then
	[ij,a0,s]=spget(A0)
else
	error('first argument must be a max-plus (full or sparse) matrix')
end
T=zeros(size(a0,1),1)
if type(A1)==257 then
	[ij2,a1,s2]=spget(sparse(A1))
elseif type(A1)==261 then
	[ij2,a1,s2]=spget(A1)
else
	error('second argument must be a max-plus (full or sparse) matrix')
end
T=[T;ones(size(a1,1),1)]
if [a0;a1]==#([])
	error('zero matrix in HOWARD')
end
[chi1,v1,pi,N,N2]=hsemihoward([ij;ij2]',[tropical(a0,0);tropical(a1,0)],s(1),T)
chi=#(chi1)
v=#(v1)
pi=pi+1
endfunction

//for historical compatibility
function [chi,v,pi,N,N2]=HOWARD0(B)
//howard algorithm 
[chi,v,pi,N,N2]=howard(B)
endfunction

function [k]=karp(B,varargin)
//chi(B')_entry 
[lhs,rhs]=argn(0)
if rhs==1 then
	entry=1
elseif rhs==2 then
	entry=varargin(1)
else
	error('Karp requires one or two arguments")
end
if type(B)==257 then
	[ij,a,s]=spget(sparse(B))
elseif type(B)==261 then
	[ij,a,s]=spget(B)
else
	error('Karp requires a max-plus (full or sparse) matrix')
end
k=#(hkarp(ij',tropical(a,0),s(1),entry))
endfunction

//for historical compatibility 
function [k]=KARP0(B,varargin)
//chi(B')_entry
[lhs,rhs]=argn(0)
if rhs==1 then
	entry=1
elseif rhs==2 then
	entry=varargin(1)
else
	error('Karp requires one or two arguments")
end
if type(B)==257 then
	[ij,a,s]=spget(sparse(B))
elseif type(B)==261 then
	[ij,a,s]=spget(B)
else
	error('Karp requires a max-plus (full or sparse) matrix')
end
k=#(hkarp(ij',tropical(a,0),s(1),entry))
endfunction

function [W]=mnorm(A)
B=tropical(A,0)
W=max(B)-min(B)
endfunction

function [precision]=getprecision(A)
u=mnorm(A)
if u==%inf
        precision=0.0000000001
else
	precision=0.0000000001*u
end
endfunction

function [k]=inspan(A,b,varargin)
//
//returns true if b is in span(A)
// for full matrices only
//
[lhs,rhs]=argn(0)
//
if rhs==2  then 
  precision=getprecision(A) 
elseif rhs==3  then 
  precision=varargin(1)
else 
  error('INSPAN requires two or three arguments') 
end
//      
if ((type(A)<>257)|(type(b)<>257)) then
error('inputs must be full max-plus matrices')  
end
//
if size(A,1)<>size(b,1) then
  error('incompatible dimensions') 
end
//      
u=hin_span(tropical(A,0),tropical(b,0),precision)
//
if u==1 then
  k=%t 
else	
  k=%f
end
endfunction

function [k]=INSPAN0(A,b,varargin)
//returns true if b is in span(A)
// for full matrices only
[lhs,rhs]=argn(0)
if rhs==2 then
        precision=getprecision(A)
elseif rhs==3 then
	precision=varargin(1)
else
	error('INSPAN requires two or three arguments')
end
if ((type(A)<>257)|(type(b)<>257)) then
	error('inputs must be full max-plus matrices')
end
k=hin_span(tropical(A,0),tropical(b,0),precision)
endfunction


function [k]=weakbasis(A,varargin)
[lhs,rhs]=argn(0)
if rhs==1 then
	precision=getprecision(A)
elseif rhs==2 then
	precision=varargin(1)
else
	error('WEAKBASIS requires one or two arguments')
end
if (type(A)<>257) then
	error('input must be a full max-plus matrix')
end
k=tropical(hweakbasis(tropical(A,0),precision),1)
endfunction

function [k]=WEAKBASIS0(A,varargin)
[lhs,rhs]=argn(0)
if rhs==1 then
	precision=getprecision(A)
elseif rhs==2 then
	precision=varargin(1)
else
	error('WEAKBASIS requires one or two arguments')
end
if (type(A)<>257) then
	error('input must be a full max-plus matrix')
end
k=tropical(hweakbasis(tropical(A,0),precision),1)
endfunction

//another algorithm 
function [k]=weakbasis2(A,varargin)
[lhs,rhs]=argn(0)
if rhs==1 then
	precision=getprecision(A)
elseif rhs==2 then
	precision=varargin(1)
else
	error('WEAKBASIS2 requires one or two arguments')
end
if (type(A)<>257) then
	error('input must be a full max-plus matrix')
end
k=tropical(hweakbasis2(tropical(A,0),precision),1)
endfunction

function [k]=includespan(A,B,varargin)
[lhs,rhs]=argn(0)
if rhs==2 then
	precision=getprecision([A,B])
elseif rhs==3 then
	precision=varargin(1)
else
	error('INCLUDESPAN requires two or three arguments')
end
if ((type(A)<>257)|(type(B)<>257)) then
	error('inputs must be full max-plus matrices')
      end
if size(A,1)<>size(B,1) then
  error('incompatible dimensions') 
end
k=hinclude_span(tropical(A,0),tropical(B,0),precision)
if k==1 then
	k=%t
	else
	k=%f
end
endfunction

function [k]=equalspan(A,B,varargin)
[lhs,rhs]=argn(0)
if rhs==2 then
	precision=getprecision([A,B])
elseif rhs==3 then
	precision=varargin(1)
else
	error('INCLUDESPAN requires two or three arguments')
end
if ((type(A)<>257)|(type(B)<>257)) then
	error('inputs must be full max-plus matrices')
end
if size(A,1)<>size(B,1) then
  error('incompatible dimensions') 
end
a=tropical(A,0);
b=tropical(B,0);
k=(hinclude_span(a,b,precision)& hinclude_span(b,a,precision))
endfunction

function [k]=rowbasis(A,B)
precision=0.0000000001*abs(mnorm(A))
k=hrowbasis(A,B,precision)
endfunction

// slow scilab macro 
function [W]=Msolve(A,B,U)
a=product(A(1,:),U)
b=product(B(1,:),U)
s=size(A)
t=size(U)
printf("%d %d ",t(1),t(2));
Z=rowbasis(a,b)
if (Z==[])
  W=[] 
else
  V=weakbasis(Z)
  UU=product(U,V)
  UUU=weakbasis(UU)
  if s(1)==1
    W=UUU
  else
    AA=A(2:s(1),:)
    BB=B(2:s(1),:)
    W=Msolve(AA,BB,UUU)
  end
end
endfunction

function [u,pi,niterations]=FordBellman(ij,v,n,entry)
//howard algorithm
//see Howard.help for more info
s=size(ij)
t=size(v)
narcs=s(1)
if (s(2)<> 2)
        error('first argument is not a tail-head matrix (should be 2 x narcs)')
end
if (t(1)<> s(1))
        error('second argument must be an 1 x narcs vector')
end
[u,pi,niterations]=hFordBellman(ij' ,v',n,entry)

endfunction

function [w]=astarb(A,b)
// calcule star(A)*b pour A et B maxplus
// sparse
[n,n]=size(A);
Ab=[[A';b'],[%zeros(n,1);%1]];
[ij,v,nm]=spget(sparse(Ab));
w=hFordBellman(ij',plustimes(v'),n+1,n+1);
w=#(w([1:n]))
endfunction

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


function [W]=msolve(A,B)
s=size(A)
Z=%eye(s(2))
W=hmsolve(A,B,Z)
endfunction

function [W]=mpsolveOLD(A,B,varargin)
[lhs,rhs]=argn(0)
if rhs==2 then
	precision=getprecision([A,B])
elseif rhs==3 then
	precision=varargin(1)
else
	error('SOLVE requires two or three arguments')
end
if ((type(A)<>257)|(type(B)<>257)) then
	error('inputs must be full max-plus matrices')
end
W=tropical(hsolve(tropical(A,0),tropical(B,0),precision),1)
endfunction

function [W]=mpsolve(A,B,varargin)
[lhs,rhs]=argn(0)
if rhs==2 then
	precision=getprecision([A,B])
elseif rhs==3 then
	precision=varargin(1)
else
	error('SOLVE requires two or three arguments')
end
if ((type(A)<>257)|(type(B)<>257)) then
	error('inputs must be full max-plus matrices')
end
W=tropical(hsolve3(tropical(A,0),tropical(B,0),precision),1)
endfunction

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

function [W1,W2]=mpleftkernel(A)
s=size(A)
Z=full(%zeros(s(2),s(1)))
AA=[A',Z]
BB=[Z,A']
W=(mpsolve(AA,BB))'
W1=W(:,1:s(1))
W2=W(:,(s(1)+1):(2*s(1)))
endfunction

