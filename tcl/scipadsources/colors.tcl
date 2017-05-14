#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2012 - Francois Vogel
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

proc setallcolorstodefault {} {
# set all colors to their default
    global bgcolors fgcolors
    foreach c "$bgcolors $fgcolors" {
        global $c
    }
    set BGCOLOR "snow1"
    set BGLNMARGCOLOR lightgrey
    set BGMLMARGCOLOR [shade $BGCOLOR [blackorwhite $BGCOLOR] 0.05]
    set FGCOLOR "black"
    set FGLNMARGCOLOR black
    set FGUSMLMARGCOLOR {#e99436}
    set FGSMLMARGCOLOR lightgreen
    set CURCOLOR "red"
    set PARCOLOR "magenta3"
    set BRAKCOLOR "DarkGoldenrod4"
    set BRACCOLOR "red"
    set PUNCOLOR "turquoise4"
    set INTFCOLOR "blue2"
    set COMMCOLOR "magenta4"
    set PDEFCOLOR "purple"
    set LFUNCOLOR "cyan4"
    set SCICCOLOR "OrangeRed"
    set OPCOLOR "blue4"
    set QTXTCOLOR "red4"
    set REMCOLOR "green4"
    set XMLCOLOR "orange"
    set NUMCOLOR "yellow4"
    set SELCOLOR "PaleGreen"    ;# _background_ selection color - the foreground sel color is calculated in proc TextStyles
    set BREAKPOINTCOLOR "pink"
    set ANYFOUNDTEXTCOLOR "LightGoldenrod1"
    set CURFOUNDTEXTCOLOR "green2"
    set CONTLINECOLOR "lemonchiffon"
    set USERFUNCOLOR {#02a5f2}
    set USERVARCOLOR {#b90746}
    set CLICKABLELINKCOLOR "blue"
    set MODELICAPUNCOLOR $PUNCOLOR
    set MODELICAPARCOLOR $PARCOLOR
    set MODELICABRAKCOLOR $BRAKCOLOR
    set MODELICABRACCOLOR $BRACCOLOR
    set MODELICAOPCOLOR $OPCOLOR
    set MODELICANUMBERCOLOR $NUMCOLOR
    set MODELICAKEYWORDCOLOR $COMMCOLOR
    set MODELICAINTROPCOLOR $INTFCOLOR
    set MODELICASTRINGCOLOR $QTXTCOLOR
    set MODELICACOMMENTCOLOR $REMCOLOR
    set MODELICAANNOTATIONCOLOR $CONTLINECOLOR
}

proc updateallcolorstodefault {} {
# apply default colors to everything, after having received user confirmation

    global pad bgcolors fgcolors
    foreach c "$bgcolors $fgcolors" {
        global $c
    }

    set tit [mc "Revert confirm?"]
    set mes [mc "Are you sure you want to revert all the current colors to their default?"]
    set answ [tk_messageBox -message $mes -type yesno -icon question -title $tit -parent $pad]

    if {$answ eq yes} {
        setallcolorstodefault
        updatecolor
    } else {
        showinfo [mc "No action taken"]
    }
}

proc changecolor {c} {
# called when changing a color option from menu
# chooses the new color and refreshes whatever needed

    global bgcolors fgcolors listoftextarea pad
    foreach c1 "$bgcolors $fgcolors" {
        global $c1
    }

    set newcol [tk_chooseColor -initialcolor [set $c] -title [mc $c]]

    if {$newcol ne ""} {
        # the user didn't click cancel
        set $c $newcol
        updatecolor
    }
}

proc updatecolor {} {
# update all what is needed when one or more colors have been changed

    global bgcolors fgcolors listoftextarea pad
    global FirstColorEntryInOptionsColorsMenu
    foreach c1 "$bgcolors $fgcolors" {
        global $c1
    }

    # refresh all the colors of the colors option menu entries
    # Warning: the following strongly relies on the layout of this menu:
    #          background colors first, foreground colors last
    set i $FirstColorEntryInOptionsColorsMenu
    foreach c $bgcolors {
        $pad.filemenu.options.colors entryconfigure $i \
           -background [set $c] -foreground $FGCOLOR -activeforeground $FGCOLOR
        incr i
    }
    foreach c $fgcolors {
        $pad.filemenu.options.colors entryconfigure $i \
           -background $BGCOLOR -foreground [set $c] -activeforeground [set $c]
        incr i
    }
    updateactiveforegroundcolormenu

    # refresh all color settings for all the opened buffers
    # we need to do it also for peers, because TextStyles is not only tag
    # management, it is also configuration of the text widget itself
    # ($FGCOLOR $BGCOLOR $CURCOLOR $SELCOLOR and more)
    foreach ta $listoftextarea {
        TextStyles $ta
    }

    # if the color of continued lines has been changed
    tagcontlinesinallbuffers

    # if the color of Modelica annotations has been changed
    tagModelicaannotationsinallbuffers
}

proc updateactiveforegroundcolormenu {} {
    global pad FirstColorEntryInOptionsColorsMenu
    for {set i $FirstColorEntryInOptionsColorsMenu} {$i<=[$pad.filemenu.options.colors index last]} {incr i} {
        if {[$pad.filemenu.options.colors type $i] != "separator" && [$pad.filemenu.options.colors type $i] != "tearoff"} {
                $pad.filemenu.options.colors entryconfigure $i -activebackground [shade \
                        [$pad.filemenu.options.colors entrycget $i -activeforeground] \
                        [$pad.filemenu.options.colors entrycget $i -background] 0.5]
        }
    }
}

# shade --
#
#   Returns a shade between two colors
#
# Arguments:
#   orig    start #rgb color
#   dest    #rgb color to shade towards
#   frac    fraction (0.0-1.0) to move $orig towards $dest
#
# This proc was copied from http://aspn.activestate.com/ASPN/Cookbook/Tcl/Recipe/133529
# Since errors were found e.g. for   shade black green2 0.8   when trying to use this color,
# format "\#%02x%02x%02x"  was changed into  format "\#%4.4x%4.4x%4.4x"
#
proc shade {orig dest frac} {
    global pad
    if {$frac >= 1.0} { return $dest } elseif {$frac <= 0.0} { return $orig }
    foreach {origR origG origB} [rgb2dec $orig] \
            {destR destG destB} [rgb2dec $dest] {
         set shade [format "\#%4.4x%4.4x%4.4x" \
            [expr {int($origR+double($destR-$origR)*$frac)}] \
            [expr {int($origG+double($destG-$origG)*$frac)}] \
            [expr {int($origB+double($destB-$origB)*$frac)}]]
    return $shade
    }
}

# rgb2dec --
#
#   Turns #rgb into 3 elem list of decimal vals.
#
# Arguments:
#   cv   The #rgb hex of the color to translate, or a known color name
# Results:
#   List of three decimal numbers, corresponding to #RRRRGGGGBBBB color
#
# This proc was inspired by http://aspn.activestate.com/ASPN/Cookbook/Tcl/Recipe/133529
# and changed by Donald Arsenau based on a discussion on comp.lang.tcl. See:
# http://groups.google.fr/group/comp.lang.tcl/browse_thread/thread/83264d872c0f13cc/e65d91f5f4261239
#
proc rgb2dec cv {
    set c [string tolower $cv]
    if {[catch {winfo rgb . $c} rgb]} {
        error "bad color value \"$cv\""
    }
    return $rgb
}

proc blackorwhite {cv} {
# return "black" or "white" according to which is more contrasted
# to the color name (or hex value #rgb) $cv
# e.g.  blackorwhite PaleGreen   returns  "black"
  foreach {r g b} [rgb2dec $cv] {}
  set r [expr {$r/65535.}]
  set g [expr {$g/65535.}]
  set b [expr {$b/65535.}]
  set lum [expr {0.3*$r+0.59*$g+0.11*$b}]
  if {$lum >= 0.5} {
    return black
  } else {
    return white
  }
}
