mode(-1);

nonlinear_pathL=get_absolute_file_path('loadmacros.sce');

mprintf( '%s\n', ' Loading macros in ' + strsubst(nonlinear_pathL,SCI,'SCI') );
load( nonlinear_pathL + 'lib' );

// icons for pal tree
%scicos_gif($+1)=[ nonlinear_pathL + 'gif_icons/' ];

clear nonlinear_pathL

