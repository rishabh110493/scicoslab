function [f,F,ta,ben]=ODSD(net,itemax,eps,eps2,eps3)
  [lhs,rhs]=argn(0)
  // itemax is the max number of global loops
  // = max number of routes generated for each OD pair

  if rhs<2, itemax=10; end
  if rhs<3, eps=1e-5; end
  if rhs<4, eps2=eps/10; end
  if rhs<5, eps3=eps2/10; end
  eps3=max(eps3,1e-15);

  itemax1=10
  itemax2=100
  mode(-1)
  timer();

  // net -> data
  tl=net.links.tail;
  hl=net.links.head;
  td=net.demands.tail ;
  hd=net.demands.head    ;
  dd=net.demands.demand   ;
  t0=net.links.lpf_data(1,:);
  nn=net.gp.node_number    ;
  na=net.gp.link_number   ;
  nd=net.gp.demand_number  ;
  lpp=net.links.lpf_data;
  nf=net.gp.lpf_model;

  // Simplification of the OD list
  [ls,lor,nor]=simplify(td,nn); 
  origins=ls(1:nor);
  ls=[];l2=[];

  // Shortest path tree determination
  [u,pi,ni]=FBPV(tl,hl,t0,nn,origins); 
  dnof=find(pi(hd+nn*(lor-1))==0);
  if dnof<>[] then 
    disp('There are non feasible OD pairs:');disp([td(dnof)' hd(dnof)']);
    disp('They are ignored in the assignment.');
  end;
  u=[];ni=[];
  selva=pi(1:$);                    
  mapa=[1:nn:1+nor*(nn-1);0*(1:nor)];      //Sumar nor*2
  rutas=[lor;0*lor];              //Sumar nd*3
  rutasOD=1:nd;
  lamda=0*lor+1;

  X(1)=nn*nor+1;
  X(2)=nor+1;
  X(3)=nd+1;

  // Flux computation
  F=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva);

  [ta,dta,cta]=lpf(F,lpp,nf);
  step=1;
  ben=[];
  /// Addition of new routes
  errorel=1;
  temp=0;scta=0;sctaold=1;
  mprintf("|===========================================================|\n");
  mprintf("|   Time  |      Cost    | Mem. used  | # routes |   Error  |\n");
  mprintf("|---------+--------------+------------+----------+----------|\n");
  lamd=1;
  rk=1
  mu=0
  sctaold=0
  scta=sum(cta)
  while errorel>eps & step<itemax,
    temp=temp+timer()
    sz=stacksize();
    if MSDOS,
      mprintf("| %7.2f | %6.5e |   %2.1e | %8d | %2.1e |\n",temp,scta,sz(2),X(3)-1,errorel);
    else
      mprintf("| %7.2f | %7.6e |   %3.2e | %8d | %3.2e |\n",temp,scta,sz(2),X(3)-1,errorel)
    end
    [u,pi,ni]=FBPV(tl,hl,ta,nn,origins);
    selva=[selva; pi(1:$)];
    mapa(2,X(2)-nor:X(2)-1)=X(2)+(0:nor-1);
    mapa=[mapa [X(1):nn:X(1)+nor*(nn-1);0*(1:nor)]];
    rutas(2,X(3)-nd:X(3)-1)=X(3)+(0:nd-1);
    rutas=[rutas [X(2)+lor-1 ;0*(1:nd)]];
    rutasOD=[rutasOD 1:nd];
    lamda=[lamda, zeros(1,nd)];
    X(1)=X(1)+nn*nor;
    X(2)=X(2)+nor;
    X(3)=X(3)+nd;
    nr=X(3)-1;

    //* Reoptimizacion del lamda */
    [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
    mu=lamda;
    lh=1;
    iter=0;
    lamd=QKSP(apq,bpq,mu,nd,step+1,rutas);
    rk=lamd-mu;

    while norm(rk)>eps3 & iter<itemax & norm(lh)>eps3;
      Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu,mapa,selva);
      [ta,dta,cta]=lpf(Fh,lpp,nf);
      [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
      gl=apq*rk';
      if gl>=-eps2
	lh=0;
      else
	ind2=find(rk<-eps3);
	if ind2==[]   // lmax no acotado a priori
	  // disp('No acotado');
	  lmax=.1
	  iten=0
	  while gl<eps2 & iten<itemax1 & 1/lmax<eps3
	    lmax=10*lmax;
	    Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lmax*rk,mapa,selva);
	    [ta,dta,cta]=lpf(Fh,lpp,nf);
	    [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
	    gl=apq*rk';
	    iten=iten+1
	  end
	else
	  lmax=min(-mu(ind2)./rk(ind2));
	end
	if lmax>0,
	  lh=lmax;lo=0;
	  Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lh*rk,mapa,selva);
	  [ta,dta,cta]=lpf(Fh,lpp,nf);
	  [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
	  glv=gl
	  gl=apq*rk'
	  iten=0
	  while abs(gl-glv)>eps2 & iten<itemax2
	    lo2=lh
	    lh=max(0,min(lmax,lh-gl*(lh-lo)/(gl-glv)))
	    Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lh*rk,mapa,selva);
	    [ta,dta,cta]=lpf(Fh,lpp,nf);
	    [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
	    glv=gl
	    gl=apq*rk'
	    lo=lo2
	    iten=iten+1
	  end
	end
      end
      mu=mu+lh*rk;
      iter=iter+1
      F=Fh;
      lamd=QKSP(apq,bpq,mu,nd,step+1,rutas);
      rk=lamd-mu;
    end
    lamda=mu
    sctaold=scta
    scta=sum(cta)
    bench=[temp;scta;errorel ]
    ben=[ben bench]
    step=step+1
    if scta>0
      errorel=abs(sctaold-scta)/scta;
    else
      errorel=0
    end
  end
  temp=temp+timer()
  sz=stacksize();
  if MSDOS,
    mprintf("| %7.2f | %6.5e |   %2.1e | %8d | %2.1e |\n",temp,scta,sz(2),X(3)-1,errorel);
  else
    mprintf("| %7.2f | %7.6e |   %3.2e | %8d | %3.2e |\n",temp,scta,sz(2),X(3)-1,errorel);
  end
  mprintf("|===========================================================|\n");
  [f,F]=Flujo(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva)
endfunction 

//////////////////////////////////////////////////////
///      dsd  (No show version of DSD)            ////
//////////////////////////////////////////////////////



function [F,ta,f]=dsd(net,itemax,eps,eps2,eps3)
  [lhs,rhs]=argn(0)

  if rhs<2, itemax=10; end
  if rhs<3, eps=1e-5; end
  if rhs<4, eps2=eps/10; end
  if rhs<5, eps3=eps2/10; end
  eps3=max(eps3,1e-15);

  itemax1=10
  itemax2=100
  mode(-1)

  // net -> data
  tl=net.links.tail;
  hl=net.links.head;
  td=net.demands.tail ;
  hd=net.demands.head    ;
  dd=net.demands.demand   ;
  t0=net.links.lpf_data(1,:);
  nn=net.gp.node_number    ;
  na=net.gp.link_number   ;
  nd=net.gp.demand_number  ;
  lpp=net.links.lpf_data;
  nf=net.gp.lpf_model;

  // Simplification of the OD list
  [ls,lor,nor]=simplify(td,nn);
  origins=ls(1:nor);
  ls=[];l2=[];

  // Shortest path tree determination
  [u,pi,ni]=FBPV(tl,hl,t0,nn,origins);
  u=[];ni=[];
  selva=pi(1:$);
  mapa=[1:nn:1+nor*(nn-1);0*(1:nor)];      //Sumar nor*2
  rutas=[lor;0*lor];              //Sumar nd*3
  rutasOD=1:nd;
  lamda=0*lor+1;

  X(1)=nn*nor+1;
  X(2)=nor+1;
  X(3)=nd+1;

  // Flux computation
  F=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva);

  [ta,dta,cta]=lpf(F,lpp,nf);
  step=1;
  ben=[];
  /// Addition of new routes
  errorel=1;
  scta=0;sctaold=1;
  lamd=1;
  rk=1
  mu=0
  sctaold=0
  scta=sum(cta)
  while errorel>eps & step<itemax,

    [u,pi,ni]=FBPV(tl,hl,ta,nn,origins);
    selva=[selva; pi(1:$)];
    mapa(2,X(2)-nor:X(2)-1)=X(2)+(0:nor-1);
    mapa=[mapa [X(1):nn:X(1)+nor*(nn-1);0*(1:nor)]];
    rutas(2,X(3)-nd:X(3)-1)=X(3)+(0:nd-1);
    rutas=[rutas [X(2)+lor-1 ;0*(1:nd)]];
    rutasOD=[rutasOD 1:nd];
    lamda=[lamda, zeros(1,nd)];
    X(1)=X(1)+nn*nor;
    X(2)=X(2)+nor;
    X(3)=X(3)+nd;
    nr=X(3)-1;

    //* Reoptimizacion del lamda */
    [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
    mu=lamda;
    lh=1;
    iter=0;
    lamd=QKSP(apq,bpq,mu,nd,step+1,rutas);
    rk=lamd-mu;

    while norm(rk)>eps3 & iter<itemax & norm(lh)>eps3;
      Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu,mapa,selva);
      [ta,dta,cta]=lpf(Fh,lpp,nf);
      [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
      gl=apq*rk';
      if gl>=-eps2
	lh=0;
      else
	ind2=find(rk<-eps3);
	if ind2==[]   // lmax no acotado a priori
	  // disp('No acotado');
	  lmax=.1
	  iten=0
	  while gl<eps2 & iten<itemax1 & 1/lmax<eps3
	    lmax=10*lmax;
	    Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lmax*rk,mapa,selva);
	    [ta,dta,cta]=lpf(Fh,lpp,nf);
	    [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
	    gl=apq*rk';
	    iten=iten+1
	  end
	else
	  lmax=min(-mu(ind2)./rk(ind2));
	end
	if lmax>0,
	  lh=lmax;lo=0;
	  Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lh*rk,mapa,selva);
	  [ta,dta,cta]=lpf(Fh,lpp,nf);
	  [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
	  glv=gl
	  gl=apq*rk'
	  iten=0
	  while abs(gl-glv)>eps2 & iten<itemax2
	    lo2=lh
	    lh=max(0,min(lmax,lh-gl*(lh-lo)/(gl-glv)))
	    Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lh*rk,mapa,selva);
	    [ta,dta,cta]=lpf(Fh,lpp,nf);
	    [apq,bpq]=Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD);
	    glv=gl
	    gl=apq*rk'
	    lo=lo2
	    iten=iten+1
	  end
	end
      end
      mu=mu+lh*rk;
      iter=iter+1
      F=Fh;
      lamd=QKSP(apq,bpq,mu,nd,step+1,rutas);
      rk=lamd-mu;
    end
    lamda=mu
    sctaold=scta
    scta=sum(cta)
    step=step+1
    if scta>0
      errorel=abs(sctaold-scta)/scta;
    else
      errorel=0
    end
  end
  if lhs==3,
    [f,F]=Flujo(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva)
  else
    F=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva)
  end
endfunction 








