=============================================================
CiudadSim5 (CS5) :  Traffic Assignment Toolboxes of Scicoslab
=============================================================

Traffic Assignment - Wardrop equilibrium computation

AUTHORS:
-------

Pablo Lotito, Elina Mancinelli
  and the collaboration of
Jean-Pierre Quadrat, L. Wynter

Inria METALAU project.


VERSION: 5
-----------

This is a beta version. It is not
completely compatible with the previous version
see the IMPROVEMENT section.

LICENSE:
--------

LGPL.

AVAILABILITY:
------------

Works on Linux, Unix (Sun Solaris, Dec alpha), Windows, MacOSX 

INSTALLATION:
------------
Put the archive in the contrib directory of ScicosLab (old name ScilabGtk).
It does not work with the official consortium Scilab.
For old  version of scilab before 4.1 it is needed to install first 
the maxplus toolbox. 

Unzip the archive. 
Put the directory CS5 at the upper level of contrib
if necessary (after some unzip process the directory CS5
is inside another directory CS5).

When we sart Scicoslab now a menu toolboxes must appear
with CS5 inside.


LOADING:
-------

The toolbox is available after loading.
For that in the Scicoslab  menu  ''toolboxes'' click on CS5.
If everything works a message will appear in the Scicoslab window:
"CiudadSim toolbox loaded ...."

Inside the Scicoslab window the command -->edit_graph
will open a window dedicated to ciudadsim. 

Try first the menu example to load an example.

There is an help completely consistant with the standard Scicoslab help.
It is "Traffic assignment" chapter of the Scicoslab help.

There is a manual in the directory manual of the the directory CS5

There is a small demo but it must be loded in the directory demo.
It is not available by the menu demo because it has to be improved.


DEMOS :
-------

A  demo is available by 
exec "demo/TrafficAssignDemo.sce"
when the working directory of Scicoslab is CS5.

During the demo don't forget to save the
edited graph. If you don't do that an error
message of Scicoslab will tell you that the edited
graph does not exist.

Inside Windows the plotting facilities
of Metanet do not work, this induces a
bug when these facilities are called.


MANUAL :
--------

In the "help" menu of Scicoslab search for "Traffic Assignment Functions" 
All the functions are documented.

An html documentation is available in the directory man/html

In the directory manual we can find the complete manual
in pdf. 


IMPROVEMENTS AND MODIFICATIONS :
--------------------------------
- A set of compatible  metanet macros are now given with the toolbox
(indeed some new edit_graph  macros ave incompatibilities with 
the ones used by CiudadSim. They are overwritten. To restore thes macros start
a fresh Scicoslab version).  
- The new version works with edit_graph instead of SCIGRAPH.
- The speed of FW and DSD has been improved
- More algorithm are provided (Logit type algorithm and NewtArc)
- The highest level function have not anymore the argument
'net' a global NetList variable '%NET' has been introduced which
contains all the information
- The Netlist have more fields name of algorithm used, precision,
etc....
- The variable 'ben' giving information about the way the
algorithm has worked has been changed and unified between
the different algorithm

PROBLEMS:
--------

In case of difficulties for loading the toolboxes.
Try the following procedure:
1) Go inside the CS5 toolbox directory 
SCI/contrib/CS5/src
2) Remove all the object files
 rm *.o *.lo *.a *.la *.so Make*
3) Remove the .dll only if you have a C compiler on windows
3') Remove the .dylib only if you have a C compiler with a Mac.
3) Leave Scicoslab
4) Start Scicoslab
5) Load CS5 

For problems, comments, ... send mail to :
plotito@exa.unicen.edu.ar
Jean-Pierre.Quadrat@inria.fr



