#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2011 - Francois Vogel
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

#####################################################################
# Note: maybe the canvas approach, as opposed
#       to the text widget approach used here,
#       has definite advantages
# <TODO> Check the canvas approach here and give it a try:
#    http://wiki.tcl.tk/20916
#    http://groups.google.com/group/comp.lang.tcl/browse_thread/thread/a18c3ee98542d2fb
#####################################################################

proc updatemodifiedlinemargin_allpeers {ta} {
# call updatemodifiedlinemargin for $ta and all its peers

    global modifiedlinemargin

    if {$modifiedlinemargin ne "hide"} {
        foreach peerta [getfullpeerset $ta] {
            if {[isdisplayed $peerta]} {
                updatemodifiedlinemargin $peerta
            }
        }
    }
}

proc updatemodifiedlinemargin {ta} {
# populate the "modified line" margin with the colors corresponding to the
# modified state of the line they are facing

    # assert: when entering this proc, we have $modifiedlinemargin ne "hide"

    # assert: when entering this proc, [isdisplayed $ta] is true

    set tapwfr [getpaneframename $ta]
    set frmargin $tapwfr.propagationoffframe
    set tamargin $frmargin.marginml

    # start modifying margin content
    $tamargin configure -state normal

    $tamargin delete 1.0 end

    # find out the height of the textarea, which will be the upper bound in
    # the loop below
    set winfoheight [winfo height $ta]

    # initialization values
    set curheight [lindex [$ta dlineinfo @0,0] 1]

    while {$curheight <= $winfoheight} {

        set pos [$ta index "@0,$curheight linestart"]

        # insert one space character per line
        $tamargin insert end " \n"

        # check whether the line starting at $pos is marked as being a modified unsaved line or not
        foreach markname [getmarknames $ta $pos "$pos + 1 c"] {
            if {[$ta compare [$ta index $markname] == $pos]} {
                # this mark is exactly at $pos (i.e. the beginning of the line)
                if {[string match unsavedmodifiedline* $markname]} {
                    # this mark is a unsavedmodified mark
                    $tamargin tag add unsavedmodifiedline "end - 2l linestart" "end - 2l lineend"
                } else {
                    if {[string match savedmodifiedline* $markname]} {
                        # this mark is a savedmodified mark
                        $tamargin tag add savedmodifiedline "end - 2l linestart" "end - 2l lineend"
                    }
                }
            }
        }

        if {[$ta compare [$ta index "$pos lineend + 1 c"] == end]} {
            # end of file reached before the bottom of the window
            break
        }

        # line height might be different for each line, therefore it cannot
        # be seen as a constant in this while loop
        set lineheightinpix [lindex [$ta dlineinfo @0,$curheight] 3]
        incr curheight $lineheightinpix
    }

    # end of modification of margin content
    $tamargin configure -state disabled

    # scroll the line numbers margin to align them perfectly with the textarea
    # this is only actually needed for Tk 8.5 but doesn't hurt in 8.4
    # in 8.4 $topinpix is always 1 since the first displayed line in the
    # textarea is never clipped by the top of the textarea
    # in 8.5 $topinpix might be negative, indicating a clipping of the first
    # displayed line
    set topinpix [lindex [$ta dlineinfo @0,0] 1]
    if {$topinpix < 0} {
        set hiddenpartof1stline [expr {- $topinpix}]
        set marginheight [winfo height $tamargin]
        set fractomoveto [expr {double($hiddenpartof1stline) / $marginheight}]
        $tamargin yview moveto $fractomoveto
    }
}

proc togglemodifiedlinemargin {} {
# for all visible textareas, show or hide the "modified line" tags in a
# textarea margin
# when entering this proc, $modifiedlinemarginmenusetting has the newly
# selected value in the options menu, and $modifiedlinemargin is the old
# value
# note: the reason why there is both modifiedlinemargin and modifiedlinemarginmenusetting
#       is that this allows to make checks in this proc, which implements some
#       sort of very basic state machine, in turn allowing for not bothering to 
#       check $modifiedlinemargin in proc showlinenumbersmargin and hidelinenumbersmargin

   global modifiedlinemargin modifiedlinemarginmenusetting

    # nothing to do if the selected option is the same as the old one
    if {$modifiedlinemargin eq $modifiedlinemarginmenusetting} {
        return
    }

    if {$modifiedlinemargin eq "hide"} {
        # from "hide" to "show"
        showmodifiedlinemargin
    } else {
        # from "show" to "hide"
        hidemodifiedlinemargin
    }

    set modifiedlinemargin $modifiedlinemarginmenusetting
}

proc showmodifiedlinemargin {} {
# for all visible textareas, show "modified line" tags in a textarea margin
    global listoftextarea
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {
            addmodifiedlinemargin $ta
        }
    }
}

proc addmodifiedlinemargin {ta} {
# create a textarea margin where "modified line" tags will be displayed
    global textFont bgcolors fgcolors
    foreach c1 "$bgcolors $fgcolors" {global $c1}
    global modifiedlinemarginpixelwidth

    set tapwfr [getpaneframename $ta]
    set frmargin $tapwfr.propagationoffframe
    set tamargin $frmargin.marginml

    # margin for "modified line" tags
    # in order to have a margin that is not too fat, the text widget
    # is put inside a frame, geometry propagation is turned off on
    # the frame, and the width of the frame is set explicitely
    # to a small number measuring the width of the modified line margin
    # in pixels
    # this trick, which was proposed by Ken Jones, allows displaying
    # a text widget having a width smaller than one character
    # see the discussion here:
    #   http://groups.google.com/group/comp.lang.tcl/browse_thread/thread/a18c3ee98542d2fb
    frame $frmargin -width $modifiedlinemarginpixelwidth
    text $tamargin -bd 0 -highlightthickness 0 -font $textFont \
            -background $BGMLMARGCOLOR \
            -height 1 -width 1 -takefocus 0 -state disabled -cursor draft_large

    # let the user think he cannot select in the margin
    $tamargin configure -selectbackground [$tamargin cget -background]
    $tamargin configure -selectforeground [$tamargin cget -foreground]
    $tamargin configure -selectborderwidth 0

    # configure visual appearance of the tags for modified lines
    $tamargin tag configure unsavedmodifiedline -background $FGUSMLMARGCOLOR
    $tamargin tag configure   savedmodifiedline -background $FGSMLMARGCOLOR

    # define bindings to allow selection of text lines from the margin displaying
    # the "modified line" tags
    # this is achieved by defining bindings for the margin that execute
    # the corresponding Text class binding, but for the textarea widget, not for
    # the margin itself
    bind $tamargin <Button-1> { \
            set ta [gettafromwidget [winfo parent [winfo parent %W]]] ; \
            if {[info exists listoffile("$ta",fullname)]} { \
                focustextarea $ta ; \
                eval [string map [list %%W $ta %%x 0 %%y %y] [bind Text <Button-1>]] ; \
                selectline ; \
            } ; break ; \
          }
    # the call to [bind Text <Button1-Motion>] is to extend selection (tk::TextSelectTo)
    # the call to [bind Text <Button1-Leave>] is to scroll (tk::TextAutoScan) when the
    # mouse runs out of the textarea or the margin
    # the call to [bind Text <Button1-Enter>] is to stop current scrolling (tk::CancelRepeat)
    # before a new one gets launched - otherwise multiple instances of tk::TextAutoScan
    # start running in parallel and become therefore impossible to stop (tk::CancelRepeat)
    # because only one afterId is stored in tk::Priv(afterId)
    bind $tamargin <Button1-Motion> { \
            set ta [gettafromwidget [winfo parent [winfo parent %W]]] ; \
            if {[info exists listoffile("$ta",fullname)]} { \
                eval [string map [list %%W $ta %%x 0 %%y %y] [bind Text <Button1-Motion>]] ; \
                eval [string map [list %%W $ta %%x 0 %%y %y] [bind Text <Button1-Enter>]] ; \
                eval [string map [list %%W $ta %%x 0 %%y %y] [bind Text <Button1-Leave>]] ; \
                focustextarea $ta ; \
            } ; break ; \
          }
    bind $tamargin <Shift-1> { \
            set ta [gettafromwidget [winfo parent [winfo parent %W]]] ; \
            if {[info exists listoffile("$ta",fullname)]} { \
                eval [string map [list %%W $ta %%x 0 %%y %y] [bind Text <Shift-1>]] ; \
            } ; break ; \
          }
    bind $tamargin <ButtonRelease-1> { \
            set ta [gettafromwidget [winfo parent [winfo parent %W]]] ; \
            if {[info exists listoffile("$ta",fullname)]} { \
                eval [string map [list %%W $ta %%x %x %%y %y] [bind Text <ButtonRelease-1>]] ; \
                focustextarea $ta ; \
            } ; break ; \
          }

    # prevent unwanted Text class bindings from triggering
    bind $tamargin <Button-3> {break}
    bind $tamargin <Shift-Button-3> {break}
    bind $tamargin <Control-Button-3> {break}
    bind $tamargin <ButtonRelease-2> {break}
    bind $tamargin <Button-2> {break}
    bind $tamargin <MouseWheel> {break}

    pack $frmargin -in $tapwfr.topleft -before $ta -side left \
            -expand 0 -fill both -padx 0
    pack propagate $frmargin false
    pack $tamargin -expand 1 -fill both

    # nothing more to do to ensure this margin is the rightmost margin,
    # this is achieved by  -before $ta

    updatemodifiedlinemargin $ta
}

proc hidemodifiedlinemargin {} {
# for all visible textareas, hide "modified line" tags from the textarea margin
    global listoftextarea
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {
            removemodifiedlinemargin $ta
        }
    }
}

proc removemodifiedlinemargin {ta} {
# remove a textarea margin where "modified line" tags are displayed
    set tapwfr [getpaneframename $ta]
    set frmargin $tapwfr.propagationoffframe
    set tamargin $frmargin.marginml
    pack forget $tamargin
    pack forget $frmargin
    destroy $tamargin
    destroy $frmargin
}

proc setunsavedmodifiedline {ta startindex stopindex} {
# in all line numbers corresponding to the indices $startindex
# to $stopindex, add a mark identifying them as unsaved modified lines

    global unsavedmodifiedmarkID

    # normalize boundaries
    set sta [$ta index "$startindex linestart"]
    set sto [$ta index "$stopindex  linestart"]

    # add marks in modified lines
    for {set pos $sta} {[$ta compare $pos <= $sto]} {set pos [$ta index "$pos + 1 line"]} {

        # check whether the line starting at $pos is already marked as
        # being a modified unsaved line or not
        set alreadymarked false
        foreach markname [getmarknames $ta $pos "$pos + 1 c"] {
            if {[$ta compare [$ta index $markname] == $pos]} {
                # the mark is exactly at $pos
                if {[string match unsavedmodifiedline* $markname]} {
                    # this mark is a unsavedmodified mark,
                    # which means this line is already marked as unsaved and modified
                    set alreadymarked true
                    # one can break now because a line already marked as unsaved cannot
                    # have a savedmodified mark at the same time (which would be tested below)
                    break
                }
                if {[string match savedmodifiedline* $markname]} {
                    # this mark is a savedmodified mark,
                    # remove it before adding an unsavedmodified mark below
                    $ta mark unset $markname
                }
            }
        }

        if {!$alreadymarked} {
            # add the unsavedmodified mark at $pos
            incr unsavedmodifiedmarkID
            set markname unsavedmodifiedline$unsavedmodifiedmarkID
            $ta mark set $markname $pos
            $ta mark gravity $markname left
        } else {
            # already marked line: do nothing so as not to have more marks
            # than needed (think of a line in which 20 characters are typed in,
            # there would be 20 marks marking the line as unsaved modified!),
            # which would have a performance impact
        }

        # in the loop declaration above,  $ta compare $pos <= $sto  is needed
        # but if the following test is not done, then there can be an endless loop
        if {[$ta compare $sto == end]} {
            break
        }
    }
}

proc setsavedmodifiedline {ta} {
# transform all unsaved modified line marks of textarea $ta
# into saved modified line marks

    global savedmodifiedmarkID

    foreach markname [$ta mark names] {
        if {[string match unsavedmodifiedline* $markname]} {
            # $markname is a mark identifying a modified unsaved line
            # add a savedmodified mark
            incr savedmodifiedmarkID
            set savedmarkname savedmodifiedline$savedmodifiedmarkID
            $ta mark set $savedmarkname $markname
            $ta mark gravity $savedmarkname left
            # remove the unsavedmodified mark
            $ta mark unset $markname
        } else {
            # $markname denotes a mark that has nothing to do with unsaved modified lines,
            # do nothing
        }
    }

    # force update of the modified line margin
    updatemodifiedlinemargin_allpeers $ta
}

proc getmodifiedlinetags {ta} {
# return information about all (saved or unsaved) modified line marks
# of textarea $ta
# return value is a flat list of mark names and corresponding
# indices in textarea $ta

    set ret [list ]
    foreach markname [$ta mark names] {
        if {[string match *savedmodifiedline* $markname]} {
            # $markname is a mark identifying
            # either a modified unsaved line
            # or     a modified   saved line
            lappend ret $markname [$ta index $markname]
        } else {
            # do nothing
        }
    }
    return $ret
}

proc setmodifiedlinetags {ta listofmodifiedlinetags} {
# first erase all modified (saved or unsaved) line tags, then
# from a list as returned by proc getmodifiedlinetags set all
# modified line tags according to the indices in $ta listed
# in $listofmodifiedlinetags
# the visual update (call to proc updatemodifiedlinemargin)
# is supposed to be done at a higher calling level
# if $listofmodifiedlinetags is the empty list, then all
# modified line tags are deleted (and none is set)

    # remove all modified line tags
    foreach markname [$ta mark names] {
        if {[string match *savedmodifiedline* $markname]} {
            # $markname is a mark identifying
            # either a modified unsaved line
            # or     a modified   saved line
            $ta mark unset $markname
        } else {
            # do nothing
        }
    }

    # set modified unsaved and saved line tags from the given list
    foreach {markname pos} $listofmodifiedlinetags {
        $ta mark set $markname $pos
        $ta mark gravity $markname left
    }
}
