
function g=mp_2_graph(a)
[ij,v]=spget(sparse(a))
g=mat_2_graph(sparse(ij,ones(1,size(ij,1))),1,'node-node')
g('edge_name')=string(plustimes(v))'
endfunction
