

function [v,p]=costo(D,H,l)
//
// Commande stochastique
//
if l>0 then
  [v,p]=costoa(D,H,l,0.001)
  v=l*v
else
  [v,p]=costoe(D,H,0.001)
end
endfunction
