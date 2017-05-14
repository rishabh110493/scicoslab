function [p,cap]=max_cap_path(i,j,g)
// Copyright INRIA
[lhs,rhs]=argn(0)
if rhs<>3 then error(39), end
// check i and j
if prod(size(i))<>1 then
  error('First argument must be a scalar')
end
if prod(size(j))<>1 then
  error('Second argument must be a scalar')
end
// check g
check_graph(g)
// compute lp, la and ln
n=g('node_number')
ma=prod(size(g('tail')))
if g('directed')==1 then
  [lp,la,ln]=m6ta2lpd(g('tail'),g('head'),n+1,n)
else
  [lp,la,ln]=m6ta2lpu(g('tail'),g('head'),n+1,n,2*ma)
end
// check max capacity
if g('edge_max_cap')==[] then
  cap=0
  p=[]
  return
end
// compute max capacity path
[c,v]=m6chcm(i,la,lp,ln,n,g('edge_max_cap'))
p=m6prevn2p(i,j,v,la,lp,ln,g('directed'))
cap=c(j)
endfunction
