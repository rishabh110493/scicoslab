function f=%c_e(varargin)
//A(i,j,k,..)

rhs=size(varargin)
M=varargin(rhs)

nind=rhs-1 
dims=[]
for k=3:nind
  ind=varargin(k)
  if type(ind)==2|type(ind)==129 then ind=horner(ind,1),end
  if type(ind)==4 then ind=find(ind),end
  if or(ind<>1) then error(21),end
  n=size(ind,'*')
  dims=[dims,n]
end
f=M(varargin(1:min(2,rhs-1)))
k=find(dims>1)
if k<>[] then
  dims(k($)+1:$)=[]
  N=prod(dims)
  szf=size(f)
  f=f(:)
  f=mlist(['hm','dims','entries'],[szf dims],matrix(f(:,ones(1,N)),-1,1))
end
endfunction