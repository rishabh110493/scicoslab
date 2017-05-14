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

###########################################################################
# Undo/Redo procs using the text widget embedded mechanism (Tk 8.4 and above)
# The modified flag is automatically handled

proc undo {textarea} {
# Performs an undo
    global listoffile

    foreach ta [getfullpeerset $textarea] {
        push_redo_modifiedlinetags $ta
    }

    undoredo $textarea <<Undo>>

    foreach ta [getfullpeerset $textarea] {
        incr listoffile("$ta",undostackdepth) -1
        incr listoffile("$ta",redostackdepth)
        pop_undo_modifiedlinetags $ta
    }
    updatemodifiedlinemargin_allpeers $textarea
}

proc redo {textarea} {
# Performs a redo
    global listoffile

    foreach ta [getfullpeerset $textarea] {
        push_undo_modifiedlinetags $ta
    }

    undoredo $textarea <<Redo>>

    foreach ta [getfullpeerset $textarea] {
        incr listoffile("$ta",undostackdepth)
        incr listoffile("$ta",redostackdepth) -1
        pop_redo_modifiedlinetags $ta
    }
    updatemodifiedlinemargin_allpeers $textarea
}

proc undoredo {textarea action} {
# To colorize the range of characters that were changed by an undo
# or redo, a string comparison between before and after the operation
# is done. A better mechanism has been asked for in Tk request 1217222
# http://sourceforge.net/tracker/?func=detail&aid=1217222&group_id=12997&atid=362997

    global buffermodifiedsincelastsearch
    global linenumbersmargin modifiedlinemargin

    if {[IsBufferEditable] == "No"} {
        return
    }

    $textarea tag remove sel 1.0 end

    # get a snapshot of the text before the undo or redo
    set bef [$textarea get 1.0 end]

    # perform undo or redo
    event generate $textarea $action

    # get a snapshot of the text after the undo or redo
    set aft [$textarea get 1.0 end]

    # find out limits of the change undergone in the undo or redo:
    #   - index i1 denoting the position of the first character changed
    #   - index i2 denoting the position of the last  character changed
    set pref [commonPrefix $bef $aft]
    set i1 [$textarea index "1.0 + [string length $pref] chars"]
    set pref [commonPrefix [sreverse $bef] [sreverse $aft]]
    set i2 [$textarea index "end - [string length $pref] chars"]
    if {[$textarea compare $i2 < $i1]} {
        set tmp $i1
        set i1 $i2
        set i2 $tmp
    }

    # colorize and tag continued lines in the required range,
    # and do other necessary updates
    set uplimit [$textarea index "$i1 linestart"]
    set dnlimit [$textarea index "$i2 lineend"]
    set uplimit_cl [getstartofcolorization $textarea $i1]
    set dnlimit_cl [getendofcolorization $textarea $i2]
    colorize $textarea $uplimit $dnlimit $uplimit_cl $dnlimit_cl
    backgroundcolorizetasks
    tagcontlines $textarea
    reshape_bp
    keyposn $textarea
    set buffermodifiedsincelastsearch true

    # explicitely calling updatelinenumbersmargin is needed when the
    # undo/redo operation occurs in a textarea that does entirely fit
    # in the alloted space (i.e. the scrollbars are disabled)
    if {$linenumbersmargin ne "hide"} {
        foreach ta [getfullpeerset $textarea] {
            if {[isdisplayed $ta]} {
                updatelinenumbersmargin $ta
            }
        }
    }
    # explicitely calling updatemodifiedlinemargin is NOT needed
    # because this will be done at the end of undo or redo processing by
    # proc pop_undo_modifiedlinetags and proc pop_redo_modifiedlinetags
    # in fact calling updatemodifiedlinemargin must not be done here
    # because the modified line tags are not up-to-date at this point
    # (they will be only in the two above pop_... procs)

    # properly set anchor in textarea to follow the insert cursor
    # otherwise next Shift-Button-1 click creates a selection from
    # the previous anchor point (last Button-1 click usually)
    setTextAnchor_scipad $textarea
}

proc startatomicedit {ta} {
    global listoffile
    set oldSeparator [$ta cget -autoseparators]
    if {$oldSeparator} {
        $ta configure -autoseparators 0
        $ta edit separator
        foreach peerta [getfullpeerset $ta] {
            incr listoffile("$peerta",undostackdepth)
            set listoffile("$peerta",redostackdepth) 0
            push_undo_modifiedlinetags $peerta
            reset_redo_modifiedlinetags $peerta
        }
    }
    return $oldSeparator
}

proc endatomicedit {ta oldSeparator} {
    if {$oldSeparator} {
        $ta edit separator
        $ta configure -autoseparators 1
        updatemodifiedlinemargin_allpeers $ta
    }
}

proc push_undo_modifiedlinetags {ta} {
# get the current state of modified line tags and save it on the undo stack of such states
    global listoffile
    lappend listoffile("$ta",undostackmodifiedlinetags) [getmodifiedlinetags $ta]
}

proc push_redo_modifiedlinetags {ta} {
# get the current state of modified line tags and save it on the redo stack of such states
    global listoffile
    lappend listoffile("$ta",redostackmodifiedlinetags) [getmodifiedlinetags $ta]
}

proc pop_undo_modifiedlinetags {ta} {
# get the last item from the undo stack of modified line tags and restore this state
    global listoffile
    set modlinetags [lindex $listoffile("$ta",undostackmodifiedlinetags) end]
    set listoffile("$ta",undostackmodifiedlinetags) [lreplace $listoffile("$ta",undostackmodifiedlinetags) end end]
    setmodifiedlinetags $ta $modlinetags
}

proc pop_redo_modifiedlinetags {ta} {
# get the last item from the redo stack of modified line tags and restore this state
    global listoffile
    set modlinetags [lindex $listoffile("$ta",redostackmodifiedlinetags) end]
    set listoffile("$ta",redostackmodifiedlinetags) [lreplace $listoffile("$ta",redostackmodifiedlinetags) end end]
    setmodifiedlinetags $ta $modlinetags
}

proc reset_redo_modifiedlinetags {ta} {
# reset the redo stack of modified line tags to the empty list
    global listoffile
    set listoffile("$ta",redostackmodifiedlinetags) [list ]
}

proc forcemodified {textarea} {
# Force the modified flag of $textarea to be set
    $textarea edit modified true
}

proc isanymodified {} {
# Return true if any buffer was modified
    global listoftextarea
    set ret false
    # the modified flag is shared among peers, no need to check all of them
    foreach textarea [filteroutpeers $listoftextarea] {
        if {[ismodified $textarea]} {
            set ret true
            break
        }
    }
    return $ret
}

proc ismodified {textarea} {
# Return true if the buffer in parameter was modified
    return [$textarea edit modified]
}

proc changedmodified {textarea} {
# Update the visual indications showing that the buffer was modified or not
# This includes title bar, colorization of the windows menu entry and
# colorization of an area in the status bar
    global closeinitialbufferallowed listoftextarea

    # this test is needed because proc changedmodified is bound to the Text
    # class, i.e. it might trigger also for non textareas such as the call
    # stack widget of the watch window
    if {[lsearch -exact $listoftextarea $textarea] == -1} {
        return
    }

    set closeinitialbufferallowed false
    modifiedtitle $textarea
}

proc resetmodified {textarea {clearstacks "keepundoredostacks"}} {
# Reset the modified flag for the given textarea, and update the visual
# indications relative to the modified state
# If $clearstacks is "clearundoredostacks", then reset also the undo/redo
# stacks, otherwise don't do it
    global listoffile

    if {$clearstacks == "clearundoredostacks"} {
        # the undo stack is common to all peers, no need to loop on peers
        # to reset the undo and redo stacks
        $textarea edit reset
    }

    # the modified flag is also common to all peers
    $textarea edit modified false

    foreach ta [getfullpeerset $textarea] {
        if {$clearstacks == "clearundoredostacks"} {
            set listoffile("$ta",undostackdepth) 0
            set listoffile("$ta",redostackdepth) 0
            set listoffile("$ta",undostackmodifiedlinetags) [list ]
            set listoffile("$ta",redostackmodifiedlinetags) [list ]
        }
        # Tk 8.4 sends automatically a <<Modified>> event to a text widget when
        # editing the modified flag of this text widget, but 8.5 does only when
        # the modified flag changes state (consistent with the manual) - See Tk
        # bug 1799782 (fixed in 8.5.0) - However fixing that bug revealed another
        # bug (Tk bug 1871474), so rather always manually send the needed event,
        # even if Tk bug 1871474 is now (25 Oct. 09) fixed:
        # the line below fixes Scilab bug 2650
        event generate $ta <<Modified>>
    }
    # send a <<Modified>> event to the textarea sent to resetmodified
    # this allows for updating the title bar with information from the right
    # peer, otherwise the last peer from the [getfullpeerset $textarea] list
    # updates the title bar last and we might be left with a title bar which
    # is no longer consistent with the focused peer
    event generate $textarea <<Modified>>
}

proc commonPrefix {a b} {
# Return the common prefix between two strings
# This is an ancillary for undo/redo
# Source: http://wiki.tcl.tk/44 - Additional string functions
    set res {}
    foreach i [split $a ""] j [split $b ""] {
        if {$i==$j} {append res $i} else break
    }
    set res
}

# Reverse a string, e.g. "abc" becomes "cba"
# This is an ancillary for undo/redo
# The sreverse procedure is implemented differently depending on whether
# Tcl 8.5 or 8.4 is running in the background
# This has some advantages over checking $Tcl85 inside sreverse everytime it
# is called:
#   First it does the 8.5 check only once, when the code is sourced
#   Second if 8.5 becomes commonplace, the 8.4 implementation becomes just a
#   piece of dead code
if {$Tcl85} {
    # TIP #272 (String and List Reversal Operations) is part of
    # Tcl 8.5, and is used if available because it's performing at a
    # tremendously better performance level - TIP #272 is in "Final" state,
    # meaning that the corresponding implementation has been included in
    # the core (this was done 9 Nov. 06)
    # Tcl8.5 implementation
    proc sreverse s {
        return [string reverse $s]
    }
} else {
    # Tcl 8.4 implementation
    # Source: http://wiki.tcl.tk/44 - Additional string functions
    proc sreverse s {
        set l [string length $s]
        set res ""
        while {$l} {append res [string index $s [incr l -1]]}
        set res
    }
}

# The lreverse procedure is implemented only if it doesn't exist
#   First it does the 8.5 check (i.e. [info commands lreverse] eq {})
#   only once, when the code is sourced
#   Second if 8.5 becomes commonplace, this is just a piece of dead code
if {[info commands lreverse] eq {} } {
    # TIP #272 (String and List Reversal Operations) is part of
    # Tcl 8.5, and is used if available because it's performing at a
    # tremendously better performance level - TIP #272 is in "Final" state,
    # meaning that the corresponding implementation has been included in
    # the core (this was done 9 Nov. 06)
    proc lreverse l {
        # Reverse a list, e.g. {a b c} becomes {c b a}
        # Tcl 8.4 implementation
        # Source: http://wiki.tcl.tk/43 - Additional list functions
        set res {}
        set i [llength $l]
        while {$i} {lappend res [lindex $l [incr i -1]]}
        set res
    }
} else {
    # Nothing to do: this is Tcl 8.5 case, which includes a native
    # lreverse command
}
