Scipad, maintained by Francois Vogel and Enrico Segre


Scipad is a powerful editor and graphical debugger for programs written
in Scilab language. It is a mature and highly configurable programmer's
editor, including features like syntax colorization, regexp search/replace,
parentheses matching, logical/physical line numbering, peer windows, line
and block text editing, and much more.

Scipad can be used along with Scicoslab or Scilab, but even as a standalone
text editor. Used as internal Sci(cos)lab editor, it interacts tightly with
the interpreter, allowing

    - Scilab code execution control
    - conditional breakpointing
    - variable retrieval and tooltip display
    - Scilab help lookup
    - access to source code of Scilab library function
    - control of Scilab facilities for Matlab code and creation of help
      documents
    - and much more

Scipad also includes basic Modelica and XML syntax colorization; it is
currently localized in 13 languages and further localizations can easily
be added.

Scipad is entirely written in Tcl/Tk and Scilab language. It has been
tested and developed under various versions of Windows and Linux;
it should run on MacOSX on top of certain environments (untested).

Historically, the ongoing versions of Scipad used to be included in the
distributions of Scilab (up to version 5.1.1). As this is no more the case,
this repository carries the latest developments of the continuing project.
Care has been taken to support at best all versions of Scilab and Scicoslab
since 4.1 to current, and all underlying versions of Tcl/Tk from 8.4.6 on.
Please note however that certain features may not be available in some
combinations of Sci(cos)lab or Tcl/Tk.

In particular:

    - The graphical debugger cannot work in any version of Scilab >= 5,
      because of broken communication support at source. For more details
      about the debugger in Scilab 5, please check this page:
        http://wiki.scilab.org/Scipad_debugger_inner_beauties
      For many, that could be a reason to stick to Scicoslab instead.
    - Peer editing is available only with Tk >= 8.5
    - Further specific issues are discussed in the tracker area.

Check out the Scipad project page:

  http://sourceforge.net/p/scipad/home/

Please see help Scipad for details about how to use this software once
installed.


----------------
-- DISCLAIMER --
----------------

This package has been developed and tested on Windows, mainly on Vista.

It is also working on Linux, but testing on this platform is a bit less
complete.

Note that Scipad worked with Scilab up to version 5.2.2 (inclusive), but
could not be launched with Scilab 5.3.0 nor 5.3.1 due to bug #7954 of
Scilab 5:
  http://bugzilla.scilab.org/show_bug.cgi?id=7954
This bug has now been fixed, and Scipad can again be launched with
Scilab 5.3.2 or later.

Please refer to the detailed tested combinations at the end of the present
readme file.


------------------
-- INSTALLATION --
------------------

Installation steps are the same for both Windows and Linux.


1. Case of a Scilab 5 environment
   ------------------------------

Scipad is distributed as a zipped atoms package in source form.
Installation steps are:

  a. Download the package:    scipad-X.YY-Scilab5.zip

  b. Save it where you want, say in a directory <MYDIR>

  c. Check if another version of Scipad is already installed by issueing:

        atomsIsInstalled("scipad")

     If the command above returns true, then the existing version of Scipad
     must be removed first through:

        atomsRemove("scipad")

     Then quit Scilab 5 and restart it

  d. Now install Scipad with the following set of commands, replacing <MYDIR>
     by the folder where you saved the package, and X.YY by the Scipad
     version number:

        scipver = "X.YY";
        atomsSetConfig("offLine","True");
        atomsInstall(<MYDIR>+"/scipad-"+scipver+"-Scilab5.zip");
        if ~exists("atomsinternalslib") then
          load("SCI/modules/atoms/macros/atoms_internals/lib");
        end
        execstr("exec("""+atomsGetInstalledPath(["scipad" scipver])+"/builder.sce"",-1)");
        atomsLoad("scipad");

     Note: <MYDIR> must be the fully expanded directory name, it must not
           use the ~ alias for the user home directory

  e. You can then launch Scipad, e.g. through the command:

        scipad()

  f. When restarting Scilab later, it will automatically remember Scipad is
     installed


2. Case of a Scicoslab 4.4 (or more) environment
   ---------------------------------------------

Scipad is distributed as a zip file.
Installation steps are:

  a. Download the package:    scipad-X.YY.-Scicoslab.zip

  b. Uncompress it somewhere, say in a directory <MYDIR>
     <MYDIR> is a path ending with /scipad-X.YY-Scicoslab

  c. In Scicoslab, type SCI to know the installation directory of ScicosLab.
     This folder is referred to below as <SCI>
     Quit Scicoslab.

  d. Copy/paste the *content* of the unzipped directory into the installation
     directory of ScicosLab.
     Note that this requires root privileges, and that you may be asked to
     accept overwriting of existing files.
       on Linux: sudo cp -r <MYDIR>/* <SCI>

  e. Open ScicosLab with root/admin privileges, i.e.:
       on Linux: sudo scicoslab
       on Windows (Vista or 7): Execute as administrator

  f. In ScicosLab, issue:

        genlib("utillib");

     A warning saying that "utillib has been updated, but cannot
     be loaded into Scilab because utillib is a protected variable"
     may appear (depending on versions), and can be ignored.

  g. Quit ScicosLab.

  h. Reopen ScicosLab and enjoy:

        scipad()


3. Case of a Scilab 4.1.2 environment
   ----------------------------------

The same recipe as for a Scicoslab environment should be used.


---------------------
-- STANDALONE MODE --
---------------------

Scipad can be run in standalone mode, i.e. with no Scilab or Scicoslab
environment running under its feet. Obviously in such a case no action
requiring communication with an underlying environment can be executed.
This includes the debugger and a number of commands such as
"Execute in Scilab", "Open source code of...", "Import Matlab file...",
"Create help skeleton..." and a few more.

Running Scipad standalone is often used for debug purposes, but it is also a
way of having a nice editor at hand.

It requires Tcl/Tk be installed on your system. If this is not already the
case, please check the Internet for explanations about how to install Tcl/Tk
for your favourite platform.

Then, Scipad can be launched from wish very easily, by executing the following
snippet:

    catch {unset pad}
    cd <SCIPADTCL>
    set Scilab5 false ; set Scilab4 false ; set Scicoslab true
    set env(SCIINSTALLPATH) <SCIINSPATH>
    set env(SCIHOME) <SCIHOME>
    set env(SCIPADINSTALLPATH) <SCIPADROOT>
    lappend ::auto_path <TK85PATH>
    source scipad.tcl
    console hide  ; # optional (the console is normally used to debug Scipad)

In this script you have to replace:
    <SCIPADTCL>   by:  the directory where the file "scipad.tcl" is located
    <SCIINSPATH>  by:  the root directory of Scilab/Scicoslab (this is used to
                       dynamically retrieve the Scicos keywords to colorize)
    <SCIHOME>     by:  the directory returned by the command SCIHOME in
                       Scilab/Scicoslab (this is where the Scipad preferences
                       file is saved)
    <SCIPADROOT>  by:  the full path of the directory where Scipad is installed
                       (this is the same as <SCIPADTCL> for a Scipad version
                       targeted to Scicoslab, but it is not for a Scipad
                       version targeted to Scilab 5)
    Warnings:
      - filepaths containing spaces must be enclosed by double quotes (")
      - even on Windows, you should use the Linux path separator /, not the
        Windows antislash character \ (or escape it by doubling it)


-------------
-- REMOVAL --
-------------

1. Case of a Scilab 5 environment
   ------------------------------

Remove Scipad by issueing the following command:

  atomsRemove("scipad");


2. Case of a Scicoslab 4.4 (or more) environment
   ---------------------------------------------

You cannot completely remove Scipad since it is an integral part of the
Scicoslab software.
You may however install a different version of Scipad (a previous version or
a newer version) by following the same installation steps as provided above.


3. Case of a Scilab 4.1.2 environment
   ----------------------------------

The same recipe as for a Scicoslab environment should be used.


--------------------------------------------
-- COMBINATIONS TESTED, WITH TEST RESULTS --
--------------------------------------------

The following combinations have been tested with revision r507 or r510 of Scipad (pre-release of Scipad 8.71 from the SVN repository):

  WINDOWS VISTA (64 bits)
    Scilab 5.4.0-beta-2, 64 bits          :   ok
    Scilab 5.4.0-beta-2, 32 bits          :   ok
    Scilab 5.3.3, 64 bits                 :   ok
    Scilab 5.3.3, 32 bits                 :   ok
    Scicoslab 4.4.1, 32 bits              :   ok
    Scilab 4.1.2, 32 bits                 :   ok
    Standalone in Tcl/Tk 8.5.9, 32 bits   :   ok

  WINDOWS 7 (64 bits)
    Scilab 5.3.3, 64 bits                 :   ok
    Scilab 5.3.3, 32 bits                 :   ok
    Scicoslab 4.4.1, 32 bits              :   ok
    Standalone in Tcl/Tk 8.6b1.2, 32 bits :   ok

  WINDOWS 7 (32 bits)
    Scilab 5.3.3, 32 bits                 :   ok
    Scicoslab 4.4.1, 32 bits              :   ok

  LINUX UBUNTU 10.04.1 LTS Lucid Lynx (32 bits)
    Scilab 5.4.0-beta-2, 32 bits          :   ok
    Scicoslab 4.4.1, 32 bits              :   ok

  LINUX UBUNTU 12.04 LTS Precise Pangolin (32 bits)
    Scilab 5.3.3, 32 bits                 :   ok
    Scicoslab 4.4.1, 32 bits              :   ok

  LINUX FEDORA 14 Laughlin (32 bits)
    Scilab 5.3.3, 32 bits                 :   ok
    Scicoslab 4.4.1, 32 bits              :   ok

  LINUX FEDORA 17 Beefy Miracle (32 bits)
    Scilab 5.4.0-beta-2, 32 bits          :   ok
    Scilab 5.3.3, 32 bits                 :   ok
    Scicoslab 4.4.1, 32 bits (FC16 rpm)   :   ok

  LINUX DEBIAN 6.0 Squeeze (32 bits)
    Scilab 5.4.0-beta-2, 32 bits          :   ok
    Scilab 5.3.3, 32 bits                 :   ok
    Scicoslab 4.4.1, 32 bits              :   ok

