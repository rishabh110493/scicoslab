mode(-1);

planar_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(planar_pathL,SCI,'SCI') );
load( planar_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ planar_pathL + 'gif_icons/' ];

clear planar_pathL

