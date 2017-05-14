mode(-1);

utils_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(utils_pathL,SCI,'SCI') );
load( utils_pathL + 'lib' );

mprintf( '%s\n', ' Adding Scicos menu ' + utils_pathL + 'cos_add_menus.sce' );
exec( utils_pathL + 'cos_add_menus.sce', -1 );

clear utils_pathL

