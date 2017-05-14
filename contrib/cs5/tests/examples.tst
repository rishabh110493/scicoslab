// Wed Jan 22 17:39:10 CET 2003
//====================================================
// ../man/AON.man
//====================================================
net=TrafficExample('Small');
F=AON(net)
//====================================================
// ../man/AONd.man
//====================================================

%net=TrafficExample('Nguyen Dupuis');
// we can see the Net
ShowNet();
//we add a non feasible OD pair
AddDemands(8,1,10);
ShowNet()
[F,f]=AONd(%net);


//====================================================
// ../man/AddDemands.man
//====================================================

%net=TrafficExample('Diamond');
ShowNet()
// Add a new demand from node 3 to node 2 with value 10 in the same net
AddDemands(3,2,10);
// We can see the modifications with
ShowNet()

//====================================================
// ../man/AddLinks.man
//====================================================

%net=TrafficExample('Diamond');
ShowNet()
// Add a new link from node 3 to node 4 with lpp=[0;0;1;1]
AddLinks(3,4,[0;0;1;1]);
// We can see the modifications with
ShowNet()

//====================================================
// ../man/AddNodes.man
//====================================================

%net=TrafficExample('Diamond');
ShowNet()
// Add 2 new nodes with coordinates x=[346,346] and y=[559,-50]
AddNodes([346,346],[559,-50]);
// We can see the modifications with
ShowNet()


//====================================================
// ../man/CAPRES.man
//====================================================

net=TrafficExample('Small');
[f,t]=CAPRES(net);


//====================================================
// ../man/DSD.man
//====================================================

net=TrafficExample("Steenbrink");
// uses the example net Steenbrink
[f,F,ta,ben]=DSD(net,5,0,1e-6,[1e-6,1e-7,1e-7],[5,50,100]);


//====================================================
// ../man/ExportMI.man
//====================================================


//====================================================
// ../man/FW.man
//====================================================

net=TrafficExample("Small");
/// generates a network with 4 nodes, 9 arcs and 2 OD-pairs
[F,ta,ben]=FW(net);


//====================================================
// ../man/Graph2Net.man
//====================================================
%net=TrafficExample('Empty');
ShowNet()
// Now you can edit in the scigraph window following the
// color conventions  to  distinguish the demands  from
// the links and then save the graph.
//g=load_graph('name.graph');
//%net=Graph2Net(g); // By default nf=6
//// You can check if the net is the same you saved.
//ShowNet()


//====================================================
// ../man/IA.man
//====================================================

net=TrafficExample('Small');
[f,ta]=IA(net,10);


//====================================================
// ../man/IAON.man
//====================================================

net=TrafficExample('Small');
[f,ta,ben]=IAON(net,10);


//====================================================
// ../man/ImportMI.man
//====================================================

//// MapInfo translation from the files SGL_Versailles.mid and SGL_Versailles.mif
//// regular town example with four modes and two classes
[%net,color,Bidir]=ImportMI(CS_DIR+"/examples/SGL_Versailles");
//// Show the translated arcs in Scilab
ShowNet()
//// Now you can add demands with AddDemands and the compute the assignment

//====================================================
// ../man/LogitB.man
//====================================================

// Graph generation (the graph must be stongly connected),
// n is the number of nodes, m the number of arcs.
n=10; m=40;
c1=m/(n*n);
A=sprand(n,n,c1)+diag(sparse(ones(n-1,1)),1);
A(n,1)=1;A=A-diag(diag(A));
// Demand generation, p is the number of demand.
p=30; c2=p/(n*n);D=sprand(n,n,c2);D=D-diag(diag(D));
//theta definition (almost determinsitic)
theta=10;
// Flow calculation
FD=LogitB(A,D,theta);

//====================================================
// ../man/LogitD.man
//====================================================

// Graph generation (the graph must be stongly connected),
// n is the number of nodes, m the number of arcs.
n=10; m=40;
c1=m/(n*n);
A=sprand(n,n,c1)+diag(sparse(ones(n-1,1)),1);
A(n,1)=1;A=A-diag(diag(A));
// Demand generation, p is the number of demand.
p=30; c2=p/(n*n);D=sprand(n,n,c2);D=D-diag(diag(D));
//theta definition (almost determinsitic)
theta=10
// Flow calculation
FD=LogitD(A,D,theta)


//====================================================
// ../man/LogitMB.man
//====================================================

// Graph generation (the graph must be stongly connected)
// n is the number of nodes, m the number of arcs
n=10; m=40;
c1=m/(n*n);
A=sprand(n,n,c1)+diag(sparse(ones(n-1,1)),1);
A(n,1)=1;A=A-diag(diag(A));
// Demand generation, p is the number of demand.
p=30;c2=p/(n*n);D=sprand(n,n,c2);D=D-diag(diag(D));
//theta definition (almost determinsitic)
theta=10
// Flow calculation
FD=LogitMB(A,D,theta)

//====================================================
// ../man/LogitMD.man
//====================================================

// Graph generation (the graph must be stongly connected)
// n is the number of nodes, m the number of arcs
n=10; m=40;
c1=m/(n*n);
A=sprand(n,n,c1)+diag(sparse(ones(n-1,1)),1);
A(n,1)=1;A=A-diag(diag(A));
// Demand generation, p is the number of demand.
p=30; c2=p/(n*n);D=sprand(n,n,c2);D=D-diag(diag(D));
//theta definition (almost determinsitic)
theta=10
// Flow calculation
FD=LogitMD(A,D,theta)

//====================================================
// ../man/LogitN.man
//====================================================

// Graph generation (the graph must be stongly connected)
%net=TrafficExample("Steenbrink");
//theta definition (almost determinsitic)
theta=10;
// Flow calculation
LogitN(theta,LogitMB)
ShowNet()



//====================================================
// ../man/LogitNE.man
//====================================================

// Graph generation (the graph must be stongly connected)
%net=TrafficExample("Steenbrink");
//theta definition (almost determinsitic)
theta=10
// Flow calculation
LogitNE(theta,LogitMD,1.e-6,30,0)
ShowNet()

//====================================================
// ../man/LogitNELS.man
//====================================================

// Graph generation (the graph must be stongly connected)
%net=TrafficExample("Steenbrink");
//theta definition (almost deterministic)
theta=10
// Flow calculation
LogitNELS(theta,LogitMD,1.e-6,40);
ShowNet()


//====================================================
// ../man/MSA.man
//====================================================

net=TrafficExample("Steenbrink");
[f,s,ben]=MSA(net,15,1e-3);



//====================================================
// ../man/MSASUE.man
//====================================================

net=TrafficExample("Small");
[f,s,ben]=MSASUE(net,1,15,1e-3);



//====================================================
// ../man/MakeNet.man
//====================================================

// Coordinates for the nodes
nx=[500 10 500 900]
ny=[10 300 600 300]
// tail and head vectors for the links
tl=[1 2 3 1 1 3]
hl=[2 3 4 4 3 1]
// link-performance-function parameters
lpp=[1 1 1 1 1 1;1 3 5 2 7 1;1 2 1 2 1 2;2 2 2 2 2 2];
// Creation of the traffic net
%net=MakeNet(4,nx,ny,tl,hl,6,lpp,1,3,10);
// We can see it with
ShowNet()



//====================================================
// ../man/Net2Par.man
//====================================================

net=TrafficExample('Sioux Falls');
[g,d,lpp,nf]=Net2Par(net);


//====================================================
// ../man/NetList.man
//====================================================


//====================================================
// ../man/Par2Net.man
//====================================================

net=TrafficExample('Sioux Falls');
[g,d,lpp,nf]=Net2Par(net);
net2=Par2Net(g,d,lpp,nf);


//====================================================
// ../man/Probit.man
//====================================================

net=TrafficExample("Small");
ta=net.links.lpf_data(1,:);
// uses the example net Small
[f,s]=Probit(net,ta,0.1,0.001,7);



//====================================================
// ../man/RandomNNet.man
//====================================================

%net=RandomNNet(3,3,1,2);
// generates a network with 3 nodes,2 OD-pairs and form
// each node the number of leaving arcs is normally dis-
// tributed with mean 3 and var 1
ShowNet();


//====================================================
// ../man/RandomNet.man
//====================================================

%net=RandomNet(3,5,2);
// generates a network with 3 nodes, 5 arcs and 2 OD-pairs
ShowNet();


//====================================================
// ../man/Regular.man
//====================================================

%net=Regular(4,5);
// generates a network with 4 horizontal streets, 5 vertical streets, 
// (20 nodes, 31 arcs) and all possible OD-pairs:343 
ShowNet();

%net=Regular(4,5,1);
// generates only one demand
ShowNet();

%net=Regular(4,5,0.5);
// generates randomly the OD-pairs with density 0.5
ShowNet();

%net=Regular(4,5,7);
// generates 7 random OD-pairs
ShowNet();



//====================================================
// ../man/ShowDemands.man
//====================================================

%net=TrafficExample('Steenbrink');
ShowDemands() // Shows the net
ShowDemands('all','between',100,200)
ShowDemands('used','between',100,200)
// Shows the net with the demands between 100 and 200,
// and the used nodes.
ShowDemands('used',[1 3 8 12],100,200)
// Shows the given demands with values between 100 and 200


//====================================================
// ../man/ShowLinks.man
//====================================================

%net=TrafficExample('Steenbrink');
%net.gp.algorithm='AON';
TrafficAssig();
ShowLinks() // Shows the net
ShowLinks('used','between',3000,6000,0,0,3)
// Shows the net with the flow corresponding to demand 3, 
// the light blue arcs are not used by the commodity 3
// but by other commodities. The width corresponds to
// the flow of the commodity 3. The arcs not shown have
// total flow less than 3000 or greater than 6000.


//====================================================
// ../man/ShowNet.man
//====================================================

%net=TrafficExample('Steenbrink');
%net.gp.algorithm='DSDisaggregated';
TrafficAssig();
ShowNet() // Shows the net
ShowNet('used','between',1000,2000,0,0,3,0,10000,3)
// Shows the net with the flow corresponding to demand 3,
// the light blue arcs are not used by the commodity 3
// but by other commodities. The width corresponds to
// the flow of the commodity 3. The arcs not shown have
// total flow less than 1000 or greater than 2000.


//====================================================
// ../man/TrafficAssig.man
//====================================================

//
// To load an editable traffic network graph
//
%net=TrafficExample("Steenbrink");
ShowNet();
//
// The black arcs are the roads and the cyan ones are the
// traffic OD demands. We can edit the net (see the net-edition demo).
//
// To compute the traffic assignment with "DSD" algorithm
//
TrafficAssig();
ShowNet();
//
// To show  the travel times select GRAPH/Display arc names/Time
//
// It is possible to assign the flow using another algorithm
// for example the incremental assignment denoted  "IA"
//
%net.gp.algorithm="IA"
%net.gp.Niter=50;
TrafficAssig();
ShowNet();
//
// For Logit assignment, the stochasticity parameter
// is in the field %net.gp.theta (default 1)
//
%net.gp.algorithm='LogitMD';
%net.gp.theta=3;
TrafficAssig();
ShowNet();
//


//====================================================
// ../man/TrafficExample.man
//====================================================

%net=TrafficExample("Sioux Falls");
ShowNet()



//====================================================
// ../man/WardropN.man
//====================================================


// Definition of the Network
nw=4;
%net=TrafficExample("Regular City",nw,nw,256);

// Traffic Assignment
bench=WardropN(0.1,2,1.e-4,12);

// Visualization of the NET
ShowNet();
//====================================================
// ../man/dlpf.man
//====================================================

net=TrafficExample('Small');
[g,d,lpp]=Net2Par(net);
dlpf(0.1,.01,2,lpp,6); // show the function with the different parameters


//====================================================
// ../man/lpf.man
//====================================================

net=TrafficExample('Small');
[g,d,lpp,nf]=Net2Par(net);
F=rand(1,9);
[ta,dta,cta]=lpf(F,lpp,nf) 
// shows the function with the different parameters
dlpf(0.1,.01,5,lpp,6);


