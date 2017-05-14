

function [R,V]=simu(n,dep,delta)

fenetre(fen2);
fenetre(fen3);

//-------> Initial distribution of cars
if delta==0 then
Xt=sort(-rand(n,1));
else
Xt=sort(-((0:n-1)'/(n*delta)+fix(rand(n,1)/(delta*n)))*delta);
end;
R=Xt;V=[];Ro=contarc(Xt);


//-------> Calcule de la matrice As=star(A)
if dep==0 then
	A=diag(#(ones(n-1,1)*delta),1);
	A(n,1)=-1+delta;
else
	A=diag(#(ones(n-2,1)*delta),2);
	A(n-1,1)=-1+delta;
	A(n,2)=-1+delta;
end;
As=star(A);


for t=1:tmax,
	lam2=1-lam1;
	vt=v1+(1+floor(rand(n,1)-lam2))*(v2-v1);
	X1=contarc(Xt(find(vt<v2)));
	X2=contarc(Xt(find(vt>v1)));
	Xc1=[X1;[X2(:,1), 0*X2(:,2)]];
	Xc2=[X2;[X1(:,1), 0*X1(:,2)]];
	[s1,k1]=sort(Xc1(:,1));[s2,k2]=sort(Xc2(:,1));
	Xd1=Xc1(k1,:); 
	Xd2=Xc2(k2,:);
	if Xd1($,1)+1==Xd1(1,1) then X1=Xd1(1:$-1,:);X2=Xd2(1:$-1,:);
		else X1=Xd1;X2=Xd2; end;
	X3=[X1(:,1), X1(:,2)+X2(:,2)];
	X1=X1(find(X3(:,2)>0),:);X3=X3(find(X3(:,2)>0),:);
	Xo=X3;

	a0=1;a1=1;a2=1;
	r0=2;r1=1;r2=2;
	isoview(-3,3,-3,3);
	xset('use color',1);
	xset('pattern',12);
	xarc(-r0,r0,2*r0,2*r0,0,64*360);
	xset('pattern',1);xset('thickness',1);
	xarc(-r1,r1,2*r1,2*r1,0,64*360);xset('thickness',3);
	Sx=[r0*cos(2*%pi*Xo(:,1)),r0*cos(2*%pi*Xo(:,1)).*(1+a0/n*Xo(:,2))];
	Sy=[r0*sin(2*%pi*Xo(:,1)),r0*sin(2*%pi*Xo(:,1)).*(1+a0/n*Xo(:,2))];
	px1=cos(2*%pi*X1(:,1));
	py1=sin(2*%pi*X1(:,1));
	S1x=[r1*px1,px1.*(r1+a1*X1(:,2)./X3(:,2))];
	S1y=[r1*py1,py1.*(r1+a1*X1(:,2)./X3(:,2))];
	S2x=[px1.*(r1+a1*X1(:,2)./X3(:,2)),r2*px1];
	S2y=[py1.*(r1+a1*X1(:,2)./X3(:,2)),r2*py1];


	xset('thickness',3); 
	xset('pattern',1); xsegs(Sx',Sy');
	xset('pattern',2); if prod(size(S1x))>0 then xsegs(S1x',S1y'); end;
	xset('pattern',3); if prod(size(S2x))>0 then xsegs(S2x',S2y'); end;

	ac=1/5;
	autito(Xt(1,1),r0,ac,5);
	autito(Xt(n/2,1),r0,ac,6);
	autito(Xt(n,1),r0,ac,12);
	Ro=[Ro;Xo];

//-------------------------------->>>>>>>>>>> Max-Plus main step
//        pause 
//	disp('Xt')
	Xt=plustimes(As*(#(Xt-vt)));
//---------------->>>> In the case with overtaking it is necessary to reorder
	if dep==1;Xt=sort(Xt);end;


	R=[R,Xt]; V=[V,vt];

	xset("window",3);xset("thickness",2);
	nnn=prod(size(R(1,:)));
	ejex=1:nnn;
	vva=-mean(R,'r')./(1:nnn);
plot2d([ejex',ejex',ejex'],[vva',ones(nnn,1)*vmedia,ones(nnn,1)*vmediac],...
[2,3,5],"110"," ",[0,0,tmax,max([vva,vmedia*10,vmediac*10])],[2,10,2,10]);
	xset("window",2);

end;

xset("window",3);
plot2d([ejex',ejex',ejex'],[vva',ones(nnn,1)*vmedia,ones(nnn,1)*vmediac],...
[2,3,5],"111","vitesse moyenne simulee@vitesse moyenne... calculee@vitesse moyenne...
corrigee",[0,0,tmax,max([vva,vmedia*10,vmediac*10])],[2,10,2,10]);
endfunction
