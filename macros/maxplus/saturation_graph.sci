//
//==============================t
//CAlCUL DU GRAPHE DE SATURATION
//==============================
//
//function [sg]=saturation_graph(g,T,N)
//[chi,v,n1,n2]=semihoward(T,N);
//an=#(plustimes(full(T))+plustimes(full(#(-plustimes(N)*diag(plustimes(chi))))));
//a=diag(v)\an*diag(v);
//[ir,ic]=find(a>#(-0.001));
//sg=subgraph(edge_nb(g,ir,ic)','edges',g);
//show_graph(sg)
//
function [sg]=Lsaturation_graph(g)
no1=ones(1,g('node_number'));
T=mp_ticks(g);
N=ttokens(g);
[chi,v,p,n1,n2]=semihoward(T,N);
an=tiplusto(g,plustimes(chi)',no1)
a=diag(v)\an*diag(v);
[ir,ic]=find(a>#(-0.000001));
sg=subgraph(edge_nb(g,ir,ic)','edges',g);
endfunction

function [sg]=Rsaturation_graph(g)
no1=ones(1,g('node_number'));
T=mp_ticks(g); N=ttokens(g);
[chi,v,p,n1,n2]=semihoward(T',N');
an=tiplusto(g,plustimes(chi)',no1)
a=diag(v)*an/diag(v);
[ir,ic]=find(a>#(-0.000001));
sg=subgraph(edge_nb(g,ir,ic)','edges',g);
endfunction
