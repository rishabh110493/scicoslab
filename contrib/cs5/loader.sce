// loader for CiudadSim
mode(-1);

libname='CSlib'
DIRCS4=SCI+'/contrib/cs5'

mess=[' --------------------------------------------';
      ' CiudadSim toolbox loaded, help menu updated.';
      '     Standard edit_graph has been modified   '; 
      ' Enter edit_graph at Scicoslab prompt-->     ';
      ' --------------------------------------------'];
libtitle=['Traffic Assignment algorithms and graphic interface'];

// macros from macros are explicitely loaded 
// with getf.

CS_DIR=SCI+'/contrib/cs5';
exec(CS_DIR+'/macros/loader.sce')

// loaded as a library. 

load('SCI/contrib/cs5/metanet/lib');

// loader for src 

exec(CS_DIR+'/src/loader.sce');
write(%io(2),mess)

// loading help pages 
add_help_chapter('Traffic Assignment',CS_DIR+'/man')  

// load the demos 
//add_demo('CiudadSim  Demo', CS_DIR+'/demo/TrafficAssignDemo.sce')  

EXAMPLES=CS_DIR+'/examples/';
default_font_size=14
clear libtitle mess get_file_path 
global %net
global %VERBOSE








