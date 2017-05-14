//
function [ed]=edge_nb(g,tail,head)
gh=g('head');
ne=sparse([g('tail')',gh'],[1:size(gh,2)]');
ed=full(ne(tail+(head-1)*g('node_number')));
endfunction
