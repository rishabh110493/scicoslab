function x=%sp_or(a,flag)
// Copyright INRIA
if argn(2)==1 then flag='*',end
if flag=='*' then
  x=find(a<>0,1)<>[]
else
  x=sum(bool2s(a),flag)>=1
end
endfunction
