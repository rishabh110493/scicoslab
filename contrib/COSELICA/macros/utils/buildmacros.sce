mode(-1);

libname='cosUTILS';

path= get_absolute_file_path('buildmacros.sce');
path=strsubst(path,SCI,'SCI');
mprintf( ' %s\n', 'Building macros in ' + path );
genlib( libname + 'lib', path, %t );
clear libname path 

