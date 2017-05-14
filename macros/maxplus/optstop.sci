
function []=optstop()
  global %StopTime
//  L=support(L)
  %StopTime.Cfilt=(1/(2^%StopTime.Eps-1))*%StopTime.Efilt*%StopTime.Cout
  [dim,dim]=size(%StopTime.MTfilt)
  h1=sparse([],[],[dim+1,dim])
  h1=[h1,ones(dim+1,1)]
  h2=%StopTime.MTfilt
  h2=[h2;sparse([],[],[1,dim])]
  h2=[h2,sparse([],[],[dim+1,1])]
  h2(dim+1,dim+1)=1
  H=sparse([h1;h2])
  d1=%diag([%StopTime.Cfilt(:,1);0])
  d2=%diag([%StopTime.Cfilt(:,2);0])  
  D=sparse(#([d1,d2]))
  [v,p]=costo(D,H,10^(-4))
  v=v/10^(-4)
  p=diag(p(:,dim+2:2*dim+2))
  v($)=[]
  p($)=[]
  %StopTime.Popt=p
  %StopTime.Copt=v
//exemple : n=20;l=8;N=200;nbr_col=3;a=0.0001;disx=30;disy=40;
//exemple : n=15;l=7;N=200;nbr_col=3;a=0.0001;disx=50;disy=70;
endfunction
