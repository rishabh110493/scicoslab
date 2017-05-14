mode(-1);

rotational_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(rotational_pathL,SCI,'SCI') );
load( rotational_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ rotational_pathL + 'gif_icons/' ];

clear rotational_pathL

