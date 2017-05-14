function sp=%sp_cos(a)
// Copyright INRIA
  [ij,v,mn]=spget(a)
  sp=sparse(ij,cos(v),mn);//sp=cos(full(a))
endfunction
