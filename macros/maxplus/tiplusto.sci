
function [TN]=tiplusto(g,l,m)
no=g('node_number');TN=full(%zeros(no,no));
e=find(g('edge_color')==11);
i=g('tail')(e); j=g('head')(e);
n=g('edge_length')(e);
TN(i+(j-1)*no)=-n.*l(j);
e=find(g('edge_color')==1);
i=g('tail')(e); j=g('head')(e);
t=g('edge_length')(e);
TN(i+(j-1)*no)=t.*m(j);
e=find(g('edge_color')==32);
i=g('tail')(e); j=g('head')(e);
t=g('edge_length')(e);
TN(i+(j-1)*no)=t.*m(j);
endfunction
