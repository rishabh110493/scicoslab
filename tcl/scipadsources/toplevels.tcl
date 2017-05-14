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

proc istoplevelopen {toplevelvarname} {
# return true if the toplevel window whose *name* is given in argument is open
# return false otherwise
# Warning: it's the _name_ of the variable containing the toplevel name that must
# be provided to this proc, not the toplevel name itself, i.e. call it with:
#   istoplevelopen bptsgui      but not    istoplevelopen $bptsgui
    global $toplevelvarname
    if {[info exists $toplevelvarname]} {
        append toplevelreference {$} $toplevelvarname
        if {[eval "winfo exists $toplevelreference"]} {
            return true
        }
    }
    return false
}

proc setwingeom {wintoset} {
# set $wintoset toplevel position such that the window is centered both
# horizontally and vertically in the Scipad window
# the window is also set to be of fixed size (i.e. non resizable)
# note: this proc must obviously be called after the content of $wintoset
# has been created
    global pad Tkbug533519_shows_up

    wm resizable $wintoset 0 0

    if {$Tkbug533519_shows_up} {
        # Don't try to center the window, it will fail because
        #   winfo $pad vroot(x|y|width|height)  returns
        # screen characteristics instead of vroot data
        return
    }
    
    set myx [expr {[winfo rootx $pad] + \
                ([winfo width  $pad]/2) - ([winfo reqwidth  $wintoset]/2)}]
    set myy [expr {[winfo rooty $pad] + \
                ([winfo height $pad]/2) - ([winfo reqheight $wintoset]/2)}]
    if {$myx >= 0 && $myy >=0 && \
        $myx < [winfo vrootwidth $pad] && $myy < [winfo vrootheight $pad]} {
        wm geometry $wintoset +$myx+$myy
    } else {
        # upper left pixel of the window to center is off screen
        # positioning will not work correctly on all wm, therefore
        # abort and let the window manager place the window
        # even if it will not be centered
    }
}

proc totalGeometry {{w .}} {
# compute the total width and height of a window, as well as its top left
# corner position
# this differs from wm geometry in that it includes the decorations width
# and height
# this proc was initially copied from http://wiki.tcl.tk/11291
# related information can be found in http://wiki.tcl.tk/11502
# it has been slightly modified to accomodate for negative values coming
# from wm geometry
# this improvement has been propagated to the wiki
    set geom [wm geometry $w]
 #   regexp -- {([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $geom -> \
      width height decorationLeft decorationTop
    scan $geom "%dx%d+%d+%d" width height decorationLeft decorationTop
    set contentsTop [winfo rooty $w]
    set contentsLeft [winfo rootx $w]

    # Measure left edge, and assume all edges except top are the
    # same thickness
    set decorationThickness [expr {$contentsLeft - $decorationLeft}]

    # Find titlebar and menubar thickness
    set menubarThickness [expr {$contentsTop - $decorationTop}]

    incr width [expr {2 * $decorationThickness}]
    incr height $decorationThickness
    incr height $menubarThickness

    return [list $width $height $decorationLeft $decorationTop]
}

proc totalGeometryInv {w width height decorationLeft decorationTop} {
# reciprocal proc of proc totalGeometry
# from the output of proc totalGeometry, create the string to pass to
# wm geometry (for details, see proc totalGeometry)

    set contentsTop [winfo rooty $w]
    set contentsLeft [winfo rootx $w]

    set decorationThickness [expr {$contentsLeft - $decorationLeft}]

    set menubarThickness [expr {$contentsTop - $decorationTop}]

    incr width [expr {-2 * $decorationThickness}]
    incr height -$decorationThickness
    incr height -$menubarThickness

    set geom $width
    append geom x$height+$decorationLeft+$decorationTop

    return $geom
}

proc restorescipadgeometry {} {
# restore position and size of the Scipad window on screen
# while making sure that Scipad is clamped inside the virtual root area
# (it is possible that $pad be no longer in the virtual root
# when two monitors were used when Scipad was last exited
# and now there is only one, or after a resolution change
# by the user, or for whatever reason - if clamping would
# not be done Scipad would open outside of the visible area)

    global Tkbug533519_shows_up
    global pad WMGEOMETRY WMSTATE

    # place the Scipad window where it was when Scipas was
    # last closed
    wm geometry $pad $WMGEOMETRY

    if {$Tkbug533519_shows_up} {
        # it is not possible to ensure that the Scipad window is
        # inside the visible area - do nothing more since running
        # the else clause in this case too would break working cases
        # because  winfo $pad vroot(x|y|width|height)  returns
        # screen characteristics, thus leading to wrongly moving
        # the window even when it's already visible
        return

    } else {
        update idletasks

        # get Scipad window position and size
        # and obtain the virtual root characteristics
        foreach {padw padh padxm padym} [totalGeometry $pad] {}
        set padxM [expr {$padxm + $padw}]
        set padyM [expr {$padym + $padh}]

        set vrxm [winfo vrootx $pad]
        set vrym [winfo vrooty $pad]
        set vrw  [winfo vrootwidth $pad]
        set vrh  [winfo vrootheight $pad]
        set vrxM [expr {$vrxm + $vrw}]
        set vryM [expr {$vrym + $vrh}]

        # now clamp this position to the virtual root
        if {$padxm < $vrxm} {
            set padxm $vrxm
            set padxM [expr {$padxm + $padw<$vrw?$padw:$vrw}]
        } elseif {$padxm >= $vrxM} {
            set padxM $vrxM
            set padxm [expr {$padxM - $padw<$vrw?$padw:$vrw}]
        } else {
            if {$padxM >= $vrxM} {
                set padxM $vrxM
            }
        }
        if {$padym < $vrym} {
            set padym $vrym
            set padyM [expr {$padym + $padh<$vrh?$padh:$vrh}]
        } elseif {$padym >= $vryM} {
            set padyM $vryM
            set padym [expr {$padyM - $padh<$vrh?$padh:$vrh}]
        } else {
            if {$padyM >= $vryM} {
                set padyM $vryM
            }
        }

        set padw [expr {$padxM - $padxm}]
        set padh [expr {$padyM - $padym}]

        # place the window as if it had no border nor menu bar
        # so that winfo rootx|y in proc totalGeometryInv below
        # will be consistent with the newly calculated but not
        # yet applied $padw, $padh, $padxm and $padym
        set tempgeom $padw
        append tempgeom x$padh+$padxm+$padym
        wm geometry $pad $tempgeom
        update idletasks

        # finally bring the window in the vroot area (and now take
        # decorations into account)
        wm geometry $pad [totalGeometryInv $pad $padw $padh $padxm $padym]

        # only restore zoomed (maximized) state of the Scipad window
        if {$WMSTATE == "zoomed"} {
            wm state $pad $WMSTATE
        }
    }
}

proc setscipadicon {toplevelname} {
# give $toplevelname the Scipad icon in the task bar and in its titlebar
    global tcl_platform pad ntgiconsdir
    if {$tcl_platform(platform) == "windows" && $tcl_platform(osVersion) == "5.0"} {
        # special case for Windows 2000: just do nothing
        # we cannot rely on catch {wm iconphoto ...} because this produces
        # a black square icon on Win 2000 (bug 3416)
        # <TODO> the proper fix would be to use
        #          wm iconbitmap $toplevelname $iconicofile
        #        but the question is how to create the ico file from the existing
        #        icon in GIF format
        # doing nothing here means Scipad will receive the Tk icon, which is fine
    } else {
        # other platforms or other Windows versions (see bug 3105)
        # wm iconphoto is officially implemented in Tk 8.5 only
        # however it is also in Tk 8.4.8 onwards
        # see http://groups.google.com/group/comp.lang.tcl/browse_thread/thread/8c6e1a59ea384573
        # to avoid testing for complicated versions and platforms, I lazily catch this...
        # there is anyway no fallback when wm iconphoto is not supported
        # (wm iconbitmap with an ico file, on Windows only... well, let's wait for bug reports, if any!)
        set iconimage [image create photo $pad.icon1 -format gif \
                            -file [file join $ntgiconsdir scipad-editor.gif]]
        catch {wm iconphoto $toplevelname $iconimage}
    }
}

proc allchildren {{w .}} {
# return a flat list of all children of window $w
# $w can be any widget or toplevel
# this proc was borrowed from  http://wiki.tcl.tk/1327
# where it was named "wlist"
   set list [list $w]
   foreach ch [winfo children $w] {
      set list [concat $list [allchildren $ch]]
   }
   return $list
}
