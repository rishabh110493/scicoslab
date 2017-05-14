mode(-1);

// [1] macros directory 

libname='CSlib'
DIR=SCI+'/contrib/cs5';

genlib('cs5lib','SCI/contrib/cs5/macros');
genlib('metanetlib','SCI/contrib/cs5/metanet');

// [2] src directory 

if c_link('libCS') 
  write(%io(2),'please do not rebuild a shared library while it is linked')
  write(%io(2),'in scilab. use ulink to unlink first');
else 
  chdir(DIR+'/src') 
  exec builder.sce 
end 

// [3] generate Path.incl 

F=mopen(DIR+'/Path.incl','w');
mfprintf(F,'SCIDIR='+SCI+'\n');
mfprintf(F,'SCIDIR1='+strsubst(SCI,'/','\\')+'\n');
mclose(F);

clear DIR libname genlib get_file_path F





