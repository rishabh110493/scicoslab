// This is the builder.sce 
// must be run from this directory 

lines(0);

ilib_name  = 'libexamples' 		// interface library name 


// objects files 

files = ['ex01intc.o'
	 'ex01intf.o'
	 'ex02intc.o'
	 'ex02intf.o'
	 'ex03intc.o' 
	 'ex04intc.o' 
	 'ex04intf.o' 
	 'ex05intc.o'
	 'ex06intc.o'
	 'ex07intc.o'
	 'ex08intc.o'
	 'ex09intc.o'
	 'ex09intf.o'
	 'ex10intc.o'
	 'ex11intc.o'
	 'ex12intc.o'
	 'ex12intf.o' 
	 'ex13intc.o'
	 'ex13intf.o'
	 'ex14intc.o'
	 'ex14intf.o'
	 'ex15intc.o'
	 'ex15intf.o'
	 'ex15f.o' 
	 'ex16intc.o'
	 'ex17intc.o'];


libs  = [] 				// other libs needed for linking

// table of (scilab_name,interface-name) 
// for fortran coded interface use 'C2F(name)'

table =['ex1c',		'intex1c';
	'ex1f',		'C2F(intex1f)';
	'ex2c_1',	'intex2c_1';
	'ex2c_2',	'intex2c_2';
	'ex2f_1',	'C2F(intex2f1)';
	'ex2f_2',	'C2F(intex2f2)';
	'ex3c_1',	'intex3c_1';
	'ex3c_2',	'intex3c_2';
	'ex3c_3',	'intex3c_3';
	'ex4c_1',	'intex4c_1';
	'ex4c_2',	'intex4c_2';
	'ex4c_3',	'intex4c_3';
	'ex4c_4',	'intex4c_4';
	'ex4f_1',	'C2F(intex4f1)';
	'ex4f_2',	'C2F(intex4f2)';
	'ex4f_3',	'C2F(intex4f3)';
	'ex4f_4',	'C2F(intex4f4)';
	'ex5c_1',	'intex5c_1';
	'ex5c_2',	'intex5c_2';
	'ex6c_1',	'intex6c_1';
	'ex6c_2',	'intex6c_2';
	'ex6c_3',	'intex6c_3';
	'ex6c_4',	'intex6c_4';
	'ex7c_1',	'intex7c_1';
	'ex7c_2',	'intex7c_2';
	'ex7c_3',	'intex7c_3';
	'ex8c_1',	'intex8c_1';
	'ex8c_2',	'intex8c_2';
	'ex9c_1',	'intex9c_1';
	'ex9c_2',	'intex9c_2';
	'ex9c_3',	'intex9c_3';
	'ex9c_4',	'intex9c_4';
	'ex9f_1',	'C2F(intex9f1)';
	'ex9f_2',	'C2F(intex9f2)';
	'ex9f_3',	'C2F(intex9f3)';
	'ex9f_4',	'C2F(intex9f4)';
	'ex10c_1',	'intex10c_1';
	'ex10c_2',	'intex10c_2';
	'ex10c_3',	'intex10c_3';
	'ex10c_4',	'intex10c_4';	
	'ex11c',	'intex11c';
	'ex12c',	'intex12c';
	'ex12f',	'C2F(intex12f)';
	'ex13c_1',	'intex13c_1';
	'ex13c_2',	'intex13c_2';
	'ex13c_3',	'intex13c_3';
	'ex13f_1',	'C2F(intex13f1)';
	'ex13f_2',	'C2F(intex13f2)';
	'ex13f_3',	'C2F(intex13f3)';
	'ex14c',	'intex14c';
	'ex14f',	'C2F(intex14f)';
	'ex15c',	'intex15c';
	'ex15f',	'intex15f';
	'ex16c',	'intex16c';
	'ex17c',	'intex17c_1'];


// extra parameters can be transmited to the linker 
// and to the C and Fortran compilers with 
// ldflags,cflags,fflags 
// for example to link a set of routines using the 
// ImageMagick library 
//  ldflags = "`Magick-config --ldflags --libs`"; 
//  cflags  = "`Magick-config --cppflags`"; 
//  fflags   = ""; 

ldflags = "";
cflags ="";
fflags ="";

// do not modify below 
// ----------------------------------------------
ilib_build(ilib_name,table,files,libs,'Makelib',ldflags,cflags,fflags)










