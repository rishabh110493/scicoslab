scilab_functions =[...
"view";
"matmul";
           ];
auxiliary="";
files=G_make(["tutorial_gateway.o","tutorial.a", auxiliary],"void(Win)");
addinter(files,"tutorial_gateway",scilab_functions);

//same as "exec tutorial.sce"
A=ones(2,2);B=ones(2,2);
C=matmul(A,B);
if norm(A*B-matmul(A,B)) > %eps then pause,end






