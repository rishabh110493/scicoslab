
function [u,pi,niterations]=FordBellman(ij,v,n,entry,flag)
//howard algorithm
//see Howard.help for more info
// jpc: a last flag is added if equal to "arc" the 
// returned strategy gives the arc to use instead of the node 
// 
  [lhs,rhs]=argn(0)
  if rhs <= 4 then flag = "node" ; end; 
  arc = bool2s(flag == "arc");
  s=size(ij)
  t=size(v)
  narcs=s(1)
  if (s(2)<> 2)
    error('first argument is not a tail-head matrix (should be 2 x narcs)')
  end
  if (t(1)<> s(1))
    error('second argument must be an 1 x narcs vector')
  end
  [u,pi,niterations]=hFordBellman(ij' ,v',n,entry,arc)
endfunction
