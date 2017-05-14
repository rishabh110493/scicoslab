//// Function Make Net
//   =================
function net=MakeNet(nn,nx,ny,tl,hl,nf,lpp,td,hd,demand)
  [lhs,rhs]=argn(0)
  if rhs<10, nf=6, end
  na=size(tl,2)
  nd=size(td,2)
  verbose=%T; algorithm='DSD';NodeDiameter=30;NodeBorder=1;
  FontSize=10;tolerance=1.e-6;theta=1;Niter=20;N0=0;
  ShowDemands=%T;Show='flow';bench=0;
  gp=tlist(["gp";"node_number";"link_number";"demand_number";"lpf_model";..
	    "verbose";"algorithm";"NodeDiameter";"NodeBorder";"FontSize";..
	    "tolerance";"theta";"Niter";"N0";"ShowDemands";"Show";"bench"],..
	   nn,na,nd,nf,verbose,algorithm,NodeDiameter,NodeBorder,FontSize,..
	   tolerance,theta,Niter,N0,ShowDemands,Show,bench)
  nodes=tlist(["nodes";"name";"x";"y"],1:nn,nx,ny)
  links=tlist(["links";"name";"tail";"head";"lpf_data";"flow";"time";..
	       "disaggregated_flow"],1:na,tl,hl,lpp,[],[],[])
  demands=tlist(["demands";"name";"tail";"head";"demand"],1:nd,td,hd,demand)
  net=tlist(["net";"gp";"nodes";"links";"demands"],gp,nodes,links,demands)
endfunction


function net=O2NNet(onet)
  verbose=%T; algorithm='DSD';NodeDiameter=30;NodeBorder=1;
  FontSize=10;tolerance=1.e-6;theta=1;Niter=20;N0=0;
  ShowDemands=%T;Show='flow';bench=0;
  gp=tlist(["gp";"node_number";"link_number";"demand_number";"lpf_model";..
	    "verbose";"algorithm";"NodeDiameter";"NodeBorder";"FontSize";..
	    "tolerance";"theta";"Niter";"N0";"ShowDemands";"Show";"bench"],..
	   onet.gp.node_number,onet.gp.link_number,onet.gp.demand_number,..
	   onet.gp.lpf_model,verbose,algorithm,NodeDiameter,NodeBorder,..
	   FontSize,tolerance,theta,Niter,N0,ShowDemands,Show,bench)
  net=tlist(["net";"gp";"nodes";"links";"demands"],gp,onet.nodes,onet.links,..
	    onet.demands)
endfunction

//////////////////////////   
//// Function add nodes
//   ==================

function AddNodes(nx,ny)
  global %net
  nn=%net("gp")("node_number")+size(nx,2)
  %net("gp")("node_number")=nn
  nx=[%net("nodes")("x") nx]
  ny=[%net("nodes")("y") ny]
  %net("nodes")=tlist(["nodes";"name";"x";"y"],1:nn,nx,ny)
endfunction


//// Function add links
//   ==================

function AddLinks(tl,hl,lpp)
  global %net
  links=%net("links")
  links("tail")=[links("tail") tl]
  links("head")=[links("head") hl]
  links("lpf_data")=[links("lpf_data") lpp]

  na=%net("gp")("link_number")+size(tl,2)
  %net("gp")("link_number")=na
  if size(links("flow"))>0
    links("flow")(1,na)=0
  end
  if size(links("time"))>0
    links("time")(1,na)=0
  end
  if size(links("disaggregated_flow"))>0
    links("disaggregated_flow")($,na)=0
  end

  links("name")=1:na
  %net("links")=links
endfunction


//// Function add demands
//   ====================

function AddDemands(td,hd,demand)
  global %net
  demands=%net("demands")
  demands("tail")=[demands("tail") td]
  demands("head")=[demands("head") hd]
  demands("demand")=[demands("demand") demand]
  nd=size(demands("tail"),2)
  demands("name")=1:nd
  %net("gp")("demand_number")=nd
  %net("demands")=demands
endfunction


//----------------------------------------------------------//
//                 Net/graph-list manipulation              //
//----------------------------------------------------------//

//// Function net -> graph
//   =====================

function g=Net2Graph(net,sel_nodes,sel_links,fmin,fmax,tmin,tmax,sel_demands,dmin,dmax,df)
// transform the net in a graph with the specificied nodes,links,demands,
// and the links with flows and costs between f/tmin and f/tmax and the demands
// between dmin,dmax. The variables nodes, links, demands can have the value
// "all" but if dmin and dmax are supplied only the demands betwwen those
// values will be shown. Other values for nodes are "used". The last parameter df
// means that the widht of the arcs are proportional to the disaggregated flow
// corresponding to the demand number df
  [lhs,rhs]=argn(0)
  gp=net("gp")
  nodes=net("nodes")
  links=net("links")
  demands=net("demands")
  nn=gp("node_number")
  na=gp("link_number")
  nd=gp("demand_number")
  flow=links("flow")
  time=links("time")
  ltail=links("tail")
  lhead=links("head")
  lpp=links("lpf_data")
  lname=links("name")
  dtail=demands("tail")
  dhead=demands("head")
  demand=demands("demand")
  dname=demands("name")
  if size(demand,'*')==0, demand=zeros(1,nd), end
  if size(flow,'*')==0, flow=zeros(1,na), end
  if size(time,'*')==0, time=zeros(1,na), end
  if rhs==11,
    if df>nd|df<1,
      disp("error, df must be a positive"+...
	   "integer not greater than"+string(nd));
      break;
    end
  end

  if rhs==1,
    sel_nodes='all'
    sel_links='all'
    fmin=0
    fmax=0
    tmin=0
    tmax=0
    sel_demands='all'
    dmin=0
    dmax=0
  end





  // Link selection
  // --------------
  select sel_links
   case "all"
    ilink=1:na
   case "between"
    ilink=find(flow>=fmin & flow<=fmax)
  else
    if type(sel_links)==1,
      aux=zeros(1,na),
      aux(sel_links)=1,
      ilink=find(flow>=fmin & flow<=fmax & time>=tmin & time<=tmax & aux==1)
    else
      disp("error on link input")
      return
    end
  end

  na=size(ilink,2)

  ltail=ltail(ilink)
  lhead=lhead(ilink)
  time=time(ilink)
  lname=lname(ilink)
  lpp=lpp(:,ilink)

  if rhs<11
    flow=flow(ilink)
  else
    flow=links("disaggregated_flow")(df,ilink)
  end



  // Demand selection
  // ----------------
  select sel_demands
   case "all"
    idem=1:nd
   case "between"
    idem=find(demand>=dmin & demand<=dmax)
  else
    if type(sel_demands)==1,
      aux=zeros(1,nd),
      aux(sel_demands)=1,
      idem=find(demand>=dmin & demand<=dmax & aux==1),
    else
      disp("error on input")
      return
    end
  end

  nd=size(idem,2)
  dtail=dtail(idem)
  dhead=dhead(idem)
  demand=demand(idem)
  dname=dname(idem)

  if nd+na==0,
    g=[];
    return;
  end


  maxflow=max(abs(flow))
  maxdem=max(abs(demand))
  maxwidth=max([maxflow,maxdem])


  if maxflow>0
    wlink=10*flow/maxwidth
    clink=ones(flow)
    clink(find(flow<maxflow/1000))=4
  else
    wlink=ones(1,na)
    clink=ones(1,na)
  end


  if maxdem>0
    wdem=10*demand/maxwidth
    cdem=ones(1,nd)*6
    // JPQ
  else
    wdem=ones(1,nd),
    cdem=6*ones(1,nd)
    // JPQ
  end





  // node selection
  // --------------
  select sel_nodes
   case "all"
    borrar=[],
   case "used"
    borrar=1:nn,
    borrar([ltail lhead dtail dhead])=0
    borrar=borrar(find(borrar>0))
  else
    borrar=1:nn,
    borrar(sel_nodes)=0
    borrar=borrar(find(borrar>0))
  end

  // Graph
  //------
  g=make_graph("CiudadSim3",1,nn,[ltail dtail],[lhead dhead])
  g("edge_min_cap")=[lpp(1,:) demand]
  g("edge_max_cap")=[lpp(2,:) demand]
  g("edge_length")=[lpp(1,:) demand]
  g("edge_q_weight")=[lpp(3,:) demand]
  g("edge_q_orig")=[lpp(4,:) demand]
  g("edge_weight")=[flow demand]
  g("edge_cost")=[time demand]
  g("edge_color")=[clink cdem]
  g("edge_width")=[wlink wdem]
  g("node_x")=nodes("x")
  g("node_y")=nodes("y")
  g("edge_name")=[string(lname) string(dname)]
  g("default_font_size")=net.gp.FontSize//default_font_size
  g("default_node_diam")=net.gp.NodeDiameter;
  g("default_node_border")=net.gp.NodeBorder;
  if prod(size(borrar))>0, g=delete_nodes(borrar,g), end
endfunction


//// Function graph -> net
//========================

function net=Graph2Net(g,nf)
  [lhs,rhs]=argn(0)
  if rhs<2, nf=6,end
  nn=g("node_number")
  nx=g("node_x")
  ny=g("node_y")

  ilink=find(g("edge_color")<6)
  // JPQ

  na=size(ilink,2)
  tl=g("tail")(ilink)
  hl=g("head")(ilink)
  flow=g("edge_weight")(ilink)
  time=g("edge_cost")(ilink)
  lpp=[g("edge_min_cap")(ilink);g("edge_max_cap")(ilink);g("edge_q_weight")(ilink)]
  ba=g("edge_q_orig")(ilink);
  // Verification de lpp
  if (nf==6 | nf==0), ba=max(1,ba); end

  if nf<6 & nf>=0, 
    if min(ca)<=0, x_message("The link capacity (ca) must be strictly positive."); end
  end

  lpp=[lpp;ba]


  lname=g("edge_name")(ilink)

  idem=find(g("edge_color")==6)
  // JPQ
  nd=size(idem,2)
  td=g("tail")(idem)
  hd=g("head")(idem)
  demand=g("edge_weight")(idem)
  dname=g("edge_name")(idem)

  net=MakeNet(nn,nx,ny,tl,hl,nf,lpp,td,hd,demand)
  net("links")("flow")=flow
  net("links")("time")=time
  net("links")("name")=lname
  net("demands")("name")=dname
endfunction


////////////-- Extraction of parameters from the net -------/////

//// Function net -> parameters g,d,lpp,nf
//   =====================================
function [g,d,lpp,nf]=Net2Par(net)

  nn=net("gp")("node_number")
  na=net("gp")("link_number")
  nd=net("gp")("demand_number")
  nf=net("gp")("lpf_model")
  ltail=net("links")("tail")
  lhead=net("links")("head")
  lpp=net("links")("lpf_data")
  g=make_graph("foo",1,nn,ltail,lhead)
  g("edge_weight")=[net("links")("flow")]
  g("edge_cost")=[net("links")("time")]
  g("node_x")=net("nodes")("x")
  g("node_y")=net("nodes")("y")
  d=[net("demands")("tail");net("demands")("head");net("demands")("demand")]
endfunction

//// Function parameters g,d,lpp,nf -> net
//   =====================================
function [net]=Par2Net(g,d,lpp,nf)
  nn=g('node_number')
  nx=g('node_x')
  ny=g('node_y')
  tl=g('tail')
  hl=g('head')
  nd=size(d,2)

  td=d(1,:)
  hd=d(2,:)
  demand=d(3,:)

  net=MakeNet(nn,nx,ny,tl,hl,nf,lpp,td,hd,demand)
endfunction

////////////////--------------------------------//////////////
/////////            Net-list display                  ///////
//----------------------------------------------------------//
//// Function Show-net
//   =================
function ShowNet(sel_nodes,sel_links,fmin,fmax,tmin,tmax,sel_demands,dmin,dmax,df)
  [lhs,rhs]=argn(0)
  global %net
  if rhs==0,
    if %net.gp.ShowDemands==%T
      g=Net2Graph(%net,"all","all",0,0,0,0,"all",0,0)
    else
      g=Net2Graph(%net,"all","all",0,0,0,0,[],0,0)
    end
  elseif rhs==10
    if %net.links.disaggregated_flow==[],
      disp('Empty disaggregated flow')
      return
    end
    g=Net2Graph(%net,sel_nodes,sel_links,fmin,fmax,tmin,tmax,sel_demands,dmin,dmax,df)
  elseif rhs==9
    if %net.links.disaggregated_flow==[],
      disp('Empty disaggregated flow')
      return
    end
    g=Net2Graph(%net,sel_nodes,sel_links,fmin,fmax,tmin,tmax,sel_demands,dmin,dmax)
  elseif rhs==6
    if %net.gp.ShowDemands==%T
      g=Net2Graph(%net,sel_nodes,sel_links,fmin,fmax,tmin,tmax,"all",0,0)
    else
      g=Net2Graph(%net,sel_nodes,sel_links,fmin,fmax,tmin,tmax,[],0,0)
    end
  else
    disp('Imput error')
    return
  end

  if  type(g)==1,
    disp('Empty graph');
    return;
  end
  // xsetech([0,0,0.6,0.6]);
  show_graph(g);
  show_scig_names('node','name');

  if (%net.links.flow==[] | max(%net.links.flow)==0),
    show_scig_names('arc','t0');
    title2='Showing link free flow travel times';
  else
    show_scig_names('arc','Flow'); title2='Showing link flows';
  end
  // xset("window",1) //JPQ-editgraph
  //xname("CiudadSim3");
endfunction

//// Function Show-links
//   ===================

function ShowLinks(sel_nodes,sel_links,fmin,fmax,tmin,tmax,df)
  [lhs,rhs]=argn(0)
  global %net
  if rhs==0,
    g=Net2Graph(%net,"all","all",0,0,0,0,[],0,0)
  elseif rhs==7,
    g=Net2Graph(%net,sel_nodes,sel_links,fmin,fmax,tmin,tmax,[],0,0,df)
  else
    g=Net2Graph(%net,sel_nodes,sel_links,fmin,fmax,tmin,tmax,[],0,0)
  end

  if type(g)==1,
    disp('Empty graph');
    return
  end
  xsetech([0,0,0.6,0.6]);
  show_graph(g)
  show_scig_names('node','name');

  if (%net.links.flow==[] | max(%net.links.flow)==0),
    show_scig_names('arc','t0');
    title2='Showing link free flow travel times'
  else
    show_scig_names('arc','Flow');
    title2='Showing link flows';
  end
  //xname("CiudadSim3");

endfunction 



//// Function Show-demands
//   =====================

function ShowDemands(sel_nodes,sel_demands,dmin,dmax)
  [lhs,rhs]=argn(0)
  global %net
  if rhs==0,
    g=Net2Graph(%net,"all",[],0,0,0,0,"all",0,0)
  else
    g=Net2Graph(%net,sel_nodes,[],0,0,0,0,sel_demands,dmin,dmax)
  end
  if  type(g)==1,
    disp('Empty graph');
    return
  end
  xsetech([0,0,0.6,0.6]);
  show_graph(g)
  show_scig_names('node','name');
  if %net.links.flow==[],
    show_scig_names('arc','t0');
    title2='Showing link free flow travel times'
  else
    show_scig_names('arc','Flow');
    title2='Showing link flows';
  end
  //xname("CiudadSim3");

endfunction

/// Random generation of nets
//  =========================

function net=RandomNet(nn,na,nd,nf)
  [lhs,rhs]=argn(0)
  if rhs>4,
    disp('Bad number of inputs')
  else
    if rhs<=3,  nf=6;  end
    if rhs<=2, nd=nn*(nn-1)/2; end
    if rhs==1, na=4*nn; end
    if rhs==0, nn=5; end

    // generates random node-arc incidence matrix
    ll=ceil(sqrt(nn))
    s1=[1:ll,ll:-1:1]
    s1=ones(1,ceil(nn/(ll*2))).*.s1
    s2=(1:ll).*.ones(1,ll)
    s1=s1(1:nn)
    s2=s2(1:nn)
    nx=s1/(max(s1)+1)*800
    ny=s2/(max(s2)+1)*600
    [ij1,v1]=spget(sprand(nn,nn,(na*(1+1/nn)-nn)/nn^2)-2*speye(nn,nn)+sparse(diag(ones(1,nn-1),1))+sparse([nn 1;nn nn],[1 0]))
    ind1=find(v1>0)

    // generates random inputs-outputs
    [ij2,v2]=spget(sprand(nn,nn,nd/(nn*(nn-1)))-2*speye(nn,nn));
    ind2=find(v2>0)
    na=size(ind1,'*')
    t0=max(0.1,rand(1,na));c0=max(0.01,rand(1,na)/10);m0=max(0.01,rand(1,na));
    lpp=[t0;c0;m0;0*t0+2]
    net=MakeNet(nn,nx,ny,ij1(ind1,1)',ij1(ind1,2)',nf,lpp,ij2(ind2,1)',ij2(ind2,2)',v2(ind2)')
    net.links.time=t0;
  end
endfunction


function electos=elegir(j,n)
  q=1:n
  electos=[]
  for i=1:j
    q=q(find(q>0))
    cual=1+int(rand(1,"uniform")*size(q,2))
    electos=[electos,q(cual)]
    q(cual)=0;
  end
endfunction

function net=RandomNNetv(nn,pna,dispe,nd,nf)
// generates random node-node incidence matrix
  [lhs,rhs]=argn(0)
  if rhs>5,
    disp('Bad number of inputs')
  else
    if rhs<=4,  nf=6;  end
    if rhs<=3, nd=nn*(nn-1)/2; end
    if rhs<=2, dispe=0.5; end
    if rhs==1, pna=4/(nn-1); end
    if rhs==0, nn=5; end

    H=spzeros(nn,nn);
    for j=1:nn,
      H(j,elegir(pna+dispe*rand(1,"normal"),nn))=1
      H(j,j)=0
    end
    g=mat_2_graph(H,1,"node-node");
    na=edge_number(g);
    ll=ceil(sqrt(nn))
    s1=[1:ll,ll:-1:1]
    s1=ones(1,ceil(nn/(ll*2))).*.s1
    s2=(1:ll).*.ones(1,ll)
    s1=s1(1:nn)
    s2=s2(1:nn)
    nx=s1/max(s1)*800-50
    ny=s2/max(s2)*600-50
    g('node_x')=nx
    g('node_y')=ny
    [nc,ncomp]=strong_connex(g);

    if nc>1
      cy(ncomp)=1:nn
      for j=1:nc-1,
	g= add_edge(cy(j),cy(j+1),g)
      end
      g=add_edge(cy(nc),cy(1),g)
      na=na+nc
    end

    // generates random inputs-outputs

    [ij2,v2]=spget(sprand(nn,nn,nd/(nn*(nn-1)))-2*speye(nn,nn));
    ind2=find(v2>0)
    d=[ij2(ind2,1),ij2(ind2,2),v2(ind2)]'
    t0=max(0.1,rand(1,na));c0=max(0.01,rand(1,na)/10);m0=max(0.01,rand(1,na));
    lpp=[t0;c0;m0;0*t0+2]
    net=Par2Net(g,d,lpp,nf)
  end
endfunction


function electos=elegir2(jj,n,si,no)
  [lhs,rhs]=argn(0)
  if rhs<4, no=[]; end
  if rhs<3, si=[]; end
  a=(1:n)
  v=rand(1,n)
  v(si)=1;
  v(no)=0;
  [v,d]=sort(v)
  j1=min(n-1,max(jj,size(si,2)))
  electos=d(1:j1)
endfunction

function net=RandomNNet(nn,pna,dispe,nd,nf)
// generates random node-node incidence matrix
  [lhs,rhs]=argn(0)
  if rhs>5,
    disp('Bad number of inputs')
  else
    if rhs<=4,  nf=6;  end
    if rhs<=3, nd=nn*(nn-1)/2; end
    if rhs<=2, dispe=0.5; end
    if rhs==1, pna=4/(nn-1); end
    if rhs==0, nn=5; end

    H=spzeros(nn,nn);
    for j=1:nn,
      cua=pna+dispe*rand(1,"normal")
      H(j,elegir2(cua,nn,modulo(j,nn)+1,j))=1
    end

    if max(H)==0 then s=ceil(nn*rand(1));H(s,modulo(s,nn)+1)=1; end

    g=mat_2_graph(H,1,"node-node");
    na=edge_number(g);
    ll=ceil(sqrt(nn))
    s1=[1:ll,ll:-1:1]
    s1=ones(1,ceil(nn/(ll*2))).*.s1
    s2=(1:ll).*.ones(1,ll)
    s1=s1(1:nn)
    s2=s2(1:nn)
    nx=s1/max(s1)*800-50
    ny=s2/max(s2)*600-50
    g('node_x')=nx
    g('node_y')=ny

    // generates random inputs-outputs

    [ij2,v2]=spget(sprand(nn,nn,nd/(nn*(nn-1)))-2*speye(nn,nn));
    ind2=find(v2>0)
    d=[ij2(ind2,1),ij2(ind2,2),v2(ind2)]'
    t0=max(0.1,rand(1,na));c0=max(0.01,rand(1,na)/10);m0=max(0.01,rand(1,na));
    lpp=[t0;c0;m0;0*t0+2]
    net=Par2Net(g,d,lpp,nf)
    net.links.time=t0;
  end
endfunction
/////////////////////////////////////////////////////////////////////
/////   Regular City
/////////////////////////////////////////////////////////////////////

function net=Regular(hs,vs,nd);
//hs: number of horizontal streets
//vs: number of vertical streets
//nd: number of demands

  [lhs,rhs]=argn(0)
  if rhs<3,nd=(hs*vs)^2;end

  blockh=500/hs;
  blockv=600/vs;
  h=[];t=[];x=[];y=[];h1=[];t1=[]

  nn=hs*vs
  na=(hs-1)*vs+(vs-1)*hs

  if modulo(hs,2)==1 then
    if modulo(vs,2)==1 then
      sacar=spzeros(nn,nn);sacar(:,vs)=1;sacar(vs*(hs-1)+1,:)=1
    else
      sacar=spzeros(nn,nn);sacar(:,vs*hs)=1;sacar(vs*(hs-1)+1,:)=1
    end
  else
    if modulo(vs,2)==1 then
      sacar=spzeros(nn,nn);sacar(:,vs)=1;sacar(vs*hs,:)=1
    else
      sacar=[]
    end
  end

  for i=1:hs,  for j=1:vs,   x((i-1)*vs+j)=30+blockv*(j-1);   end; end

  for i=1:hs,   for j=1:vs,   y((i-1)*vs+j)=20+blockh*(i-1);   end; end

  for i=1:hs,
    if i/2-int(i/2)<>0 then
      t1=[];
      for j=1:vs-1,
	t1(j)=j+(i-1)*vs;
      end;
      t=[t;t1];
    else
      t1=[]; for j=1:vs-1,  t1(j)=i*vs-j+1;  end;  t=[t;t1];
    end
  end

  for j=1:vs,
    if j/2-int(j/2)==0 then
      t1=[]; for i=1:hs-1, t1(i)=j+(i-1)*vs;  end; t=[t;t1];
    else
      t1=[];  for i=1:hs-1, t1(i)=vs*(hs-i)+j;  end;  t=[t;t1];
    end;
  end

  for i=1:hs,
    if i/2-int(i/2)==0 then
      h1=[];  for j=1:vs-1; h1(j)=i*vs-j;  end; h=[h;h1]
    else
      h1=[]; for j=1:vs-1, h1(j)=j+1+(i-1)*vs;   end; h=[h;h1];
    end
  end

  for j=1:vs,
    if j/2-int(j/2)==0 then
      h1=[]; for i=1:hs-1, h1(i)=j+(i)*vs;  end; h=[h;h1];
    else
      h1=[];  for i=1:hs-1, h1(i)=vs*(hs-i-1)+j;  end; h=[h;h1];
    end
  end

  if nd==(vs*hs)^2 then
    [ij2,v2]=spget(sparse(ones(nn,nn))-2*speye(nn,nn)-2*sacar);
    ind2=find(v2>=0);
    d=[ij2(ind2,:),v2(ind2)]'
  elseif nd==1 then
    d=[1,vs*hs-max(modulo(hs,2)-modulo(vs,2),0),1]'
  elseif 0<nd & nd <1 then
    [ij2,v2]=spget(sprand(nn,nn,nd)-2*speye(nn,nn)-2*sacar);
    ind2=find(v2>0)
    d=[ij2(ind2,1),ij2(ind2,2),ones(size(ind2,2),1)]'
  else
    [ij2,v2]=spget(sprand(nn,nn,1)-2*speye(nn,nn)-2*sacar);
    [sv2,ind2]=sort(v2.*(ij2(:,2)-ij2(:,1))^2)
    d=[ij2(ind2(1:nd),1),ij2(ind2(1:nd),2),ceil(10*v2(ind2(1:nd)))+ceil(5*rand(nd,1))]'

  end

  lpp=ones(4,na)

  h=h'
  t=t'

  g=make_graph('pueblo',1,nn,h,t);
  g('node_x')=x';
  g('node_y')=y';
  net=Par2Net(g,d,lpp,3)
  net.links.time=ones(1,na)
endfunction



/////////////////////////////////////////////////
//////  Data Base handling functions   //////////
/////////////////////////////////////////////////


function net=TrafficExample(example,p1,p2,p3,p4)
  [lhs,rhs]=argn(0)
  if rhs<5, p4=2; end
  if rhs<4, p3=2;  end
  if rhs<3, p2=10;  end
  if rhs<2, p1=6;  end
  if rhs<1, example='';  end
  net=[]
  select example
   case "Braess"
    load(EXAMPLES+"Braess.net")
    net=O2NNet(braess)
    clear braess
   case "Regular City"
    if rhs<4, p3=(p1*p2)^2;end
    net=Regular(p1,p2,p3);
   case "Steenbrink"
    load(EXAMPLES+"steenbrink.net")
    net=O2NNet(netst)
    clear netst
   case "Chicago"
    load(EXAMPLES+"chisincen.net")
    net=O2NNet(chisincen)
    clear chisincen
   case "Random City"
    net=RandomNet(p1,p2,p3,p4)
   case "Normal Random City"
    net=RandomNNet(p1,p2,p3,p4)
   case "Sioux Falls"
    load(EXAMPLES+"sioux.net")
    net=O2NNet(sioux)
    clear sioux
   case "Triangle"
    load(EXAMPLES+"triangle.net")
    net=net0
    clear net0
   case "Diamond"
    load(EXAMPLES+"diamond.net")
    net=O2NNet(diamond)
    clear netd
   case "Small"
    load(EXAMPLES+"small.net")
    net=O2NNet(small)
    clear small
   case "Empty"
    load(EXAMPLES+"emptynet.net")
    net=O2NNet(nete)
    clear nete
   case "Nguyen Dupuis"
    load(EXAMPLES+"dupuis.net")
    net=O2NNet(dupuis)
    clear dupuis
   case "Versailles"
    net=ImportMI(EXAMPLES+"SGL_Versailles");
    net.demands=tlist(["demands";"name";"tail";"head";"demand"],..
		      1,1,20,1)
    net.gp.demand_number=1


  else
    disp("The options are:")
    disp("    Braess")
    disp("    Chicago")
    disp("    Diamond")
    disp("    Empty")
    disp("    Nguyen Dupuis")
    disp("    Normal Random City")
    disp("    Random City")
    disp("    Regular City")
    disp("    Sioux Falls")
    disp("    Small")
    disp("    Steenbrink")
    disp("    Triangle")
    disp("    Versailles")

  end
endfunction

//================================ Modif Scilab ===================

function show_scig_names(a,b)
endfunction  

function ge_do_options()
//Copyright INRIA
//Author : Serge Steer 2002

  execstr('global EGdata_'+w+';EGdata=EGdata_'+w)
  node=list('Nodes',EGdata.NodeId+1,['Nothing','Number','Name','Demand','Label'])
  arc=list('Arcs',EGdata.ArcId+1,['nothing','number','name','time','t0','ca',..
		    'empty time', 'ma','ba', ...
		    'flow','label'])
  rep=x_choices("Select information to display",list(node,arc))
  
  if EGdata.NodeId<>rep(1)-1 | ...
	EGdata.ArcId<>rep(2)-1 then
    EGdata.NodeId=rep(1)-1
    EGdata.ArcId=rep(2)-1
    execstr('EGdata_'+w+'=EGdata')
    GraphList=EGdata.GraphList
    xbasc()
    ge_set_winsize()
    ge_drawobjs(GraphList),
  end
endfunction

function ge_draw_std_arcs(xx,yy,Ids)
//Copyright INRIA
//Author : Serge Steer 2002

  if xx==[] then return,end
  xset("thickness",1)
  width=GraphList.edge_width(sel1);
  width(width==0)=GraphList.default_edge_width
  c=GraphList.edge_color(sel1)
  c(c==0)=1
  uwidth=unique(width)
  for w=uwidth
    k=find(width==w)
    xset("thickness",w)
    xpolys(xx(:,k),yy(:,k),15+c(k))
  end
  xx([1 4],:)=[];yy([1 4],:)=[];
  Ids=ge_get_arcs_id(sel1)
  
  if GraphList.directed|Ids<>[] then
    x0f=(2*xx(2,:)+xx(1,:))/3;y0f=(2*yy(2,:)+yy(1,:))/3; 
    //   x0=(7*xx(2,:)+xx(1,:))/8;y0=(7*yy(2,:)+yy(1,:))/8;   
    x0=xx(2,:);y0=yy(2,:);
    l=sqrt((xx(2,:)-xx(1,:)).^2+(yy(2,:)-yy(1,:)).^2);
    co=(xx(2,:)-xx(1,:))./l;si=-(yy(2,:)-yy(1,:))./l;
    arrowW=arrowWidth/3;
    arrowL=arrowLength/3;
    x0=[x0+arrowW*si;x0+arrowL*co;x0-arrowW*si;x0+arrowW*si]
    y0=[y0+arrowW*co;y0-arrowL*si;y0-arrowW*co;y0+arrowW*co]
    if GraphList.directed then // draw the arrows
      for w=uwidth
	k=find(width==w)
	xset("thickness",w)
	xpolys(x0(:,k),y0(:,k),15+c(k))
      end
    end
    if Ids<>[] then//draw the arc identification
      f=GraphList.edge_font_size(sel1)
      f(f==0)=GraphList.default_font_size
      for k=1:size(Ids,'*')
	//rect=xstringl(x0(2,k),y0(1,k),Ids(k))
	xset("font size",ge_font(f(k)))
	//	xstring(x0(2,k),y0(1,k),Ids(k))	
        angle=-sign(co+0.001).*sign(-si).*acos(abs(co))*180/%pi;
	xset("color",1);
	xstring(x0f(k),y0f(k),Ids(k),angle(k))
      end
    end
  end
  xset("thickness",1)
endfunction

function  Ids=ge_get_arcs_id(sel)
//Copyright INRIA
//Author : Serge Steer 2002

  execstr('ArcId=EGdata_'+string(win)+'.ArcId')
  Ids=[]
  select ArcId
   case 1 then 
    if size(sel,1)==-1 then 
      Ids=string(1:size(GraphList.tail(sel),'*'))
    else
      Ids=string(sel)
    end
   case 2 then Ids=GraphList.edge_name(sel)
   case 3 then Ids=string(int(100*GraphList.edge_cost(sel))/100)
   case 4 then Ids=string(GraphList.edge_min_cap(sel))
   case 5 then Ids=string(GraphList.edge_max_cap(sel))
   case 6 then Ids=string(GraphList.edge_length(sel))
   case 7 then Ids=string(GraphList.edge_q_weight(sel))
   case 8 then Ids=string(GraphList.edge_q_orig(sel))
   case 9 then Ids=string(int(100*GraphList.edge_weight(sel))/100)
   case 10 then Ids=string(GraphList.edge_label(sel))
  end
endfunction


function ge_do_information()
//Copyright INRIA
//Author : Serge Steer 2002
// Shows the information about the graph

  execstr(['global EGdata_'+w
	   'GraphList=EGdata_'+w+'.GraphList'])

  r=x_choices('Information can be displayed or sent to file',..
	      list(list('',1,['Send to text file','Send to TeX file'])))
  if r==1 then
    path=xgetfile()
    if path<>'' then
      mputl(ge_make_text_info(),path)
    end
  elseif r==2 then
    path=xgetfile('*.tex')
    if path<>'' then
      mputl(ge_make_tex_info(),path)
    end
  end
endfunction


function txt=ge_make_text_info()
  global %net
  na=%net.gp.link_number
  
  txt=[' ']
  txt=[txt;'Number of nodes : '+string(%net.gp.node_number)];
  txt=[txt;'Number of arcs  : '+string(%net.gp.link_number)];
  txt=[txt;'Number of demands  : '+string(%net.gp.demand_number)];
  txt=[txt;'Link model type  : nf='+string(%net.gp.lpf_model)];
  
  //Information on arcs
  txt=[txt;'';
       'Information on arcs'
       '-------------------';''];
  
  
  w='';
  c=['Nbrs';
     '----';
     string(1:na)'];
  
  c=part(c,1:max(length(c)+1));
  w=w+c;
  
  c=['tail';
     '-----';
     string(%net.links.tail(:))];
  
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;
  
  c=['head';
     '----'
     string(%net.links.head(:))];
  
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;
  
  
  c=['Time     ';
     '---------'
     string(%net.links.time(:))];
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;
  
  c=['t0   ';
     '------'
     string(%net.links.lpf_data(1,:)')];
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;

  
  c=['ca    ';
     '------'
     string(%net.links.lpf_data(2,:)')];
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;
  
  
  c=['ma    ';
     '------'
     string(%net.links.lpf_data(3,:)')];
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;
  
  
  c=['ba    ';
     '------'
     string(%net.links.lpf_data(4,:)')];
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;

  c=['Flow      ';
     '----------'
     string(%net.links.flow(:))];
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;
  

  w=w+'|'
  
  txt=[txt;w];
  
  //Information on demands
  txt=[txt;'';
       'Information on demands'
       '----------------------';''];
  
  nd=%net.gp.demand_number 
  w='';
  c=['Nbrs';
     '----';
     string(na+1:na+nd)'];
  
  c=part(c,1:max(length(c)+1));
  w=w+c;
  
  c=['tail';
     '-----';
     string(%net.demands.tail(:))];
  
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;
  
  c=['head';
     '----'
     string(%net.demands.head(:))];
  
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;
  
  
  c=['Demand';
     '------'
     string(%net.demands.demand(:))];
  c=part(c,1:max(length(c)+1));
  w=w+'|'+c;
  
  w=w+'|'
  txt=[txt;w];
endfunction

///////////////////
function txt=ge_make_tex_info()
  txt=['\documentclass{article}'
       '\begin{document}'
       '\begin{center}'
       '{\large \bf Information about graph : '+GraphList.name+'}'
       '\end{center}'
       '\bigskip\bigskip'
       ' ']
  if GraphList.directed==0 then
    txt=[txt;'Graph is not directed\par'];
  else
    txt=[txt;'Graph is  directed\par'];
  end
  txt=[txt;''];
  nn=size(GraphList.node_x,'*');
  na=size(GraphList.tail,'*');
  txt=[txt;'{\bf Number of nodes:}  '+string(nn)+', {\bf Number of arcs:} '+string(na)];
  
  //Information on nodes
  txt=[txt;'';
       '\section{Information on nodes}';'']
  
  w='';
  edge_length=%f;edge_cost=%f;edge_min_cap=%f;edge_max_cap=%f;
  edge_q_weight=%f;  edge_q_orig=%f;edge_weigh=%f;edge_label=%f;
  
  c=['Numbers'
     string(1:nn)'];
  c=part(c,1:max(length(c)+1));
  w=w+c;
  
  c=['Names'
     GraphList.node_name(:)];
  c=part(c,1:max(length(c)+1));
  w=w+'&'+c;
  
  c=['Types';
     string(GraphList.node_type(:))];
  c=part(c,1:max(length(c)+1));
  w=w+'&'+c;
  
  c=['Demands';
     string(GraphList.node_demand(:))];
  c=part(c,1:max(length(c)+1));
  w=w+'&'+c;
  
  c=['Labels'
     ;string(GraphList.node_label(:))];
  c=part(c,1:max(length(c)+1));
  w=w+'&'+c;
  
  w=w+'\\ \hline'
  
  txt=[txt;
       '\begin{tabular}{|l|l|l|l|l|}\hline';
       w;
       '\end{tabular}'];
  
  //Information on arcs
  txt=[txt;'';
       '\section{Information on arcs}';'']
  
  w='';
  c=['Numbers';
     string(1:na)'];
  
  c=part(c,1:max(length(c)+1));
  w=w+c;
  
  c=['Names';
     GraphList.edge_name(:)];
  
  c=part(c,1:max(length(c)+1));
  w=w+'&'+c;
  
  if or(GraphList.edge_length<>0) then
    c=['Length';
       string(GraphList.edge_length(:))];
    
    c=part(c,1:max(length(c)+1));
    w=w+'&'+c;
    edge_length=%t;
  end
  
  if or(GraphList.edge_cost<>0) then
    c=['Costs';
       string(GraphList.edge_cost(:))];
    c=part(c,1:max(length(c)+1));
    w=w+'&'+c;
    edge_cost=%t;
  end
  
  if or(GraphList.edge_min_cap<>0) then
    c=['Min Capacities';
       string(GraphList.edge_min_cap(:))];
    c=part(c,1:max(length(c)+1));
    w=w+'&'+c;
    edge_min_cap=%t;
  end
  
  if or(GraphList.edge_max_cap<>0) then
    c=['Max Capacities';
       string(GraphList.edge_max_cap(:))];
    c=part(c,1:max(length(c)+1));
    w=w+'&'+c;
    edge_max_cap=%t;
  end
  
  if or(GraphList.edge_q_weight<>0) then
    c=['Quadratic weights';
       string(GraphList.edge_q_weight(:))];
    c=part(c,1:max(length(c)+1));
    w=w+'&'+c;
    edge_q_weight=%t;
  end
  
  if or(GraphList.edge_q_orig<>0) then
    c=['Quadratic origins';
       string(GraphList.edge_q_orig(:))];
    c=part(c,1:max(length(c)+1));
    w=w+'&'+c;
    edge_q_orig=%t;
  end
  
  if or(GraphList.edge_weight<>0) then
    c=['Weights';
       string(GraphList.edge_weight(:))];
    c=part(c,1:max(length(c)+1));
    h    w=w+'&'+c;
    edge_weigh=%t;
  end


  if or(GraphList.edge_label<>'') then
    c=['Labels';
       GraphList.edge_label(:)];
    c=part(c,1:max(length(c)+1));
    w=w+'&'+c;
    edge_label=%t;
  end
  w=w+'\\ \hline'

  t=[edge_length;edge_cost;edge_min_cap;edge_max_cap;
     edge_q_weight;edge_q_orig;edge_weigh;edge_label];
  d='|'+strcat('l'+emptystr(1,size(find(t),'*')+2),'|')+'|'
  w=['\begin{tabular}{'+d+'}\hline';
     w;
     '\end{tabular}'];
  if ~and(t) then
    T=['Empty time';'Time';'to';'ca';
       'ma';'ba';'Flow';'Label'];
    T=T(~t)
    if size(T,'*')==1 then
      txt=[txt;'';strcat(T,', ')+' is set to default values';'\par'];
    else
      txt=[txt;'';strcat(T,', ')+' are set to default values';'\par'];
    end
  end 
  txt=[txt;w;'\end{document}'];
endfunction


// function [Menus,Shorts]=initial_editgraph_tables()
// //Copyright INRIA
// //Author : Serge Steer 2002

// //Editgraph Menu definitions
//   Menus=list(['Graph','New','Zoom','Replot','Find Node','Find Arc','SaveAs','Save','Load',..
// 	      'Options','Settings','Information','Export','Quit'],..
// 	     ['Edit','NewNode','NewArc','Move Node','Move Region',..
// 	      'Copy Region To ClipBoard','Paste','Delete',..
// 	      'Delete Region','Properties','Give Default Names','Undo'],..
// 	     ['Node','Show Numbers','New','Move','Delete','Find','Edit'],..
//              ['Arc','Show Numbers', 'Show Times','Show Flows','New','Delete','Find','Edit'],..
//  	     ['Algorithm','Frank_Wolf','DSD','All-Or-Noth.','IA','Logit','Probit'],..
//  	     ['Customize','Node Diameter','Node Border Width','Font Size','Edge Width'],..
//  	     ['Show','One Node Fields','One Arc Fields','Demands','Data Bases','Nothing'],..
// 	     ['Assign'],..
// 	     ['Help'])
//   Shorts=['d','Delete'; 
// 	  'x','Delete Region'
// 	  'c',"Copy Region To ClipBoard"
// 	  'm','Move Node';      
// 	  'u','Undo';      
// 	  'n','NewNode';   
// 	  'a','NewArc';    
// 	  's','Save';      
// 	  'r','Replot';    
// 	  'q','Quit';  
// 	  'p','Properties';
// 	  'v','Paste'
// 	  'o','Options'
// 	  'l','Load']
// endfunction

function [Menus,Shorts]=initial_editgraph_tables()
//Copyright INRIA
//Author : Serge Steer 2002

//Editgraph Menu definitions
  Menus=list(['Graph','New','Find Node','Find Arc','SaveAs','Save','Load',..
	      'Export ASCII Tex','Export Graph','Quit'],..
	     ['Edit','NewNode','NewArc','Move Node','Move Region',..
	      'Copy Region To ClipBoard','Paste','Delete',..
	      'Delete Region','Attributes','Give default names','Undo'],..
	     ['Compute','AON','Wardrop DSD','Wardrop FW','Logit','Logit Equilibrium','Initialize'],..
	     ['Examples','Steenbrink','Regular City','Sioux Falls','Chicago'],..
	     ['Attribute'],..
	     ['Data'],..
	     ['Customize'],..
	     ['Replot'],..
	     ['Zoom'],..
	     ["Help"])
  Shorts=['d','Delete'; 
	  'x','Delete Region'
	  'c',"Copy Region To ClipBoard"
	  'm','Move Node';      
	  'u','Undo';      
	  'n','NewNode';   
	  'a','NewArc';    
	  's','Save';      
	  'r','Replot';    
	  'q','Quit';  
	  'p','Attributes';
	  'v','Paste'
	  'o','Options'
	  'l','Load']
endfunction


// function ge_do_arcs(item,win)
//   execstr('global EGdata_'+w+';EGdata=EGdata_'+w)
//   if item==1 then EGdata.ArcId='Number'
//   else if item==2 then EGdata.ArcId='Cost'
//   else if item==3 then EGdata.ArcId='Weight'
//    end    
//     execstr('EGdata_'+w+'=EGdata')
//     GraphList=EGdata.GraphList
//     xbasc()
//     ge_set_winsize()
//     ge_drawobjs(GraphList)

//   endfunction

function ge_help(w,b)
  help('edit_graph_menus')
endfunction

function r=ge_compute(kmen,win)
  global %net
  w=string(win)
  mens=['AON','Wardrop DSD','Wardrop FW','Logit','Logit Equil.', ...
	'Initialize'],
  mess=['Assign wit the All or Nothing method.',..
	'Compute the Wardrop equilibrium with DSD method.',..
	'Compute the Wardrop equilibrium with Frank Wolf method.',..
        'Stochastic Assignment with the Logit method.',..
        'Stochastic equilibrium for the Logit modeling',..
	'Traffic reinitialization.'];
  r=%f
  select mens(kmen)
   case "AON" then   
    mess=['Assign wit the All or Nothing method..']  
    xinfo(mess(kmen))
    old=xget('window');xset('window',win);seteventhandler("")
    %net.gp.algorithm="AON"
    TrafficAssig()
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Wardrop DSD" then     
    %net.gp.algorithm="DSD"  
    xinfo(mess(kmen))
    old=xget('window');xset('window',win);seteventhandler("")  
    TrafficAssig()
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Wardrop FW" then   
    %net.gp.algorithm="FW"  
    xinfo(mess(kmen))
    old=xget('window');xset('window',win);seteventhandler("")  
    TrafficAssig()
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Logit" then   
    %net.gp.algorithm="LogitD" 
    xinfo(mess(kmen))
    old=xget('window');xset('window',win);seteventhandler("")  
    TrafficAssig()
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Logit Equil." then   
    %net.gp.algorithm="LogitDE"
    xinfo(mess(kmen))
    old=xget('window');xset('window',win);seteventhandler("")  
    TrafficAssig()
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Initialize" then   
    xinfo(mess(kmen)) 
    old=xget('window');xset('window',win);seteventhandler("")  
    %net.links.flow(:)=0
    %net.links.time(:)=%net.links.lpf_data(1,:)
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
  end
endfunction


function r=ge_examples(kmen,win)
  global %net
  w=string(win)
  mens=['Steenbrink','Regular City','Sioux Falls','Chicago']
  mess=['Steenbrink','Regular City','Sioux Falls','Chicago']
  r=%f
  select mens(kmen)
   case "Steenbrink" then   
    mess=['Assign wit the All or Nothing method..']  
    xinfo(mess(kmen))
    old=xget('window');xset('window',win);seteventhandler("")
    %net=TrafficExample("Steenbrink")
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Regular City" then     
    xinfo(mess(kmen))
    old=xget('window');xset('window',win);seteventhandler("")
    %net=TrafficExample("Regular City",6,6,1)
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Sioux Falls" then   
    xinfo(mess(kmen))
    old=xget('window');xset('window',win);seteventhandler("")  
    %net=TrafficExample("Sioux Falls")
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Chicago" then   
    xinfo(mess(kmen))
    stacksize(100000000)
    old=xget('window');xset('window',win);seteventhandler("")  
    %net=TrafficExample("Chicago")
    %net.gp.ShowDemands=%f
    %net.gp.NodeDiameter=4
    ShowNet()
    seteventhandler("ge_eventhandler") ;xset('window',old)
  end
endfunction


function ge_attribute(kmen,win)    
  w=string(win)
  execstr('global EGdata_'+w+'; mens=EGdata_'+w+'.Menus(1)(2:$)')   
  r=%f
  old=xget('window');xset('window',win);seteventhandler("")  
  ge_do_options()
  seteventhandler("ge_eventhandler") ;xset('window',old)
endfunction

function ge_data(kmen,win)    
  w=string(win)
  execstr('global EGdata_'+w+'; mens=EGdata_'+w+'.Menus(1)(2:$)')   
  r=%f
  old=xget('window');xset('window',win);seteventhandler("")  
  execstr(['global EGdata_'+w
	   'GraphList=EGdata_'+w+'.GraphList'])
  x_message_modeless(ge_make_text_info());
  //    msg=ge_make_text_info()
  //    nl=size(msg)
  //    strg="\n" 
  //    for i=1:nl(1),  
  //      strg=strg+strcat(msg(i,:))+"\n" , 
  //    end;
  //    printf(strg)
  seteventhandler("ge_eventhandler") ;xset('window',old)
endfunction

function ge_customize(kmen,win)    
  w=string(win)
  execstr('global EGdata_'+w+'; mens=EGdata_'+w+'.Menus(1)(2:$)')   
  r=%f
  old=xget('window');xset('window',win);seteventhandler("")  
  ge_do_settings()
  seteventhandler("ge_eventhandler") ;xset('window',old)
endfunction

function ge_replot(kmen,win)    
  w=string(win)
  execstr('global EGdata_'+w+'; mens=EGdata_'+w+'.Menus(1)(2:$)')   
  r=%f
  old=xget('window');xset('window',win);seteventhandler("")  
  execstr('EGdata=EGdata_'+w)
  GraphList=EGdata.GraphList
  xbasc()
  ge_set_winsize()
  ge_drawobjs(GraphList),
  seteventhandler("ge_eventhandler") ;xset('window',old)
endfunction

function ge_zoom(kmen,win)    
  w=string(win)
  execstr('global EGdata_'+w+'; mens=EGdata_'+w+'.Menus(1)(2:$)')   
  r=%f
  old=xget('window');xset('window',win);seteventhandler("")  
  ge_do_zoom()
  seteventhandler("ge_eventhandler") ;xset('window',old)
endfunction

// function r=ge_assign(kmen,win)   
//   old=xget('window');xset('window',win);seteventhandler("")  
//   TrafficAssig() 
//   ShowNet()    
//   seteventhandler("ge_eventhandler") ;xset('window',old)
// endfunction

function r=ge_graph(kmen,win)
//Copyright INRIA
//Author : Serge Steer 2002
  global %net
  w=string(win)
  execstr('global EGdata_'+w+'; mens=EGdata_'+w+'.Menus(1)(2:$)')   


  r=%f
  
  select mens(kmen)
   case "New" then
    old=xget('window');xset('window',win);seteventhandler("")  
    ge_do_new()
    seteventhandler("ge_eventhandler") ;xset('window',old)
    //  case "Zoom" then
    //    old=xget('window');xset('window',win);seteventhandler("")  
    //    ge_do_zoom()
    //    seteventhandler("ge_eventhandler") ;xset('window',old)
    //  case "Replot" then
    //    old=xget('window');xset('window',win);seteventhandler("")  
    //    execstr('EGdata=EGdata_'+w)
    //    GraphList=EGdata.GraphList
    //    xbasc()
    //    ge_set_winsize()
    //    ge_drawobjs(GraphList),
    //    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "SaveAs"
    seteventhandler("")  
    execstr('GraphList=EGdata_'+w+'.GraphList;path=EGdata_'+w+'.Path')
    %net=Graph2Net(GraphList)
    [GraphList,ok,path]=ge_do_SaveAs(GraphList,path)
    if ok then
      ge_drawtitle(GraphList.name)
      execstr('EGdata_'+w+'.GraphList=GraphList;EGdata_'+w+'.Edited=%f;EGdata_'+w+'.Path=path;')
    end
    seteventhandler("ge_eventhandler") 
   case "Save"
    seteventhandler("")  
    execstr('GraphList=EGdata_'+w+'.GraphList;path=EGdata_'+w+'.Path')
    %net=Graph2Net(GraphList)
    ok=ge_do_save(GraphList,path)   
    if ok then
      execstr('EGdata_'+w+'.Edited=%f;')
    end
    seteventhandler("ge_eventhandler") 
   case "Load"
    old=xget('window');xset('window',win);seteventhandler("")  
    execstr('EGdata=EGdata_'+w)
    edited=EGdata.Edited
    [ok,GraphList,edited,path]=ge_do_load()
    if ok then
      EGdata.GraphList=GraphList
      EGdata.Edited=edited
      EGdata.Path=path
      ge_clear_history()
      xbasc()
      ge_set_winsize()
      ge_drawobjs(GraphList),
      execstr('EGdata_'+w+'=EGdata;')
    end
    seteventhandler("ge_eventhandler") ;xset('window',old)
    //  case "Options" then
    //    old=xget('window');xset('window',win);seteventhandler("")  
    //    ge_do_options()
    //    seteventhandler("ge_eventhandler") ;xset('window',old)
    //  case "Settings" then
    //    old=xget('window');xset('window',win);seteventhandler("")  
    //    ge_do_settings()
    //    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Export Graph" then
    old=xget('window');xset('window',win);seteventhandler("")  
    ge_do_export()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Export ASCII Tex" then
    old=xget('window');xset('window',win);seteventhandler("")  
    ge_do_information()
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Find Node" then
    old=xget('window');xset('window',win);seteventhandler("")  
    ge_do_find('Node')
    seteventhandler("ge_eventhandler") ;xset('window',old)
   case "Find Arc" then
    old=xget('window');xset('window',win);seteventhandler("")  
    ge_do_find('Arc')
    seteventhandler("ge_eventhandler") ;xset('window',old)

   case "Quit" then
    old=xget('window');xset('window',win);seteventhandler("")  
    if ge_do_quit() then 
      xdel(win),
    else
      seteventhandler("ge_eventhandler") ;xset('window',old)
    end
  end
endfunction

function r=ge_edit(kmen,win)
//Copyright INRIA
//Author : Serge Steer 2002
  w=string(win)
  mess=['Click on a point to add a node'
	'Left click on first on arc tail node then on arc head node'
	'Left click on a node, move and left click new position'
	'Left click on a point, drag, left click to validate selection, left click to fix position'
	'Left click on a point, drag, left click to validate selection'
	'Left click to fix position'
	'Left click on the node or the arc to delete'
	'Left click on a point, drag, left click to validate selection'
	'Left click on the node or the arc to open properties dialog'
	' ']
  mens=['NewNode','NewArc','Move Node','Move Region',..
	"Copy Region To ClipBoard",'Paste','Delete',..
	'Delete Region','Attributes','Give default names','Undo']
  execstr('global EGdata_'+w+'; EGdata_'+w+'.Cmenu='''+mens(kmen)+'''')
  if mens(kmen)=='Undo' then
    old=xget('window');xset('window',win);seteventhandler("")
    ge_do_undo()
    execstr('global EGdata_'+w+'; EGdata_'+w+'.Edited=%t')
    execstr('EGdata_'+w+'.Cmenu=[]')
    seteventhandler("ge_eventhandler") ;xset('window',old)
  elseif mens(kmen)=='Give default names' then
    old=xget('window');xset('window',win);seteventhandler("")  
    ge_do_default_names()
    execstr('global EGdata_'+w+'; EGdata_'+w+'.Edited=%t')
    execstr('EGdata_'+w+'.Cmenu=[]')
    seteventhandler("ge_eventhandler") ;xset('window',old)
  else
    xinfo(mess(kmen))
  end
  r=%t
endfunction

function GraphList=ge_do_attributes(GraphList,xc,yc)
//Copyright INRIA
//Author : Serge Steer 2002

// Copyright INRIA
  edited=%f
  
  
  
  [k,wh]=ge_getobj(GraphList,[xc;yc])
  if k==[] then return,end
  if wh=='node' then 
    fn=ge_node_fields()
    typ=list();ini=[];
    for f=fn
      x=GraphList(f)(k)
      if type(x)==1 then
	typ($+1)='vec'; typ($+1)=1
	ini=[ini sci2exp(x)]
      elseif type(x)==10 then
	typ($+1)='str'; typ($+1)=-1
	ini=[ini x]
      else
      end
    end
    execstr('[ok,'+strcat(fn,',')+']=getvalue(''Enter Node attributes'',fn,typ,ini)')
    if ~ok then return,end
    Hist=list("node_property",k)
    for f=fn
      if GraphList(f)(k)<>evstr(f) then
	edited=%t,
	Hist($+1)=f;Hist($+1)=GraphList(f)(k);
      end
    end
    if edited
      karcs=find(GraphList.tail==k|GraphList.head==k)
      ge_drawarcs(karcs);ge_drawnodes(k); //erase arcs and node
      for f=fn
	GraphList(f)(k)=evstr(f);
      end
      ge_drawnodes(k);ge_drawarcs(karcs) //redraw
      ge_add_history(Hist)
    end
  else
    fnn=['tail'
	 'head'
	 'edge_name'
	 'edge_color'
	 'edge_width'
	 'edge_hi_width'
	 'edge_font_size'
	 'edge_empty_time'
	 'edge_time'
	 'edge_t0'
	 'edge_ca'
	 'edge_ma'
	 'edge_ba'
	 'edge_flow'
	 'edge_label']'
    fnn(fnn=='head')=[]
    fnn(fnn=='tail')=[]
    fn=ge_arc_fields()
    fn(fn=='head')=[]
    fn(fn=='tail')=[]
    
    typ=list();ini=[];
    for f=fn
      x=GraphList(f)(k)
      if type(x)==1 then
	typ($+1)='vec'; typ($+1)=1
	ini=[ini sci2exp(x)]
      elseif type(x)==10 then
	typ($+1)='str'; typ($+1)=-1
	ini=[ini x]
      else
      end
    end
    execstr('[ok,'+strcat(fn,',')+']=getvalue(''Enter edge attributes'',fnn,typ,ini)')
    if ~ok then return,end
    Hist=list("edge_property",k)
    for f=fn
      if GraphList(f)(k)<>evstr(f) then 
	edited=%t,
	Hist($+1)=f;Hist($+1)=GraphList(f)(k);
      end
    end
    if edited then
      T=GraphList.tail(k);H=GraphList.head(k)
      karcs=find((GraphList.tail==T&GraphList.head==H)|(GraphList.tail==H&GraphList.head==T))
      ge_drawarcs(karcs) //erase arc
      for f=fn
	GraphList(f)(k)=evstr(f);
      end
      ge_drawarcs(karcs) //redraw
      ge_add_history(Hist)
    end
  end
  edited=return(edited)
endfunction

function ge_eventhandler(win,x,y,ibut)
//Copyright INRIA
//Author : Serge Steer 2002

  if or(win==winsid()) then //does the windows still exists
    old=xget('window'); xset('window',win)
    seteventhandler("")  
  else //window has been deleted by an asynchronous xdel()
    ok=ge_do_quit()
    if ~ok then //re_create editgraph window with its menus
      xset('window',win);
      ge_create_menus(win)
      seteventhandler('ge_eventhandler')  
    end
    return
    
  end

  if ibut<0 then 
    if ibut==-1000 then //the window has been closed by the window manager
      ok=ge_do_quit(),
      if ~ok then //re_create editgraph window with its menus
	xset('window',win);
	ge_create_menus(win)
	seteventhandler('ge_eventhandler')   
      end
      return
    end
    seteventhandler("ge_eventhandler"),return,
    
  end

  w=string(win)
  if ibut>2 then 
    if ~ge_shortcut(ibut) then seteventhandler("ge_eventhandler"),xset('window',old),return;end
  end

  execstr('global EGdata_'+w+'; Cmenu=EGdata_'+w+'.Cmenu')

  if Cmenu==[]  then seteventhandler("ge_eventhandler"),xset('window',old), return,end

  [x,y]=xchange(x,y,'i2f')
  GL='EGdata_'+w+'.GraphList';
  xset("alufunction",6),edited=%f
  if Cmenu=="NewNode" then
    execstr(GL+'=ge_add_node('+GL+',node_x=x,node_y=y)')
    edited=%t
  elseif Cmenu=="NewArc" then
    execstr(GL+'=ge_newarc('+GL+',x,y)')
  elseif Cmenu=="Move Node" then  
    execstr(GL+'=ge_do_move('+GL+',x,y)')
  elseif Cmenu=="Move Region" then  
    execstr(GL+'=ge_do_move_region('+GL+',x,y)')
  elseif Cmenu=="Delete" then
    execstr(GL+'=ge_do_delete('+GL+',x,y)')
  elseif Cmenu=="Delete Region" then
    execstr(GL+'=ge_do_delete_region('+GL+',x,y)')
  elseif Cmenu=="Paste" then
    execstr(GL+'=ge_do_paste('+GL+',x,y)') 
  elseif Cmenu=="Attributes" then
    execstr(GL+'=ge_do_attributes('+GL+',x,y)') 
  elseif Cmenu=="Copy Region To ClipBoard"  then
    execstr('ge_copy_region_to_cb('+GL+',x,y)') 
    execstr('EGdata_'+w+'.Cmenu=[]')
  elseif Cmenu=="Undo" then
    ge_do_undo()
    execstr('EGdata_'+w+'.Cmenu=[]')
    //  elseif Cmenu=="Select" then 
    //  to used later for a selection based edition
    //     execstr('ge_do_select('+GL+',x,y)') 
    //    execstr('EGdata_'+w+'.Cmenu=[]')
    
  end  
  execstr('EGdata_'+w+'.Edited=EGdata_'+w+'.Edited|edited')
  seteventhandler("ge_eventhandler")  
  xset('alufunction',3)
  if xget('pixmap') then xset('wshow'),end
  xset('window',old)
endfunction

function ge_do_settings()
//Copyright INRIA
//Author : Serge Steer 2002
  global %net
  execstr('global EGdata_'+w+';EGdata=EGdata_'+w)
  default_node_diam=EGdata.GraphList.default_node_diam
  default_node_border=EGdata.GraphList.default_node_border
  default_edge_width=EGdata.GraphList.default_edge_width
  // default_edge_hi_width=EGdata.GraphList.default_edge_hi_width
  default_font_size=EGdata.GraphList.default_font_size
  if %net.gp.ShowDemands==%f then directed='no',else directed='yes',end
  while %t 
    [ok,default_node_diam,default_node_border,default_font_size,directed]=getvalue('Default parameters',..
						  ['Default Node diameter','Default Border node width',..
		    'Default font size','Show Demands ? (yes/no)'],..
						  list('vec',1,'vec',1,'vec',1,'str',-1),..
						  [string([default_node_diam,default_node_border,default_font_size]),directed])
    if ~ok then return,end
    mess=[]
    if default_node_diam <0 then 
      mess=[mess;'Default Node diameter must be positive']
    end
    if default_node_border <0 then 
      mess=[mess;'Default Node border must be positive']
    end
    //    if default_edge_width <0 then 
    //      mess=[mess;'Default edge width must be positive']
    //    end
    if default_font_size <0 then 
      mess=[mess;'Default font size must be positive']
    end
    directed=convstr(stripblanks(directed))
    if and(directed<>['yes','no']) then
      mess=[mess;'The answer for ""Show Demand ?"" must be ""yes"" or"+...
	    " ""no""']
    elseif directed=='yes' then
      %net.gp.ShowDemands=%t
    elseif directed=='no'
      %net.gp.ShowDemands=%f
    end
    if mess<>[] then
      x_message(mess)
    else
      break
    end
  end
  %net.gp.NodeDiameter=default_node_diam
  %net.gp.NodeBorder=default_node_border
  %net.gp.FontSize=default_font_size
  ShowNet()
  //   EGdata.GraphList.default_node_diam = default_node_diam
  //   EGdata.GraphList.default_node_border = default_node_border
  //   EGdata.GraphList.default_edge_width =default_edge_width 
  //   EGdata.GraphList.default_font_size = default_font_size 
  //   EGdata.GraphList.directed=find(directed==['no','yes'])-1
  //   execstr('EGdata_'+w+'=EGdata')
  //   GraphList=EGdata.GraphList
  //   xbasc()
  //   ge_set_winsize()
  //  ge_drawobjs(GraphList),
endfunction

function ge_drawnodes_0(sel)
  d=matrix(GraphList.node_diam(sel),1,-1)
  if d==[] then return,end
  d(d==0)=GraphList.default_node_diam;
  x=matrix(GraphList.node_x(sel),1,-1)
  y=matrix(GraphList.node_y(sel),1,-1)
  b=matrix(GraphList.node_border(sel),1,-1)
  b(b==0)=GraphList.default_node_border
  c=matrix(GraphList.node_color(sel),1,-1)+15
  arcs=[x-d/2
	y+d/2
	d
	d
	0*d
	360*64*ones(d)];
  for bu=unique(b)
    k=find(b==bu)
    xset("thickness",bu)
    xarcs(arcs(:,k),c(k));
  end
  
  Ids=ge_get_nodes_id(sel)
  if Ids<>[] then//ge_draw the node identification
    f=GraphList.node_font_size(sel)
    f(f==0)=GraphList.default_font_size
    //    xset("font",1,10)
    for k=1:size(Ids,'*')
      xset("font size",ge_font(f(k)));
      r=xstringl(0,0,Ids(k),1,f(k))
      //      xstring(x(k)-r(3)/2,y(k)-d(k)/2-r(4)*1.5,Ids(k))
      //     xstring(x(k),y(k),Ids(k))
      xstring(x(k)-r(3)/4,y(k)-r(4)/4,Ids(k))
    end
  end
endfunction

function ge_drawnodes(sel)
//Copyright INRIA
//Author : Serge Steer 2002

  thick=xget("thickness")
  if or(type(sel)==[2 129]) then 
    sel=horner(sel,size(GraphList.node_x,'*')),
  elseif size(sel,1)==-1 then 
    sel=1:size(GraphList.node_x,'*'),
  end
  t=GraphList.node_type(sel)
  tu=unique(t)
  for tu=unique(t)
    execstr('ge_drawnodes_'+string(tu)+'(sel(t==tu))')
  end
  if xget('pixmap') then xset('wshow'),end
  xset("thickness",thick)
endfunction

function Ids=ge_get_nodes_id(sel)
  execstr('NodeId=EGdata_'+string(win)+'.NodeId')
  Ids=[]
  select NodeId
   case 1 then Ids=string(sel)
   case 2 then Ids=GraphList.node_name(sel)
   case 3 then Ids=string(GraphList.node_demand(sel))
   case 4 then Ids=string(GraphList.node_label(sel))
  end
endfunction

function win=edit_graph(GraphList,%zoom,%wsiz)
// edit_graph - graph editor
//%SYNTAX
// edit_graph(GraphList)
//%PARAMETERS
// GraphList    : scilab list, edit_graph main data structure
//!
//Copyright INRIA
//Author : Serge Steer 2002

// Copyright INRIA
  [lhs,rhs]=argn(0)

  if rhs<2 then %zoom=1,end
  if rhs<3 then %wsiz=[],end 

  //Initialisation
  [Menus,Shorts]=initial_editgraph_tables()

  if winsid()<>[] then 
    old=xget('window');win=max(winsid())+1
  else
    old=[];win=0
  end

  edited=%f
  %path='./'

  //initial graph data structure
  %fil=''
  if rhs>=1 then 
    if type(GraphList)==10 then //diagram is given by its filename
      %fil=GraphList
      [ok,GraphList,edited]=ge_do_load(%fil)
      if ~ok then return,end
    else //diagram is given by its datastructure
      if typeof(GraphList)<>'graph' then 
	error('first argument must be a graph data structure'),
      end
    end
  else //empty graphlist
    GraphList=editgraph_diagram()
  end

  GraphList=ge_complete_defaults(GraphList)


  //initialize graphics
  xset('window',win);
  xset("font",1,10);
  set("figure_style","old")
  xselect();driver('Rec');
  pixmap=%f

  if %wsiz==[] then
    rect=ge_dig_bound(GraphList);
    if rect<>[] then 
      %wsiz=min(%zoom*[rect(3)-rect(1),rect(4)-rect(2)], [1000,800]);
    else
      %wsiz=[600,400]
    end
  end
  xset('wpdim',%wsiz(1),%wsiz(2))

  selection=tlist(['Sel','Nodes','Arcs'],[],[])
  EGdata=tlist(['egdata','GraphList','Cmenu','Win','Zoom', ...
		'Wsize','Menus','Edited','ArcId','NodeId','ShortCuts','Sel','Path'],GraphList,[], ...
	       win,%zoom,%wsiz,[],edited,0,0,[],selection,%fil)
  ge_set_winsize()

  //keyboard shortcuts
  execstr('load .editgraph_short','errcatch')  
  EGdata.ShortCuts=Shorts;

  w=string(win)


  EGdata.Menus=Menus

  //Create the global variable indexed by the editor window number

  execstr('EGdata_'+w+'=EGdata; global  EGdata_'+w+' EGcurrent')
  EGcurrent=win //set current Editgraph window
  ge_clear_history()
  ge_drawobjs(GraphList)
  if xget('pixmap') then xset('wshow'),end
  //create the menu buttons
  ge_create_menus(win)
  seteventhandler('ge_eventhandler')   
  if old<>[] then xset('window',old),end
endfunction

function  ok=ge_do_quit(check_if_edited)
//Copyright INRIA
//Author : Serge Steer 2002
  if argn(2)<1 then check_if_edited=%t,end
  global EGcurrent
  w=string(win)
  execstr('global EGdata_'+w+'; edited=EGdata_'+w+'.Edited')
  if edited&check_if_edited then
    ok=x_message(['Current graph is modified'
		  'Really quit?'],['yes','no'])
    if ok==2 then ok=%f,return,end
  end
  //  seteventhandler('')
  if win==EGcurrent then EGcurrent=[],end
  execstr('clearglobal EGdata_'+w+' EGhist_'+w)
  ok=%t
endfunction
function GraphList=ge_add_node(GraphList,node_x,node_y)
//Copyright INRIA
//Author : Serge Steer 2002

  n=size(GraphList.node_x,'*')+1
  GraphList.node_number=n
  GraphList.node_name(1,n)=""
  GraphList.node_type(1,n)=0;
  GraphList.node_x(1,n)=node_x
  GraphList.node_y(1,n)=node_y
  GraphList.node_color(1,n)=1;
  GraphList.node_diam(1,n)=0
  GraphList.node_border(1,n)=0
  GraphList.node_font_size(1,n)=0
  GraphList.node_demand(1,n)=0;
  GraphList.node_label(1,n)='';
  ge_drawnodes(n) 
  ge_add_history(list('add_node',n))
endfunction
