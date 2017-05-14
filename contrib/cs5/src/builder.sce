// This is the builder.sce 
// must be run from this directory 

ilib_name  = 'libCS' ;		// interface library name 

// objects files 

files=['interCS.obj';'costo.obj';'derivada.obj';
       'fbpv.obj';'flujo.obj';'flujototal.obj';
       'simp2.obj';'qksp.obj'];

libs  = [] ;				// other libs needed for linking

// table of (scilab_name,interface-name) 
// for fortran coded interface use 'C2F(name)'

funciones=['Costo';'DH';'FBPV';'Flujo';'FlujoT';'simplify';'qksp'];
table =[funciones, 'i'+funciones];

// do not modify below 
// ----------------------------------------------
ilib_build(ilib_name,table,files,libs)
