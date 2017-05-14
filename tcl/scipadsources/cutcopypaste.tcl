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

proc deletetext {} {
# cut text procedure (delete key hit, i.e. erases the character
# at the right of the cursor)
    global buffermodifiedsincelastsearch

    set textareacur [gettextareacur]

    if {[IsBufferEditable] == "No"} {return}

    stopcursorblink ; # see comments in proc puttext

    set sepflag [startatomicedit $textareacur]

    set selindices [gettaselind $textareacur any]

    if {$selindices == {}} {
        # there is no selection in the textarea
        $textareacur delete "insert" "insert+1c"
        set first [$textareacur index insert]
        set last $first
    } else {
        $textareacur mark set leftbound [lindex $selindices 0]
        $textareacur mark gravity leftbound left
        $textareacur mark set rightbound [lindex $selindices end]
        $textareacur mark gravity rightbound right
        # text deletion must be done at once and not range by range!
        eval "$textareacur delete $selindices"
        set first [$textareacur index leftbound]
        set last [$textareacur index rightbound]
    }

    set uplimit [$textareacur index "$first linestart"]
    set dnlimit [$textareacur index "$last lineend"]
    set uplimit_cl [getstartofcolorization $textareacur $first]
    set dnlimit_cl [getendofcolorization $textareacur $last]
    colorize $textareacur $uplimit $dnlimit $uplimit_cl $dnlimit_cl
    backgroundcolorizetasks
    setunsavedmodifiedline $textareacur $uplimit $dnlimit
    tagcontlines $textareacur
    reshape_bp
    $textareacur see insert

    endatomicedit $textareacur $sepflag

    # update menues contextually
    keyposn $textareacur

    set buffermodifiedsincelastsearch true

    restorecursorblink ; # see comments in proc puttext
}

proc backspacetext {} {
# cut text procedure (backspace key hit, i.e. erases the character
# at the left of the cursor)
    global buffermodifiedsincelastsearch

    set textareacur [gettextareacur]

    if {[IsBufferEditable] == "No"} {return}

    stopcursorblink ; # see comments in proc puttext

    set sepflag [startatomicedit $textareacur]

    set selindices [gettaselind $textareacur any]

    if {$selindices == {}} {
        $textareacur delete "insert-1c" "insert"
        set first [$textareacur index insert]
        set last $first
    } else {
        $textareacur mark set leftbound [lindex $selindices 0]
        $textareacur mark gravity leftbound left
        $textareacur mark set rightbound [lindex $selindices end]
        $textareacur mark gravity rightbound right
        # text deletion must be done at once and not range by range!
        eval "$textareacur delete $selindices"
        set first [$textareacur index leftbound]
        set last [$textareacur index rightbound]
    }

    set uplimit [$textareacur index "$first linestart"]
    set dnlimit [$textareacur index "$last lineend"]
    set uplimit_cl [getstartofcolorization $textareacur $first]
    set dnlimit_cl [getendofcolorization $textareacur $last]
    colorize $textareacur $uplimit $dnlimit $uplimit_cl $dnlimit_cl
    backgroundcolorizetasks
    setunsavedmodifiedline $textareacur $uplimit $dnlimit
    tagcontlines $textareacur
    reshape_bp
    $textareacur see insert

    endatomicedit $textareacur $sepflag

    # update menues contextually
    keyposn $textareacur

    set buffermodifiedsincelastsearch true

    restorecursorblink ; # see comments in proc puttext
}

proc cuttext {mode {tocutinblockmode ""}} {
# cut text procedure: copy current selection into the clipboard,
# and remove the selected text from the current buffer
# note: block selection is supported
# if $mode is "normal": usual cut
#     all the text tagged with sel is sent to the clipboard and is deleted
#     from the textarea
# if $mode is "block": block cut
#     all the text tagged with sel is sent to the clipboard (unless
#     $tocutinblockmode is not empty), but deletion of the tagged
#     text occurs only for line selections having more than a single \n
# the second argument tocutinblockmode is optional and can only be given
# when $mode=="block". If it is given, it contains the indices of the text
# to cut in the current textarea, otherwise the text to cut is extracted
# from the selection. If it is given, the text is not sent to the clipboard
# (it is simply deleted from the current textarea)

    global buffermodifiedsincelastsearch

    if {[IsBufferEditable] eq "No"} {
        return
    }

    set textareacur [gettextareacur]

    if {$mode eq "block" && $tocutinblockmode ne ""} {
        set dndmode true
    } else {
        set dndmode false
    }

    if {$dndmode} {
        set selindices $tocutinblockmode
    } else {
        set selindices [gettaselind $textareacur any]
        if {$selindices eq {}} {
            return
        }
    }

    stopcursorblink ; # see comments in proc puttext

    set sepflag [startatomicedit $textareacur]

    if {!$dndmode} {
        sendtaregiontoclipboard $textareacur $selindices
    }

    # save first sel position, so that the cursor can be placed there
    # after the cut - this position being before everything selected
    # (that will be deleted), it won't change in the following process
    # therefore no adjustment is needed when placing the cursor there
    set firstselpos [lindex $selindices 0]
    set i1 $firstselpos
    set i2 [lindex $selindices end] ; # an overkill, but how else?
    # mark tempcutmark is used to identify the end of the modified
    # area without having to deal with recomputing indices
    $textareacur mark set tempcutmark $i2
    $textareacur mark gravity tempcutmark right

    # now cut it! note that tk_textCut being designed to work with a
    # single range selection, this command cannot be used here directly
    # text deletion must be done at once and not range by range!
    if {$mode eq "normal"} {
        # normal cut
        eval "$textareacur delete $selindices"
    } else {
        # $mode eq "block", this is block cut
        blockcuttext $textareacur $selindices
    }

    $textareacur tag remove sel 1.0 end
    set uplimit [$textareacur index "$i1 linestart"]
    set dnlimit [$textareacur index "$i2 lineend"]
    set uplimit_cl [getstartofcolorization $textareacur $i1]
    set dnlimit_cl [getendofcolorization $textareacur $i2]
    colorize $textareacur $uplimit $dnlimit $uplimit_cl $dnlimit_cl
    backgroundcolorizetasks
    setunsavedmodifiedline $textareacur $uplimit tempcutmark
    $textareacur mark unset tempcutmark
    tagcontlines $textareacur
    reshape_bp
    if {!$dndmode} {
       $textareacur mark set insert $firstselpos
    }
    $textareacur see insert

    endatomicedit $textareacur $sepflag

    # update menues contextually
    keyposn $textareacur

    set buffermodifiedsincelastsearch true

    restorecursorblink ; # see comments in proc puttext
}

proc blockcuttext {w selindices} {
# ancillary of proc cuttext
# deletes the characters identified by the selindices list, but do this in
# "block-style", i.e. do not cut empty lines
    set selindicestodelete [list ]
    foreach {sta sto} $selindices {
        # a selected line must be deleted if and only if it does not
        # contain only a \n
        set lines [split [$w get $sta $sto] "\n"]
        set charcount 0
        foreach lineoftext $lines {
            set linelength [string length $lineoftext]
            if {$linelength != 0} {
                set sta1 [$w index "$sta + $charcount c"]
                set sto1 [$w index "$sta1 + $linelength c"]
                lappend selindicestodelete $sta1 $sto1
            }
            incr charcount [expr {$linelength + 1}]
        }
    }
    if {$selindicestodelete ne {}} {
        eval "$w delete $selindicestodelete"
    }
}

proc copytext {} {
# copy text procedure: copy current selection into the clipboard
# note: block selection is supported

    set textareacur [gettextareacur]

    set selindices [gettaselind $textareacur any]

    if {$selindices == {}} {return}

    stopcursorblink ; # see comments in proc puttext

    # now copy it! note that tk_textCopy being designed to work with a
    # single range selection, this command cannot be used here directly
    sendtaregiontoclipboard $textareacur $selindices

    restorecursorblink ; # see comments in proc puttext
}

proc pastetext {mode {topasteinblockmode ""}} {
# paste text procedure: copy clipboard content into the current buffer
# where the insert cursor is
# note: block selection is supported (i.e. it is first collapsed
# to its first range and then replaced by the pasted text)
# if $mode is "normal": usual paste
#     the clipboard content to paste is viewed as a single string that can
#     contain \n
# if $mode is "block": block paste
#     the clipboard content to paste is viewed as a a number of strings each
#     separated by \n
# the second argument topasteinblockmode is optional and can only be given
# when $mode=="block". If it is given, it contains the text to paste,
# otherwise the text to paste is extracted from the clipboard

    global buffermodifiedsincelastsearch

    if {[IsBufferEditable] == "No"} {return}

    set textareacur [gettextareacur]

    if {$mode == "block" && $topasteinblockmode != ""} {
        set topaste $topasteinblockmode
    } else {
        # retrieve the clipboard content, if there is none, simply return
        if {[catch {selection get -displayof $textareacur -selection CLIPBOARD} topaste]} {
            return
        }
    }

    stopcursorblink ; # see comments in proc puttext

    set sepflag [startatomicedit $textareacur]

    # delete the selection content if there is one,
    # so that (block or normal) pasting will appear to
    # have replaced it
    set selindices [gettaselind $textareacur any]
    if {$selindices eq {}} {
        set i1 [$textareacur index insert]
    } else {
        set i1 [$textareacur index sel.first]
        eval "$textareacur delete $selindices"
        $textareacur mark set insert $i1
    }

    # now paste it!
    # note that the replace mode (the one with the fat insert cursor)
    # is not tested: paste is always an insert whether in normal or
    # in block mode, and this is a choice: if the user wants to paste
    # over existing text he should select this text first, even when
    # in replace mode
    if {$mode == "normal"} {
        # normal paste
        $textareacur insert insert $topaste
    } else {
        # $mode == "block", this is block paste
        # while the block selection process is a pixel-based one,
        # this paste is an index-based paste, not a pixel-based one
        # the difference is only apparent with tabs and/or non fixed width fonts
        set listoflines [split $topaste "\n"]
        set n 0
        foreach aline $listoflines {
            $textareacur insert insert $aline
            incr n
            $textareacur mark set insert "$i1 + $n l"
            # make room for next line if end of buffer has been reached
            if {[$textareacur compare insert == "end - 1 c"] && \
                $n < [llength $listoflines]} {
                puttext $textareacur "\n" "forceinsert"
                $textareacur mark set insert "$i1 + $n l"
            }
        }
    }
    set  i2 [$textareacur index insert]
    set uplimit [$textareacur index "$i1 linestart"]
    set dnlimit [$textareacur index "$i2 lineend"]
    set uplimit_cl [getstartofcolorization $textareacur $i1]
    set dnlimit_cl [getendofcolorization $textareacur $i2]
    colorize $textareacur $uplimit $dnlimit $uplimit_cl $dnlimit_cl
    backgroundcolorizetasks
    setunsavedmodifiedline $textareacur $uplimit $dnlimit
    tagcontlines $textareacur
    reshape_bp
    $textareacur see insert

    endatomicedit $textareacur $sepflag

    # update menues contextually
    keyposn $textareacur

    set buffermodifiedsincelastsearch true

    restorecursorblink ; # see comments in proc puttext
}

proc button2copypaste {w x y} {
# we have to write a full proc for this because we need
# to take care of colorization, insert only when editable, etc
#
# On Linux (checked on Ubuntu 10.10 Maverick Meerkat), this feature:
#   - does not change the clipboard content
#   - unselects the X selection, but an additional button-2 click
#     will paste the same string again, even if there is no selection
#   - honors the replace mode (in Kate for instance), not only the
#     insert mode
#   - honors block selections and perform a block paste in such a case
#
# <TODO>: Block selections are not really supported: All selected text
#         is currently concatenated in a single line and pasted as is
#         at the target position - should block paste instead

    global button2copypastebuffer

    # the target textarea gets focused, even if paste is forbidden there
    if {[IsBufferEditable] eq "No"} {
        focustextarea $w
        return
    }

    # retrieve the X selection, or use the previously pasted string
    if {![catch {selection get -displayof $w -selection PRIMARY} topaste]} {
        # there is a primary X selection
        set button2copypastebuffer $topaste
    } else {
        # there is no primary X selection
        if {![info exists button2copypastebuffer]} {
            # button-2 was used with no previous X selection,
            # can't paste anything
            return
        } else {
            # do nothing: reuse the previously pasted string
            # already stored in button2copypastebuffer
        }
    }

    stopcursorblink ; # see comments in proc puttext

    set sepflag [startatomicedit $w]

    # in principle, focustextarea $w would be enough here since $w is
    # already visible (it has just been clicked!)
    # but because of Scilab bug 1544, [selection get] might last 10 s
    # or so during which the Tcl event loop is active, allowing the user
    # to Ctrl-n or anything else that switches buffers and hides the one
    # that was Button-2 clicked for pasting. Then one of the following
    # errors would be triggered:
    #   can't read "listoffile(".scipad.new1",displayedname)": no such element in array
    #   invalid command name "none"
    # Even without bug 1544, using proc showtext instead of focustextarea
    # is an extra precaution that could indeed be needed because it also
    # lauches recolorization of user functions, which might change on paste
    showtext $w
    $w mark set insert [TextClosestGap_scipad $w $x $y]

    # unselect the X selection:
    #   - remove it (applies to the selection wherever it is, be it
    #                in Scipad or not)
    #   - and remove the sel tag from the Scipad textarea
    selection clear -displayof $w -selection PRIMARY
    $w tag remove sel 1.0 end

    puttext $w $button2copypastebuffer "replaceallowed"

    endatomicedit $w $sepflag

    restorecursorblink ; # see comments in proc puttext
}

proc copyfullfilepathtoclipboard {ta} {
# copy the full pathname of the buffer displayed in textarea $ta
# and paste it into the clipboard
    global listoffile
	sendtoclipboard $ta $listoffile("$ta",fullname)
}

proc sendtaregiontoclipboard {ta indices} {
# copy in the clipboard the text identified by $indices in textarea $ta
# $indices is a list of $start $stop text widget indices
# warning: this list is supposed to identify contiguous lines, i.e. a block
#          selection
	sendtoclipboard $ta [gettatextstring $ta $indices]
}

proc sendtoclipboard {ta sometext} {
# copy in the clipboard the text $sometext
# the textarea name $ta is needed for the -displayof option
    clipboard clear -displayof $ta
    clipboard append -displayof $ta $sometext
}
