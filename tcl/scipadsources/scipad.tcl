#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2015 - Francois Vogel
#
#  Localization files ( in tcl/msg_files/) are copyright of the 
#  individual authors, listed in the header of each file
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# See the file scipad/license.txt
#

#!/bin/sh
# the next line restarts using wish \
exec `which wish` "$0" "$@"

if { [info exists pad] } { 
    # when scipad(...); is invoked from Scilab when Scipad is already
    # open, just show its window - file opening is handled in scipad.sci
    # see also bug 4038 about why it's needed to keep this part
    wm deiconify $pad
    raise $pad
    update

} else {

# Debug for bug 4053 - <TODO> can be removed later
set dynamickeywords_ran_once false
set dynamickeywords_running false

    set pad .scipad

    if {$Scilab5} {
        # paths for Scilab5, Scipad installed through atoms
        set moduledir $env(SCIPADINSTALLPATH)
        set sourcedir [file join "$moduledir" "tcl"]
        set intmacdir [file join "$moduledir" "macros" "scipad_internals"]
        set scicosdir [file join "$env(SCIINSTALLPATH)" "modules" "scicos" "macros" "scicos_scicos"]
        set blocksdir [file join "$env(SCIINSTALLPATH)" "modules" "scicos_blocks" "macros"]
    } else {
        # paths for Scilab4 and Scicoslab
        set moduledir $env(SCIPADINSTALLPATH)
        set sourcedir $moduledir
        set intmacdir $sourcedir
        set scicosdir [file join "$env(SCIINSTALLPATH)" "macros" "scicos"]
        set blocksdir [file join "$env(SCIINSTALLPATH)" "macros" "scicos_blocks"]
    }

    set msgsdir   [file join "$sourcedir" "msg_files"]

    set iconsdir  [file join "$sourcedir" "icons"]
    set ntgiconsdir [file join "$iconsdir" "nontango" "32x32"]
    set dbgiconsdir [file join "$ntgiconsdir" "debugger"]
    set tgactionslargeiconsdir [file join "$iconsdir" "tango" "32x32" "actions" "gif"]
    set tgactionssmalliconsdir [file join "$iconsdir" "tango" "16x16" "actions" "gif"]

    set binddir   [file join "$sourcedir" "bindings"]

    # load first environment flags and some debug settings
    source [file join $sourcedir envflags.tcl]
    source [file join $sourcedir scipaddebug1.tcl]

    # now all the proc source files
    # note: in special circumstances there may be a few lines main level
    # code in these files
    source [file join $sourcedir toplevels.tcl]
    source [file join $sourcedir popupmenus.tcl]
    source [file join $sourcedir scilabexec.tcl]
    source [file join $sourcedir whichfun.tcl]
    source [file join $sourcedir filecommands.tcl]
    source [file join $sourcedir print.tcl]
    source [file join $sourcedir cutcopypaste.tcl]
    source [file join $sourcedir findreplaceengine.tcl]
    source [file join $sourcedir findreplace.tcl]
    source [file join $sourcedir findincremental.tcl]
    source [file join $sourcedir findinfiles.tcl]
    source [file join $sourcedir gotoline.tcl]
    source [file join $sourcedir marginlinenumbers.tcl]
    source [file join $sourcedir marginmodifiedline.tcl]
    source [file join $sourcedir peerslayout.tcl]
    source [file join $sourcedir colors.tcl]
    source [file join $sourcedir colorize.tcl]
    source [file join $sourcedir completion.tcl]
    source [file join $sourcedir modselection.tcl]
    source [file join $sourcedir inputtext.tcl]
    source [file join $sourcedir helps.tcl]
    source [file join $sourcedir textarea.tcl]
    source [file join $sourcedir infomessages.tcl]
    source [file join $sourcedir undoredo.tcl]  ;  # note: contains main level code
    source [file join $sourcedir debugger.tcl] 
    source [file join $sourcedir localetools.tcl] 
    source [file join $sourcedir tkdndtools.tcl] 
    source [file join $sourcedir platformbind.tcl] 
    source [file join $sourcedir menues.tcl]
    source [file join $sourcedir fonts.tcl]
    source [file join $sourcedir tooltips.tcl]
    source [file join $sourcedir progressbar.tcl]
    source [file join $sourcedir scrollableframe.tcl]
    source [file join $sourcedir MRUlist.tcl]
    source [file join $sourcedir combobox combobox.tcl]
    source [file join $sourcedir comboboxtools.tcl]
    source [file join $sourcedir scipadupdate.tcl]
    source [file join $sourcedir toolbar.tcl]
    source [file join $sourcedir toolbartools.tcl]
    source [file join $sourcedir filelayout.tcl]
    source [file join $sourcedir proxy uri.tcl]   ; # order matters (dependencies)
    source [file join $sourcedir proxy base64.tcl]
    source [file join $sourcedir proxy autoproxy.tcl]
    # console invocation from the system menu is a windows-only feature
    # Linux does not have the "console" command since it does not need it
    if {$tcl_platform(platform) eq "windows"} {
        source [file join $sourcedir consoleaux.tcl]
    }

    # now all the pure main level code
    source [file join $sourcedir defaults.tcl]
    source [file join $sourcedir mainwindow.tcl]
    source [file join $sourcedir db_init.tcl]

    initswitchablebindings
    source [file join $sourcedir commonbindings.tcl]

    # additional initial state operations, now that all the widgets have been set
    load_words

    # source the switchable bindings, i.e. fill in the bindset array
    # this is intentionally done after sourcing commonbindings.tcl
    # so that overwrite can happen, if any, when running rebind below
    loadbindings

    initinternetconnectionsettings

    # menues must exist before executing proc rebind
    createmenues

    # main toolbar
    createmaintoolbar

    # set initial debug state
    setdbstate "NoDebug"

    # now that the menues exist, really set the bindings (using the bindset array)
    rebind

    # the following update makes background tasks work on Linux
    # since bug 865 is fixed
    update
    focustextarea [gettextareacur]

    # if sufficient time has passed since last check, have a look whether
    # the Scipad project has released a newer version on the Internet,
    # and reschedule checks periodically
    periodiccheckfornewerscipadversion

    # finally source debug settings that must be executed after the procs definition
    source [file join $sourcedir scipaddebug2.tcl]

    # deiconify "seq"entially so that this will be done after completion
    # of dynamickeywords
    # this way the user has no control on Scipad before the initialization
    # sequence is completely finished, including full execution of
    # dynamickeywords. This is needed to avoid starting to colorize a file
    # (when opened through the file menu) before the words and chset arrays
    # have been populated
    ScilabEval_lt "TCL_EvalStr(\"wm deiconify $pad\",\"scipad\")" "seq"

    # restore the files opened during the previous Scipad session
    if {!$standaloneScipad} {
        # because of keywords loading scheduling, this has to be done this way...
        ScilabEval_lt "TCL_EvalStr(\"restorescipadgeometry\",\"scipad\")" "seq"
        ScilabEval_lt "TCL_EvalStr(\"restorelayoutstructureatendofprevsession\",\"scipad\")" "seq"
    } else {
        # even in standalone mode, one wants this feature to be executed
        # but now there is no need for sequencing this after keywords loading
        # since there are anyway no Scilab keywords in standalone mode
        restorescipadgeometry
        restorelayoutstructureatendofprevsession
    }
}
