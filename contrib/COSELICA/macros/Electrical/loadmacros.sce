mode(-1);

electrical_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(electrical_pathL,SCI,'SCI') );
load( electrical_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ electrical_pathL + 'gif_icons/' ];

clear electrical_pathL

