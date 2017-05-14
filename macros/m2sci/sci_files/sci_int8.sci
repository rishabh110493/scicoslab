function [tree]=sci_int8(tree)
// File generated from sci_PROTO9.g: PLEASE DO NOT EDIT !
// Copyright INRIA
// M2SCI function
// Conversion function for Matlab int8()
// Input: tree = Matlab funcall tree
// Ouput: tree = Scilab equivalent for tree
// Emulation function: mtlb_int8()
// V.C.

// %c_int8 and %b_int8 are not defined in Scilab
x = getrhs(tree)

// Matlab int8() can return Boolean type value
if or(x.vtype==[Boolean,Unknown]) then
  vtype=Unknown
else
  vtype=Int
end

x = convert2double(x)

tree.rhs=Rhs(x)

if is_complex(x) then
  set_infos("Scilab int8() does not work with Complex values: int8() call IGNORED !",2);
  if typeof(x)=="operation" then
    x.out=tree.lhs
  elseif typeof(x)=="funcall" then
    x.lhs=tree.lhs
  end
  tree=x
elseif ~is_real(x) then
  set_infos("Scilab int8() does not work with Complex values: int8() call IGNORED !",2);
  repl_poss(x,tree,x,"is real")
  if typeof(x)=="operation" then
    x.out=tree.lhs
  elseif typeof(x)=="funcall" then
    x.lhs=tree.lhs
  end
  tree=x
else
  tree.name="mtlb_int8"
  tree.lhs(1).dims=x.dims
  tree.lhs(1).type=x.type
end

endfunction
