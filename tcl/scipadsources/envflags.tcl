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


##########################################################################
# Detect Tcl and Tk versions
# and set global flags to true if versions are >= 8.5
#                          and if versions are >= 8.6
#
# This is used to improve Scipad when used with recent Tcl/Tk without
# preventing its use with older ladies
#
# Note that if, say, $Tk86 is assessed to be true below, then $Tk85 will be as well.
# Therefore tests such as  if {$Tk85} {dostuff}  must be understood as "if Tk version
# is *_at_least_ 8.5_*, then dostuff (as opposed to exact 8.5 version checking)
#
# ex of 8.5 use: a. -strictlimits option in find/replace
#                b. -stretch always option for panedwindows
#                c. proc timestamp uses clock milliseconds
#                d. peer text widgets are used when splitting
#                e. Tk bug 1169429 (relative to cursor blinking) is fixed, workaround hack removed
#                f. -topmost option of toplevels used also on Linux
#                g. string reverse (TIP #272) is used during undo/redo, improving performance drastically
#                h. the replace cursor is a nice looking block cursor
#
# ex of 8.6 use: a. bug fixed: events name changed for <Left> and <Right> keys Text class bindings

if { [package vcompare $tcl_version 8.5] >= 0 } {
    set Tcl85 1
} else {
    set Tcl85 0
}
if { [package vcompare $tk_version 8.5] >= 0 } {
    set Tk85 1
} else {
    set Tk85 0
}
if { [package vcompare $tk_version 8.6] >= 0 } {
    set Tk86 1
} else {
    set Tk86 0
}

# End of Tcl/Tk versions detection
##########################################################################


##########################################################################
# Detect if Scipad is launched outside of Scilab, e.g. from wish

# Warning: "sync" "seq" option is mandatory so that colorization
#          works with scipad somefile.sci
if {[catch {ScilabEval ";" "sync" "seq"}] != 0} {

    # Define ScilabEval to a void function, if it is unknown. This is
    # useful in order to run scipad outside of scilab (e.g. to debug it)
    proc ScilabEval args {
        # catched because may be called before the main window is ready
        # to display the message, or before the localization procs such
        # as mc are sourced
        catch {showinfo [mc "NOT CONNECTED TO SCILAB"]}
        puts $args
    }
    set sciprompt 0

    # hide the superfluous toplevel created by wish by default
    wm withdraw .

    # show the console in a fixed screen position and size
    if {$tcl_platform(platform) eq "windows"} {
        console show
        console eval {wm geometry . 80x25+0+0}
        console title "Scipad debug"
    }

    # give a value to tmpdir (when Scipad is launched from Scilab,
    # this is done in scipad.sci)
    set tmpdir $env(SCIHOME)

    # deiconify now with no need to have Scilab running since
    # ScilabEval "TCL_EvalStr(\"wm deiconify $pad\",\"scipad\")" "seq"
    # at the end of scipad.tcl won't run - anyway, dynamickeywords is
    # not executed
    after idle {wm deiconify $pad}

    set standaloneScipad true

} else {

    set standaloneScipad false

}

# End of detection of whether Scipad is launched outside of Scilab
##########################################################################


##########################################################################
# Flags to trim Scipad to the host environment
# (host computer OS, underlying Tcl/Tk version...)


# On Vista (osVersion is 6.0) there is bug 2672 which happens with the 8.4
# series of Tcl/Tk only
# This issue also happens with Windows 7 (osVersion is 6.1), but with a
# different incarnation, see
#   https://groups.google.com/forum/#!topic/comp.soft-sys.math.scilab/6J6NyQwlF4M
# The -parent option has problems in Vista and Win 7 in Tk 8.4.15 at least,
# but no longer in Tk 8.4.18. However given that Tk 8.4 is now (July 2013)
# deprecated, and since only Scilab-4.1.2 uses it among the Scilab/Scicoslab
# current versions, the workaround will be geared in for all Tk 8.4.x
# versions (simpler, although not completely minimal)
# This flag allows for easy checking whether the workaround for this
# bug must be geared in or not

if {$tcl_platform(platform) == "windows"                 && \
    [string compare $tcl_platform(osVersion) "6.0"] >= 0 && \
    !$Tk85} {
    # don't use the -parent option in tk_get*File
    set bug2672_shows_up true
} else {
    # use the -parent option in tk_get*File
    set bug2672_shows_up false
}


# On Linux with Tk8.5, there is bug 2776 which prevents from choosing
# multiple files in the tk_getOpenFile dialog
# This is a Tk bug, see the full details at:
# http://sourceforge.net/tracker/index.php?func=detail&aid=1904322&group_id=12997&atid=112997
# Here is the workaround - This should be removed when Tk bug 112997 gets
# fixed in Tk 8.5.x or at least it should be tuned so that it is geared
# in only for Tk 8.5.0 -> Tk 8.5.x but not in Tk 8.5.y with y > x

if {$tcl_platform(platform) == "unix" && $Tk85} {
    # gear in the workaround for Tk bug 112997
    option add *__tk_filedialog*takeFocus 0
} else {
    # nothing to do
}


# Hide/show Modelica annotations is based on text elision
# In 8.4.x : there is no concept of display char, therefore moving the cursor
#            does move it inside elided text while this text is not visible,
#            thus making the user think the cursor has disappeared
# In 8.5.x and 8.6.x : there is a concept of elided text but moving the
#            cursor inside it may freeze the Tk interpreter. This is a
#            showstopper for the show/hide annotations feature.
#            BUT I have fixed this bug 3021557 in Tk 8.5 and 8.6 on 19/01/2012:
#   https://sourceforge.net/tracker/?func=detail&aid=3021557&group_id=12997&atid=112997
#   https://sourceforge.net/tracker/?func=detail&aid=3472539&group_id=12997&atid=312997
# Therefore this feature:
#   - does not work correctly in any Tcl/Tk version in 8.4.x
#   - does work correctly in Tcl/Tk version 8.5 or 8.6 both later than 19/01/12,
#     i.e. starting from 8.5.12 and 8.6b3

if { ($Tk86 && [package vcompare [info patchlevel] 8.6b3 ] >= 0)           || \
     ($Tk85 && [package vcompare [info patchlevel] 8.5.12] >= 0 && !$Tk86)   } {
    set Tkbug3021557_shows_up false
} else {
    set Tkbug3021557_shows_up true
}


# There was a bug in Tk with respect to  $ta mark next $ind  that returned
# only marks set in $ta from $ta, and not marks set from a peer
# of $ta (BUG! marks should be shared between peers!)
#
# See:
#   https://groups.google.com/group/comp.lang.tcl/browse_thread/thread/61e065bc28709f6f
# and Tk bug 3288113:
#   https://sourceforge.net/tracker/?func=detail&aid=3288113&group_id=12997&atid=112997
# See also Tk bug 3288121:
#   https://sourceforge.net/tracker/?func=detail&aid=3288121&group_id=12997&atid=112997
#
# I have fixed both bugs above in Tk 8.5 and 8.6 on 22/01/2012:
#   https://sourceforge.net/tracker/?func=detail&aid=3471873&group_id=12997&atid=312997
# The fix is therefore only available in Tk 8.5.12 and Tk 8.6b3 (or higher than one of
# these).
# Tk 8.4: N/A of course, since there are no peer text widgets in 8.4

if { ($Tk86 && [package vcompare [info patchlevel] 8.6b3 ] >= 0)           || \
     ($Tk85 && [package vcompare [info patchlevel] 8.5.12] >= 0 && !$Tk86)   } {
    set Tkbug3288113_shows_up false
} else {
    set Tkbug3288113_shows_up true
}


# It is possible that, on Scipad opening, the Scipad window be out of the
# virtual root area when two monitors were used when Scipad was last exited
# and now there is only one monitor, or after a resolution change by the user
#
# Restoring the correct Scipad window position was not possible due to
# Tk bug 533519:
#   http://sourceforge.net/tracker/?func=detail&atid=112997&aid=533519&group_id=12997
#  winfo . vroot(x|y|width|height)  could not be used on Windows to get
# the size and position of the virtual root window because it erroneously
# gave the size and position of the screen
#
# This bug has been fixed in Tk 8.6 on 29/04/2012, and in Tk 8.4 and 8.5 on 02/05/2012
# This fix is therefore only available in Tk 8.4.20, Tk 8.5.12 and Tk 8.6b3 (or
# higher than one of these).

if { $tcl_platform(platform) == "windows" && \
     ( ($Tk86 && [package vcompare [info patchlevel] 8.6b3 ] >= 0)           || \
       ($Tk85 && [package vcompare [info patchlevel] 8.5.12] >= 0 && !$Tk86) || \
       (         [package vcompare [info patchlevel] 8.4.20] >= 0 && !$Tk85)    \
      ) } {
    set Tkbug533519_shows_up false
} else {
    set Tkbug533519_shows_up true
}


# There was a crash in Tk on tk_getSaveFile in at least some versions of Windows,
# which was reported as Tk bugs 3071836 and 3146418:
#   http://sourceforge.net/tracker/index.php?func=detail&aid=3071836&group_id=12997&atid=112997
#   http://sourceforge.net/tracker/index.php?func=detail&aid=3146418&group_id=12997&atid=112997
# This bug was created by a commit on 05/01/2010:
#   in core-8-5-branch:      http://core.tcl.tk/tk/info/f9049c72a7
#   in trunk (8.6 branch):   http://core.tcl.tk/tk/info/e47383bdeb
# and was fixed on 24/11/2010:
#   in core-8-5-branch:      http://core.tcl.tk/tk/info/86a806c278
#   in trunk (8.6 branch):   http://core.tcl.tk/tk/info/94cb1f50c3
# Therefore:
#   in the 8.4 branch,         this bug was never present
#   in the 8.5 branch,         this bug was present in Tk 8.5.9 only
#   in the trunk (8.6) branch, this bug was present in Tk 8.6b2 only

if { $tcl_platform(platform) == "windows" && \
     ( ($Tk86 && [package vcompare [info patchlevel] 8.6b2 ] == 0)           || \
       ($Tk85 && [package vcompare [info patchlevel] 8.5.9]  == 0 && !$Tk86)    \
      ) } {
    set Tkbug3071836_shows_up true
} else {
    set Tkbug3071836_shows_up false
}


# There was a bug in Tk with respect to panes resizing in a panedwindow having panes
# with -stretch always 
#
# See:
#   http://core.tcl.tk/tk/info/53f8fc9c2f
#
# I have fixed this bug in Tk 8.5 and 8.6 on 24/05/2015
# The fix is therefore only available in Tk 8.5.19 and Tk 8.6.5 (or higher than one of
# these).
# Tk 8.4: N/A, the panedwindow does not have the -stretch option in 8.4, and the problem
#         was introduced with this option that first came in with 8.5 (TIP #177)

if { ($Tk86 && [package vcompare [info patchlevel] 8.6.5 ] >= 0)           || \
     ($Tk85 && [package vcompare [info patchlevel] 8.5.19] >= 0 && !$Tk86)   } {
    set Tkbug53f8fc9c2f_shows_up false
} else {
    set Tkbug53f8fc9c2f_shows_up true
}


# End of flags to trim Scipad to the host environment
# (host computer OS, underlying Tcl/Tk version...)
##########################################################################


##########################################################################
# Flags to trim Scipad to the host Scilab version

# On Windows the cursor blink was once disabled because of what is explained at
# http://groups.google.fr/group/comp.soft-sys.math.scilab/browse_thread/thread/b07a13adc073623d/b4e07072205c0435
# On Linux the cursor blink was once disabled because of bug 865 (originated in
# bug 473)
# now both issues have been fixed, therefore:

set cursorblink true


# The break command can only be used with Scilab versions having bug 2384 fixed
# Currently (26/08/07), this is done in svn trunk and BUILD4 branches
# but nowhere else, e.g. in Scicoslab
# Checked again (19/09/08) in scilab-gtk-4.2: it is fixed (thus also in Scicoslab)
# The flag below allows for easy adjustment of Scipad to Scilab versions,
# especially with backported Scipad versions in mind
# Bug 2384 in fact fixes the sync seq options of ScilabEval (interruptibility)

set bug2384_fixed true


# The debugger has been broken by the operational team of the Scilab Consortium
# and they could not fix the situation on time for Scilab 5 release, despite
# Scilab 5 has been delayed more than one year. Their desperate request is that
# the debugger be unplugged from Scilab 5...

if {$Scilab5 && !$standaloneScipad} {
    set bug2789_fixed false
} else {
    # Scilab 4.x, Scilab-Gtk, any Scicoslab, or stand-alone Scipad
    set bug2789_fixed true
}


# There are other bugs, such as:
#
#   2226 (concurrent launch of many Scipad): Fixed in trunk, not fixed in BUILD4
#        nor in scilab-gtk as of 26/08/07, nor in scilab-gtk-4.2, nor in Scicoslab-4.3
#        04/07/09: Indeed the fix for 2226 is based on exists("SCIPADISSTARTING","nolocal")
#        which is available only in Scilab 5 environment
#
# but there is no workaround implemented in Scipad for them, therefore no flag here

# End of flags to trim Scipad to the host Scilab version
##########################################################################
