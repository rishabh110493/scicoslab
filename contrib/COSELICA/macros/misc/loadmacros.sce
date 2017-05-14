mode(-1);

misc_pathL=get_absolute_file_path('loadmacros.sce');

mprintf(" Temporary fix: getf " + misc_pathL + "IMPSPLIT_f.sci\n");
getf( misc_pathL + 'IMPSPLIT_f.sci' );

clear misc_pathL

