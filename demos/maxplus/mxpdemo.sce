//diary('COURS/boutheon.diary')
mode(-1)
x_message([..
    "   Max_Plus Linear Systems in Scilab and Application to ",..
    "                 Production Systems                     ",..
    "          G. Cohen, S.Gaubert & J.P. Quadrat            ",..
    "                                                        ",..
    "                                                          ",..
    "                      OUTLINE:                            ",..
    "                                                          ",..
    " 1) Max-Plus Types, Scalars and Matrices                  ",..
    " 2) State Space Representation of Linear Systems          ",.. 
    " 3) Application to Production Systems                     ",..
    "   3.1) Critical Circuit and Pallet Optimization          ",.. 
    "   3.2) Simulation and Transient Behaviour                "]);

x_message(["",..
"  1) MAX-PLUS TYPE, SCALARS AND MATRICES"]);
mode(7);
//
// Standard type
a=2
type(a)
// Max-plus type
b=#(3)
type(b)
// Changing type
plustimes(b)
type(ans)
// Max-Plus Zero
%0
type(%0)
// Standard infinity
%inf
type(%inf)
// Max-plus one
%1
// Max-plus operations
b
type(b)
b + %0
b * %1
b + b
b * b
b / b
b & %0
b == b
b <> b
b >= b
b > b
// Operation between objects of different types
b+3
type(ans)
b*3
// Max-plus matrix creation
//
// from a max-plus scalar
c=[b,4;5,6]
type(c)
// from a standard matrix
d=[1,2;3,4]
type(d)
e=#(d)
type(e)
// by extraction
f=e(1,:)
type(f)
// by insertion
e(5,5)=6
type(e)
// Important matrices
%ones(2,5)
%eye(2,5)
g=%zeros(2,5)
// g is a sparse matrix
type(g)
// changing a sparse in a full matrix
full(g)
type(ans)
// changing a full in sparse matrix
%ones(2,5)
sparse(ans)
type(ans)
// Max-plus operations with matrices
c
d
c + d
c * c
c / c
d & c
star(c)
c == c
c <> c
d > c
// Column concatenation
h=[e,e]
// Row concatenation
i=[e;e]
size(i)
// Extraction
i([1,3],:)
// Spectral computation
c
[chi,v]=howard(c)
// chi provides the eigenvalue (here unique), v is an eigenvector
chi(1)*v==c*v
// The spectral elements give the asymptotic behaviour
x=[%1;%0]
[x,c*x,c*c*x,c*c*c*x,c*c*c*c*x]
// Howard is a "linear" in the number of arcs
timer();
[chi,v]=howard(#(sprand(10000,10000,0.0005)+0.001*speye(10000,10000)));
timer()
chi(1:10)
mode(-1);
x_message(["",..
" 2) STATE SPACE REPRESENTATION OF MAX-PLUS LINEAR SYSTEMS",..
"                                                         ",..
" Creation of max-plus dynamical linear systems in implicit state form :",..
"                                                                       ",..
"     X(n)=DX(n)+AX(n-1)+BU(n),  Y(n)=CX(n)",..
"                                           "]);
mode(7);
s1=mpsyslin([1,2;3,4],[0;0],[0,0],%eye(2,2))
s1('D')
s1('X0')
s1=full(s1)
s1('X0')
explicit(s1)
s2=mpsyslin([1,2,3;4,5,6;7,8,9],[0;0;0],[0,0,0],%eye(3,3))
s2=sparse(s2);
//
// System operators have the same syntax as the matrix ones
//
// Diagonal composition
s4=s1|s2
// Parallel composition
s3=s1+s2
// Series composition
s1*s2
// Input in common
[s1;s2]
// Output addition
[s1,s2]
// Feedback composition
s1/.s2
// Extraction 
s4=full(s4)
s4(1,1)
// Simulation
y=simul(s1,[1:10])
plot2d(y')
mode(-1);
x_message(["",..
" 3) APPLICATION TO PRODUCTION SYSTEMS "]);
mode(7)
//
// Entering the processing times of a flowshop
//
PT=[#(2),3.9,0.95,1.1,0.7,1.4;
%0,%0,2,1.2,%0,1.7;
3.7,%0,2.2,%0,6.4,%0;
%0,%0,2,%0,1,1;
1.7,3.1,3,%0,1.3,%0;
0.5,3.2,4.3,1.9,1.6,0.4;
1,1,1,1,1,1;
1.5,1.5,1.5,1.2,1.2,1.2]
//
[nmach,npiece]=size(PT)
//
// Entering the machine numbers
//
nm=ones(1,nmach)

//
// Entering the pallet numbers
//
np=ones(1,npiece)
//
// Graphic representation of the cyclic flowshop
//
//xbasc();
//xset('window',1);
xsetech([0,0,0.7,0.7]);
[g,T,N]=flowshop_graph(PT,nm,np,50);
//
// Computation of the throughput by the Howard algorithm
//
[chi,v]=semihoward(T,N);
chi'
v'
//
// Showing the critical circuit
//
show_cr_graph(g);
mode(-1);
x_message([..
" 3.1) OPTIMISATION OF THE PALLET NUMBERS"]);
mode(7)
//
// First modification of the  pallet numbers
//
pnb=[1,16,28,46,58,74];
g('edge_length')(pnb)=[1,1,2,1,1,1];
//
// The new critical circuit
//
show_cr_graph(g);
//
// Second modification of the pallet numbers
//
g('edge_length')(pnb)=[1,2,2,1,2,1];
//
// The new critical circuit
//
show_cr_graph(g);
//
// Third modification of the pallet numbers
//
g('edge_length')(pnb)=[2,2,2,1,2,1];
//
// The new critical circuit
//
show_cr_graph(g);
//
// Fourth modification of the pallet numbers
//
g('edge_length')(pnb)=[2,2,2,1,2,2];
//
// The new critical circuit
//
show_cr_graph(g);
//
// Fifth modification of the pallet numbers
//
g('edge_length')(pnb)=[2,2,2,2,2,2];
//
// The final  critical circuit with saturation of the slowest machine
//
show_cr_graph(g);
mode(-1);
x_message([..
" 3.2) STATE SPACE REPRESENTATION AND SIMULATION"]);
mode(7)
//
// Open-loop flowshop state space 4-uple
//
s=flowshop(PT)
//
nm
//
// Building shift in counting system associated
//  to machine tokens
//
fbm=shift(nm(1),0) ;
for i=1:nmach-1, fbm=fbm|shift(nm(i),0) ; end ;
//
np
//
// Building shift in counting system associated
//   to pallet tokens 
//
fbp=shift(np(1),0);
for i=1:npiece-1, fbp=fbp|shift(np(i),0) ; end ;
fbp
//
// Building the feedback system
//
sb=s/.(fbp|fbm);
//
//  Reducing and putting in explicit form
//
sbs=explicit(sb);
//
// Simulation of the feedback system
//
u=ones(nmach+npiece,1)*(1:100);
y=simul(sbs,u);
y(:,100)'
//
// Plotting ouputs
//
xset('window',0);
//xsetech([0 0 0.5 0.5]);
xbasc(); plot2d(y(:,[1:100])');
//
// Elimination of the drift term
//
chi=howard(sbs('A'));
chit=plustimes(chi(1))*[1:100];
y=plustimes(y)-ones(nmach+npiece,1)*chit;
xbasc(); plot2d(y(:,[1:15])');
//
// Another case 
//
np=2*ones(1,npiece); nm=3*ones(1,nmach);
[chi,y]=flowshop_simu(s,nm,np,u);
xbasc(); plot2d(y(:,[1:100])');
//
// What happens at the beginning ?
//
xbasc(); plot2d(y(:,[1:15])');
//
// Let us see the corresponding critical graph
//
mnb=[2,30,4,34,6,8,10,12];
g('edge_length')(mnb)=nm;
g('edge_length')(pnb)=np;
// xbasc(); 
//xsetech([0 0 0.7 0.7]);
xset('window',1);
show_cr_graph(g);
//
// Periodicity 3
//
np=3*ones(1,6); nm=3*ones(1,8);
[chi,y]=flowshop_simu(s,nm,np,u);
//xsetech([0 0 0.5 0.5]);
xset('window',0);
xbasc(); plot2d(y(:,[1:100])');
xbasc(); plot2d(y(:,[1:15])');
mode(-1);
x_message([..
"   THE END  "]);
