//
//===========================================================
//

function [f]=LogitD(Adj,D,theta) 
// Affectation stochastique de trafic de type logit
// Ici on considere seulement les chemins efficaces
// qui se rapprochent toujours de la destination.
// -Adj matrice d'adjacence des temps de parcours du reseau
//   ( fortement connexe) 
// -D matrice d'adjacense des demandes de transport
// -theta parametre de degre de stochasticite
//      theta=0 les arcs sortant d'un noeud se rapprochant
//                de la cible sont equiprobable,
//      theta=infini les seuls arcs appartenant aux chemins
//              optimaux sont choisis;
// -f  matrice noeud-noeud des flots.
//
  theta=theta+1.E-10;
  nn=size(Adj,'r');
  [ija,a,dima]=spget(sparse(Adj));
  A1=sparse(ija,exp(-theta*a),dima);
  A0=sparse(ija,ones(size(ija,'r'),1),dima);
  A2=#(sparse(-Adj));
  f=spzeros(nn,nn);
  od=sum(D,'c');
  ir=find(od>0);
  for j=ir
    bj=%zeros(nn,1)
    bj(j,1)=%1
    wj=plustimes(astarb(A2',bj))
    vj=diag(sparse(exp(-wj)))*A0*diag(sparse(exp(wj)))
    A11=A1.*bool2s((vj<1)) 
    AA=speye(nn,nn)-A11 
    bjs=zeros(1,nn)
    bjs(1,j)=1
    Wpl=bjs/AA
    Dp=(D(j,:)./Wpl)'
    Wpr=AA\Dp
    f=f+(Wpl')*(Wpr').*A11
  end
endfunction

//
//================================================================
//
function [f]=LogitB(A,D,theta)
//
// Affectation stochastique de trafic de type logit
// par la methode de Bell ou on considere tous les chemins meme ceux
// qui retournent en arriere.
// -A la matrice noeud-origine noeud-destination des temps de parcours 
//      du reseau (suppose  fortement connexe)
// -D la  matrice noeud-origine noeud-destination
//   des demandes de transport
// -theta parametre de degre de stochasticite
//      theta=0 les arcs sortant d'un noeud se rapprochant
//                de la cible sont equiprobable,
//      theta=infini les seuls arcs appartenant aux chemins
//              optimaux sont choisis;
// -f  matrice noeud-noeud des flots.
//
  nn=size(A,'c')
  [ij,a,mn]=spget(sparse(A))
  W=sparse(ij,exp(-theta*a),mn)
  Wstar=(eye(nn,nn)-W)^(-1)
  f=W.*(Wstar'*(Wstar*(sparse(D)./Wstar)')')
endfunction 

//
//=================================================================
//
function [f]=LogitMD(Adj,D,theta)
// Affectation stochastique de trafic de type logit
// Ici on considere seulement les chemins efficaces
// qui se rapprochent toujours de la destination.
// La matrice de transition est ici normalisee pour
// larendre markovienne.
// -Adj matrice d'adjacence des temps de parcours du reseau
//   ( fortement connexe)
// -D matrice d'adjacense des demandes de transport
// -theta parametre de degre de stochasticite
//      theta=0 les arcs sortant d'un noeud se rapprochant
//                de la cible sont equiprobable,
//      theta=infini les seuls arcs appartenant aux chemins
//              optimaux sont choisis;
// -f  matrice noeud-noeud des flots.
//
  theta=theta+1.e-10
  nn=size(Adj,'r')
  [ija,a,dima]=spget(sparse(Adj))
  A1=sparse(ija,exp(-theta*a),dima)
  A0=sparse(ija,ones(size(ija,'r'),1),dima)
  A2=#(sparse(-Adj))
  f=spzeros(nn,nn)
  [ijd,d,dimd]=spget(sparse(D))
  od=sum(D,'r')
  ir=find(od>0)
  for j=ir
    bj=%zeros(nn,1)
    bj(j,1)=%1
    wj=theta*plustimes(astarb(A2,bj))
    vj=diag(sparse(exp(-wj)))*A0*diag(sparse(exp(wj)))
    AA=A1.*bool2s((vj>1)).*vj 
    nm=sum(AA,'c')
    nm=nm+bool2s((nm==0))
    AN=sparse([[1:nn];[1:nn]]',ones(nn,1)./nm)*AA
    Aj=AN
    Aj(:,j)=[]
    Aj(j,:)=[]
    dj=D(:,j)
    dj(j)=[]
    fj=lusolve(speye(nn-1,nn-1)-Aj',full(dj))
    ff=[fj(1:j-1);0;fj(j:nn-1)]
    f=f+sparse([[1:nn];[1:nn]]',ff)*AN
  end  
endfunction

//
//=============================================================
//

function [f]=LogitMB(Adj,D,theta)
// Affectation stochastique de trafic de type logit
// Ici on considere tous les chemins meme ceux
// qui retournent en arriere. Voir les commentaires et
// differences avec Dial.
//
// -Adj matrice d'adjacence des temps de parcours du reseau
//   ( fortement connexe)
// -D matrice d'adjacense des demandes de transport
// -theta parametre de degre de stochasticite
//      theta=0 les arcs sortant d'un noeud se rapprochant
//                de la cible sont equiprobable,
//      theta=infini les seuls arcs appartenant aux chemins
//              optimaux sont choisis;
// -f  matrice noeud-noeud des flots.
//
  nn=size(Adj,'r')
  [ija,a,dima]=spget(sparse(Adj))
  A1=sparse(ija,exp(-theta*a),dima)
  A2=#(sparse(-Adj))
  f=spzeros(nn,nn)
  [ijd,d,dimd]=spget(sparse(D))
  od=sum(D,'r')
  ir=find(od>0)
  for j=ir
    bj=%zeros(nn,1)
    bj(j,1)=%1
    wj=theta*plustimes(astarb(A2,bj))
    AA=diag(sparse(exp(-wj)))*A1*diag(sparse(exp(wj)))
    nm=sum(AA,'c')
    AN=sparse([[1:nn];[1:nn]]',ones(nn,1)./nm)*AA
    Aj=AN
    Aj(:,j)=[]
    Aj(j,:)=[]
    dj=D(:,j)
    dj(j)=[]
    fj=lusolve(speye(nn-1,nn-1)-Aj',full(dj))
    ff=[fj(1:j-1);0;fj(j:nn-1)]
    f=f+sparse([[1:nn];[1:nn]]',ff)*AN
  end  
endfunction

//
//========================================
//

function LogitN(theta,logittype)
//
// Calcule une affectation logit de type
// logittype appartenant a {logitB (Bell), LogitD (Dial),
// LogitMB (Markov Bell), LogitMD (Markov Dial)}.
// Les donnees sont de type Netlist
// et theta est le degre de stochasticite.
//
//
  global %net
  nn=%net.gp.node_number
  mn=[nn,nn]
  tl=%net.links.tail'
  hd=%net.links.head'
  A=sparse([tl,hd],%net.links.time+1.e-10,mn)
  D=sparse([%net.demands.tail',%net.demands.head'],%net.demands.demand',mn)
  f=logittype(A,D,theta)
  %net.links.flow=full(f((hd-1)*nn+tl))'
endfunction 

//
//
//===================================================================
//

function ben=LogitNE(theta,logittype,eps,Niter,Num)
//
// Calcule un equilibre logit de type
// logittype appartenant a {logitB (Bell), LogitD (Dial), 
// LogitMB (Markov Bell), LogitMD (Markov Dial)}. 
// Les donnees sont de type NetList
// et theta est le degre de stochasticite.
//
//
  global %net;
  %VERBOSE=%net.gp.verbose;
  sz=stacksize();
  %STACKSIZEREF=sz(2);
  Nb=Num;
  er=1;
  temps=0;
  timer();
  //ben=zeros(Niter,5);
  ben=[];
  if %VERBOSE then
    mprintf("  \n");
    mprintf("==================================\n");
    mprintf("| Logit Equil.  %4d %4d %4d  |\n",%net.gp.node_number,..
	    %net.gp.link_number,%net.gp.demand_number);
    mprintf("===========================================================\n")
    mprintf("| It. |   Time  |     Cost        |  Mem. used  | Fl. Er. |\n")
    mprintf("-----------------------------------------------------------\n")
  end;
  while (er>eps)&(Nb<Niter)
    Nb=Nb+1;
    rhon=1/Nb;
    fo=%net.links.flow;
    %net.links.time=lpf(%net.links.flow,%net.links.lpf_data,..
			%net.gp.lpf_model);
    LogitN(theta,logittype);
    %net.links.flow=fo*(1-rhon)+rhon*%net.links.flow;
    er=norm(fo-%net.links.flow,1)/(rhon*(1.e-10+norm(fo,1)));
    temps=temps+timer();
    sz=stacksize();
    stcksz=sz(2)-%STACKSIZEREF;
    [ta,dta,cta]=lpf(%net.links.flow,%net.links.lpf_data,%net.gp.lpf_model);
    cout=sum(cta);
    if %VERBOSE then
      mprintf("| %2d  | %7.2f | %10.9e |   %3.2e  | %2.1e |\n",Nb,temps,cout,stcksz,er);
    end ;
    //ben(Nb,:)=[Nb,temps,cout,stcksz,er];
    ben=[ben;Nb,temps,cout,stcksz,er]
  end
  mprintf("===========================================================\n")
endfunction

function ben=LogitNELS(theta,logittype,eps,Niter)
//
// Calcule un equilibre logit de type
// logittype appartenant a {logitB (Bell), LogitD (Dial), 
// LogitMB (Markov Bell), LogitMD (Markov Dial)}. 
// Les donnees sont de type NetList
// et theta est le degre de stochasticite.
// Utilise une recherche linéaire.
//
  global %net;
  %VERBOSE=%net.gp.verbose;
  sz=stacksize();
  %STACKSIZEREF=sz(2);
  Nb=1;
  er=1;
  temps=0;
  timer();
  ben=[];
  if %VERBOSE then
    mprintf("  \n");
    mprintf("==========================================\n");
    mprintf("| Logit Eq. Lin. Search  %4d %4d %4d  |\n",%net.gp.node_number,..
	    %net.gp.link_number,%net.gp.demand_number);
    mprintf("===========================================================\n")
    mprintf("| It. |   Time  |     Cost        |  Mem. used  | Fl. Er. |\n")
    mprintf("-----------------------------------------------------------\n")
  end;
  %net.links.time=lpf(%net.links.flow,%net.links.lpf_data,..
		      %net.gp.lpf_model);
  LogitN(theta,logittype);
  [ta,dta,cta]=lpf(%net.links.flow,%net.links.lpf_data,..
		   %net.gp.lpf_model);
  cout=sum(cta);
  %net.links.time=ta;
  while (er>eps)&(Nb<Niter)
    Nb=Nb+1;
    fo=%net.links.flow;
    LogitN(theta,logittype);
    [ta,dta,cta]=lpf(%net.links.flow,%net.links.lpf_data,%net.gp.lpf_model);
    cout1=sum(cta)-cout;
    [ta,dta,cta]=lpf((%net.links.flow+fo)/2,%net.links.lpf_data,%net.gp.lpf_model);
    cout2=sum(cta)-cout;
    lambda=max((cout1-4*cout2)/(4*cout1-8*cout2),1/Nb);
    %net.links.flow=fo*(1-lambda)+lambda*%net.links.flow;
    er=norm(fo-%net.links.flow,1)/(lambda*(1.e-10+norm(fo,1)));
    temps=temps+timer();
    sz=stacksize();
    stcksz=sz(2)-%STACKSIZEREF;
    [ta,dta,cta]=lpf(%net.links.flow,%net.links.lpf_data,%net.gp.lpf_model);
    %net.links.time=ta;
    cout=sum(cta);
    if %VERBOSE then
      mprintf("| %2d  | %7.2f | %10.9e |   %3.2e  | %2.1e |\n",Nb,temps,cout,stcksz,er);
    end ;
    ben=[ben;[Nb,temps,cout,stcksz,er]];
  end
  mprintf("===========================================================\n")
endfunction


//
//===================================================================
//

function [Fn,V]=LinearN(Fo,Fi,V,H,D,a)
//
// Iteration de Wardrop 
//
  global %net
  [ta,dta,cta]=lpf(Fo+Fi,%net.links.lpf_data,%net.gp.lpf_model)
  to=ta-dta.*(Fo+Fi)
  R=diag(sparse(unl./(dta+a/10)))
  LnkSgn=diag(sparse(sign(Fo)))
  AL=LnkSgn*H
  A=H'*R*AL+a*speye(nn,nn)
  V=(D+(to*R+Fi)*AL+a*V)/A
  Fn=max(0,(V*H'-to)*R-Fi)

endfunction 

function ben=WardropN(a,k,pre,niter)
//
// Grace a une formulation noeud-arc
// calcule un equilibre de Wardrop par
// un methode de relaxation.
// pre : defini le niveau d'erreur
// niter : le nbre maxi d'iteration
// a : regularise le pb doit etre petit.
//
// Les donnees Globales prise dans %net.
// Les resultats sont mis dans %net.
//
  global %net;
  %VERBOSE=%net.gp.verbose;
  sz=stacksize();
  %STACKSIZEREF=sz(2);
  nd=%net.gp.demand_number;
  nn=%net.gp.node_number;
  nl=%net.gp.link_number;
  numd=[1:nd]';
  temps=0;
  timer();
  //ben=zeros(niter,5);
  ben=[];
  Dh=sparse([numd,%net.demands.head'],%net.demands.demand,[nd,nn]);
  Dt=sparse([numd,%net.demands.tail'],-%net.demands.demand,[nd,nn]);
  d=Dh+Dt;
  und=ones(1,nd);
  D=full(und*d);
  unn=ones(nn,1);
  unl=ones(1,nl);
  zerol=zeros(1,nl);
  numl=[1:nl]';
  Hh=sparse([numl,%net.links.head'],unl,[nl,nn]);
  Ht=sparse([numl,%net.links.tail'],unl,[nl,nn]);
  H=Hh-Ht;
  //
  // Resolution du probleme agrege
  //
  iter=0;
  if %VERBOSE then
    mprintf("  \n");
    mprintf("============================\n");
    mprintf("| Wardrop  %4d %4d %4d  |\n",nn,nl,nd);
    mprintf("===========================================================\n")
    mprintf("| It. |   Time  |     Cost        |  Mem. used  | Fl. Er. |\n")
    mprintf("-----------------------------------------------------------\n")
  end;
  //printf("\n");
  //printf("Initialisation: Aggregated Demand\n");
  //printf("\n");
  //ac=a;
  //err=1;
  //%net.links.flow=ones(1,nl)*sum(Dh)*sqrt(nn)/(3*nl);
  //V=zeros(1,nn);
  //while niter>iter & err>pre;
  //  ac=ac/k;
  //  iter=iter+1;
  //  [F,V]=LinearN(%net.links.flow,zerol,V,H,D,ac);
  //  err=norm(%net.links.flow-F,'inf');
  //  printf("|  %2d  | %2.1e |\n",iter,err);
  //  %net.links.flow=F;
  //end
  //
  // Iteration pour assurer la positivite
  // des flots individuels.
  //
  iter=0;
  err=1;
  ac=a;
  %net.links.flow=ones(1,nl)*sum(Dh)*sqrt(nn)/(3*nl);
  %net.links.disaggregated_flow=zeros(nd,nl);
  w=zeros(nd,nn);
  //for i=1:nd
  //  %net.links.disaggregated_flow(i,:)=%net.links.flow/nd;
  //  w(i,:)=V;
  //end
  while niter>iter & err>pre
    f=%net.links.flow;
    ac=ac/k;
    iter=iter+1;
    for i=1:nd
      qo= %net.links.disaggregated_flow(i,:);
      fi=f-qo;
      iteri=0;
      erri=1;
      di=d(i,:);
      v=w(i,:);
      while niter>iteri & erri>pre
	iteri=iteri+1;
	[qn,v]=LinearN(qo,fi,v,H,di,ac);
	erri=norm(qn-qo);
	qo=qn;
      end
      %net.links.disaggregated_flow(i,:)=qn;
      f=fi+qn;
      w(i,:)=v;
    end 
    err=norm(f-%net.links.flow,'inf');
    %net.links.flow=und*%net.links.disaggregated_flow;
    [ta,dta,cta]=lpf(%net.links.flow,%net.links.lpf_data,%net.gp.lpf_model);
    cout=sum(cta);
    %net.links.time=ta;
    temps=temps+timer();
    sz=stacksize();
    stcksz=sz(2)-%STACKSIZEREF;
    if %VERBOSE then
      mprintf("| %2d  | %7.2f | %10.9e |   %3.2e  | %2.1e |\n",iter,temps,cout,stcksz,err);
    end ;
    //ben(iter,:)=[iter,temps,cout,stcksz,err];
    ben=[ben;[iter,temps,cout,stcksz,err]];
  end
  errV=0;
  errQ=0;
  //
  // Verifie les conditions d'optimalite
  //
  for i=1:nd
    [ta,dta,cta]=lpf(%net.links.flow,%net.links.lpf_data,%net.gp.lpf_model);
    errV=max(errV,norm((w(i,:)*H'-ta)*..
		       diag(sparse(sign(%net.links.disaggregated_flow(i,:)))),"inf"));
    errQ=max(errQ,norm(%net.links.disaggregated_flow(i,:)*H-d(i,:),"inf"));
  end
  if %VERBOSE then;
    mprintf("===========================================================\n")
    mprintf("|errV=%2.1e|errQ=%2.1e|\n",errV/(norm(w,"inf")+1.e-10),..
	    errQ/(1.e-10+norm(d,"inf")));
    mprintf("===========================\n");
  end ;
endfunction
