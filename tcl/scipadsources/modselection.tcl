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

proc selectall {} {
    # end position to select is end-1c so that the final \n in the textarea
    # is not selected (it is anyway not part of the actual text entered by
    # the user, but is needed in any text widget
    [gettextareacur] tag add sel 1.0 end-1c
    [gettextareacur] mark set insert end
    # update menues contextually
    keyposn [gettextareacur]
}

proc selectline {} {
# ancillary for un/comment, un/indent
# select the physical line of text where the insert cursor lies
    set ta [gettextareacur]
    set i1 [$ta index "insert linestart"]
    set i2 [$ta index "insert lineend"]
    $ta tag remove sel 1.0 end
    $ta tag add sel $i1 $i2
    set seltext [$ta get $i1 $i2]
    return $seltext
}

proc gettatextstring {ta indices} {
# construct a single string from the text identified by $indices in textarea $ta
# $indices is a list of $start $stop text widget indices
# warning: this list is supposed to identify contiguous lines, i.e. a block
#          selection
    set prevsto [lindex $indices 1]
    set fullstring [$ta get [lindex $indices 0] $prevsto]
    foreach {sta sto} [lreplace $indices 0 1] {
        # if there are multiple ranges, split the selected lines with
        # a \n in the clipboard, but only if the range does not
        # already have a trailing \n in the previous line
        if {[$ta get "$prevsto-1c" $prevsto] != "\n"} {
            append fullstring "\n"
        }
        append fullstring [$ta get $sta $sto]
        set prevsto $sto
    }
    return $fullstring
}

proc gettaselind {textarea {supportmultiple "single"}} {
# return the selection as a list of start / stop indices if there is one
# in $textarea, or an empty string if there is none
# if there are multiple selections (this can only be the case for a block
# selection), return the list of selected text indices if $supportmultiple
# is not set to "single"
# the optional input parameter supportmultiple might contain
#    single: no multiple (i.e. block) selection allowed
#    any   : any selection allowed
# with "any", the calling proc must handle multiple (non contiguous)
# selections
# with "single", multiple selections are collapsed to a single selection
# which is the first range of the multiple selection
# the X selection is not used nor changed, it's the sel tag of $textarea
# that is checked
    set selranges [$textarea tag ranges sel]
    if {$supportmultiple == "single" && [llength $selranges] > 2} {
        # collapse possibly existing multiple selection to a single selection
        # being the first sel range
        foreach {sta sto} [lreplace $selranges 0 1] {
            $textarea tag remove sel $sta $sto
        }
        set selranges [$textarea tag nextrange sel 1.0]
        if {$selranges != {}} {
            $textarea mark set insert sel.last
        }
    }
    return $selranges
}

proc isposinsel {w x y} {
# return true if the pixel position @$x,$y in textarea $w is strictly
# inside the (possibly block) selection of textarea $w
    set testpos [$w index @$x,$y]
    set insel false
    foreach {sta sto} [gettaselind $w any] {
        if {[$w compare $sta < $testpos] && [$w compare $testpos < $sto]} {
            set insel true
            break
        }
    }
    return $insel
}

proc startblockselection {w x y} {
# initiate a block selection
    global wordWrap pad MenuEntryId blockseltoggledwordwrap blockselanchor
    global Tk85

    # save the original (before un-wordwrap) pointed position
    set selstartpos [$w index @$x,$y]

    # temporarily force no word wrapping
    if {$wordWrap != "none"} {
        $pad.filemenu.options invoke $MenuEntryId($pad.filemenu.options.[mcra "Word &wrap"])
        set blockseltoggledwordwrap true
    } else {
        set blockseltoggledwordwrap false
    }

    # the block selection anchor must be the character pointed
    # to when starting the block selection -> the block selection
    # anchor is $selstartpos corrected by the amount of y space
    # that moved up when un-wordwrapping
    foreach {px py} [winfo pointerxy $w] {} ; # in screen coordinate system
    set pxw [expr {$px - [winfo rootx $w]}] ; # in $w coordinate system
    set pyw [expr {$py - [winfo rooty $w]}]
    if {$Tk85} {
        # the count command for text widgets is not available in Tk 8.4,
        # only in Tk 8.5 and later
        set nypix [$w count -update -ypixels $selstartpos @$pxw,$pyw]
    } else {
        # for Tk 8.4, fall back to something that will not work (the starting
        # point of the block selection will not be the expected one) when
        # there are wrapped lines, however at least it does not crash
        set nypix 0
    }
    set blockselanchor [list $x [expr {$y - $nypix}]]

    $w tag remove sel 1.0 end
}

proc endblockselection {w} {
# finish a block selection
    global pad MenuEntryId blockseltoggledwordwrap blockselanchor

    unset -nocomplain -- blockselanchor

    # restore word wrapping
    if {$blockseltoggledwordwrap} {
        $pad.filemenu.options invoke $MenuEntryId($pad.filemenu.options.[mcra "Word &wrap"])
        set blockseltoggledwordwrap false
    }
}

proc selectblock {w x y} {
# extend the block selection from the block selection anchor point,
# i.e. the point where the mouse was when button-1 was pressed,
# to the current mouse position

    global blockselanchor

    if {![info exists blockselanchor]} {
        # Shift-Control was hit while a normal selection had started
        startblockselection $w $x $y
    }

    set anchorx [lindex $blockselanchor 0]
    set anchory [lindex $blockselanchor 1]
    set cornerx $x
    set cornery $y

    # avoid border effects when the mouse goes outside of the textarea
    if {$cornery < 1} {
        set cornery 1
    }
    if {$cornery > [winfo height $w]} {
        set cornery [winfo height $w]
    }

    # possible cases at this point (A=anchor, C=corner):
    #    A      A     C      C    A    C    AC    CA
    #     C    C       A    A     C    A
    set inverted false
    if {$cornery < $anchory} {
        set temp $cornery
        set cornery $anchory
        set anchory $temp
        set inverted true
    }
    if {$cornerx < $anchorx} {
        set temp $cornerx
        set cornerx $anchorx
        set anchorx $temp
    }
    # possible cases at this point:
    #            anchorx  cornerx    anchorx=cornerx    anchorx  cornerx
    #
    # anchory->     A                       A              A        C
    #
    # cornery->              C              C
    #
    # at this point we always have $anchory <= $cornery
    # and $anchorx <= $cornerx, so that @$anchory,$anchorx
    # and @$cornery,$cornerx are the indices of respectively
    # the upper left corner and the lower right corner of
    # the block selection

    # finally, tag the lines!
    $w tag remove sel 1.0 end
    # note: since $anchory and $corney are pixel coordinates, one could
    #       have thought of using {incr i $lineheigth} instead of {incr i}
    #       but this would cause incredible headaches to have the cursor
    #       never after the end of the selection, and never inside it
    #       so I forgot any optimization here and run the loop pixel
    #       by pixel, eventually tagging the same portion of text multiple
    #       times
    for {set i $anchory} {$i <= $cornery} {incr i} {
        set sta [TextClosestGap_scipad $w $anchorx $i]
        set sto [TextClosestGap_scipad $w $cornerx $i]
        if {[$w compare $sta == $sto]} {
            # @$x,$y must be used otherwise empty lines might be forgotten when
            # block-selecting from farther than the middle of the line
            set sta [$w index @$anchorx,$i]
            set sto $sta
            if {[$w compare $sta != "end - 1 c"]} {
                set dlinfo [$w dlineinfo $sta]
                set linex [lindex $dlinfo 0]
                set linewidth [lindex $dlinfo 2]
                if {[$w compare [TextClosestGap_scipad $w [expr {$linex+$linewidth}] $i] <= $sta]} {
                    # the line is shorter than the block left limit
                    # in this case, tag the \n at the end of this line
                    # note that the test above works even if the textarea
                    # has been scrolled horizontally: $linex is negative
                    # in this case, and this is what is needed
                    set sto "$sto + 1l linestart"
                }
            }
        }
        $w tag add sel $sta $sto
    }

    # update the insertion cursor position
    if {$inverted} {
        catch {$w mark set insert sel.first}
    } else {
        catch {$w mark set insert sel.last}
    }
}

proc CommentSel {} {
# comment the selection, or insert "//" at the current point
# if there is no selection
# note: block selection is supported

    if {[IsBufferEditable] == "No"} {return}

    set ta [gettextareacur]

    set savedinsertindex [$ta index insert]

    set sepflag [startatomicedit $ta]

    set selindices [gettaselind $ta any]
    if {$selindices == {}} {
        # if there is no selection, simply insert // at the insert point
        puttext $ta "//" "forceinsert"

    } else {
        # there is a selection in the current textarea
        # note: do NOT extend selection to the beginning of the line!

        # we don't want a comment sign be inserted at the beginning of
        # the last line when the selection ends at column 0, thus in
        # this case trim the selection one char to the left
        set lastselpos [lindex $selindices end]
        if {[$ta compare "$lastselpos linestart" == $lastselpos]} {
            set flagtrimmed true
            $ta tag remove sel "$lastselpos - 1 c"
        } else {
            set flagtrimmed false
        }
        # note that now there might be no selection left if the initial
        # selection was just an empty line, thus the test on
        #  $currentlastselpos ne {}  below

        # insert // at the beginning of each line (the regsub in
        # proc apply_RE_to_sel_text has -line option)
        apply_RE_to_sel_text $ta {^} "//"

        # restore full selection if it was trimmed above (otherwise
        # this is dealt with in proc apply_RE_to_sel_text)
        if {$flagtrimmed} {
            set currentlastselpos [lindex [gettaselind $ta any] end]
            if {$currentlastselpos ne {}} {
                $ta tag add sel "$currentlastselpos lineend"
            } else {
                # restore the removed selected char (apply_RE_to_sel_text
                # did not change anything, this happens only for a single
                # empty slected line)
                $ta tag add sel "$lastselpos - 1 c"
            }
        }
    }

    endatomicedit $ta $sepflag

    $ta mark set insert $savedinsertindex
    $ta see $savedinsertindex

    # update menues contextually
    keyposn $ta
}

proc UnCommentSel {} {
# uncomment the selection, or the current line if there is no selection
# if the selection or current line are not commented, do nothing
# note: block selection is supported

    if {[IsBufferEditable] == "No"} {return}

    set ta [gettextareacur]

    set savedinsertindex [$ta index insert]

    set sepflag [startatomicedit $ta]

    if {[gettaselind $ta any] == {}} {
        # if there is no selection, select the current line and uncomment
        # if this selected line is not empty
        if {[selectline] != ""} {
            UnCommentSel
        }

    } else {
        # there is a selection in the current textarea
        # note: do NOT extend selection to the beginning of the line!

        # remove leading //, possibly prepended with blanks
        apply_RE_to_sel_text $ta {^[[:blank:]]*//} ""
    }

    endatomicedit $ta $sepflag

    $ta mark set insert $savedinsertindex
    $ta see $savedinsertindex

    # update menues contextually
    keyposn $ta
}

proc IndentSel {} {
# indent the selection, or the current line if there is no selection
# note: block selection is supported

    global tabinserts indentspaces listoffile

    if {[IsBufferEditable] == "No"} {return}

    if {$tabinserts == "spaces"} {
        set skip ""
        for {set x 0} {$x<$indentspaces} {incr x} {
            append skip " "
        }
    } else {
        # tab inserts tabs, then $skip is one tab character
        set skip "\x9"
    }

    set ta [gettextareacur]

    set savedinsertindex [$ta index insert]

    set selindices [gettaselind $ta any]

    if {$selindices == {}} {
        # if there is no selection, select the current line and indent
        # if this selected line is not empty
        if {[selectline] != ""} {
            IndentSel
        }

    } else {
        # there is a selection in the current textarea
        # extend selection to the beginning of the line,
        # but only if this is not a block selection
        if {[llength $selindices] == 2} {
            set firstind [lindex $selindices 0]
            $ta tag add sel "$firstind linestart" $firstind
        }

        # so only one undo is required to undo indentation
        set sepflag [startatomicedit $ta]

        # remove leading spaces or tabs
        # this is useful when reindenting with tabs (or spaces) a text
        # already indented with spaces (respectively tabs)
        if {$tabinserts == "spaces"} {
            # remove leading tabs
            apply_RE_to_sel_text $ta {^\t*} ""
        } else {
            # remove leading spaces
            apply_RE_to_sel_text $ta {^ *} ""
        }

        # maybe the removal collapsed the selection, then select again
        if {[gettaselind $ta any] == {}} {
            if {[selectline] != ""} {
                IndentSel
            }
        } else {
            # insert $skip at the beginning of each line of the selection,
            # but do not modify (match) empty lines, so that there is no need
            # to clean up lines which would otherwise contain only spaces
            apply_RE_to_sel_text $ta {^(.+)} "$skip\\1"
        }

        endatomicedit $ta $sepflag
    }

    $ta mark set insert $savedinsertindex
    $ta see $savedinsertindex

    # update menues contextually
    keyposn $ta
}

proc UnIndentSel {} {
# unindent the selection, or the current line if there is no selection
# if the selection or current line are not indented, do nothing
# note: block selection is supported

    global indentspaces

    if {[IsBufferEditable] == "No"} {return}

    set ta [gettextareacur]

    set savedinsertindex [$ta index insert]

    set selindices [gettaselind $ta any]

    if {$selindices == {}} {
        # if there is no selection, select the current line and unindent
        # if this selected line is not empty
        if {[selectline] != ""} {
            UnIndentSel
        }

    } else {
        # there is a selection in the current textarea
        # extend selection to the beginning of the line,
        # but only if this is not a block selection
        if {[llength $selindices] == 2} {
            set firstind [lindex $selindices 0]
            $ta tag add sel "$firstind linestart" $firstind
        }

        set sepflag [startatomicedit $ta]

        # remove up to $indentspaces leading spaces or one tab character
        # at the beginning of each line
        apply_RE_to_sel_text $ta "(^ {1,$indentspaces})|(^\\t)" ""

        endatomicedit $ta $sepflag
    }

    $ta mark set insert $savedinsertindex
    $ta see $savedinsertindex

    # update menues contextually
    keyposn $ta
}

proc apply_RE_to_sel_text {ta REpat repltext} {
# ancillary for un/comment, un/indent, converttabstospaces
# and convertspacestotabsinsel
# the textarea $ta is supposed to have a selection
# in that selection, a regsub is performed using $REpat and the
# replacement text $repltext
# the resulting text replaces the original one in $ta
# the selection is updated according to the changes that were done
# note: multiple (i.e. block) selection is supported: the regexp is
# applied range by range (i.e. line by line in case of a block
# selection)

    # application of the regexp should be seen as an atomic operation,
    # even for multiple (block) selections
    set sepflag [startatomicedit $ta]

    set selindices [gettaselind $ta any]

    # split $selindices into single lines, so that undo will work
    # (see comments below)
    set tempselindices [list ]
    set splitflags [list ]
    foreach {sta sto} $selindices {
        if {[$ta compare [$ta index "$sta linestart"] == [$ta index "$sto linestart"]]} {
            # $sta and $sto denote indices on the same line
            lappend tempselindices $sta $sto
            lappend splitflags false
        } else {
            # $sta and $sto denote indices on different lines
            set splitsta $sta
            set splitsto [$ta index "$splitsta lineend"]
            while {[$ta compare $splitsto < $sto]} {
                lappend tempselindices $splitsta $splitsto
                set splitsta [$ta index "$splitsta + 1 line linestart"]
                set splitsto [$ta index "$splitsta lineend"]
                lappend splitflags true
            }
            lappend tempselindices $splitsta $sto
            lappend splitflags false
        }
    }
    set selindices $tempselindices

    # prevent puttext from messing selections
    $ta tag remove sel 1.0 end
    set newselindices [list ]

    foreach {sta sto} $selindices splitflag $splitflags {
        # these marks will maintain the selection boundaries correctly
        # even during puttext below
        $ta mark set leftbound [$ta index $sta]
        $ta mark gravity leftbound left
        $ta mark set rightbound [$ta index $sto]
        $ta mark gravity rightbound right

        set seltext [$ta get leftbound rightbound]

        # for each line of the (possibly multiline, but contiguous) selection,
        # replace any text matching $REpat by a new text $repltext
        # warning: assumption is made at the caller level that regsub
        #          is performed here with -line option, thus don't change
        #          that without thinking twice
        set nbreplaceinthisline [regsub -all -line -- $REpat $seltext $repltext newtext]

        if {$nbreplaceinthisline > 0} {
            # delete selection range, preserve bounds marks
            $ta mark set insert $sto
            $ta delete $sta $sto

            # note that puttext (correctly) collapses multiple selections
            puttext $ta $newtext "forceinsert"

        } else {
            # specifically do nothing since there was no match, in particular
            # don't replace text by identical text, otherwise when undoing later,
            # colorization, which limits are set by detecting changes in the text
            # between before and after undo action, may not colorize the entire
            # replaced text
            # this precaution added to the matching line by line makes undo
            # work in any case (hopefully...)
        }

        # save new selection bounds, and cleanup marks
        if {$splitflag} {
            lappend newselindices [$ta index leftbound] [$ta index "rightbound + 1 c"]
        } else {
            lappend newselindices [$ta index leftbound] [$ta index rightbound]
        }
        $ta mark unset leftbound rightbound
    }

    # restore selection with updated bounds
    foreach {sta sto} $newselindices {
        $ta tag add sel $sta $sto
    }

    # application of the regexp should be seen as an atomic operation,
    # even for multiple (block) selections
    endatomicedit $ta $sepflag
}

proc togglecomments {} {
# toggle comments in the selected area of the current textarea
# note: multiple (i.e. block) selection is supported

    set ta [gettextareacur]

    set selindices [gettaselind $ta any]

    if {$selindices == {}} {
        # if there is no selection, do nothing
        showinfo [mc "No text selected!"]

    } else {
        # remove all selections so that applying (Un/)CommentSel
        # will apply only to a line that will be selected below
        $ta tag remove sel 1.0 end

        # toggling comments should be seen as an atomic operation,
        # even for multiple (block) selections
        set sepflag [startatomicedit $ta]

        # there is a (possibly multiple) selection, toggle
        # comments on each selection range
        foreach {sta sto} $selindices {
            set cursta $sta
            if {[$ta compare $sto != "$sto linestart"]} {
                set sto "$sto lineend + 1 c"
            }
            while {[$ta compare $cursta < $sto]} {
                set endind [$ta index "$cursta lineend + 1 c"]
                $ta tag remove sel 1.0 end
                $ta tag add sel $cursta $endind
                if {[islinecommented $ta $cursta]} {
                    UnCommentSel
                } else {
                    CommentSel
                }
                set cursta "$cursta lineend + 1 c"
            }
        }
        foreach {sta sto} $selindices {
            $ta tag add sel $sta $sto
        }

        # toggling comments should be seen as an atomic operation,
        # even for multiple (block) selections
        endatomicedit $ta $sepflag
    }
}

proc islinecommented {ta pos} {
# return true:
#    if position $pos in textarea $ta denotes a position in a commented line
#        (i.e. starting with // possibly prepended with blanks)
#    or if position $pos in textarea $ta starts a comment (i.e. the next two
#        non blank characters are //)
# return false otherwise
#   note: comments detection is performed without using the rem2 tag that
# is used to colorize comments - this is to have a working proc islinecommented
# even if colorization is not engaged
#   warning: this proc is exactly what is needed as an ancillary to proc
# togglecomments - it is NOT fitted to detecting whether the cursor is in a
# commented line since it will return false (which is the expected behaviour)
# when the cursor is inside the comment part of a line such as:
#    a=1;  // my comment

    set theline [$ta get "$pos linestart" "$pos lineend"]
    set trimmedline [string trimleft $theline]
    if {[string match {//*} $trimmedline]} {
        # line containing $pos is a Scilab comment (it's a line
        # starting with // possibly prepended with blanks)
        return true
    }

    set endofline [$ta get $pos "$pos lineend"]
    set trimmedendline [string trimleft $endofline]
    if {[string match {//*} $trimmedendline]} {
        # position $pos in the line is a Scilab comment (the
        # next two non blank characters are //)
        return true
    }

    # if we're still here then no previous test was successful
    return false
}

proc updatedoubleclickscheme {} {
    global doubleclickscheme tcl_wordchars tcl_nonwordchars
    global tcl_wordchars_linux tcl_nonwordchars_linux
    global tcl_wordchars_windows tcl_nonwordchars_windows 
    global tcl_wordchars_scilab tcl_nonwordchars_scilab
    if {$doubleclickscheme == "Linux"} {
        set tcl_wordchars $tcl_wordchars_linux
        set tcl_nonwordchars $tcl_nonwordchars_linux
    } elseif {$doubleclickscheme == "Windows"} {
        set tcl_wordchars $tcl_wordchars_windows
        set tcl_nonwordchars $tcl_nonwordchars_windows
    } else {
        # "Scilab"
        set tcl_wordchars $tcl_wordchars_scilab
        set tcl_nonwordchars $tcl_nonwordchars_scilab
    }
}

proc rot13substitute {} {
# substitute the current selection in the current textarea
# by its rot13 cipher
# note: block selection is supported

    set ta [gettextareacur]
    set selindices [gettaselind $ta any]

    if {$selindices == {}} {
        # no current selection: do nothing
        showinfo [mc "No text selected!"]

    } else {
        # (possibly multiple) selection exists in $ta

        # application of rot13 should be seen as an atomic operation,
        # even for multiple (block) selections
        set sepflag [startatomicedit $ta]

        # prevent puttext from messing selections
        $ta tag remove sel 1.0 end
        set newselindices [list ]

        foreach {sta sto} $selindices {

            # these marks will maintain the selection boundaries correctly
            # even during puttext below
            $ta mark set leftbound [$ta index $sta]
            $ta mark gravity leftbound left
            $ta mark set rightbound [$ta index $sto]
            $ta mark gravity rightbound right

            set seltext [$ta get leftbound rightbound]

            # delete selection range
            $ta mark set insert $sto
            $ta delete $sta $sto

            # note that puttext (correctly) collapses multiple selections
            puttext $ta [rot13 $seltext] "forceinsert"

            # save new selection bounds, and cleanup marks
            lappend newselindices [$ta index leftbound] [$ta index rightbound]
            $ta mark unset leftbound rightbound
        }

        # restore selection with updated bounds
        foreach {sta sto} $newselindices {
            $ta tag add sel $sta $sto
        }

        # application of the rot13 should be seen as an atomic operation,
        # even for multiple (block) selections
        endatomicedit $ta $sepflag

        # update menues contextually
        keyposn $ta
    }
}

proc rot13 {str} {
# rot13 of $str
# this is a variation of the Caesar cipher
    return [tr A-Za-z N-ZA-Mn-za-m $str]
}

proc tr {from to string} {
# transliterate characters
# credits: this proc was copied from  http://wiki.tcl.tk/460 
    set mapping [list]
    foreach c1 [trExpand $from] c2 [trExpand $to] {
        lappend mapping $c1 $c2
    }
    return [string map $mapping $string]
}

proc trExpand {chars} {
# helper proc for proc tr
# this takes a string of characters like A-F0-9_ and
# expands it to a list of characters
# like {A B C D E F 0 1 2 3 4 5 6 7 8 9 _}
# credits: this proc was copied from  http://wiki.tcl.tk/460 
    set state noHyphen
    set result [list]
    foreach c [split $chars {}] {
       switch -exact -- $state {
           noHyphen {
               set lastChar $c
               lappend result $c
               set state wantHyphen
           }
           wantHyphen {
               if { [string equal - $c] } {
                   set state sawHyphen
               } else {
                   set lastChar $c
                   lappend result $c
               }
           }
           sawHyphen {
               scan $lastChar %c from
               incr from
               scan $c %c to
               if { $from > $to } {
                   error "$lastChar does not precede $c."
               }
               for { set i $from } { $i <= $to } { incr i } {
                   lappend result [format %c $i]
               }
               set state noHyphen
           }
       }
    }
    if { [string equal sawHyphen $state] } {
       lappend result -
    }
    return $result
}

proc removetrailingblanksinsel {} {
# delete all blanks (spaces and tabs) terminating each line in the selection
# note: block selection is supported

    set ta [gettextareacur]

    set selindices [gettaselind $ta any]

    if {$selindices == {}} {
        # no current selection: do nothing
        showinfo [mc "No text selected!"]

    } else {
        set sepflag [startatomicedit $ta]

        # (possibly multiple) selection exists in $ta
        apply_RE_to_sel_text $ta {[[:blank:]]+$} ""

        endatomicedit $ta $sepflag

        # update menues contextually
        keyposn $ta
    }
}

proc converttabstospacesinsel {} {
# replace each tab in the selection by spaces
# the number of spaces replacing one tab is given in the options menu ($tabsizeinchars)
# note: block selection is supported

    global tabsizeinchars

    set ta [gettextareacur]

    set selindices [gettaselind $ta any]

    if {$selindices == {}} {
        # no current selection: do nothing
        showinfo [mc "No text selected!"]

    } else {
        set sepflag [startatomicedit $ta]

        # (possibly multiple) selection exists in $ta
        apply_RE_to_sel_text $ta {\t} [string repeat " " $tabsizeinchars]

        endatomicedit $ta $sepflag

        # update menues contextually
        keyposn $ta
    }
}

proc convertspacestotabsinsel {} {
# replace spaces in the selection by tabs
# the number of spaces taken for one tab is given in the options menu ($tabsizeinchars)
# in each line, when there are not enough spaces for a replacement, the remaining spaces
# are left untouched
# note: block selection is supported

    global tabsizeinchars

    set ta [gettextareacur]

    set selindices [gettaselind $ta any]

    if {$selindices == {}} {
        # no current selection: do nothing
        showinfo [mc "No text selected!"]

    } else {
        set sepflag [startatomicedit $ta]

        # (possibly multiple) selection exists in $ta
        apply_RE_to_sel_text $ta [string repeat " " $tabsizeinchars] "\x9"

        endatomicedit $ta $sepflag

        # update menues contextually
        keyposn $ta
    }
}

proc convertsinglequotestodoublequotes {} {
# turn single quotes in the selection into double quotes
# the textquoted tag is used to avoid dealing with the case
# of the transpose operator
# note: block selection is supported

    global pad listoffile scilabSingleQuotedStrings
    global Scheme backgroundtasksallowed

    set ta [gettextareacur]

    if {$listoffile("$ta",language) ne "scilab"} {
        set tit [mc "Single quotes to double quotes"]
        set mes [concat [mc "This function works only with Scilab language files."] \
                        [mc "Do you want to switch to the Scilab sheme?"] ]
        set answ [tk_messageBox -message $mes -icon warning -title $tit -type yesno -parent $pad]
        if {$answ eq yes} {
            # do colorisation in foreground otherwise it may not be over
            # when looking for single quotes to switch to double quotes
            set old_backgroundtasksallowed $backgroundtasksallowed
            set backgroundtasksallowed false
            set Scheme "scilab"
            changelanguage $Scheme
            set backgroundtasksallowed $old_backgroundtasksallowed
        } else {
            return
        }
    }

    if {!$scilabSingleQuotedStrings} {
        set tit [mc "Single quotes to double quotes"]
        set mes [concat [mc "This function needs colorization of single quoted strings."] \
                        [mc "Should Scipad colorize these strings from now on?"] ]
        set answ [tk_messageBox -message $mes -icon warning -title $tit -type yesno -parent $pad]
        if {$answ eq yes} {
            # do colorisation in foreground otherwise it may not be over
            # when looking for single quotes to switch to double quotes
            set old_backgroundtasksallowed $backgroundtasksallowed
            set backgroundtasksallowed false
            set scilabSingleQuotedStrings yes
            refreshQuotedStrings
            set backgroundtasksallowed $old_backgroundtasksallowed
        } else {
            return
        }
    }

    set selindices [gettaselind $ta any]

    if {$selindices == {}} {
        # no current selection: do nothing
        showinfo [mc "No text selected!"]

    } else {

        # find out the ranges with textquoted tag within the selection

        set textquotedranges [$ta tag ranges textquoted]
        set listofsinquotpos [list ]
        foreach {selsta selsto} $selindices {
            foreach {quosta quosto} $textquotedranges {
                # note: deciding about <= >= < or > required quite a lot of thinking
                #       therefore don't change without knowing!
                if {[$ta compare $quosto <= $selsta]} {
                    # selection entirely after the string, no index to record
                    continue
                }
                if {[$ta compare $selsto <= $quosta]} {
                    # selection entirely before the string, no index to record
                    continue
                }
                if {[$ta compare $quosta < $selsta]} {
                    if {[$ta compare $quosto <= $selsto]} {
                        # selection starts strictly inside the string and ends after end of string
                        lappend listofsinquotpos [$ta index "$quosto - 1 c"]
                    } else {
                        # selection entirely included in the quoted string, no index to record
                        continue
                    }
                } else {
                     if {[$ta compare $quosto <= $selsto]} {
                        # selection spans the complete quoted string
                        lappend listofsinquotpos $quosta
                        lappend listofsinquotpos [$ta index "$quosto - 1 c"]
                    } else {
                        # selection starts before the string and ends inside the string
                        lappend listofsinquotpos $quosta
                    }
                }
            }
        }

        # replace each single quote delimiter by a double quote

        set savedinsertindex [$ta index insert]

        # prevent puttext from messing selections
        $ta tag remove sel 1.0 end

        set sepflag [startatomicedit $ta]

        set nbrepldone 0
        foreach pos $listofsinquotpos {
            if {[$ta get $pos] eq {'}} {
                $ta mark set insert $pos
                $ta delete $pos
                puttext $ta {"} "forceinsert"
                incr nbrepldone
            } else {
                # the delimiter is a double quote: don't replace, so that
                # the undo stack is clean from replacement of " by the same "
            }
        }

        endatomicedit $ta $sepflag

        # restore the (possibly block) selection and the insert cursor position
        eval "$ta tag add sel $selindices"
        $ta mark set insert $savedinsertindex
        $ta see $savedinsertindex

        # update menues contextually
        keyposn $ta

        showinfo "$nbrepldone [mc "replacements done"]"
    }
}

proc touppercase {} {
    toupperorlowercase true
}

proc tolowercase {} {
    toupperorlowercase false
}

proc toupperorlowercase {upper} {
# turn each character of the selection to uppercase if $upper is true,
# or to lowercase if $upper is false
# note: block selection is supported

    set ta [gettextareacur]

    set selindices [gettaselind $ta any]

    if {$selindices == {}} {
        # no current selection: do nothing
        showinfo [mc "No text selected!"]

    } else {
        set sepflag [startatomicedit $ta]

        $ta tag remove sel 1.0 end

        foreach {sta sto} $selindices {
            if {$upper} {
                set converted [string toupper [$ta get $sta $sto]]
            } else {
                set converted [string tolower [$ta get $sta $sto]]
            }
            $ta mark set insert $sta
            $ta delete $sta $sto
            puttext $ta $converted "forceinsert"
        }

        # restore selection (indices did not change in the process)
        foreach {sta sto} $selindices {
            $ta tag add sel $sta $sto
        }

        endatomicedit $ta $sepflag

        # update menues contextually
        keyposn $ta
    }
}

proc capitalize {} {
    switchcaseorcapitalize true
}

proc switchcase {} {
    switchcaseorcapitalize false
}

proc switchcaseorcapitalize {toupperonly} {
# if there is a selection:
#   turn each first character of each word of the selection to uppercase
#   (if $toupperonly is true), or switch case of first letter of words (otherwise)
#   note: block selection is supported
#   note: for the sake of simplicity of coding, the definition of a "word"
#         does not take into account the tcl_wordchars and tcl_nonwordchars
#         regular expressions - could be done, but let's first give it a try
#         by just saying a "word" is obtained simply by splitting a string
#         based on " " (space) and \n (newline) characters only - <TODO>
# if there is no selection:
#   capitalize (if $toupperonly is true), or switch case (otherwise)
#   of the character to the right of the insert cursor, and move
#   the insertion cursor one character to the right (i.e. right after
#   the character that was just modified)

    set ta [gettextareacur]

    set selindices [gettaselind $ta any]

    if {$selindices == {}} {

        # no current selection, capitalize the character
        # at the right of the insert cursor

        set sepflag [startatomicedit $ta]

        set insertpos [$ta index insert]
        set nextchar [$ta get $insertpos]
        if {!$toupperonly} {
            if {[string is upper $nextchar]} {
                set converted [string tolower $nextchar]
            } else {
                set converted [string toupper $nextchar]
            }
        } else {
            set converted [string toupper $nextchar]
        }
        $ta delete $insertpos
        puttext $ta $converted "forceinsert"

        # place the insert cursor right after the converted character
        $ta mark set insert "$insertpos + 1 c"

        endatomicedit $ta $sepflag

        keyposn $ta

    } else {
        set sepflag [startatomicedit $ta]

        $ta tag remove sel 1.0 end

        set splitchars " "

        foreach {sta sto} $selindices {
            set thewords [split [$ta get $sta $sto] $splitchars]
            set convertedsel [list ]
            foreach aword $thewords {
                # $aword may be composed of the last word of a line plus \n
                # plus the first word of next line (and more if more lines)
                set thewordsinaword [split $aword \n]
                set convertedselaword [list ]
                foreach anotherword $thewordsinaword {
                    if {!$toupperonly} {
                        if {[string is upper [string index $anotherword 0]]} {
                            lappend convertedselaword [string tolower $anotherword 0 0]
                        } else {
                            lappend convertedselaword [string toupper $anotherword 0 0]
                        }
                    } else {
                        lappend convertedselaword [string toupper $anotherword 0 0]
                    }
                }
                set convertedaword [join $convertedselaword \n]
                lappend convertedsel $convertedaword
            }
            set converted [join $convertedsel $splitchars]
            $ta mark set insert $sta
            $ta delete $sta $sto
            puttext $ta $converted "forceinsert"
        }

        # restore selection (indices did not change in the process)
        foreach {sta sto} $selindices {
            $ta tag add sel $sta $sto
        }

        endatomicedit $ta $sepflag

        keyposn $ta
    }
}

proc sortselection {typeofelts order} {
# sort the text lines contained in the selection
# sorting order is ascending if $ascending is true, or descending otherwise
# note: block selection is supported

    global pad

    set ta [gettextareacur]

    set selindices [gettaselind $ta any]

    $ta tag remove sel 1.0 end

    if {$selindices == {}} {
        # no current selection: sort all lines of the textarea
        selectall
        set selindices [gettaselind $ta any]
    }

    if {[llength $selindices] > 2} {

        # block selection: each couple ($sta,$sto) is a single line,
        # and all such lines have the same number of characters

        set linestosort [list ]
        foreach {sta sto} $selindices {
            set candidateline [$ta get $sta $sto]
            if {$candidateline eq "\n"} {
                set tit [mc "Sort"]
                set mes [concat [mc "Can't sort block selection containing empty lines!"] ]
                tk_messageBox -message $mes -icon error -title $tit -type ok -parent $pad
                return
            }
            lappend linestosort $candidateline
        }

        if {[catch {set sortedlines [lsort $typeofelts $order $linestosort]}]} {
            set tit [mc "Sort"]
            set mes [concat [mc "Sorting failed: elements do not match the selected type!"] ]
            tk_messageBox -message $mes -icon error -title $tit -type ok -parent $pad
            return
        }

        set sepflag [startatomicedit $ta]

        set i 0
        foreach {sta sto} $selindices {
            $ta mark set insert $sta
            $ta delete $sta $sto
            puttext $ta [lindex $sortedlines $i] "forceinsert"
            incr i
        }       

        endatomicedit $ta $sepflag

        foreach {sta sto} $selindices {
            $ta tag add sel $sta $sto
        }

    } else {

        # single selection: the couple ($sta,$sto) denotes a single continuous
        # selection possibly containing several lines

        foreach {sta sto} $selindices {}
        set sta [$ta index "$sta linestart"]
        if {[$ta compare $sto > "$sto linestart"]} {
            # end of selection is not at beginning of a line, make sure it is*
            # by selecting the rest of the line where $sto is, including the \n
            set sto [$ta index "$sto lineend + 1c"]
        }

        set linestosort [split [$ta get $sta $sto] "\n"]

        # remove the last empty item resulting from the final \n in the selection
        set linestosort [lrange $linestosort 0 end-1]

        if {[catch {set sortedlines [lsort $typeofelts $order $linestosort]}]} {
            set tit [mc "Sort"]
            set mes [concat [mc "Sorting failed: elements do not match the selected type!"] ]
            tk_messageBox -message $mes -icon error -title $tit -type ok -parent $pad
            return
        }

        set sepflag [startatomicedit $ta]

        $ta mark set insert $sta
        $ta delete $sta $sto
        set i 0
        foreach item $sortedlines {
            puttext $ta [lindex $sortedlines $i]\n "forceinsert"
            incr i
        }

        endatomicedit $ta $sepflag

        $ta tag add sel $sta $sto

    }
        
    # update menues contextually
    keyposn $ta

}

proc joinlinesnotspacetrim {{mode realrun}} {
    return [joinlines false $mode]
}

proc joinlineswithspacetrim {{mode realrun}} {
    return [joinlines true $mode]
}

proc joinlines {trimspaces mode} {
# join all lines from the selection such that they make a single line
# lines are joined together by removing the trailing \n
# moreover, if $trimspaces true then leading and trailing white space
# of each line is trimmed and a space character is inserted between
# joined lines
# in any case:
#     leading white space of the first line is not changed
#     trailing white space of the last line is not changed
# note: block selection is (obviously) not supported
# if $mode is "realrun", the current textarea is really changed
# otherwise, the text resulting from reformatting is returned but no change is
# made in the current textarea

    set ta [gettextareacur]

    set selindices [gettaselind $ta single]

    if {$selindices == {}} {
        # no current selection: do nothing
        showinfo [mc "No text selected!"]
        set newtext ""

    } else {
        # a single (contiguous) selection exists in $ta

        set sepflag [startatomicedit $ta]

        foreach {sta sto} $selindices {}

        # if the end of the selection is the start of a line, we will
        # consider that the user intends to join lines up to the end
        # of the selection, but keep the \n of the selection end
        if {[$ta compare $sto == "$sto linestart"]} {
            set sto [$ta index "$sto - 1 char"]
        }
        set seltext [$ta get $sta $sto]

        if {$trimspaces} {
            set patS {[[:space:]]*\n[[:space:]]*}
            set patR " "
        } else {
            set patS {\n}
            set patR ""
        }
        set nbreplace [regsub -all -- $patS $seltext $patR newtext]

        if {$mode eq "realrun"} {
            if {$nbreplace > 0} {
                $ta tag remove sel 1.0 end
                $ta mark set insert $sta
                $ta delete $sta $sto
                puttext $ta $newtext "forceinsert"
                $ta tag add sel $sta "$sta lineend"
            } else {
                # do nothing since there was no match (the selection spans
                # no \n, i.e. it lies on a single line)
            }
        }

        endatomicedit $ta $sepflag

    }

    # update menues contextually
    keyposn $ta

    return $newtext
}

proc reformatlinesdialog {} {
# ask the user about how many characters should the reformated lines be,
# and launch reformatting

    global pad menuFont textFont refdlg reformatlinewidth
    global reformatleadingstring1stline reformatleadingstringotherlines
    global reformattrailingstringlastline reformattrailingstringotherline

    if {[gettaselind [gettextareacur] single] == {}} {
        # no current selection: do nothing
        showinfo [mc "No text selected!"]
        return
    }

    if {![info exist reformatlinewidth]} {
        clearreformatlines
    }

    set refdlg $pad.reformatlines
    toplevel $refdlg -class Dialog
    wm transient $refdlg $pad
    wm withdraw $refdlg
    setscipadicon $refdlg
    wm title $refdlg [mc "Reformat lines"]

    frame $refdlg.params

    frame $refdlg.params.f1
    label $refdlg.params.f1.l1 -text [mc "Number of characters:"] -font $menuFont
    entry $refdlg.params.f1.e1 -textvariable reformatlinewidth -justify center \
            -width 8 -font $textFont
    button $refdlg.params.f1.b1 -text [mc "Window width"] -font $menuFont \
            -command "getwindowlinewidth"
    pack $refdlg.params.f1.l1 $refdlg.params.f1.e1 $refdlg.params.f1.b1 \
            -side left -anchor w -pady 5 -padx 3

    labelframe $refdlg.params.f2 -text [mc "Leading strings to prepend with"] \
            -borderwidth 2 -relief groove -font $menuFont
    label $refdlg.params.f2.l1 -text [mc "First line:"] -font $menuFont
    entry $refdlg.params.f2.e1 -textvariable reformatleadingstring1stline \
            -justify left -font $textFont
    label $refdlg.params.f2.l2 -text [mc "Next lines:"] -font $menuFont
    entry $refdlg.params.f2.e2 -textvariable reformatleadingstringotherlines \
            -justify left -font $textFont
    grid $refdlg.params.f2.l1 -row 0 -column 0 -sticky w
    grid $refdlg.params.f2.e1 -row 0 -column 1 -sticky we
    grid $refdlg.params.f2.l2 -row 1 -column 0 -sticky w
    grid $refdlg.params.f2.e2 -row 1 -column 1 -sticky we
    grid columnconfigure $refdlg.params.f2 1 -weight 1

    labelframe $refdlg.params.f3 -text [mc "Trailing strings to append"] \
            -borderwidth 2 -relief groove -font $menuFont
    label $refdlg.params.f3.l1 -text [mc "Last line:"] -font $menuFont
    entry $refdlg.params.f3.e1 -textvariable reformattrailingstringlastline \
            -justify left -font $textFont
    label $refdlg.params.f3.l2 -text [mc "Previous lines:"] -font $menuFont
    entry $refdlg.params.f3.e2 -textvariable reformattrailingstringotherline \
            -justify left -font $textFont
    grid $refdlg.params.f3.l1 -row 0 -column 0 -sticky w
    grid $refdlg.params.f3.e1 -row 0 -column 1 -sticky we
    grid $refdlg.params.f3.l2 -row 1 -column 0 -sticky w
    grid $refdlg.params.f3.e2 -row 1 -column 1 -sticky we
    grid columnconfigure $refdlg.params.f3 1 -weight 1

    frame $refdlg.params.f9
    set bestwidth [mcmaxra "OK" "Cancel" "Reset"]
    button $refdlg.params.f9.ok -text [mc "OK"] -font $menuFont -width $bestwidth \
            -command "reformatlines ; destroy $refdlg"
    button $refdlg.params.f9.cancel -text [mc "Cancel"] -font $menuFont \
            -width $bestwidth -command "destroy $refdlg"
    button $refdlg.params.f9.reset -text [mc "Reset"] -font $menuFont \
            -width $bestwidth -command "clearreformatlines"
    pack $refdlg.params.f9.ok $refdlg.params.f9.cancel $refdlg.params.f9.reset \
            -side left -pady 5 -padx 20

    pack $refdlg.params.f1 $refdlg.params.f2 $refdlg.params.f3 $refdlg.params.f9
    pack configure $refdlg.params.f2 -expand 1 -fill x -padx 3 -pady 7
    pack configure $refdlg.params.f3 -expand 1 -fill x -padx 3 -pady 7

    frame $refdlg.preview

    frame $refdlg.preview.ff
    text $refdlg.preview.ff.t -font $textFont -state disabled -wrap none \
            -height 13 -yscrollcommand "managescroll $refdlg.preview.ff.sby" \
            -xscrollcommand "managescroll $refdlg.preview.sbx"
    pack $refdlg.preview.ff.t -in $refdlg.preview.ff -side left -expand 1 -fill both
    scrollbar $refdlg.preview.ff.sby -command "$refdlg.preview.ff.t yview" \
            -takefocus 0
    $refdlg.preview.ff.sby set [lindex [$refdlg.preview.ff.t yview] 0] \
            [lindex [$refdlg.preview.ff.t yview] 1]
    pack $refdlg.preview.ff.sby -in $refdlg.preview.ff -side right -expand 0 -fill y \
            -before $refdlg.preview.ff.t
    pack $refdlg.preview.ff -expand 1 -fill both
    scrollbar $refdlg.preview.sbx -command "$refdlg.preview.ff.t xview" \
            -takefocus 0 -orient horizontal
    $refdlg.preview.sbx set [lindex [$refdlg.preview.ff.t xview] 0] \
            [lindex [$refdlg.preview.ff.t xview] 1]
    pack $refdlg.preview.sbx -in $refdlg.preview -expand 0 -fill x \
            -after $refdlg.preview.ff

    updatereformatpreview

    pack $refdlg.params $refdlg.preview -side left -anchor n

    update idletasks
    setwingeom $refdlg
    wm deiconify $refdlg

    focus $refdlg.params.f1.e1
    grab $refdlg

    # validation of the width entry to prevent the user to enter nasty things
    $refdlg.params.f1.e1 configure -validate all -vcmd "validreformatlinewidth $refdlg %P"

    # validations for updating the preview area
    $refdlg.params.f2.e1 configure -validate all -vcmd "updatereformatpreview"
    $refdlg.params.f2.e2 configure -validate all -vcmd "updatereformatpreview"
    $refdlg.params.f3.e1 configure -validate all -vcmd "updatereformatpreview"
    $refdlg.params.f3.e2 configure -validate all -vcmd "updatereformatpreview"

    $refdlg.params.f1.e1 selection range 0 end

    bind $refdlg <Return> {reformatlines ; destroy [winfo toplevel %W]}
    bind $refdlg <Escape> {destroy [winfo toplevel %W]}

}

proc validreformatlinewidth {w value} {
# a valid entry value for reformat line width is a positive integer only
# no max value set checked here, the user may want any value (however the
# preview window has a max display width in proc idleupdatereformatpreview)
    if {[string is integer -strict $value] &&
        $value >= 0} {
        after idle {updatereformatpreview}
        return true
    } else {
        return false
    }
}

proc clearreformatlines {} {
# reset values of the reformat lines dialog to defaults
    global reformatleadingstring1stline reformatleadingstringotherlines
    global reformattrailingstringlastline reformattrailingstringotherline
    getwindowlinewidth  ; # this sets reformatlinewidth
    set reformatleadingstring1stline ""
    set reformatleadingstringotherlines ""
    set reformattrailingstringlastline ""
    set reformattrailingstringotherline ""
}

proc getwindowlinewidth {} {
# set the current line width as the number of characters that fit in the
# textara width
# warning: this is accurate for fixed width fonts only
    global reformatlinewidth textFont
    # "0" because of man -width: "If the font does not have a uniform width
    # then the width of the character “0” is used in translating from
    # character units to screen units"
    set fontwidth [font measure $textFont "0"]
    set tawidth [winfo width [gettextareacur]]
    set reformatlinewidth [expr {$tawidth / $fontwidth}]
}

proc updatereformatpreview {} {
    after idle {idleupdatereformatpreview}
    # this is a validation proc
    return true
}

proc idleupdatereformatpreview {} {
# update the text shown in the preview area of the reformat lines dialog
    global refdlg reformatlinewidth textFont
    $refdlg.preview.ff.t configure -state normal
    $refdlg.preview.ff.t delete 1.0 end
    $refdlg.preview.ff.t insert 1.0 [reformatlines dryrun]
    $refdlg.preview.ff.t configure -state disabled
    # clamp width to some arbitrary reasonable maximum, which is 70% of
    # the screen width (not 100% because of the controls displayed in the
    # left of the reformat lines window)
    set fontwidth [font measure $textFont "0"]
    set maxlinewidth [expr {[winfo screenwidth $refdlg] *7/10 / $fontwidth}]
    if {$reformatlinewidth > $maxlinewidth} {
        set linewidthtouse $maxlinewidth
    } else {
        set linewidthtouse $reformatlinewidth
    }
    $refdlg.preview.ff.t configure -width $linewidthtouse
}

proc reformatlines {{mode realrun}} {
# re-arrange selected lines by joining them and inserting hard (\n) word
# wrapping at most at a given distance $reformatlinewidth from the
# beginning of the line
# additional strings may be prepended/appended on each line:
# - prepended string may be different for first line (compared to next lines)
# - appended string may be different for last line (compared to previous lines)
# if $mode is "realrun", the current textarea is really changed
# otherwise, the text resulting from reformatting is returned but no change is
# made in the current textarea
# note: block selection is (obviously) not supported

    global reformatlinewidth
    global reformatleadingstring1stline reformatleadingstringotherlines
    global reformattrailingstringlastline reformattrailingstringotherline

    # assert: a single (contiguous) selection exists in $ta

    set ta [gettextareacur]

    set savedinsertindex [$ta index insert]

    set sepflag [startatomicedit $ta]

    set selindices [gettaselind $ta single]
    foreach {sta sto} $selindices {}
    $ta mark set leftbound [$ta index $sta]
    $ta mark gravity leftbound left
    $ta mark set rightbound [$ta index $sto]
    $ta mark gravity rightbound right

    set seltext [string trim [joinlineswithspacetrim $mode]]

    $ta mark set insert leftbound
    if {$mode eq "realrun"} {
        foreach {sta sto} [gettaselind $ta single] {}
    }

    set newtext ""
    set curlinetext ""
    set firstline true

    set sllead1 [string length $reformatleadingstring1stline]
    set slleadn [string length $reformatleadingstringotherlines]
    set sltraillast [string length $reformattrailingstringlastline]
    set sltrailn [string length $reformattrailingstringotherline]
    set threshold [expr { $reformatlinewidth - max( \
            $sllead1 + $sltraillast , \
            $sllead1 + $sltrailn , \
            $slleadn + $sltraillast , \
            $slleadn + $sltrailn )}]

    foreach word [split $seltext " "] {
        set curlinelength [string length $curlinetext]
        set wordlength [string length $word]
        # at least one word shall go on each line, even if this
        # word is longer than $nbchar, thus test on $curlinelength == 0
        if {[expr {$curlinelength + $wordlength}] < $threshold || \
                $curlinelength == 0} {
            # the word can go on the line (sufficient space left)
            append curlinetext $word " "
        } else {
            # not enough space left on the line for the word, remove
            # trailing space and start dealing with a new line
            set curlinetext [string range $curlinetext 0 end-1]
            if {$firstline} {
                append newtext $reformatleadingstring1stline \
                        $curlinetext $reformattrailingstringotherline "\n"
                set firstline false
            } else {
                append newtext $reformatleadingstringotherlines \
                        $curlinetext $reformattrailingstringotherline "\n"
            }
            set curlinetext "$word "
        }
    }
    if {$firstline} {
        append newtext $reformatleadingstring1stline \
                [string range $curlinetext 0 end-1] \
                $reformattrailingstringlastline
    } else {
        append newtext $reformatleadingstringotherlines \
                [string range $curlinetext 0 end-1] \
                $reformattrailingstringlastline
    }

    if {$mode eq "realrun"} {
        if {$seltext ne $newtext} {
            $ta tag remove sel 1.0 end
            $ta mark set insert $sta
            $ta delete $sta $sto
            puttext $ta $newtext "forceinsert"
            $ta tag add sel leftbound rightbound
        } else {
            # do nothing since there was no change
        }
    }

    $ta mark unset leftbound rightbound

    endatomicedit $ta $sepflag

    $ta mark set insert $savedinsertindex
    $ta see $savedinsertindex

    # update menues contextually
    keyposn $ta

    return $newtext
}
