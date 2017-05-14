//  Scipad - programmer's editor and debugger for Scilab
//
//  Copyright (C) 2002 -      INRIA, Matthieu Philippe
//  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
//  Copyright (C) 2004-2011 - Francois Vogel
//
//  Localization files ( in tcl/msg_files/) are copyright of the 
//  individual authors, listed in the header of each file
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// See the file scipad/license.txt
//

function scipad(varargin)

// Start Scipad editor

    // First find out if we are in Scilab-4, Scicoslab, or Scilab-5

    // Scipad must work aside (primary compatibility targets):
    //   Scilab-4.1.2
    //   Scicoslab-4.4 and above
    //   Scilab-5.1.1 and above (but with limited functionalities, e.g. no debugger, see bug 2789)
    //
    // The test to distinguish Scilab-5 from the rest is on whereis(scipad)
    // The test to distinguish Scicoslab-4.x (x>=4) from other Scilab-4-like environments
    // is based on the string output of getversion()
    //
    // For the following environments, "!!"+getversion()+"!!" returns:
    //      Scilab-4.1.2                !!scilab-4.1.2!!
    //      Scilab-gtk-4.2              !!ScilabGtk-4.2!!
    //      Scicoslab-4.3               !!4.3!!
    //      Scicoslab-4.4               !!4.4!!
    //      Scilab-5.1.1                !!scilab-5.1.1!!
    //      Scilab-5 master branch      !!scilab-branch-master!!
    //      <anything else>             <unknown and untested answer>
    //      
    //  Therefore in those environments, Scilab5  Scilab4  Scicoslab  variables become:
    //      Scilab-4.1.2                    %f       %t        %f
    //      Scilab-gtk-4.2                  %f       %t        %f
    //      Scicoslab-4.3                   %f       %t        %f
    //      Scicoslab-4.4                   %f       %f        %t
    //      Scilab-5.1.1                    %t       %f        %f
    //      Scilab-5 master branch          %t       %f        %f
    //      <anything else>                 ??       ??        ??

    if (whereis("scipad") == "scipadlib") then
        // we're running aside of Scilab-5
        Scilab5 = %t ; Scilab4 = %f ; Scicoslab = %f ;
    else
        // the environment is a Scilab-4-like code tree
        env_version = getversion();
        ierr = execstr("[env_version_ma,env_version_mi] = sscanf(env_version,""%d.%d"");","errcatch")
        if ierr <> 0 then
            // the environment is supposed to be Scilab-4.1.2
            Scilab5 = %f ;  Scilab4 = %t ;  Scicoslab = %f ;
        else
            if env_version_ma == 4 then
                // we're running aside of Scicoslab
                if env_version_mi > 3 then
                    // the environment is Scicoslab-4.4 or above
                    Scilab5 = %f ;  Scilab4 = %f ;  Scicoslab = %t ;
                else
                    // the environment is Scicoslab-4.3 (only possible case)
                    // in this case let Scipad believe this is Scilab-4
                    Scilab5 = %f ;  Scilab4 = %t ;  Scicoslab = %f ;
                end
            else
                error(gettext("Unexpected Scicoslab version number."))
            end
        end
    end

    // Find out the Scipad version
    // Convention: Scipad version numbers follow the "%d.%d-%s" format
    //             at least the "%d.%d" should be present
    //             if there is something after "%d.%d", then it is textual version
    //             details
    //             the first character of the version details shall be - (otherwise
    //             the version details are ignored)
    //             at the end of the version number processing one have:
    //               ScipadVerString: the full version string
    //               ScipadVer_major: the major version number (float)
    //               ScipadVer_minor: the minor version number (float)
    //               ScipadVer_details: either "" or any string (including the leading -)
    // Note: when installed by atoms (Scilab 5), the installation directory
    // of Scipad is either the "allusers" zone, i.e. SCI/contrib/scipad/<version_number>
    //              or     the "user"     zone, i.e. SCIHOME/atoms/scipad/<version_number>
    if Scilab5 then
        // Scipad has been installed in Scilab 5 as an atoms package
        // load the internal atoms library because two atoms functions are needed
        // in scipad.sci:    atomsGetInstalledVers    and    atomsGetInstalledPath
        // Warning: the atomsinternalslib variable MUST be cleared before
        //          source-ing the Tcl files since these files will run
        //          dynamickeywords.sce and the latter would populate the words
        //          array with names from atomsinternalslib. This is bad since
        //          these names will later be unknown (because the load is in the
        //          context of the present function scipad) when trying from
        //          Scipad to Open source of...
        if ~exists("atomsinternalslib") then
          load("SCI/modules/atoms/macros/atoms_internals/lib");
        end
        // find out what Scipad version we will be running,
        // and where it is installed
        ScipadVerString     = atomsGetInstalledVers("scipad");
        scipadrootpath_sci5 = atomsGetInstalledPath(["scipad" ScipadVerString])
        // clear NOW, i.e.:
        //       after use of the last function from atomsinternalslib
        //   and before the source-ing of the Tcl files, which will run
        //       dynamickeywords.sce and populate the words array with names
        //       that are in fact unknown later when running Open source of...
        clear atomsinternalslib
        // Scipad versions are supposed to follow the %d.%d scanf format
        [nbscanned,ScipadVer_major,ScipadVer_minor,ScipadVer_details] = msscanf(ScipadVerString,"%d.%d-%s")
        // last safeguard in case ScipadVerString has unexpected content
        if nbscanned < 2 then
          warning("Unexpected Scipad version could not be parsed: "+ScipadVerString);
          ScipadVer_major   = "{}";
          ScipadVer_minor   = "{}";
          ScipadVer_details = "{}";
        else
          ScipadVer_major   = msprintf("%d",ScipadVer_major);
          ScipadVer_minor   = msprintf("%d",ScipadVer_minor);
          if nbscanned == 3 then
            ScipadVer_details = "-" + ScipadVer_details;
          else
            ScipadVer_details = "{}";
          end
        end
    else
        // Scilab 4 or Scicoslab environment
        // Scipad version is set automatically here
        // when making the release for Scicoslab
        // Warning: don't change even a space here, or change
        //          makeScipadReleases.tcl accordingly
        ScipadVerString   = "8.75";
        ScipadVer_major   = "8";
        ScipadVer_minor   = "75";
        ScipadVer_details = "{}";
    end

    // Make some workarounds for Scilab4-like trees (this includes Scicoslab)
    if ~Scilab5 then
        // fake gettext function - no localization of Scilab in Scilab 4.x nor in Scicoslab
        function sss = gettext(sss)
        endfunction
    end

    global SCIPADISSTARTING
    // ensure that no concurrent launching occurs
    // this fixes the issue that shows up when quickly
    // clicking twice the menu or icon button in the
    // Scilab window (bug 2226) [relies on exists(..."nolocal"), only in Scilab-5]
    if Scilab5 & exists("SCIPADISSTARTING","nolocal") then
        return
    end
    SCIPADISSTARTING = 1;  // guard variable

    // check if Scipad can be launched, given the Scilab configuration
    nwnimode  = find(sciargs()=="-nwni" );
    noguimode = find(sciargs()=="-nogui");
    if (nwnimode <> [] | noguimode <> []) then
        error(gettext("Scilab in no window no interactive mode: Scipad unavailable."));
    end;

    if with_tk() then

        if ~TCL_ExistInterp("scipad") then
            TCL_EvalStr("interp create scipad")

            ///////////////////////////////////////
            // horrible workaround to deal with broken search of Tk in Fedora 12
            // while this was not needed with Fedora 11
            // see http://www.rhinocerus.net/forum/lang-tcl/602854-package-require-tk-fails.html 
            //     http://forums.fedoraforum.org/showthread.php?p=1295845
            //     https://bugzilla.redhat.com/show_bug.cgi?id=540296
            if ~(getos()=="Windows") then
                TCL_EvalStr("lappend ::auto_path /usr/lib/tk8.5","scipad")
            end
            // end of horrible workaround
            // <TODO> remove this ASAP!
            ///////////////////////////////////////

            // In Scilab-5,  package require Tk  fails because
            // directories "tcl8.5" and "tk8.5" are not at the correct nesting level
            // (they are two levels too deep in the hierarchy)
            // These directories are OK in both Scilab-4 and Scicoslab
            // The right thing to do is   package require Tk
            // but we work around the bug in Scilab-5
            if Scilab5 then
                TCL_EvalStr("load {"+gettklib()+"} Tk scipad")
            else
                TCL_EvalStr("package require Tk","scipad")
            end
            TCL_EvalStr("wm withdraw .","scipad")
            TCL_EvalStr("scipad alias ScilabEval ScilabEval")
            if Scilab5 then
                // sciprompt is no longer supported in Scilab-5 which means there is
                // no way of knowing whether Scilab is busy or not from Scipad
                // fortunately this still works in both Scilab-4 and Scicoslab
                TCL_EvalStr("set sciprompt 0", "scipad")
            end
        end

        if Scilab5 then
            TCL_EvalStr("set Scilab5 1","scipad")
        else
            TCL_EvalStr("set Scilab5 0","scipad")
        end
        if Scilab4 then
            TCL_EvalStr("set Scilab4 1","scipad")
        else
            TCL_EvalStr("set Scilab4 0","scipad")
        end
        if Scicoslab then
            TCL_EvalStr("set Scicoslab 1","scipad")
        else
            TCL_EvalStr("set Scicoslab 0","scipad")
        end

        // ScipadVerString can be any string
        // ScipadVer_major and ScipadVer_minor are either the empty string
        // or a number (possibly with several digits), i.e. a  %d  scanf
        // format - this must not be changed since Scipad versions will be
        // compared later when searching for an update on the Internet
        // ScipadVer_details is the empty string or any string starting with -
        TCL_EvalStr("set ScipadVersion "+ScipadVerString,"scipad")
        TCL_EvalStr("set ScipadVersion_major "+ScipadVer_major,"scipad")
        TCL_EvalStr("set ScipadVersion_minor "+ScipadVer_minor,"scipad")
        TCL_EvalStr("set ScipadVersion_details "+ScipadVer_details,"scipad")

        if exists("SCIHOME") then
            if getos() == "Windows" then
                TCL_EvalStr("set env(SCIHOME) """+strsubst(SCIHOME,"\","/")+"""","scipad")
            else
                TCL_EvalStr("set env(SCIHOME) """+pathconvert(SCIHOME,%f,%t)+"""","scipad")
            end
        else
            // SCIHOME must exist since the preferences file is saved there
            error(gettext("SCIHOME does not exist - Scipad can''t run, sorry!"));
        end

        // Set Scipad's tmpdir to Scilab's TMPDIR
        // note that global TMPDIR is not needed since TMPDIR is not a global
        // but an environment variable, in fact a local variable of the main
        // level that is inherited/visible in this macro (same as SCI)
        if getos() == "Windows" then
            TCL_EvalStr("set tmpdir """+strsubst(TMPDIR,"\","/")+"""","scipad")
            TCL_EvalStr("set env(SCIINSTALLPATH) """+strsubst(SCI,"\","/")+"""","scipad")
        else
            TCL_EvalStr("set tmpdir """+pathconvert(TMPDIR,%f,%t)+"""","scipad")
            TCL_EvalStr("set env(SCIINSTALLPATH) """+pathconvert(SCI,%f,%t)+"""","scipad")
        end

        if Scilab5 then
            // Scipad in Scilab 5, installed through atoms
            scipadrootpath_sci5 = pathconvert(scipadrootpath_sci5,%f,%t); // expand SCI
            if getos() == "Windows" then
                TCL_EvalStr("set env(SCIPADINSTALLPATH) """+strsubst(scipadrootpath_sci5,"\","/")+"""","scipad")
                TCL_EvalStr("source """+strsubst(scipadrootpath_sci5,"\","/")+"/tcl/scipad.tcl""","scipad")
            else
                TCL_EvalStr("set env(SCIPADINSTALLPATH) """+pathconvert(scipadrootpath_sci5,%f,%t)+"""","scipad")
                TCL_EvalStr("source """+scipadrootpath_sci5+"/tcl/scipad.tcl""","scipad")
            end
        else
          // Scipad in Scilab 4 or Scicoslab
          if getos() == "Windows" then
              TCL_EvalStr("set env(SCIPADINSTALLPATH) """+strsubst(SCI+"/tcl/scipadsources","\","/")+"""","scipad")
          else
              TCL_EvalStr("set env(SCIPADINSTALLPATH) """+pathconvert(SCI+"/tcl/scipadsources",%f,%t)+"""","scipad")
          end
          TCL_EvalStr("source """+SCI+"/tcl/scipadsources/scipad.tcl""","scipad")
        end

        // open the files specified on the command line that launched Scipad
        nfiles=argn(2)
        if nfiles>0 then
            for i=1:nfiles
                validfile=%f;
                f=varargin(i)
                select type(f)
                case 1 then filetoopen=string(f); validfile=%t;
                case 8 then filetoopen=string(f); validfile=%t;
                case 10 then
                    libmacro = whereis(f);
                    if isempty(libmacro) then
                        filetoopen=f; validfile=%t;
                    else
                        // f is the name of a macro from a library
                        a=string(eval(libmacro));libpath=a(1)
                        if ~isempty(libpath) then
                            validfile=%t;
                            // the correspondence between function and file name is tacitly assumed
                            filetoopen=pathconvert(libpath+f+".sci",%f)
                        else
                            // should never happen
                            warning(gettext("Function ")+f+gettext(" is not contained in a loaded library, ") ..
                                    +gettext("Scipad doesn''t know where to find its source"))
                        end
                    end
                ////nice try, but can't be done. The assignment to the argument
                //// overrides the original function name, and this is correct.
                //  case 13 then
                //      b=macr2tree(f); funname=b(2) //DOESN'T WORK. How else?
                //      libmacro=whereis(funname)
                //      disp(libmacro,funname)
                //      if libmacro<>[] & funname<>[] then
                //          a=string(eval(libmacro));libpath=a(1)
                //          if libpath<>[] then
                //              validfile=%t;
                //              //the correspondance between function and file name it is tacitly assumed
                //              filetoopen=pathconvert(libpath+funname+".sci",%f)
                //          else
                //              warning(gettext('Function ')+funname+gettext(' is not contained in a loaded library, ') ..
                //                      +gettext('Scipad doesn''t know where to find its source'))
                //          end
                //      end
                else
                    warning(gettext("Scipad cannot open a ")+typeof(f)+gettext(" object!"))
                end
                // prepare the file name for being used from within Tcl
                if validfile then
                    // Tcl handles the filenames correctly with any path separator but on
                    // Windows the separator is \ and in Tcl this is an escape. We cannot
                    // use the scilab macro pathconvert(,"u") alone to solve the problem, as
                    // by construction it creates cygwin paths. Therefore, we replace ad hoc
                    // slashes.
                    filetoopen=pathconvert(filetoopen,%f,%t);
                    if getos()=="Windows" then
                        filetoopen=strsubst(filetoopen,"\","/");
                    end
                    // take care of single or double quotes which may be included in the filename
                    // on Windows at least a filename cannot contain double quotes, but substitute
                    // them anyway, this does not harm
                    filetoopen=strsubst(filetoopen,"''","''''");
                    filetoopen=strsubst(filetoopen,"""","""""");
                    // The complication below is needed to comply with ScilabEval sync limitations: what
                    // is executed during a sync is not available in the interpreter after the sync has
                    // ended (because sync launches a new interpreter - same thing as running in a function),
                    // thus sync cannot be used for loading colorization arrays chset and words, and a seq
                    // is used. But then the file opening should be queued after the loading of keywords,
                    // which means the following nested complication is needed
                    TCL_EvalStr("ScilabEval {TCL_EvalStr(""openfile {"+ filetoopen +"}"",""scipad"")} ""seq"" ")
                    // instead of the much simpler (but wrongly queued) following statement
                    // TCL_EvalStr("openfile """+filetoopen+"""","scipad")
                end
            end  // end of "for i=1:nfiles"
        end  // end of "if nfiles>0"

    else
        // with_tk() is %f
        clearglobal SCIPADISSTARTING
        error(gettext("Scilab has not been built with Tcl/Tk: Scipad unavailable."))
    end

    clearglobal SCIPADISSTARTING

endfunction