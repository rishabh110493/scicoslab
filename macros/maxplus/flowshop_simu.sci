
function [chi,y]=flowshop_simu(s,nm,np,u)
nmach=size(nm,2); npiece=size(np,2); nt=size(u,2); 
fbm=shift(nm(1),0) ;
for i=1:nmach-1, fbm=fbm|shift(nm(i),0) ; end ;
fbp=shift(np(1),0);
for i=1:npiece-1, fbp=fbp|shift(np(i),0) ; end ;
sb=s/.(fbp|fbm);
sbs=explicit(sb);
chi=howard(sbs('A'));
y=simul(sbs,u);
chit=plustimes(chi(1))*[1:nt];
y=plustimes(y)-ones(nmach+npiece,1)*chit;
//plot2d(y(:,[1:nt])');
endfunction
