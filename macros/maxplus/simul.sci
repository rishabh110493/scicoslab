//
//===========
// SIMULATION
//===========
//
function [y]=simul(s,u)
//
// s max-plus linear system
// u max-plus input
// y max-plus output
//
sf=full(s);
[a,b,c,d,x]=sf(2:6);y=[];
for k=1:size(u,2)
  x=a*x+b*u(:,k)
  z=c*x
  y=[y,z]
end;
endfunction
