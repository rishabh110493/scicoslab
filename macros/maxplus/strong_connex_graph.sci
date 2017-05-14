
function [gc]=strong_connex_graph(g)
[nc,ncomp]=strong_connex(g);
en=find(ncomp(g('head'))==ncomp(g('tail')));
gc=g;
gc('tail')=g('tail')(en);
gc('head')=g('head')(en);
gc('edge_name')=g('edge_name')(en);
gc('edge_color')=g('edge_color')(en);
gc('edge_length')=g('edge_length')(en);
endfunction
