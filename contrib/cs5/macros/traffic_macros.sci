//////////////////////////////////////////////////////////////
//////     Link Perfomance function  ///////////////////////
//////////////////////////////////////////////////////////////

function [c,dc,ic]=lpf(F,lpp,nf)
// F=total flow on each arc
// na=number of arcs
// lpp=link perfomance parameters (na x 4 matrix)
// nf= travel time formula used
  fF=full(F)
  t0=lpp(1,:)
  ca=lpp(2,:)
  ma=lpp(3,:)
  ba=lpp(4,:)
  select nf
   case 0,	
    ic=t0.*fF+(ma/2)./ca.*(fF).^2+ma./(ba+1).*(max(0,fF-ca)).^(ba+1)
    c=t0+ma./ca.*fF+ma.*(max(0,fF-ca)).^ba
    dc=ma./ca+ma.*ba.*max(0,(fF-ca).^(ba-1))
   case 1,	
    ic=ca.*t0.*exp(fF./ca-1)
    c=t0.*exp(fF./ca-1)
    dc=t0.*exp(fF./ca-1)./ca
   case 2,	
    ic=t0.*2.^(fF./ca-1).*ca/log(2)
    c=t0.*2.^(fF./ca-1)
    dc=t0.*2.^(fF./ca-1)./ca*log(2)
   case 3,
    ic=t0.*(fF+0.15*((fF./ca).^(ma+1)).*ca./(ma+1))
    c=t0.*(1+0.15*(fF./ca).^ma)
    dc=t0.*(0.15*(fF./ca).^(ma-1)).*ma./ca
   case 4,
    ic=(t0+log(ca)).*fF+(ca-fF).*(log(ca-fF)-1)
    c=t0+log(ca)-log(ca-fF)
    dc=(ca-fF).^(-1)
   case 5,
    ic=ba.*fF-ca.*(t0-ba).*log(fF-ca)
    c=ba-ca.*(t0-ba)./(fF-ca)
    dc=ca.*(t0-ba)./((fF-ca).^2)
   case 6,
    ic=t0.*fF+(ca/2).*(fF).^2+ma./(ba+1).*fF.^(ba+1)
    c=t0+ca.*fF+ma.*fF.^ba
    dc=ca+ma.*ba.*fF.^(ba-1)
  else
    disp("error in lpf"),
  end
endfunction

function aa=dlpf(ini,inc,fin,lpp,nf)
// Grafica la lpf  para f variando entre ini y fin
// nf= numero de formula para lpf
  aa=[];bb=[];cc=[]
  na=size(lpp,2)
  for j=ini:inc:fin,
    [a,b,c]=lpf(ones(1,na)*j,lpp,nf)
    aa=[aa;a]
    bb=[bb;b]
    cc=[cc;c]
  end
  xset("window",1)
  xbasc()
  plot2d((ini:inc:fin)'*ones(1,na),aa)
  xtitle("Link Perfomance Functions")
  xset("window",2)
  xbasc()
  plot2d((ini:inc:fin)'*ones(1,na),bb)
  xtitle("Derivate of the Link Perfomance Functions")
  xset("window",3)
  xbasc()
  plot2d((ini:inc:fin)'*ones(1,na),cc)
  xtitle("Integral of the Link Perfomance Functions")
  //xset("window",4)
  //xbasc()
  //plot2d((ini:inc:fin)'*ones(1,3*na),[aa,bb,cc])
  //xtitle("All together")
endfunction

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
////////    Traffic Assignment algorithms            /////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////
//////     All or Nothing      ///////////////////////////////
//////////////////////////////////////////////////////////////

function [F]=aon(tl,hl,t0,nn,origins,td,hd,dd)
  [narg1,narg]=argn(0)
  if narg<=2,
    net=tl
    if narg==2,
      t0=hl;
    else
      t0=net.links.lpf_data(1,:);
    end
    tl=net.links.tail;
    hl=net.links.head;
    td=net.demands.tail ;
    hd=net.demands.head    ;
    dd=net.demands.demand   ;
    nn=net.gp.node_number    ;
    na=net.gp.link_number   ;
    nd=net.gp.demand_number  ;
    lpp=net.links.lpf_data;
    nf=net.gp.lpf_model;
  else
    na=size(tl,'*');
    nd=size(td,'*');
  end
  
  // Simplification of the OD list
  [lss,lor,nor]=simplify(td,nn); 
  origins=lss(1:nor);
  lss=[];l2=[];

  // Shortest path tree determination
  [u,pi,ni]=FBPV(tl,hl,t0,nn,origins); 
  u=[];ni=[];
  selva=pi(1:$);                    
  mapa=[1:nn:1+nor*(nn-1);0*(1:nor)];//Sumar nor*2
  rutas=[lor;0*lor];//Sumar nd*3
  rutasOD=1:nd;
  lamda=0*lor+1;
  // Flux computation
  F=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva);
endfunction

function [F,f]=aond(tl,hl,t0,nn,origins,td,hd,dd)
  [narg1,narg]=argn(0)
  if narg<=2,
    net=tl
    if narg==2,
      t0=hl;
    else
      t0=net.links.lpf_data(1,:);
    end 
    tl=net.links.tail;
    hl=net.links.head;
    td=net.demands.tail ;
    hd=net.demands.head    ;
    dd=net.demands.demand   ;
    nn=net.gp.node_number    ;
    na=net.gp.link_number   ;
    nd=net.gp.demand_number  ;
    lpp=net.links.lpf_data;
    nf=net.gp.lpf_model;

  else
    na=size(tl,'*');
    nd=size(td,'*');
  end
  // Simplification of the OD list
  [lss,lor,nor]=simplify(td,nn);
  origins=lss(1:nor);
  lss=[];l2=[];
  
  // Shortest path tree determination
  [u,pi,ni]=FBPV(tl,hl,t0,nn,origins); 
  u=[];ni=[];
  selva=pi(1:$);                    
  mapa=[1:nn:1+nor*(nn-1);0*(1:nor)];//Sumar nor*2
  rutas=[lor;0*lor];//Sumar nd*3
  rutasOD=1:nd;
  lamda=0*lor+1;
  // Flux computation
  [f,F]=Flujo(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva);
endfunction


function [F]=AON(tl,hl,t0,nn,origins,td,hd,dd)
  [narg1,narg]=argn(0)
  if narg<=2,
    net=tl
    if narg==2,
      t0=hl;
    else
      t0=net.links.lpf_data(1,:);
    end
    tl=net.links.tail;
    hl=net.links.head;
    td=net.demands.tail ;
    hd=net.demands.head    ;
    dd=net.demands.demand   ;
    nn=net.gp.node_number    ;
    na=net.gp.link_number   ;
    nd=net.gp.demand_number  ;
    lpp=net.links.lpf_data;
    nf=net.gp.lpf_model;
  else
    na=size(tl,'*');
    nd=size(td,'*');
  end

  // Simplification of the OD list
  [lss,lor,nor]=simplify(td,nn);
  origins=lss(1:nor);
  lss=[];l2=[];

  // Shortest path tree determination
  [u,pi,ni]=FBPV(tl,hl,t0,nn,origins);
  dnof=find(pi(hd+nn*(lor-1))==0);
  if dnof<>[] then
    disp('There are non feasible OD pairs:');disp([td(dnof)' hd(dnof)']);
    disp('They are ignored in the assignment.');
  end;

  u=[];ni=[];
  selva=pi(1:$);
  mapa=[1:nn:1+nor*(nn-1);0*(1:nor)];//Sumar nor*2
  rutas=[lor;0*lor];//Sumar nd*3
  rutasOD=1:nd;
  lamda=0*lor+1;
  // Flux computation
  [F]=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva);
endfunction

function [F,f]=AONd(tl,hl,t0,nn,origins,td,hd,dd)
  [narg1,narg]=argn(0)
  if narg<=2,
    net=tl
    if narg==2,
      t0=hl;
    else
      t0=net.links.lpf_data(1,:);
    end
    tl=net.links.tail;
    hl=net.links.head;
    td=net.demands.tail ;
    hd=net.demands.head    ;
    dd=net.demands.demand   ;
    nn=net.gp.node_number    ;
    na=net.gp.link_number   ;
    nd=net.gp.demand_number  ;
    lpp=net.links.lpf_data;
    nf=net.gp.lpf_model;

  else
    na=size(tl,'*');
    nd=size(td,'*');
  end
  // Simplification of the OD list
  [lss,lor,nor]=simplify(td,nn);
  origins=lss(1:nor);
  lss=[];l2=[];

  // Shortest path tree determination
  [u,pi,ni]=FBPV(tl,hl,t0,nn,origins);
  dnof=find(pi(hd+nn*(lor-1))==0);
  if dnof<>[] then
    disp('There are non feasible OD pairs:');disp([td(dnof)' hd(dnof)']);
    disp('They are ignored in the assignment.');
  end;
  u=[];ni=[];
  selva=pi(1:$);
  mapa=[1:nn:1+nor*(nn-1);0*(1:nor)];//Sumar nor*2
  rutas=[lor;0*lor];//Sumar nd*3
  rutasOD=1:nd;
  lamda=0*lor+1;
  // Flux computation
  [f,F]=Flujo(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva);
endfunction

//////////////////////////////////////////////////////////////
//////     Iterated All or Nothing     ///////////////////////
//////////////////////////////////////////////////////////////

function [f,ta,ben]=IAON(net,kmax)
  [narg1,narg]=argn(0)
  if narg<2, kmax=20,end
  minerr=0.001
  timer()
  sz=stacksize()
  %STACKSIZEREF=sz(2)
  temp=0
  ben=[]
  // Step 0
  nn=net.gp.node_number
  na=net.gp.link_number
  nd=net.gp.demand_number
  lpp=net.links.lpf_data 
  nf=net.gp.lpf_model;
  ta=lpf(0,lpp,nf)
  F=AON(net,ta)
  k=0
  while k<kmax,
    tv=ta
    [ta,dtn,ctn]=lpf(F,lpp,nf)
    F=aon(net,ta)
    k=k+1
    errr=norm(ta-tv)
    sz=stacksize()
    temp=temp+timer()
    ben=[ben ; [k, temp, sum(ctn),sz(2)-%STACKSIZEREF,errr]]
    if (errr<minerr),
      k=kmax 
    end
  end
  [F,f]=aond(net,ta)
endfunction



//////////////////////////////////////////////////////////////
//////  CAPRES algorithm     /////////////////////////////////
//////////////////////////////////////////////////////////////


function [f,ta]=CAPRES(net)
  kmax=4
  // Step 0
  lpp=net.links.lpf_data 
  nf=net.gp.lpf_model;
  [t0,dt0,c0]=lpf(0,lpp,nf)
  [F,f]=AONd(net,t0)
  Y=F
  y=f
  k=0
  terminate=%F

  while k<kmax
    // Step 1
    V=(1-1/kmax)*F+(1/kmax)*Y
    [ta,dta,cta]=lpf(V,lpp,nf)
    [Y,y]=aond(net,ta)
    F=(1-1/kmax)*F+(1/kmax)*Y
    f=(1-1/kmax)*f+(1/kmax)*y
    k=k+1
  end
endfunction



//////////////////////////////////////////////////////////////
//////  Incremental Assignment algorithm   ///////////////////
//////////////////////////////////////////////////////////////


function [f,ta]=IA(net,K)
  kmax=K
  alfa=1/K
  // Step 0
  lpp=net.links.lpf_data
  nf=net.gp.lpf_model;
  [t0,dt0,c0]=lpf(0,lpp,nf)
  [Y,y]=AONd(net,t0)
  F=alfa*Y
  f=alfa*y
  k=1
  while k<K
    // Step 1
    [ta,dtt,ctt]=lpf(F,lpp,nf)
    [Y,y]=aond(net,ta)
    // Step 2
    F=F+alfa*Y
    f=f+alfa*y

    k=k+1
    // Step 3
  end
  [ta,dtt,ctt]=lpf(F,lpp,nf)
endfunction

//////////////////////////////////////////////////////////////
//////  MSA algorithm                 ////////////////////////
//////////////////////////////////////////////////////////////
function [F,ta,ben]=MSA(net,kmax,tol)
  [narg1,narg]=argn(0)

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

  if narg<3, tol=1e-6,end
  if narg<2, kmax=20,end

  %VERBOSE=net.gp.verbose
  ben=[]
  stz=stacksize();
  %STACKSIZEREF=stz(2);

  // Step 0

  [ta,dta,ca]=lpf(zeros(1,na),lpp,nf)
  temp=0
  timer()
  Ca=sum(ca)
  [lss,lor,nor]=simplify(td,nn);
  origins=lss(1:nor);
  [F]=AON(tl,hl,t0,nn,origins,td,hd,dd)


  k=1

  if %VERBOSE then
    mprintf("  \n")
    mprintf("==========================\n")
    mprintf("PAL     /Q/%3d/%3d/%4d/\n",nn,na,nd)
    mprintf("==========================\n")
    mprintf("  \n")
    mprintf("|================================================================|\n")
    mprintf("| Step  |   Time   |       Cost      |  Mem. used  | Rel.Gap     |\n")
    mprintf("|-------+----------+-----------------+-------------+-------------|\n")
  end


  Rerror=1,Relgap=1e10,LBD=1;
  ben=[];

  while k<kmax & Relgap>tol
    // Step 1
    [ta,dta,ca]=lpf(F,lpp,nf)
    Ca=sum(ca)   //T(Fk)
    temp=temp+timer();
    stz=stacksize()
    sz=stz(2)-%STACKSIZEREF;
    bench=[k,temp,Ca,sz,Relgap]
    ben=[ben;bench]

    if %VERBOSE then
      if kmax>1000,
	if modulo(k,100)==0,
	  if MSDOS,
	    mprintf("|  %3d  |  %7.2f | % 10.7e |  %4.3e |  %4.3e |\n",k,temp,Ca,sz,Relgap)
	  else
	    mprintf("|  %3d  |  %7.2f | % 11.8e |  %5.4e |  %5.4e |\n",k,temp,Ca,sz,Relgap)
	  end
	end
      else
	if MSDOS,
	  mprintf("|  %3d  |  %7.2f | % 10.7e |  %4.3e |  %4.3e |\n",k,temp,Ca,sz,Relgap)
	else
	  mprintf("|  %3d  |  %7.2f | % 11.8e |  %5.4e |  %5.4e |\n",k,temp,Ca,sz,Relgap)
	end
      end
    end


    // Step 1
    [Y]=aon(tl,hl,ta,nn,origins,td,hd,dd)
    LBD=max(LBD,Ca+ta*(Y-F)')
    // Step 2
    ln=1/(k+1)
    // Step 3

    F=(1-ln)*F+ln*Y
    k=k+1
    Relgap=2*abs(Ca-LBD)/(LBD+Ca)
  end
  
  [ta,dta,ca]=lpf(F,lpp,nf)
  Ca=sum(ca)   //T(Fk)
  temp=temp+timer();
  stz=stacksize()
  sz=stz(2)-%STACKSIZEREF;
  bench=[k,temp,Ca,sz,Relgap]
  ben=[ben;bench]

  if %VERBOSE then
    mprintf("--------+----------+-----------------+-------------+-------------+\n")
  end
endfunction




//////////////////////////////////////////////////////////////
//////  Probit-based  algorithm       ////////////////////////
//////////////////////////////////////////////////////////////


function [f,s]=Probit(net,ta,beta,accuracy,kmax)
  [narg1,narg]=argn(0)
  /// The travel time is stochastic but flow independet
  if narg<5, kmax=20,end
  if narg<4, accuracy=1e-3,end
  if narg<3, beta=1,end
  lpp=net.links.lpf_data
  if narg<2, 
    if net.links.time==[], 
      ta=lpp(1,:)
    else
      ta=net.links.time
    end
  end
  // Step 0
  Ta=max(0,rand(ta,'normal').*(beta*ta)+ta)
  [Y,y]=AONd(net,Ta)
  f=y;F=Y
  k=2
  YY=[Y]
  while k<kmax
    // Step 1
    Ta=max(0,rand(ta,'normal').*(beta*ta)+ta)
    // Step 2
    [Y,y]=aond(net,Ta)
    YY=[YY;Y]
    // Step 3
    f=((k-1)*f+y)/k
    F=sum(f,'r')
    // Step 4
    s=max((sum((YY-F.*.ones(k,1)).^2,'r')/(k*(k-1))).^1/2)
    if s<= accuracy
      k=kmax 
    end
    k=k+1	
  end
endfunction

//////////////////////////////////////////////////////////////
//////  MSA algorithm for SUE                ////////////////////////
//////////////////////////////////////////////////////////////


function [f,ta,ben]=MSASUE(net,beta,kmax,tol)
  [narg1,narg]=argn(0)
  ben=[]
  sz=stacksize()
  %STACKSIZEREF=sz(2)
  temp=0
  if narg<4, tol=1e-3,end
  if narg<3, kmax=10,end
  if narg<2, beta=1, end
  lpp=net.links.lpf_data 
  nf=net.gp.lpf_model
  // Step 0
  f=Probit(net,lpf(0,lpp,nf),beta,tol,kmax)
  F=sum(f,'r')
  itemax=20
  k=1
  ta=0
  while k<kmax
    // Step 1
    y=Probit(net,lpf(F,lpp,nf),beta,tol,kmax)
    // Step 2
    ln=1/k
    // Step 3
    f=(1-ln)*f+ln*y
    F=sum(f,'r')
    k=k+1	
    tv=ta
    [ta,dta,cta]=lpf(F,lpp,nf)
    // Step 3
    if (norm(ta-tv)<tol),
      k=kmax 
    end
    temp=temp+timer()
    ben=[ben ;[k,temp, sum(cta),sz(2)-%STACKSIZEREF,norm(f-y)/k]]
  end
endfunction

//////////////////////////////////////////////////////////////
//////  Frank-Wolfe algorithm         ////////////////////////
//////////////////////////////////////////////////////////////


function [F,ta,ben]=FW(net,kmax,tol)
  [narg1,narg]=argn(0)
  sz=stacksize()
  %STACKSIZEREF=sz(2)
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
  %VERBOSE=net.gp.verbose;

  if narg<3, tol=1e-16,end
  if narg<2, kmax=20,end


  // Step 0

  [ta,dta,ca]=lpf(zeros(1,na),lpp,nf)
  timer()
  temp=0
  Ca=sum(ca)
  ben=[]
  [lss,lor,nor]=simplify(td,nn);
  origins=lss(1:nor);
  //destinos=l2(1:nor);
  [F]=AON(tl,hl,t0,nn,origins,td,hd,dd)
  itemax=20
  k=1
  terminate=%F
  Cv=Ca
  if %VERBOSE then
    mprintf("  \n")
    mprintf("------------------------------------------------------------\n")
    mprintf("|  Step | Time   |  Cost        |  Rel. error |  Rel. gap  |\n")
    mprintf("--------+--------+--------------+-------------+-------------\n")
  end
  Rerror=1;Relgap=1e10;LBD=1;ben=[];
  //while (k<kmax) & (Rerror>tol)


  while (k<kmax) & (Relgap>tol)
    // Step 1
    [ta,dta,ca]=lpf(F,lpp,nf)
    Ca=sum(ca)   //T(Fk)
    temp=temp+timer();
    //	bench=[temp;Ca]
    stz=stacksize()
    sz=stz(2)-%STACKSIZEREF;
    bench=[k,temp,Ca,sz,Relgap]
    ben=[ben;bench]
    if %VERBOSE then
      if kmax>1000,
	if modulo(k,100)==0,
	  if MSDOS,
	    mprintf("|  %3d  |  %5.2f | % 11.4e |  %5.3e | %5.3e |\n",k,temp,Ca,Rerror,Relgap)
	  else
	    mprintf("|  %3d  |  %5.2f | % 12.5e |  %6.4e | %6.4e |\n",k,temp,Ca,Rerror,Relgap)
	  end
	end
      else
	if MSDOS,
	  mprintf("|  %3d  |  %5.2f | % 11.4e |  %5.3e | %5.3e |\n",k,temp,Ca,Rerror,Relgap)
	else
	  mprintf("|  %3d  |  %5.2f | % 12.5e |  %6.4e | %6.4e |\n",k,temp,Ca,Rerror,Relgap)
	end
      end
    end

    [Y]=aon(tl,hl,ta,nn,origins,td,hd,dd)
    LBD=max(LBD,Ca+ta*(Y-F)') // Y is the minimum of the linear approx.
    // around F, so T(Fmin)>=T(Y)
    [ta,dta,ca]=lpf(Y,lpp,nf)
    Tmin=sum(ca)
    // Step 2
    // Search for lambda that minimizes the global cost
    l=0.5
    iter=1
    Fv=F
    Cvv=0
    while abs(Ca-Cvv)>tol & iter<=itemax
      Cvv=Ca
      [ta,dta,ca]=lpf((1-l)*F+l*Y,lpp,nf)

      Ca=sum(ca)

      Jp=ta*(Y-F)'
      Js=(Y-F)*diag(dta)*(Y-F)'
      if abs(Jp)>tol
	l=l-Jp/Js
      end
      if l<=0, l=0, end
      if l>=1, l=1, end
      iter=iter+1
    end
    // Step 3
    F=(1-l)*F+l*Y
    //	F=sum(f,'r')
    k=k+1
    //	LBD=max(LBD,Ca+ta*(Y-F)')
    Rerror=abs(Ca-Cv)/Ca
    Relgap=2*abs(Ca-LBD)/(LBD+Ca)
    Cv=Ca
  end

  [ta,dta,ca]=lpf(F,lpp,nf)
  Ca=sum(ca)   //T(Fk)
  temp=temp+timer();
  stz=stacksize()
  sz=stz(2)-%STACKSIZEREF;
  bench=[k,temp,Ca,sz,Relgap]
  ben=[ben;bench]


  if %VERBOSE then
    mprintf("------------------------------------------------------------\n")
  end
endfunction
//////////////////////////////////////////////////////////////
//////     Disaggregate simplicial decomposition      ////////
//////////////////////////////////////////////////////////////

//// Function add zeros up to nn
//   ===========================
function l=pz(ll,nn)
  ll=[ll zeros(1,nn)]
  l=ll(1:nn)
endfunction
//// Function take out zeros
//   =======================
function l=toz(ll)
  lz=find(ll<>0)
  l=ll(lz)
endfunction
//// Function DSD
//   ============
function [F,ta,ben,f] = DSD(net,routemax,nFW,eps,list_eps,list_itemax)
  [lhs,rhs] = argn(0)

  //    routemax :  maximun number of routes to be generated.
  //         nFW : the number of initial iterations itemax is
  //               the max number of global loops.
  //         eps : the succesive relative error.
  //    list_eps : the precision in the stopping tests for each of the 3 loops.
  // list_itemax : the maximum number of iterations in each of the 3 loops.

  if rhs < 2, routemax = 10 ; end
  if rhs < 3, nFW = 0 ; end
  if rhs < 4, eps = 1e-3 ; end
  if rhs < 5, list_eps = [1e-6,1e-7,1e-8] ; end
  if rhs < 6, list_itemax = [10,50,100] ; end
  if or(size(list_eps) <> [1,3]) |  or(size(list_itemax) <> [1,3])
    disp ("Syntax error in the list_eps or list_itemax parameters, see the help")
  end

  stz=stacksize();
  %STACKSIZEREF=stz(2);
  eps1 = list_eps(1) ; eps2 = list_eps(2) ; eps3 = list_eps(3)
  itemax1 = list_itemax(1) ; itemax2 = list_itemax(2) ; itemax3 = list_itemax(3)

  zero = 1e-15 ; mode(-1)
  temp = 0
  timer();
  //  ta : is the time in the arc a,
  //  ca : the cost, the integral of the time,
  // dta : its derivative.
  //  Ca : is sum(ca) the sum for all the arcs, that is Ca=T(f).
  //   F : is the vector of flows over the arcs (non disaggregated).

  // net -> data
  tl = net.links.tail
  hl = net.links.head
  td = net.demands.tail
  hd = net.demands.head
  dd = net.demands.demand
  t0 = net.links.lpf_data(1,:)
  nn = net.gp.node_number
  na = net.gp.link_number
  nd = net.gp.demand_number
  lpp = net.links.lpf_data
  nf = net.gp.lpf_model
  %VERBOSE=net.gp.verbose


  // Simplification of the OD list
  [lss,lor,nor]  =  simplify(td,nn)
  origins = lss(1:nor)

  // Shortest-paths tree determination
  [u,pi,ni] = FBPV(tl,hl,t0,nn,origins)
  dnof = find(pi(hd+nn*(lor-1)) == 0)
  if dnof <> [],
    disp('There are non feasible OD pairs:');disp([td(dnof)' hd(dnof)'])
    disp('They are ignored in the assignment.')
  end;
  selva = pi(1:$)
  mapa = [1:nn:1+nor*(nn-1);0*(1:nor)]
  rutas = [lor;0*lor]
  rutasOD = 1:nd
  lamda = 0*lor+1

  X(1) = nn*nor+1  ;  X(2) = nor+1  ;  X(3) = nd+1
  nr=X(3)-1 ; NGR = 1  // Number of gernerated columns for each commodity

  // Flux computation
  F = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva)
  [ta,dta,ca] = lpf(F,lpp,nf)
  step = 1  ;  ben = []  ;  Ca = sum(ca)

  Rerror = 1  ;  //temp = 0


  if %VERBOSE then
    if MSDOS,
      mprintf("\n|======================================================================================|\n")
      mprintf("| Step  |   Time  |      Cost        | Mem. used  | # routes | Rel. Error |  Rel. Gap  |\n")
      mprintf("|-------+---------+------------------+------------+----------+------------+------------|\n")
    else
      mprintf("\n|==================================================================================|\n")
      mprintf("| Step  |   Time  |      Cost       | Mem. used | # routes | Rel.Error | Rel.Gap   |\n")
      mprintf("|-------+---------+-----------------+-----------+----------+-----------+-----------|\n")
    end
  end

  //////////////////////
  // Frank-Wolfe part //
  //////////////////////

  itemax=120 ; k=0 ; terminate=%F ; Cv=Ca ; Rerror=1 ; Relgap=1e10;LBD=1 ;

  while (k < nFW) & (Relgap > eps) //& (Rerror>0.01*eps)
    [ta,dta,ca] = lpf(F,lpp,nf) ; Ca = sum(ca)   //T(Fk)
    temp = temp+timer() ;
    stz=stacksize()
    sz=stz(2)-%STACKSIZEREF;
    //bench = [temp;Ca;Relgap]
    bench=[step,temp,Ca,sz,Relgap]
    ben = [ben;bench] ;

    if (nFW < 10) | (k > 10*floor(nFW/10)) | ((nFW >= 10) & (modulo(k,10) == 0) ),
      if %VERBOSE then
	mprintf("|FW%3d  | %7.2f | %10.9e |   %2.1e | %8d | %4.3e | %4.3e |\n",k,temp,Ca,sz,X(3)-1,Rerror,Relgap)
      end
    end
    [u,pi,ni] = FBPV(tl,hl,ta,nn,origins)
    selva = [selva; pi(1:$)]
    mapa(2,X(2)-nor:X(2)-1) = X(2)+(0:nor-1)
    mapa = [mapa [X(1):nn:X(1)+nor*(nn-1);0*(1:nor)]]
    rutas(2,X(3)-nd:X(3)-1) = X(3)+(0:nd-1)
    rutas = [rutas [X(2)+lor-1 ;0*(1:nd)]]
    rutasOD = [rutasOD 1:nd];
    //  lamda=[lamda*0, zeros(1,nd)+1];
    X(1) = X(1)+nn*nor  ;  X(2) = X(2)+nor  ;  X(3) = X(3)+nd
    nr = X(3)-1  ;  NGR = NGR+1

    // Flux computation
    Y = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,[lamda*0 zeros(1,nd)+1],mapa,selva)
    LBD = max(LBD,Ca+ta*(Y-F)')

    // Y is the minimum of the linear approx. around F, so T(Fmin)>=T(Y)
    [ta,dta,ca] = lpf(Y,lpp,nf)

    // Search for lambda that minimizes the global cost
    l = 0.5  ;  iter = 1  ;  Fv = F  ;  Cvv = 0
    while (abs(Ca-Cvv) > eps *Ca) //& (iter <= itemax),
      Cvv = Ca
      [ta,dta,ca] = lpf((1-l)*F+l*Y,lpp,nf)
      Ca = sum(ca)
      Jp = ta*(Y-F)'
      Js = (Y-F)*diag(dta)*(Y-F)'
      if abs(Jp) > eps,
	l = l-Jp/Js;
      end
      l = max(min(1,l),0)
      iter = iter+1
    end
    // Step 3
    F = (1-l)*F+l*Y
    //	F=sum(f,'r')
    k = k+1
    //	LBD=max(LBD,Ca+ta*(Y-F)')
    Rerror = abs(Ca-Cv)/Ca
    Relgap = 2*abs(Ca-LBD)/(LBD+Ca)
    Cv = Ca
    lamda = [lamda*(1-l) zeros(1,nd)+l]
  end


  ////////////////
  //  DSD part  //
  ////////////////

  lamd = 1  ;  rk = 1  ;  mu = 0  ;  Cv = 0  ;  Fh=F
  if nFW == 0,
    [u,pi,ni] = FBPV(tl,hl,ta,nn,origins)
    selva = [selva; pi(1:$)]
    mapa(2,X(2)-nor:X(2)-1) = X(2)+(0:nor-1)
    mapa = [mapa [X(1):nn:X(1)+nor*(nn-1) ; 0*(1:nor)] ]
    rutas(2,X(3)-nd:X(3)-1) = X(3)+(0:nd-1)
    rutas = [rutas [X(2)+lor-1 ;0*(1:nd)]]
    rutasOD = [rutasOD 1:nd]
    Y = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,[0*lamda 1+zeros(1,nd)],mapa,selva)
    LBD = max(LBD,Ca+ta*(Y-F)')

    lamda = [lamda, zeros(1,nd)]
    X(1) = X(1)+nn*nor  ;  X(2) = X(2)+nor  ;  X(3) = X(3)+nd
    nr = X(3)-1  ;  NGR = NGR+1
    Relgap = 2*abs(Ca-LBD)/(LBD+Ca)
  end

  while (Relgap > eps) & (step < routemax-nFW) &(Rerror>(1e-6)*eps),
    temp=temp+timer()
    stz=stacksize()
    sz=stz(2)-%STACKSIZEREF;
    bench=[step,temp,Ca,sz,Relgap]
    ben = [ben; bench]//elina
    if %VERBOSE then
      mprintf("| %4d  | %7.2f | %10.9e |   %2.1e | %8d | %4.3e | %4.3e |\n",step,temp,Ca,sz,X(3)-1,Rerror,Relgap)
    end
    //* Reoptimizacion del lamda */
    [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
    mu = lamda  ;  lh = 1  ;  iter = 0
    lamd = QKSP(apq,bpq,mu,nd,NGR,rutas)
    rk = lamd-mu  ;  var = norm(rk)

    /// While Quasi Newton
    Cv2 = 0  ;  Ca2 = Ca
    //disp(max(abs(Ca-Cv),1))
    while abs(Ca2-Cv2) > eps1*max(abs(Ca-Cv),1) & iter < itemax1*step^3 & norm(rk)>eps3& norm(lh)>eps3//3
      //    Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu,mapa,selva);
      [ta,dta,ca] = lpf(Fh,lpp,nf)
      [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
      gl=apq*rk'
      if gl >= -zero,
	lh = 0
      else
	ind2 = find(rk < -zero)
	if ind2 == [],   // lmax no acotado a priori
	  lmax = 0.1
	  iten = 0
	  while (gl < eps2) & (iten < itemax2) & (1/lmax > eps2),
	    lmax = 10*lmax
	    Fh = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lmax*rk,mapa,selva)
	    [ta,dta,ca] = lpf(Fh,lpp,nf)
	    [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
	    gl = apq*rk'
	    iten = iten+1
	  end
	else
	  lmax = min(-mu(ind2)./rk(ind2))
	end
	if lmax > 0,
	  lh = lmax  ;  lhv = 0
	  Fh = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lh*rk,mapa,selva)
	  [ta,dta,ca] = lpf(Fh,lpp,nf)
	  [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
	  glv = gl  ; gl = apq*rk'
	  iten  =0
	  // while abs(gl-glv)/abs(glv)>eps3 & iten<itemax3
	  while ((lh-lhv) > eps3) & (iten < itemax3)
	    lh = max(0 , min(lmax , lh-gl*(lh-lhv)/(gl-glv)))
	    Fh = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lh*rk,mapa,selva)
	    [ta,dta,ca] = lpf(Fh,lpp,nf)
	    [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
	    glv = gl  ;  gl = apq*rk'
	    iten = iten+1
	    lhv = lh
	  end
	end
      end
      mu = mu+lh*rk
      var=norm(lh*rk)
      iter = iter+1
      F = Fh
      lamd = QKSP(apq,bpq,mu,nd,NGR,rutas)
      rk = lamd-mu
      Cv2=Ca2
      Ca2=sum(ca)
    end
    /// End While Quasi Newton
    lamda = mu
    Cv = Ca
    Ca = sum(ca)
    step = step+1
    if Ca > 0,
      Rerror = abs(Cv-Ca)/Ca
    else
      Rerror = 0
    end
    [u,pi,ni] = FBPV(tl,hl,ta,nn,origins)
    selva = [selva; pi(1:$)]
    mapa(2,X(2)-nor:X(2)-1) = X(2)+(0:nor-1)
    mapa = [mapa [X(1):nn:X(1)+nor*(nn-1) ; 0*(1:nor)] ]
    rutas(2,X(3)-nd:X(3)-1) = X(3)+(0:nd-1)
    rutas = [rutas [X(2)+lor-1 ;0*(1:nd)]]
    rutasOD = [rutasOD 1:nd]
    Y = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,[0*lamda 1+zeros(1,nd)],mapa,selva)
    LBD = max(LBD,Ca+ta*(Y-F)')
    //  disp(LBD)
    lamda = [lamda, zeros(1,nd)]
    X(1) = X(1)+nn*nor  ;  X(2) = X(2)+nor  ;  X(3) = X(3)+nd
    nr = X(3)-1  ;  NGR = NGR+1
    Relgap = 2*abs(Ca-LBD)/(LBD+Ca)
  end   /// End While route generation

  temp=temp+timer()
  stz=stacksize()
  sz=stz(2)-%STACKSIZEREF;

  if %VERBOSE then
    mprintf("| %4d  | %7.2f | %10.9e |   %2.1e | %8d | %4.3e | %4.3e |\n",step,temp,Ca,sz,X(3)-1,Rerror,Relgap)
  end

  bench=[step,temp,Ca,sz,Relgap]
  ben = [ben; bench]

  if %VERBOSE then
    if MSDOS,
      mprintf("|======================================================================================|\n")
    else
      mprintf("|==================================================================================|\n")
    end
  end


  if lhs > 2,
    [f,F]=Flujo(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva)
  else
    F=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva);
  end
endfunction



//////////////////////////////////////////////////////
///      dsd  (No show version of DSD)            ////
//////////////////////////////////////////////////////

function [F,ta,f] = dsd(net,routemax,nFW,eps,list_eps,list_itemax)
  [lhs,rhs] = argn(0)

  //    routemax :  maximun number of routes to be generated.
  //         nFW : the number of initial iterations itemax is
  //               the max number of global loops.
  //         eps : the succesive relative error.
  //    list_eps : the precision in the stopping tests for each of the 3 loops.
  // list_itemax : the maximum number of iterations in each of the 3 loops.

  if rhs < 2, routemax = 10 ; end
  if rhs < 3, nFW = 0 ; end
  if rhs < 4, eps = 1e-3 ; end
  if rhs < 5, list_eps = [1e-6,1e-7,1e-8] ; end
  if rhs < 6, list_itemax = [10,50,100] ; end
  if or(size(list_eps) <> [1,3]) |  or(size(list_itemax) <> [1,3])
    disp ("Syntax error in the list_eps or list_itemax parameters, see the help")
  end

  //stz=stacksize();
  //%STACKSIZEREF=stz(2);
  eps1 = list_eps(1) ; eps2 = list_eps(2) ; eps3 = list_eps(3)
  itemax1 = list_itemax(1) ; itemax2 = list_itemax(2) ; itemax3 = list_itemax(3)

  zero = 1e-15 ; mode(-1)
  //temp = 0
  //timer();
  //  ta : is the time in the arc a,
  //  ca : the cost, the integral of the time,
  // dta : its derivative.
  //  Ca : is sum(ca) the sum for all the arcs, that is Ca=T(f).
  //   F : is the vector of flows over the arcs (non disaggregated).

  // net -> data
  tl = net.links.tail
  hl = net.links.head
  td = net.demands.tail
  hd = net.demands.head
  dd = net.demands.demand
  t0 = net.links.lpf_data(1,:)
  nn = net.gp.node_number
  na = net.gp.link_number
  nd = net.gp.demand_number
  lpp = net.links.lpf_data
  nf = net.gp.lpf_model
  //%VERBOSE=%F

  // Simplification of the OD list
  [lss,lor,nor]  =  simplify(td,nn)
  origins = lss(1:nor)

  // Shortest-paths tree determination
  [u,pi,ni] = FBPV(tl,hl,t0,nn,origins)
  dnof = find(pi(hd+nn*(lor-1)) == 0)
  if dnof <> [],
    disp('There are non feasible OD pairs:');disp([td(dnof)' hd(dnof)'])
    disp('They are ignored in the assignment.')
  end;
  selva = pi(1:$)
  mapa = [1:nn:1+nor*(nn-1);0*(1:nor)]
  rutas = [lor;0*lor]
  rutasOD = 1:nd
  lamda = 0*lor+1

  X(1) = nn*nor+1  ;  X(2) = nor+1  ;  X(3) = nd+1
  nr=X(3)-1 ; NGR = 1  // Number of gernerated columns for each commodity

  // Flux computation
  F = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva)
  [ta,dta,ca] = lpf(F,lpp,nf)
  step = 1  ;  ben = []  ;  Ca = sum(ca)

  Rerror = 1  ;  //temp = 0

  //////////////////////
  // Frank-Wolfe part //
  //////////////////////

  itemax=120 ; k=0 ; terminate=%F ; Cv=Ca ; Rerror=1 ; Relgap=1e10;LBD=1 ;

  while (k < nFW) & (Relgap > eps) //& (Rerror>0.01*eps)
    [ta,dta,ca] = lpf(F,lpp,nf) ; Ca = sum(ca)   //T(Fk)

    [u,pi,ni] = FBPV(tl,hl,ta,nn,origins)
    selva = [selva; pi(1:$)]
    mapa(2,X(2)-nor:X(2)-1) = X(2)+(0:nor-1)
    mapa = [mapa [X(1):nn:X(1)+nor*(nn-1);0*(1:nor)]]
    rutas(2,X(3)-nd:X(3)-1) = X(3)+(0:nd-1)
    rutas = [rutas [X(2)+lor-1 ;0*(1:nd)]]
    rutasOD = [rutasOD 1:nd];
    //  lamda=[lamda*0, zeros(1,nd)+1];
    X(1) = X(1)+nn*nor  ;  X(2) = X(2)+nor  ;  X(3) = X(3)+nd
    nr = X(3)-1  ;  NGR = NGR+1

    // Flux computation
    Y = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,[lamda*0 zeros(1,nd)+1],mapa,selva)
    LBD = max(LBD,Ca+ta*(Y-F)')

    // Y is the minimum of the linear approx. around F, so T(Fmin)>=T(Y)
    [ta,dta,ca] = lpf(Y,lpp,nf)

    // Search for lambda that minimizes the global cost
    l = 0.5  ;  iter = 1  ;  Fv = F  ;  Cvv = 0
    while (abs(Ca-Cvv) > eps *Ca) //& (iter <= itemax),
      Cvv = Ca
      [ta,dta,ca] = lpf((1-l)*F+l*Y,lpp,nf)
      Ca = sum(ca)
      Jp = ta*(Y-F)'
      Js = (Y-F)*diag(dta)*(Y-F)'
      if abs(Jp) > eps,
	l = l-Jp/Js;
      end
      l = max(min(1,l),0)
      iter = iter+1
    end
    // Step 3
    F = (1-l)*F+l*Y
    //	F=sum(f,'r')
    k = k+1
    //	LBD=max(LBD,Ca+ta*(Y-F)')
    Rerror = abs(Ca-Cv)/Ca
    Relgap = 2*abs(Ca-LBD)/(LBD+Ca)
    Cv = Ca
    lamda = [lamda*(1-l) zeros(1,nd)+l]
  end


  ////////////////
  //  DSD part  //
  ////////////////

  lamd = 1  ;  rk = 1  ;  mu = 0  ;  Cv = 0  ;  Fh=F
  if nFW == 0,
    [u,pi,ni] = FBPV(tl,hl,ta,nn,origins)
    selva = [selva; pi(1:$)]
    mapa(2,X(2)-nor:X(2)-1) = X(2)+(0:nor-1)
    mapa = [mapa [X(1):nn:X(1)+nor*(nn-1) ; 0*(1:nor)] ]
    rutas(2,X(3)-nd:X(3)-1) = X(3)+(0:nd-1)
    rutas = [rutas [X(2)+lor-1 ;0*(1:nd)]]
    rutasOD = [rutasOD 1:nd]
    Y = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,[0*lamda 1+zeros(1,nd)],mapa,selva)
    LBD = max(LBD,Ca+ta*(Y-F)')

    lamda = [lamda, zeros(1,nd)]
    X(1) = X(1)+nn*nor  ;  X(2) = X(2)+nor  ;  X(3) = X(3)+nd
    nr = X(3)-1  ;  NGR = NGR+1
    Relgap = 2*abs(Ca-LBD)/(LBD+Ca)
  end

  while (Relgap > eps) & (step < routemax-nFW) &(Rerror>(1e-6)*eps),
    //* Reoptimizacion del lamda */
    [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
    mu = lamda  ;  lh = 1  ;  iter = 0
    lamd = QKSP(apq,bpq,mu,nd,NGR,rutas)
    rk = lamd-mu  ;  var = norm(rk)

    /// While Quasi Newton
    Cv2 = 0  ;  Ca2 = Ca
    while abs(Ca2-Cv2) > eps1*max(abs(Ca-Cv),1) & iter < itemax1*step^3 & norm(rk)>eps3& norm(lh)>eps3//3
      //    Fh=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu,mapa,selva);
      [ta,dta,ca] = lpf(Fh,lpp,nf)
      [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
      gl=apq*rk'
      if gl >= -zero,
	lh = 0
      else
	ind2 = find(rk < -zero)
	if ind2 == [],   // lmax no acotado a priori
	  lmax = 0.1
	  iten = 0
	  while (gl < eps2) & (iten < itemax2) & (1/lmax > eps2),
	    lmax = 10*lmax
	    Fh = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lmax*rk,mapa,selva)
	    [ta,dta,ca] = lpf(Fh,lpp,nf)
	    [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
	    gl = apq*rk'
	    iten = iten+1
	  end
	else
	  lmax = min(-mu(ind2)./rk(ind2))
	end
	if lmax > 0,
	  lh = lmax  ;  lhv = 0
	  Fh = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lh*rk,mapa,selva)
	  [ta,dta,ca] = lpf(Fh,lpp,nf)
	  [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
	  glv = gl  ; gl = apq*rk'
	  iten  =0
	  // while abs(gl-glv)/abs(glv)>eps3 & iten<itemax3
	  while ((lh-lhv) > eps3) & (iten < itemax3)
	    lh = max(0 , min(lmax , lh-gl*(lh-lhv)/(gl-glv)))
	    Fh = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,mu+lh*rk,mapa,selva)
	    [ta,dta,ca] = lpf(Fh,lpp,nf)
	    [apq,bpq] = Costo(tl,hd,dd,nr,na,ta,dta,rutas,mapa,selva,rutasOD)
	    glv = gl  ;  gl = apq*rk'
	    iten = iten+1
	    lhv = lh
	  end
	end
      end
      mu = mu+lh*rk
      var=norm(lh*rk)
      iter = iter+1
      F = Fh
      lamd = QKSP(apq,bpq,mu,nd,NGR,rutas)
      rk = lamd-mu
      Cv2=Ca2
      Ca2=sum(ca)
    end
    /// End While Quasi Newton
    lamda = mu
    Cv = Ca
    Ca = sum(ca)
    step = step+1
    if Ca > 0,
      Rerror = abs(Cv-Ca)/Ca
    else
      Rerror = 0
    end
    [u,pi,ni] = FBPV(tl,hl,ta,nn,origins)
    selva = [selva; pi(1:$)]
    mapa(2,X(2)-nor:X(2)-1) = X(2)+(0:nor-1)
    mapa = [mapa [X(1):nn:X(1)+nor*(nn-1) ; 0*(1:nor)] ]
    rutas(2,X(3)-nd:X(3)-1) = X(3)+(0:nd-1)
    rutas = [rutas [X(2)+lor-1 ;0*(1:nd)]]
    rutasOD = [rutasOD 1:nd]
    Y = FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,[0*lamda 1+zeros(1,nd)],mapa,selva)
    LBD = max(LBD,Ca+ta*(Y-F)')
    //  disp(LBD)
    lamda = [lamda, zeros(1,nd)]
    X(1) = X(1)+nn*nor  ;  X(2) = X(2)+nor  ;  X(3) = X(3)+nd
    nr = X(3)-1  ;  NGR = NGR+1
    Relgap = 2*abs(Ca-LBD)/(LBD+Ca)
  end   /// End While route generation


  if lhs > 2,
    [f,F]=Flujo(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva)
  else
    F=FlujoT(tl,hl,nn,na,nd,td,hd,dd,lor,rutas,lamda,mapa,selva);
  end
endfunction



////////////////////////////////   QKSP

function [lamd]=QKSP(apq,bpq,mu,nd,nR,rutas)
  if nd*nR>=size(rutas,2),
    lamd=qksp(apq,bpq,mu,nd,nR,rutas(2,:));
  else,
    mprintf("Bad call of QKSP");
    abort;
  end
endfunction

function [lamd]=QKSP2(apq,bpq,mu,C,nd,eps)
  if min(bpq)>0,   // Case there is NO bpqi equal=0
    pi=ones(1,nd)*min(-apq)
    lamd=max(0,mu-(apq+pi*C)./bpq)
    fpi=lamd*C'-1
    dfpi=(-sign(lamd)./bpq)*C'
    while norm(fpi)>eps
      pid=0*pi
      ii0=find(dfpi<0)
      pid(ii0)=-fpi(ii0)./dfpi(ii0)
      pi=pi+pid
      lamd=max(0,mu-(apq+pi*C)./bpq)
      fpi=lamd*C'-1
      dfpi=(-sign(lamd)./bpq)*C'
    end 
  else    
    // Case there is at least one bpqi equal=0
    minbi=plustimes(#(-bpq)*Cmp')-1
    I0=find(bpq==0)  //index of bi=0
    pq0=find(minbi==0) //commodities with some bi=0
    I1=find(bpq>0)  //index of bi>0
    pq1=find(minbi<0) // commodities with all bi>0
    pi0=plustimes( #(-apq(I0)) * Cmp(pq0,I0)' )-1
    pi1=-1 ./(bpq(I1)*C(pq1,I1)')-plustimes(#(apq(I1)-bpq(I1).*mu(I1))*Cmp(pq1,I1)')+1
    pi(pq0)=pi0
    pi(pq1)=pi1
    // critical commodities
    lamd=0*mu
    if I1<>[]
      lamd(I1)=max(0,mu(I1)-(apq(I1)+pi(pq1)*C(pq1,I1))./bpq(I1))
    end
    fpi=lamd*C'-1
    ind0=pq0(find(fpi(pq0)<=0)) //indices of pi already defined
    ind1=pq0(find(fpi(pq0)>0))
    ind2=[ind1 pq1]
    // Newton				
    dfpi(ind2)=(-sign(lamd(I1))./bpq(I1))*C(ind2,I1)'
    
    
    while norm(fpi(ind2))>eps
      pid=0*pi(ind2)
      ii0=ind2(find(dfpi(ind2)<0 & fpi(ind2)<>0))
      pid(ii0)=-fpi(ii0)./dfpi(ii0)
      pi(ii0)=pi(ii0)+pid(ii0)
      lamd(I1)=max(0,mu(I1)-(apq(I1)+pi(ind2)*C(ind2,I1))./bpq(I1))
      fpi(ind2)=lamd(I1)*C(ind2,I1)'-1
      dfpi(ind2)=(-sign(lamd(I1))./bpq(I1))*C(ind2,I1)'
    end
    //	ind0
    //	indu=I0(find(apq(I0)+pi*C(:,I0)==0))
    //	lamd(indu)=-fpi(indu)
  end
endfunction



//////////////////////////////////////////////////////////////
//////  Traffic Assigment Problem      ///////////////////////
//////////////////////////////////////////////////////////////


function TrafficAssig(p1,p2,p3)
  [narg1,narg]=argn(0)
  global %net

  if %net.gp.demand_number==0 then
    return
  end

  algo=%net.gp.algorithm
  niter=%net.gp.Niter
  tol=%net.gp.tolerance
  other=10
  //if narg==1 then algo="DSD"; end
  f=[];F=[];ta=[];
  err=0

  select algo,

   case "FW" then
    if narg==2 then tol=p2; end;
    if narg>=1 then niter=p1; end;
    [F,ta,ben]=FW(%net,niter,tol),
    %net.gp.bench=ben,
    %net.links.flow=F,
    %net.links.time=ta,

   case "IA" then
    if narg==1 then niter=p1; end;
    [f,ta]=IA(%net,niter); F=sum(f,"r"),
    %net.links.flow=F,
    %net.links.time=ta,
    %net.links.disaggregated_flow=f

   case "MSA" then
    if narg==2 then tol=p2; end;
    if narg>=1 then niter=p1; end;
    [f,ta,ben]=MSA(%net,niter,tol); F=sum(f,"r"),
    %net.gp.bench=ben,
    %net.links.flow=F,
    %net.links.time=ta,
    %net.links.disaggregated_flow=f


   case "DSD" then
    if narg==2 then tol=p2; end;
    if narg>=1 then niter=p1; end;
    [F,ta,ben]=DSD(%net,niter,0,tol),
    %net.gp.bench=ben,
    %net.links.flow=F,
    %net.links.time=ta,


   case "DSDisaggregated" then
    if narg==2 then tol=p2; end;
    if narg>=1 then niter=p1; end;
    [F,ta,ben,f]=DSD(%net,niter,0,tol),
    %net.gp.bench=ben,
    %net.links.flow=F,
    %net.links.time=ta,
    %net.links.disaggregated_flow=f


   case "CAPRES" then
    [f,ta]=CAPRES(%net); F=sum(f,"r"),
    %net.links.flow=F,
    %net.links.time=ta,
    %net.links.disaggregated_flow=f


   case "AON" then
    if narg==1,
      if p1==1,
	[F,f]=AONd(%net),
	%net.links.disaggregated_flow=f
      else
	[F]=AON(%net)
      end
    else
      [F]=AON(%net)
    end
    %net.links.flow=F,


   case "IAON" then
    if narg==1 then niter=p1; end;
    [f,ta,ben]=IAON(%net,niter); F=sum(f,"r"),
    %net.gp.bench=ben,
    %net.links.flow=F,
    %net.links.time=ta,
    %net.links.disaggregated_flow=f

   case "Probit" then
    kmax=20;accuracy=1e-3;beta=1;
    if narg==3 then kmax=p3; end;
    if narg>=2 then accuracy=p2; end;
    if narg>=1 then beta=p1; end;
    f=%net.links.flow;
    if f==[] then ta=%net.links.lpf_data(1,:);
    else ta=lpf(f,%net.links.lpf_data,%net.gp.lpf_model);end;
      f=Probit(%net,ta,beta,accuracy,kmax);F=sum(f,'r'),
      %net.links.flow=F,
      %net.links.time=ta,
      %net.links.disaggregated_flow=f


   case "ProbitE" then
    kmax=10;tol=1e-3;beta=1;
    if narg==3 then kmax=p3; end;
    if narg>=2 then tol=p2; end;
    if narg>=1 then beta=p1; end;
    [f,ta]=MSASUE(%net,beta,kmax,tol);F=sum(f,'r'),
    %net.links.flow=F,
    %net.links.time=ta,
    %net.links.disaggregated_flow=f

   case "LogitB" then
    LogitN(%net.gp.theta,LogitB)

   case "LogitD" then
    LogitN(%net.gp.theta,LogitD)

   case "LogitMB" then
    LogitN(%net.gp.theta,LogitMB)

   case "LogitMD" then
    LogitN(%net.gp.theta,LogitMD)

   case "LogitBE" then
    %net.gp.bench=LogitNE(%net.gp.theta,LogitB,tol,niter,%net.gp.N0)

   case "LogitDE" then
    %net.gp.bench=LogitNE(%net.gp.theta,LogitD,tol,niter,%net.gp.N0)

   case "LogitMBE" then
    %net.gp.bench=LogitNE(%net.gp.theta,LogitMB,tol,niter,%net.gp.N0)

   case "LogitMDE" then
    %net.gp.bench=LogitNE(%net.gp.theta,LogitMD,tol,niter,%net.gp.N0)

   case "NwtArc" then
    %net.gp.bench=WardropN(0.1,2,tol,niter)
  else
    disp("Wrong name of the algorithm, the valid names are:");
    disp("AON");
    disp("CAPRES");
    disp("DSD");
    disp("DSDisaggregated");
    disp("FW");
    disp("IA");
    disp("IAON");
    disp("MSA");
    disp("Probit");
    disp("ProbitE");
    disp("LogitB");
    disp("LogitD");
    disp("LogitMB");
    disp("LogitMD");
    disp("LogitBE");
    disp("LogitDE");
    disp("LogitMBE");
    disp("LogitMDE");
    disp("NwtArc");
    err=1;
  end,

  //if err<1,
  //	neta=net;
  //	neta("links")("flow")=F;
  //	neta("links")("time")=ta;
  //	if algo<>'AON',
  //	  neta("links")("disaggregated_flow")=f;
  //	elseif narg==3, if p1==1,
  //	   neta("links")("disaggregated_flow")=f
  ////   neta.links.disaggregated_flow=f
  //	 end end
  //end, 	

endfunction 


