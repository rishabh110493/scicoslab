function   tree=sci_xlabel(tree)
// Copyright INRIA
// M2SCI function
// Conversion function for Matlab xlabel()
// Input: tree = Matlab funcall tree
// Ouput: tree = Scilab equivalent for tree
// F.B.

global("m2sci_to_insert_a")
if typeof(tree.lhs(1))=="variable" & tree.lhs(1).name == "ans"   then
  tree.lhs(1).type=Type(Handle,Unknown)
else
  m2sci_to_insert_a($+1)=list("EOL")
  m2sci_to_insert_a($+1)=Equal(list(tree.lhs(1)),Funcall("get",1,list(Funcall("gca",1,list(),list()),'""x_label""'),list()))
  tree.lhs(1)=Variable("ans",tlist(["infer","dims","type","contents"],list(1,1),Type(Handle,Unknown),Contents()))
end

endfunction