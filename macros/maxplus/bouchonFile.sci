function [B]=contar(X,eps);
// Pour compter choses different de zero
if argn(0)==1 then eps=0; end;
D=find(abs([X;0]-[0;X])>eps);
D1=D(2:$)-D(1:$-1);D1=D1';
B=[X(D(1:$-1)) D1];
endfunction

function [B]=contarc(X,eps)
// Pour compter choses different de zero dans un ensemble periodique (per=1)
[l1,l2]=argn(0);
if l2==1 then eps=0.0000000001; end;
B1=contar(X);
if abs(B1(1,1)-B1($,1)-1)<eps then
	B=B1(1:$-1,:);B(1,2)=B(1,2)+B1($,2);
else B=B1;
end;
endfunction

function q=bouchonvm(N,k,l)
// Function vitesse moyenne
// Parametres: 
//     l: probabilite de la vitesse v2
//     N: quantite de voitures
//     k:quantite de bouchons
q=l;
for n=1:N-1,
	q=l/(n+k)*(k+n*q);
end;
endfunction

function qq=Vm(N,V2,lam);
// Function vitesse moyenne
// Parametres: 
//     V2: vector de vitesses v2
//     lam: probabilite de la vitesse v2
//     N: quantite de voitures
//     k: quantite de bouchons
q=lam*ones(V2);
K=ceil(V2.^(-1));
qq=q./K;
for n=1:N-1,
	q=(lam./(n+K)).*(K+n*q);
	qq=[qq;q./K];
end;
endfunction

function fenetre(data);
// no,x,y,w,h,autoclear
n=max(size(data));
xset("window",data(1));
if n>1,
xset('wpos',data(2),data(3)); 
if n>3,
xset('wdim',data(4),data(5));
if n>5,
if data(6)==1, xset("auto clear","on");end;
end;end;end;
endfunction

function cfenetre(no);
// Femer la fenetre no si elle existe

if ~(find(winsid()==no)==[]);xbasc();xdel(no); end;
endfunction
	
function autito(x,r,a,color)
xset("pattern", color);
x1=r*cos(2*%pi*x);
y1=r*sin(2*%pi*x);
xfarc(x1-a/2,y1+a/2,a,a,0,360*64);
endfunction


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

//=========================------------>>>>>> Main menu 
function bouchon();

m1=%T;m2=%F;tt=1;tp=1;rr=[1,1,1,1,2,1];

//----->>>> Donnes des fenetres
//Dimenions de l'ecran
//xm=1256;ym=1024;
xm=800;ym=600;
//Dimensions des fenetres 
//x1=600;y1=400;
x1=430;y1=280;
d1=50;dh=5;dv=60
fen1=[1,d1,y1+dv,x1,y1,1];
fen2=[2,d1+x1+dh,0,x1,y1,1];
fen3=[3,d1+x1+dh,y1+dv,x1,y1,1];
fen4=[4,d1+x1*2/3,y1*2/3,3*x1/2,3*y1/2,1];

while m1,
	items=["Simulations";"Vitesse-Moyenne(#voitures,vitesse-max)"]; 
	opc=x_choose(items,...
           "Formation de bouchons sur un anneau: (Choisisez une opcion)",...
           "Done");
 	if opc==0 then m1=%F; 
		cfenetre(4);
	end;
  	if opc==2 then  
		gxy=Vm(100,.01:.01:.995,.5);cfenetre(4);
		fenetre(fen4);isoview(0,1,0,1);
		plot3d(1:100,1:99,gxy/max(gxy)*100,345,45,"N. de ...
		voitures@V2@V.moyenne",[12,1,3],[1,100,1,99,0,100]);
 	 end; 


	if opc==1 then 	m2=%T; cfenetre(4); end; 

//----------------------------------------------->>>> Parametres de la simulation
// vitesses
 	lisv=[0.01,0.1,0.11,0.111,0.34,0.5,0.55,0.6]; 	
// lambdas
	lisl=[0.2,0.3,0.5,0.7,0.8,1];
// epaiseurs
	lisd=[0,0.001,0.01,0.1];
// nombres de voitures
	lisn=[10,20,30,40,50,60,70,80,90,95,100]; 	
// temps de simulation
	listemp=[10,100,200,500,1000]; 	

 	while m2, 	
		l1=list('Depassement',rr(1),['Sans','Avec']); 	
		l2=list('Nombre de voitures',rr(2),string(lisn));  
		l3=list('Vitesse',rr(3),string(lisv)); 	
		l4=list('Epaisseur',rr(4),string(lisd)); 	
		l5=list('Lambda',rr(5),string(lisl)); 	
		l6=list('Temps',rr(6),string(listemp)); 	
		rep=x_choices('Parametres de la simulation',list(l1,l2,l3,l4,l5,l6)); 
	  	if rep==[] then m2=%F;	cfenetre(1);cfenetre(2);cfenetre(3);
	 		else 	 
			rr=rep;	v1=0; 		
			lisdep=[0,1];dep=lisdep(rep(1));  	
			n=lisn(rep(2)); v2=lisv(rep(3)); 
			del=lisd(rep(4)); lam1=lisl(rep(5)); 
			tmax=listemp(rep(6)); k=ceil(1/(v2-v1)); 		
			depa="avec";ccc=2;
			if dep==0 then depa="sans";ccc=1;end;

			fenetre(fen1);isoview(0,1,0,1);
			// xbasc();
			xset('use color',1);  		
			xset("font",5,6); xset("pattern",10); 		
			xstring(0,1,"Simulation "+depa+" depassement"); 
			xset("font",2,4); xset("pattern",10);		
			xstring(0,.8,"Nombre de voitures : "+string(n)+...
		 	"         Epaisseur: "+string(del)); 		
			xstring(0,.7,"v1="+string(v1)+"   v2="+string(v2)+...  
			"    lambda ="+string(lam1)); 		
			xstring(0,.6,"Nombre de bouchons attendus : "+string(k*ccc));  
			vmedia=bouchonvm(n,ccc*k,lam1)*v2 ;
			vmediac=bouchonvm(n,ccc*k,lam1)*(v2-(k*v2-1)/k);
			xstring(0,.5,"Vitesse moyenne : "+string(vmedia));  
			xstring(0,.4,"Vitesse moyenne...
			 corrigee : "+string(vmediac));   
		 	xrects([.09,.31,.22,.22;.49,.31,.22,.22]',[10,10]);  	
			xrects([.1,.3,.2,.2;.5,.3,.2,.2]',[12,12]); 
		        xset("pattern",11); xstring(0.1,.2," Done ");
   			xstring(0.5,.2," Start ");

			sigo=%T;
			while sigo;
				[c1,c2,c3]=xclick();
				if c1==0,
					if max(abs(c2-.2),abs(c3-.2))<.1 then sigo=%F; 				
					elseif max(abs(c2-.6),abs(c3-.2))<.1 ,
						[R,V]=simu(n,dep,del); 
		   	 	 		xset("window",1);
				  	end;  
				end;
			end;
		end;
	end;
end;
endfunction
