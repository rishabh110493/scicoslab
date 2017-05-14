mode(-1);

translational_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(translational_pathL,SCI,'SCI') );
load( translational_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ translational_pathL + 'gif_icons/' ];

clear translational_pathL

