
function cfenetre(no);
// Femer la fenetre no si elle existe

if ~(find(winsid()==no)==[]);xbasc();xdel(no); end;
endfunction
