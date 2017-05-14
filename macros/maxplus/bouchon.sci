
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
