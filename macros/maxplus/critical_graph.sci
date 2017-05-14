
function [edn,gh]=critical_graph(g,sg)
[nc,ncomp]=strong_connex(sg);
en=find(ncomp(sg('head'))==ncomp(sg('tail')));
ng=evstr(sg('edge_name'));
edn=ng(en);
w=ones(1,edge_number(g));
w(edn)=4;
gh=g;
gh('edge_width')=w;
show_graph(gh);
endfunction
