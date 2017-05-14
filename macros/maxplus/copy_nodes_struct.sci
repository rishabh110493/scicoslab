
function [gc]=copy_nodes_struct(g,gc)
l=list('node_number','node_name','node_type','node_x','node_y','node_color',..
    'node_diam','node_font_size','node_demand')
for i=l, gc(i)=g(i), end
endfunction
