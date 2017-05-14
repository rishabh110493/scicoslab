function [sg]=Rsaturation_graph(g)
no1=ones(1,g('node_number'));
T=mp_ticks(g); N=ttokens(g);
[chi,v,p,n1,n2]=semihoward(T',N');
an=tiplusto(g,plustimes(chi)',no1)
a=diag(v)*an/diag(v);
[ir,ic]=find(a>#(-0.000001));
sg=subgraph(edge_nb(g,ir,ic)','edges',g);
endfunction
