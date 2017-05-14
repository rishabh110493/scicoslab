//////////////////////////////////////////////////////////////
//////     Bilevel optimization functions   //////////////////
//////////////////////////////////////////////////////////////

function [prix,opfV,s1,s2,s3]=bilevel(prlk,lp,up,algho,d1,d2,d3)
//For a given traffic network %net this function computes the optimun of the
//bilevel problem using algorithm "algo".
//prlk: row vector of priced links
//lp: lower bound for prices
//up: upper bound for prices
//algho: (default 'BiGls'): function name defining the algorithm choosen for doing the optimization.
//d1,d2,d3, different algorithms' parameters
//		algho='biGls', then d1:if it is true a diaglonal search direction is used first.
//                   d2:initial prices, d3:precision.
//		algho='biterGrid, then d1:grid's size, d2:precision, d3:number of grid subdivision.
//		algho='biGraphic', then d1:grid's size.
//prix: price
//opfV: optimum value of the profit function
//s1,s2,s3: different output parameters depending on the algorithm
//		algho:'biGls' or "biterGrid', then s1: spfV: sequence of profit function values
//						s2: sequence of prices.
//		algho:'biGraphic', then s1:matrix of the the profit function's values,
//						s2 and s3: price's vectors.

  [narg1,narg]=argn(0)

  global %net

  prix=[];opfV=[];s1=[];s2=[];s3=[];

  if narg<3 then
    disp('The entered parameters are not enough')
    return
  end
  if narg==3 then algho='biGls'; end


  select algho
   case "biGls" then
    if narg<=6 then d3=1e-6;end
    if narg<=5 then d2=lp;end
    if narg<=4 then d1=1;end
    [prix,opfV,s1,s2]=biGls(prlk,lp,up,d1,d2,d3);

   case "biterGrid" then
    if narg<=6 then d3=3;end
    if narg<=5 then d2=1e-6;end
    if narg<=4 then d1=50;end
    [prix,opfV,s1,s2]=biterGrid(prlk,lp,up,d1,d2,d3);

   case "biGraphic" then
    if narg<=4 then d1=50;end
    [prix,opfV,s1,s2,s3]=biGraphic(prlk,lp,up,d1);

  else
    disp("Wrong name of the algorithm, the valid names are:");
    disp("biGls");
    disp("biterGrid");
    disp("biGraphic");
    err=1;
  end
endfunction 

//////////////////////////////////////////////////////////////
////////    Bilevel optimization algorithms          /////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////     Bilevel optimization using GLS    /////////////////
//////////////////////////////////////////////////////////////

function [prix,opfV,sfV,sP]=biGls(prlk,lp,up,dia,prix0,eps)
//Function to optimize the bilevel problem in a single class net.
//prlk: priced links
//lp: lower bound for prices
//up: uper bound for prices
//dia:if it is true first dialonal search direction is used
//prix0: initial price for the priced links
//eps: precision
//prix: optimal link prices
//opfV: optimum value of the profit function
//sfV: sequence of the profit function values
//sP: sequence of prices.

  global %net

  cap=max(size(prlk))
  if max(size(lp))==1 then lp=lp*ones(1,cap);end
  if max(size(up))==1 then up=up*ones(1,cap); end
  if max(size(prix0))==1 then prix0=prix0*ones(1,cap);end

  norma=1;
  sfV=[];
  sP=[]
  norma1=1
  norma2=1

  po=zeros(1,cap);
  po0=zeros(1,cap);

  prt=0;
  data=list();
  %net.links.flow=0*%net.links.flow
  %net.links.disaggregated_flow=[];
  data(1)=%net;
  data(2)=prlk';

  prix=prix0;

  nloc=4;
  small=.0000001;
  smax=35;
  fmin0=0;

  //diagonal search
  if dia then
    p=ones(1,cap)
    alist=[];
    flist=[];
    [alist,flist,nf]=gls2(ganancia,data,lp',up',prix0,p,alist,flist,nloc,small,smax);
    [fmin,imin]=min(flist);
    prix=prix0+alist(imin)*p;
    sP=[sP;prix];
    sfV=[sfV;-fmin];
    prix0=prix;
    fmin0=fmin;
  end

  i=0
  //mm=0;
  while norma1 > eps | norma2>eps
    for j=1:cap
      p=zeros(1,cap);
      p(j)=1;
      alist=[];
      flist=[];
      //disp("estoy parando aca")		//lAGREGADO!!!!!!!
      [alist,flist,nf]=gls2(ganancia,data,lp',up',prix0,p,alist,flist,nloc,small,smax);
      [fmin,imin]=min(flist);
      prix=prix0+alist(imin)*p;
      norma1=abs(fmin-fmin0)
      norma2=norm(prix-prix0)
      sP=[sP;prix];
      sfV=[sfV;-fmin];
      prix0=prix;
      fmin0=fmin;
      //disp('pase',mm)
      //mm=mm+1;
    end
  end
  opfV=-fmin;
  %net.links.lpf_data(1,prlk)=data(1).links.lpf_data(1,prlk)+prix
endfunction 



function [gan]=ganancia(data,precio)
//Profit function
//data: list
//gan: profit value
  global %net
  net=data(1);
  prlk=data(2);
  %net=net;
  %net.gp.verbose=%F
  %net.links.lpf_data(1,prlk)=data(1).links.lpf_data(1,prlk)+precio
  TrafficAssig()
  F=%net.links.flow
  gan=-F(prlk)*precio'
endfunction 

//////////////////////////////////////////////////////////////
///     Bilevel optimization using an iterated grid      /////
//////////////////////////////////////////////////////////////

function [prix,opfV,sfV,sP]=biterGrid(prlk,lp,up,n,esp,m)
//prlk: row vector of priced links
//lp: lower bound for prices
//up: upper bound for prices
//n: grid's size
//m: number of "refinamientos del mallado"
//eps: precision
//prix: price
//opfV: optimum value of the profit function
//sfV: sequence of profit values
//sP: sequence of prices


  global %net

  %net.links.flow=0*%net.links.flow
  %net.links.disaggregated_flow=[];
  %net.gp.verbose=%F
  net1=%net;

  if size(prlk,1)<>1 then 
    disp('The priced links must be entered as a row vector')
    return
  end

  cap=size(prlk,2)
  pa=[];
  if max(size(lp))==1 then
    pa1=[lp:(up-lp)/n:up]
    pa=ones(cap,1)*pa1
    lp=lp*ones(1,cap);up=up*ones(1,cap)
  else
    for j=1:cap,
      pa=[pa;[lp(j):(up(j)-lp(j))/n:up(j)]],
    end

  end

  gan=zeros(1,n+1);
  xa1=[]; xa2=[]; gan=[];sfV=[];v0=0;
  sP=[],
  norma=1;
  u=1
  i=0
  k=0
  prix=pa(:,1);
  donde=ones(1,cap);

  %net.links.lpf_data(1,prlk)=net1.links.lpf_data(1,prlk)+pa(:,1)';
  TrafficAssig()
  F=%net.links.flow
  maxv=F(prlk)*pa(:,1)


  esp1=esp

  for k=1:m
    while  norma>esp1
      V=[],pre=[]
      for j=1:cap
	arco=prlk(j)
	u1=donde(j)
	uc=n+1-u1
	gan(u1)=maxv,
	for ia=u1+1:u1+uc
	  %net.links.lpf_data(1,arco)=net1.links.lpf_data(1,arco)+pa(j,ia);
	  TrafficAssig()
	  F=%net.links.flow
	  prix(j)=pa(j,ia)
	  gan(ia)=F(prlk)*prix
	end

	for ia=u1-1:-1:1
	  %net.links.lpf_data(1,arco)=net1.links.lpf_data(1,arco)+pa(j,ia);
	  TrafficAssig()
	  F=%net.links.flow
	  prix(j)=pa(j,ia)
	  gan(ia)=F(prlk)*prix
	end

	[maxv,ou]=max(gan)
	pre=[pre,pa(j,ou)];
	prix(j)=pa(j,ou)
	donde(j)=ou;
	V=[V,maxv]
	%net.links.lpf_data(1,arco)=net1.links.lpf_data(1,arco)+prix(j);
      end

      norma=abs(maxv-v0)
      v0=maxv
      sfV=[sfV;V]
      sP=[sP;pre]
      i=i+1;
    end
    esp1=.001*esp1
    [nn,paa]=spget(sparse(pa+1e-20));
    lp=paa(max([ones(1,cap);donde-2],'r')+(n+1)*[0:cap-1])
    up=paa(min([(n+1)*ones(1,cap);donde+2],'r')+(n+1)*[0:cap-1])
    pa=[];
    for j=1:cap;
      pa=[pa;[lp(j):(up(j)-lp(j))/n:up(j)]];
    end
    donde=floor(n/2)*ones(1,cap);
    k=k+1
    norma=1
  end
  opfV=V;
  prix=prix'
  %net.links.lpf_data(1,prlk)=net1.links.lpf_data(1,prlk)+prix;
  clean(prix);clean(opfV);clean(sP);clean(sfV)
endfunction 

//////////////////////////////////////////////////////////////
//////     Graphic of the upper level function ///////////////
//////////////////////////////////////////////////////////////

function [prix,opfV,gan,p1,p2]=biGraphic(prlk,lp,up,n)
//prlk: priced links
//lp: prices lower bound
//up: prices upper bound
//n: grid size
//prix: optimal link prices
//opfV: optimum value of the profit function
//gan: matrix of the the profit function's values.
//p1 and p2: price's vectors

  if size(prlk,1)<>1|size(prlk,2)>2 then
    error("prlk must be a row vector of dimension at most 2")
  end
  cap=size(prlk,2)
  if max(size(lp))==1 then lp=lp*ones(1,cap);end
  if max(size(up))==1 then up=up*ones(1,cap); end

  global %net

  %net.gp.verbose=%F


  if size(prlk,2)<>1 then
    if max(size(lp))==1 then lp=lp*ones(1,2);end
    if max(size(up))==1 then up=up*ones(1,2); end
    p1=[lp(1):(up(1)-lp(1))/n:up(1)]
    p2=[lp(2):(up(2)-lp(2))/n:up(2)]
    net=%net;
    gan=[],
    II=[],

    for i=1:n+1
      net.links.lpf_data(1,prlk(1))=%net.links.lpf_data(1,prlk(1))+p1(i)
      for j=1:n+1
	net.links.lpf_data(1,prlk(2))=%net.links.lpf_data(1,prlk(2))+p2(j)
	F=DSD(net);
	gan(i,j)=F(prlk(1))*p1(i)+F(prlk(2))*p2(j)
      end
      II=[II,i]
    end
    [opfV,position]=max(gan)
    prix=[p1(position(1)),p2(position(2))]
    %net.links.lpf_data(1,prlk)=%net.links.lpf_data(1,prlk)+prix;
    TrafficAssig()
    xset("window",1)
    xbasc()
    plot3d(p1,p2,gan)
    xset("window",2)
    xbasc()
    contour(p1,p2,gan,30);

  else
    p1=[lp(1):(up(1)-lp(1))/n:up(1)]
    p2=[]
    net=%net;
    gan=[],
    II=[],
    for i=1:n+1
      net.links.lpf_data(1,prlk(1))=%net.links.lpf_data(1,prlk(1))+p1(i)
      F=DSD(net);
      gan(i)=F(prlk(1))*p1(i)
      II=[II,i]
    end
    [opfV,position]=max(gan)
    prix=p1(position(1))
    %net.links.lpf_data(1,prlk)=%net.links.lpf_data(1,prlk)+prix;
    TrafficAssig()
    plot2d(p1,gan)
  end
endfunction 




