mode(-1);

continuous_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(continuous_pathL,SCI,'SCI') );
load( continuous_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ continuous_pathL + 'gif_icons/' ];

clear continuous_pathL

