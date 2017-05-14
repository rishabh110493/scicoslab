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

proc updatelinenumbersmargin {ta} {
    global linenumberstype
    if {[colorizationinprogress nomessage]} {
        return
    }
    switch -- $linenumberstype {
        "physical"                {updatelinenumbersmargin_physical $ta}
        "logical"                 -
        "logical_ignorecontlines" {updatelinenumbersmargin_logical $ta}
    }
}

proc updatelinenumbersmargin_physical {ta} {
# delete the line numbers in the margin of textarea $ta, and
# re-enter all of them taking into account the possibly new end of $ta
# the width of the margin is also updated, depending on the number of
# digits to display
# Algorithm:
#   Instead of having a text widget with the same number of lines as the
# textarea, with one line number in each of its line (hence line 1 always
# contains number 1), and arranging for yview to fit in both (this was
# my first idea), now I have a text widget that is never scrolled and
# whose first line contains the first line number of the textarea aside
# This is much more performant, and fits also nicely with wrapped lines
# and elided text
# Wrapped lines detection is done the following way, and takes elided
# text into account:
#   - retrieve the display line height
#   - loop from the first displayed line (not from start of textarea!)
#      . if the line number of the beginning of display line is equal to:
#        a. the line number of the previous line plus one, then:
#             the current line did not wrap
#             there is no jump due to elided lines
#             --> the line number of the beginning of display line must be
#                 inserted in the margin
#        b. the line number of the previous line, then:
#             if this is the end of the buffer:
#                 no more line numbers to display in the margin
#             otherwise:
#                 the current line wrapped
#                 there is no jump due to elided lines
#                 --> an empty line must be inserted in the margin
#        c. another value, then:
#             the current line did not wrap
#             there is a jump due to elided lines
#             --> the line number of the beginning of display line must be
#                 inserted in the margin
#   - until last display line (i.e. when current y in pixels is greater
#     than [winfo height $ta])
# See also http://wiki.tcl.tk/20916  (showed up after I wrote this proc,
# might be better than mine, however the line numbers are just literally
# inserted at beginnings of lines, so copy & paste of multiple lines
# would need toggling line numbers off first)
    global linenumbersmargin

    # assert: when entering this proc, we have $linenumbersmargin ne "hide"

    # assert: when entering this proc, [isdisplayed $ta] is true

    set tamargin [getpaneframename $ta].marginln

    # start modifying margin content
    $tamargin configure -state normal

    $tamargin delete 1.0 end

    set endindex [$ta index end]
    scan $endindex "%d.%d" yend xend
    set nbyendchar [string length [expr {$yend - 1}]]

    # find out the height of the textarea, which will be the upper bound in
    # the loop below
    set winfoheight [winfo height $ta]

    # initialization values
    scan [$ta index @0,0] "%d.%d" prevline_p1 junk
    set curheight [lindex [$ta dlineinfo @0,0] 1]
    set spacepad ""
    set eofreached false

    while {$curheight <= $winfoheight} {
        scan [$ta index @0,$curheight] "%d.%d" linenum dropthis
        if {$linenum == $prevline_p1} {
            set prevline_p1 [expr {$linenum + 1}]
        } elseif {$linenum == [expr {$prevline_p1 - 1}]} {
            # either this is a wrapped line,
            # or the end of file has been reached before the bottom of the window
            if {[$ta compare [$ta index "@0,$curheight lineend + 1 c"] == end]} {
                # end of file reached before the bottom of the window
                set eofreached true
            } else {
                # wrapped line
                set linenum ""
            }
        } else {
            # jump of more than 1 in the line numbers, due to elided text
            set prevline_p1 [expr {$linenum + 1}]
        }
        if {$eofreached} {
            # stop immediately writing line numbers in the margin
            break
        }
        if {$linenumbersmargin eq "right"} {
            set spacepad [string repeat " " [expr {$nbyendchar - [string length $linenum]}]]
        } else {
            # spacepad is the empty string
        }
        $tamargin insert end "$spacepad$linenum\n"
        # line height might be different for each line, therefore it cannot
        # be seen as a constant in this while loop
        set lineheightinpix [lindex [$ta dlineinfo @0,$curheight] 3]
        incr curheight $lineheightinpix
    }

    # end of modification of margin content
    $tamargin configure -state disabled

    # update margin width according to the size of what it displays
    $tamargin configure -width $nbyendchar

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

proc updatelinenumbersmargin_logical {ta} {
# launch a doupdatelinenumbersmargin_logical command in background
# doupdatelinenumbersmargin_logical is a bit costly even if the inefficient
# whichfun is no longer called
# the principle is the same as for proc keyposn:
# if many updates are waiting for execution, e.g. when the user types
# quicker than the position can be updated by Scipad, there can be many
# commands pending -> first delete them since they are now pointless
# and launch only the latest command
# doupdatelinenumbersmargin_logical is catched to deal more easily with
# buffers that were closed before the command could be processed
    global backgroundtasksallowed
    if {$backgroundtasksallowed} {
        after cancel [list after 1 "catch \"doupdatelinenumbersmargin_logical $ta\""]
        after idle   [list after 1 "catch \"doupdatelinenumbersmargin_logical $ta\""]
    } else {
        doupdatelinenumbersmargin_logical $ta
    }
}

proc doupdatelinenumbersmargin_logical {ta} {
# delete the line numbers in the margin of textarea $ta, and
# re-enter all of them taking into account the possibly new end of $ta
# the width of the margin is also updated, depending on the number of
# digits to display and the nesting level of functions
# Algorithm is quite the same as in proc updatelinenumbersmargin_physical
# but has been adapted to display logical line numbers and dealing with
# special cases at functions boundary lines
# the logical line numbers displayed take the continued lines into account
# if $linenumberstype eq "logical", or continued lines are counted the same
# as any other line if $linenumberstype eq "logical_ignorecontlines"
# wrapped lines are properly taken into account in any case
#
# note 1: the algorithm does not deal with the case of functions defined
#         multiple times in the same buffer - line numbering will be wrong
#         Can't see a way of fixing this - happens usually during buffer
#         editing
#
# note 2: there is normally no need here to test for language scheme to be
#         scilab or to check that the buffer is colorized because in those
#         cases getallfunctionsareasintextarea will return the empty list
#         (because getallfunsintextarea will), thus logical line numbering
#         here is the same as physical line numbering - this is also the
#         reason why the logical/physical option menu is global and does
#         not need to be local to each buffer
#         HOWEVER: the language scheme IS checked to be scilab, so that if
#         it's not one is redirected to updatelinenumbersmargin_physical
#         Reasons for that:
#           a. doupdatelinenumbersmargin_logical does not need to take elided
#              characters into account (which can happen when using the
#              Modelica language scheme), only updatelinenumbersmargin_physical
#              needs to do this
#           b. updatelinenumbersmargin_physical should exhibit better performance
#              than doupdatelinenumbersmargin_logical

    global listoffile
    global linenumbersmargin
    global linenumberstype

    # assert: when entering this proc, we have $linenumbersmargin != "hide"

    # assert: when entering this proc, [isdisplayed $ta] is true

    if {$listoffile("$ta",language) ne "scilab"} {
        updatelinenumbersmargin_physical $ta
        return
    }

    set tamargin [getpaneframename $ta].marginln

    # start modifying margin content
    $tamargin configure -state normal

    $tamargin delete 1.0 end

    set endindex [$ta index end]
    scan $endindex "%d.%d" yend xend
    set nbyendchar [string length [expr {$yend - 1}]]
    set maxcurnestlevel 0

    # find out the height of the textarea, which will be the upper bound in
    # the loop below
    set winfoheight [winfo height $ta]

    # find out the width of the textarea, which will be used for peeking at
    # the last pixel of the line instead of the first one, the goal being to
    # get line in fun 1 for the line containing the function declaration
    # indeed, if we look at first pixel, this pixel is *before* the function
    # and this line would get a line number from the surrounding code.
    # actually the situation is more complex. This deals with function xxxx
    # but not with endfunction lines, that will be treated specially below
    set winfowidth [winfo width $ta]

    # initialization values
    set contlinesindexstop [$ta index @0,0]
    if {$linenumberstype eq "logical"} {
        set nbcontlinesbefore [countcontlines $ta "1.0" $contlinesindexstop]
    } else {
        set nbcontlinesbefore 0
    }
    set allfunctionsareas [getallfunctionsareasintextarea $ta]
    set pos [$ta index @$winfowidth,0]
    set posinlastiteration -1.0
    set funandlineandnest [getfunandlogicallineandnestlevelatpos $ta $allfunctionsareas $pos]
    if {[lindex $funandlineandnest 0] ne ""} {
        foreach {currentfunname prevline_p1 curnestlevel} $funandlineandnest {}
    } else {
        # we're out of any function and displaying logical line numbers,thus:
        # if $linenumberstype eq "logical":
        #   physical line numbers in the textarea must be corrected
        #   according to the number of previous continued lines
        #   $contlinesindexstop is maintained to avoid the costly call to
        #   [countcontlines $ta "1.0" ...] i.e. from the beginning of the textarea
        # if $linenumberstype eq "logical_ignorecontlines"
        #   continued lines are ignored thus physical line numbers in the textarea
        #   must be displayed unchanged, which is achieved since $nbcontlinesbefore
        #   is zero (see the "if" on $linenumberstype above)
        set currentfunname ""
        scan $contlinesindexstop "%d." prevline_p1
        set prevline_p1 [expr {$prevline_p1 - $nbcontlinesbefore}]
        set curnestlevel 0
    }
    set curheight [lindex [$ta dlineinfo @0,0] 1]
    set spacepad ""

    while {$curheight <= $winfoheight} {
        # maintain knowledge of where we are in the code
        set enteringnewfunction false
        set leavingpreviousfunctionforwrapperfunction false
        set leavingpreviousfunctionforlevelzero false
        set pos [$ta index @$winfowidth,$curheight]
        if {$posinlastiteration == $pos} {
            # $pos is the index of the last real character in the buffer (i.e. the position
            # just before the final hidden \n of the textarea) but this line was already
            # numbered previously
            # one must jump out of the loop immediately in order to avoid numbering
            # a ghost non existing line after the end of the text content - moreover,
            # jumping out now improves performance for buffers ending before $winfoheight
            # since there is no need to run the algorithm below after the end of the text
            # (line numbers were already erased above)
            break
        } else {
            set posinlastiteration $pos
        }
        set funandlineandnest [getfunandlogicallineandnestlevelatpos $ta $allfunctionsareas $pos]

        if {[lindex $funandlineandnest 0] ne ""} {
            # we are in a function
            foreach {localfunname linenum curnestlevel} $funandlineandnest {}
            if {$linenum == 1} {
                if {$localfunname ne $currentfunname} {
                    # entering a new function
                    set enteringnewfunction true
                    set currentfunname $localfunname
                } else {
                    # still in the same function
                    # (this is a continued first line of the function)
                }
            } else {
                if {$localfunname ne $currentfunname} {
                    # either we're leaving the previously current function,
                    # or it's the endfunction line
                    set pos [$ta index @0,$curheight]
                    set funandlineandnest2 [getfunandlogicallineandnestlevelatpos $ta $allfunctionsareas $pos]
                    if {[lindex $funandlineandnest2 0] eq $currentfunname} {
                        # this is the endfunction line
                        set linenum [lindex $funandlineandnest2 1]
                        set curnestlevel [lindex $funandlineandnest2 2]
                        # $currentfunname remains unchanged: endfunction (start of) line is part of it
                    } else {
                        # leaving the previously current function
                        if {[lindex $funandlineandnest2 0] eq $localfunname} {
                            # leaving the previously current function with a "normal" line
                            set currentfunname $localfunname
                        } else {
                            # leaving the previously current function with again an endfunction
                            foreach {currentfunname linenum curnestlevel} $funandlineandnest2 {}
                        }
                        set leavingpreviousfunctionforwrapperfunction true
                    }
                } else {
                    # still in the same function
                }
            }

        } else {
            # we're out of any function and displaying logical line numbers, thus:
            # if $linenumberstype eq "logical":
            #   physical line numbers in the textarea must be corrected
            #   according to the number of previous continued lines
            # if $linenumberstype eq "logical_ignorecontlines"
            #   continued lines are ignored thus physical line numbers in the textarea
            #   must be displayed unchanged
            set newcontlinesindexstop [$ta index @0,$curheight]
            scan $newcontlinesindexstop "%d." linenum
            if {$linenumberstype eq "logical"} {
                incr nbcontlinesbefore [countcontlines $ta $contlinesindexstop $newcontlinesindexstop]
            } else {
                # nothing to do, nbcontlinesbefore keeps its value (zero)
            }
            set linenum [expr {$linenum - $nbcontlinesbefore}]
            set contlinesindexstop $newcontlinesindexstop
            set curnestlevel 0
            if {$currentfunname ne ""} {
                # either we're leaving the previously current function,
                # or it's the endfunction line
                set pos [$ta index @0,$curheight]
                set funandlineandnest2 [getfunandlogicallineandnestlevelatpos $ta $allfunctionsareas $pos]
                if {[lindex $funandlineandnest2 0] eq $currentfunname} {
                    # this is the endfunction line
                    set linenum [lindex $funandlineandnest2 1]
                    set curnestlevel [lindex $funandlineandnest2 2]
                    # $currentfunname remains unchanged: endfunction (start of) line is part of it
                } else {
                    # leaving the previously current function
                        if {[lindex $funandlineandnest2 0] eq ""} {
                            # leaving the previously current function with a "normal" line
                            set currentfunname ""
                        } else {
                            # leaving the previously current function with again an endfunction
                            foreach {currentfunname linenum curnestlevel} $funandlineandnest2 {}
                        }
                    set leavingpreviousfunctionforlevelzero true
                }
            } else {
                # previous line was already at level zero
            }
        }

        # adjust $prevline_p1 (previous line number + 1) for special cases
        # such as entering or leaving functions
        if {$enteringnewfunction} {
            set prevline_p1 1
        } elseif {$leavingpreviousfunctionforwrapperfunction} {
            set prevline_p1 $linenum
        } elseif {$leavingpreviousfunctionforlevelzero} {
            set prevline_p1 $linenum
        } else {
            # no other case with adjustment is needed
        }

        # deal with continued lines and wrapped lines,
        # i.e. do not display their line number
        if {$linenum == $prevline_p1} {
            set prevline_p1 [expr {$linenum + 1}]
        } else {
            set linenum ""
        }

        # pad with spaces according to alignment and nesting level,
        # and display line numbers in the margin
        if {$linenumbersmargin eq "right"} {
            set spacepad [string repeat " " [expr {$nbyendchar * ( $curnestlevel + 1 ) - [string length $linenum]}]]
        } else {
            # $linenumbersmargin eq "left"
            set spacepad [string repeat " " [expr {$nbyendchar * $curnestlevel}]]
        }
        $tamargin insert end "$spacepad$linenum\n"

        if {$maxcurnestlevel < $curnestlevel} {
            set maxcurnestlevel $curnestlevel
        }

        # line height might be different for each line, therefore it cannot
        # be seen as a constant in this while loop
        set lineheightinpix [lindex [$ta dlineinfo @0,$curheight] 3]
        incr curheight $lineheightinpix
    }

    # end of modification of margin content
    $tamargin configure -state disabled

    # update margin width according to the size of what it displays
    $tamargin configure -width [expr {$nbyendchar * ( $maxcurnestlevel + 1 )}]

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

proc togglelinenumbersmargin {} {
# for all visible textareas, show or hide line numbers in a textarea margin
# when entering this proc, $linenumbersmarginmenusetting has the newly
# selected value in the options menu, and $linenumbersmargin is the old
# value
# note: the reason why there is both linenumbersmargin and linenumbersmarginmenusetting
#       is that this allows to make checks in this proc, which implements some
#       sort of very basic state machine, in turn allowing for not bothering to 
#       check $linenumbersmargin in proc showlinenumbersmargin and hidelinenumbersmargin

    global linenumbersmargin linenumbersmarginmenusetting

    # nothing to do if the selected option is the same as the old one
    if {$linenumbersmargin eq $linenumbersmarginmenusetting} {
        return
    }

    if {$linenumbersmargin eq "hide"} {
        # from "hide" to "left" or "right"
        showlinenumbersmargin
    } elseif {$linenumbersmarginmenusetting eq "hide"} {
        # from "left" or "right" to "hide"
        hidelinenumbersmargin
    } else {
        # from "left" to "right", or from "right" to "left"
        hidelinenumbersmargin ; update idletasks
        showlinenumbersmargin
    }

    set linenumbersmargin $linenumbersmarginmenusetting
}

proc showlinenumbersmargin {} {
# for all visible textareas, show line numbers in a textarea margin
    global listoftextarea
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {
            addlinenumbersmargin $ta
        }
    }
}

proc addlinenumbersmargin {ta} {
# create a textarea margin where line numbers will be displayed
    global textFont bgcolors fgcolors
    global modifiedlinemargin
    foreach c1 "$bgcolors $fgcolors" {global $c1}

    set tapwfr [getpaneframename $ta]
    set tamargin $tapwfr.marginln

    # margin for line numbers
    # -width 1 ensures that the bottom scrollbar shows up
    # whatever the size of the textarea
    # the correct -width is anyway set in proc updatelinenumbersmargin
    text $tamargin -bd 0 -highlightthickness 0 -font $textFont \
            -background $BGLNMARGCOLOR -foreground $FGLNMARGCOLOR \
            -height 1 -width 1 -takefocus 0 -state disabled -cursor draft_large

    # let the user think he cannot select in the margin
    $tamargin configure -selectbackground [$tamargin cget -background]
    $tamargin configure -selectforeground [$tamargin cget -foreground]
    $tamargin configure -selectborderwidth 0

    # define bindings to allow selection of text lines from the margin displaying
    # the line numbers
    # this is achieved by defining bindings for the margin that execute
    # the corresponding Text class binding, but for the textarea widget, not for
    # the margin itself
    bind $tamargin <Button-1> { \
            set ta [gettafromwidget [winfo parent %W]] ; \
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
            set ta [gettafromwidget [winfo parent %W]] ; \
            if {[info exists listoffile("$ta",fullname)]} { \
                eval [string map [list %%W $ta %%x 0 %%y %y] [bind Text <Button1-Motion>]] ; \
                eval [string map [list %%W $ta %%x 0 %%y %y] [bind Text <Button1-Enter>]] ; \
                eval [string map [list %%W $ta %%x 0 %%y %y] [bind Text <Button1-Leave>]] ; \
                focustextarea $ta ; \
            } ; break ; \
          }
    bind $tamargin <Shift-1> { \
            set ta [gettafromwidget [winfo parent %W]] ; \
            if {[info exists listoffile("$ta",fullname)]} { \
                eval [string map [list %%W $ta %%x 0 %%y %y] [bind Text <Shift-1>]] ; \
            } ; break ; \
          }
    bind $tamargin <ButtonRelease-1> { \
            set ta [gettafromwidget [winfo parent %W]] ; \
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

    pack $tamargin -in $tapwfr.topleft -before $ta -side left \
            -expand 0 -fill both -padx 0

    # ensure this margin is the leftmost margin
    if {[winfo exists $tapwfr.propagationoffframe]} {
        pack configure $tamargin -before $tapwfr.propagationoffframe
    }

    updatelinenumbersmargin $ta
}

proc hidelinenumbersmargin {} {
# for all visible textareas, hide line numbers from the textarea margin
    global listoftextarea
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {
            removelinenumbersmargin $ta
        }
    }
}

proc removelinenumbersmargin {ta} {
# remove a textarea margin where line numbers are displayed
    set tapwfr [getpaneframename $ta]
    pack forget $tapwfr.marginln
    destroy $tapwfr.marginln
}

proc togglelinenumberstype {} {
# for all visible textareas, switch the type of line numbers
# in a textarea margin
    hidelinenumbersmargin ; update idletasks
    showlinenumbersmargin
    # keyposn needed to update the logical line number in the
    # status bar, which may change when switching between the
    # two logical line numbers schemes
    keyposn [gettextareacur]
    # if the breakpoints gui is open, the displayed line numbers
    # may need to be updated
    switchdisplayedlinenumbersinbptsgui
}
