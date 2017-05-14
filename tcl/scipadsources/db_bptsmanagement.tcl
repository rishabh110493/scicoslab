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
#
# Breakpoints management
#
# Breakpoints are implemented through text widget tags that can be
# visually identified by their background (configurable) color, which
# is usually pink
# The tag associated to a breakpoint is breakpoint_ID, where ID is
# a unique numerical identifier for the breakpoint (starts at 0 and
# always increases)
#
# Breakpoints are also represented in an internal array bptsprops,
# with the following fields:
#
#   $bptsprops($ID,funname):
#     Name of the function where the breakpoint number $ID is set
#
#   $bptsprops($ID,funline):
#     Line number in the function funname where the breakpoint number $ID
#     is set. This is the line number as reported by whichfun, and is
#     therefore:
#       - always a logical line number
#       - one unit greater than the line number that must be used in the
#         setbpt instruction: setbpt(...,x) will show "Stop after row  x
#         in function foobar" in the Scilab shell, however when breakpointing
#         line x one wants Scilab to stop just *before* executing that line,
#         which means sending setbpt(...,x-1)
#         The hell is that this is only true in Scilab-4-like code trees older
#         than Scicoslab 4.3
#         For Scilab 5 and Scicoslab 4.x (x>3):
#           what is sent to setbpt()/delbpt() must be converted (logical
#           -> physical) by proc loglinetophyslineinfun_* from $bptsprops($ID,funline)
#           what is retrieved from where() must be converted (physical in function
#           -> logical by proc physlineinfuntologline before going into
#          $bptsprops($ID,funline)
#
#   $bptsprops($ID,funphysline):
#     Physical line number (in function) corresponding to $bptsprops($ID,funline),
#     in other words the logical line number but counting continued lines as any
#     other (non continued) line
#
#   $bptsprops($ID,enable):
#     If this is true the breakpoint identified by $ID is taken into account
#     in the debug, otherwise it is ignored (the debug does not stop at
#     this breakpoint but it is still visible in the textarea)
#
#   $bptsprops($ID,expression):
#     Condition to be tested when the breakpoint identified by $ID is
#     reached. If this condition is true then the breakpoint is said
#     to be hit
#
#   $bptsprops($ID,curexpvalue):
#     Current value (i.e. value as was evaluated at the previous stop) of
#     bptsprops($ID,expression)
#     The value of the conditional expression is initialized to the empty
#     string. Later values are formatted by FormatStringsForWatch
#
#   $bptsprops($ID,conditiontype):
#     Can be either "istrue" or "haschanged".
#     If "istrue", the condition stored in $bptsprops($ID,expression)
#     is checked against a boolean true.
#     If "haschanged", it is checked that the condition result has changed
#     since the previous stop
#     Note that this field always contains the above identifiers regardless
#     of the current locale (e.g. "istrue" is never translated in any language)
#
#   $bptsprops($ID,watched):
#     If this is true then the expression associated to the breakpoint is
#     watched as a generic expression and this expression is added in the
#     list of such expressions in the watch window 
#
#   $bptsprops($ID,hitcount):
#     Number of times the breakpoint identified by $ID has been hit.
#     This is reset to zero at the beginning of the debug (when the first
#     debug command is issued after the configure step), and can also be
#     reset manually by the user during debug
#
#   $bptsprops($ID,hitcountcondition):
#     Type of condition for the test on the hit count.
#     By default it is set to "always"
#
#   $bptsprops($ID,hitcountthreshold):
#     Number against which the hit count is tested. The type of test is given
#     by the hit count condition, i.e. against $bptsprops($ID,hitcountcondition).
#     This defaults to 1
#
# At any time, only one ID must correspond to a given couple (funname,funline)
# The only exception is between an edit action and the subsequent execution
# of proc reshape_bp, whose purpose is exactly to restore this identity.
#
# The ID of the breakpoint located at (funname,funline) can be retrieved
# thanks to proc where2bptID
#
# Breakpointed functions and lines can be queried using getfunnamesfrombptsprops
# and getfunlinesfrombptsprops, and the IDs currently in use can be found
# by getusedIDsfrombptprops
#
#####################################################################

proc createnewbptID {} {
# return a new breakpoint unique ID, that has never been used before
# IDs are integers starting from zero
    global lastuniquebptID
    if {![info exists lastuniquebptID]} {
        set lastuniquebptID -1
    }
    return [incr lastuniquebptID]
}

proc where2bptID {fun lin {condconvertphystolog false}} {
# return the breakpoint ID corresponding to line number $funline in function
# named $funname
# this is done by browsing the bptsprops array
# condconvertphystolog is a flag that must be set to true if where2bptID
# is called with $lin containing a line number from where() ; it must be
# set to false (or omitted) when where2bptID is called with $lin containing
# a line number that is already logical, such as the one provided by the
# output of whichfun, or the one from the bptsprops array
# Assert: only one ID corresponds to a given couple (funname,funline)
# if this condition is not true, then the first match is returned
# if there is no match, return -1
    global bptsprops
    if {$condconvertphystolog} {
        set lin [condphyslinetologline $fun $lin]
    }
    set indexsandfuns [array get bptsprops *,funname]
    foreach {arindex arfun} $indexsandfuns {
        if {$arfun eq $fun} {
            scan $arindex "%d,funname" ID
            if {$bptsprops($ID,funline) == $lin} {
                return $ID
            }
        }
    }
    return -1
}

proc getusedIDsfrombptprops {} {
# return the (unordered) list of IDs currently in use in array $bptsprops
    global bptsprops
    return [string map {",funname" ""} [array names bptsprops -glob *,funname]]
}

proc getfunnamesfrombptsprops {} {
# return the alphabetically sorted list of function names currently
# breakpointed in array $bptsprops
# there is only one entry per function in the output list
    global bptsprops
    set indexsandfuns [array get bptsprops *,funname]
    regsub -all -- {[0-9]*,funname} $indexsandfuns "" onlyfuns
    set uniquefuns [lsort -unique -increasing -dictionary $onlyfuns]
    return $uniquefuns
}

proc getfunlinesfrombptsprops {fun} {
# return the list of all the breakpointed lines of function named $fnam
# as extracted from the $bptsprops array
# the output list is ordered in increasing order, and an empty list is
# returned if $fnam does not have any breakpoint
    global bptsprops
    set lineslist [list ]
    set indexsandfuns [array get bptsprops *,funname]
    foreach {arindex arfun} $indexsandfuns {
        if {$arfun eq $fun} {
            scan $arindex "%d,funname" ID
            lappend lineslist $bptsprops($ID,funline)
        }
    }
    return [lsort -increasing -integer $lineslist]
}

proc isbreakpointedplace {textarea pos} {
# return the full textual breakpoint tag tagging index $pos
# in textarea $textarea if this location is breakpointed,
# i.e. if it is tagged with breakpoint_ID, ID being anything
# if $pos is not breakpointed, return the empty string
    set activetags [$textarea tag names $pos]
    set matchpos [lsearch -glob $activetags breakpoint_*]
    return [lindex $activetags $matchpos]
}

proc getbreakpointtagranges {textarea} {
# return all the ranges in $textarea that are tagged with breakpoint_ID,
# ID being any breakpoint identifier
# ranges are sorted in order of occurrence in $textarea
# this proc in fact performs something like   $textarea tag ranges -glob breakpoint_*

    global tainwhichtocompindex ; # a global must be used because the -command option of lsort does not allow to pass an argument

    proc compindex {i j} {
        global tainwhichtocompindex
        if {[$tainwhichtocompindex compare $i < $j]} {
            return -1
        } elseif {[$tainwhichtocompindex compare $i == $j]} {
            return 0
        } else {
            return 1
        }
    }

    set bptranges [list ]
    foreach ID [getusedIDsfrombptprops] {
        set ranges_ID [$textarea tag ranges breakpoint_$ID]
        if {$ranges_ID != {}} {
            lappend bptranges $ranges_ID
        }
    }
    set tainwhichtocompindex $textarea
    set sortedbptranges [lsort -increasing -index 0 -command {compindex} $bptranges]
    set flattensortedbptranges [list ]
    foreach arange $sortedbptranges {
        foreach {i j} $arange {}
        lappend flattensortedbptranges $i $j
    }
    return $flattensortedbptranges
}

proc textareacontainsbreakpointID {ta ID} {
# return true if textarea $ta has a range tagged with breakpoint_$ID
# return false otherwise
    if {[$ta tag ranges breakpoint_$ID] ne ""} {
        return true
    } else {
        return false
    }
}

proc getbreakpointsIDsfoundintextarea {ta} {
# return the list of the IDs of the breakpoints set in textarea $ta
# the list is ordered by order of appearance in $ta (i.e. not necessarily
# by increasing IDs)
# algorithm: from the list of currently used IDs (dispatched among all the
# textareas), find which ones are in $ta. This is believed to be much quicker
# than the other approach making a call to whichfun:
#    foreach {tstart tstop} [getbreakpointtagranges $ta] {
#        set infun [whichfun [$ta index $tstart] $ta]
#        lappend listofIDs [where2bptID [lindex $infun 0] [lindex $infun 1]]
#    }

    set listofIDs [list ]
    foreach ID [getusedIDsfrombptprops] {
        if {[textareacontainsbreakpointID $ta $ID]} {
            lappend listofIDs $ID
        }
    }
    return $listofIDs
}

proc gettextareacontainingbreakpointID {ID} {
# find which textarea contains the tag breakpoint_$ID
# in principle there is always one and only one such textarea
    global listoftextarea
    foreach textarea [filteroutpeers $listoftextarea] {
        if {[textareacontainsbreakpointID $textarea $ID]} {
            return $textarea
        }
    }
    # return an invalid textarea name so that a Tcl error gets thrown
    # if I forgot something (this should never be run)
    return "none"
}

proc tagconfigurebreakpointbackground_textarea {ta} {
# configure background of all breakpoint tags, i.e. all breakpoint_ID
# tags, in textarea $ta, with:
#  - color $colorvalue
#  - stipple solid or gray50, depending on the enable setting
# this is a replacement for $textarea tag configure breakpoint_$i -bg...
# that shouldn't be used in Scipad elsewhere than here, unless special case
# such as creation of a new single breakpoint
    foreach ID [getbreakpointsIDsfoundintextarea $ta] {
        tagconfigurebreakpointbackground $ID
    }
}

proc tagconfigurebreakpointbackground {ID} {
# configure background color of the breakpoint tagged as breakpoint_$ID
# with color $BREAKPOINTCOLOR
# From $BREAKPOINTCOLOR:
#   - breakpoints with no condition receive -bg $BREAKPOINTCOLOR
#   - breakpoints with a condition receive  -bg [shade $BREAKPOINTCOLOR]
# Moreover, -bgstipple is set to:
#   - "" (solid filled background) for enabled breakpoints
#   - gray25 for disabled breakpoints
    global bptsprops
    global BREAKPOINTCOLOR

    set darkenedbreakpointcolor [shade $BREAKPOINTCOLOR black 0.1]

    set textarea [gettextareacontainingbreakpointID $ID]

    if {[string trim $bptsprops($ID,expression)] eq "%t"} {
        $textarea tag configure breakpoint_$ID -background $BREAKPOINTCOLOR
    } else {
        $textarea tag configure breakpoint_$ID -background $darkenedbreakpointcolor
    }

    if {$bptsprops($ID,enable)} {
        $textarea tag configure breakpoint_$ID -bgstipple ""
    } else {
        $textarea tag configure breakpoint_$ID -bgstipple gray25
    }
}

proc taglowerbreakpoint {textarea othertag} {
# lower the priority of all the breakpoint tags in $textarea, i.e. all
# breakpoint_ID tags, such that $othertag has higher priority than any
# breakpoint tag
# this is a replacement for $textarea tag raise $atag breakpoint_$i that
# shouldn't be used in Scipad elsewhere than here, unless special case
# such as creation of a new single breakpoint
    foreach ID [getbreakpointsIDsfoundintextarea $textarea] {
        $textarea tag raise $othertag breakpoint_$ID
    }
}

proc createbreakpoint {textarea i1 i2 nameoffun lineinfun contlines condexpr} {
# create a new breakpoint, i.e.:
#  - tag from $i1 to $i2 in $textarea
#  - create new entries in the bptsprops array
    global bptsprops BREAKPOINTCOLOR

    set newID [createnewbptID]
    $textarea tag add breakpoint_$newID $i1 $i2
    $textarea tag configure breakpoint_$newID -background $BREAKPOINTCOLOR
    $textarea tag raise activebreakpoint breakpoint_$newID
    $textarea tag bind breakpoint_$newID <Enter> [list highlightbptinbptsgui   $newID]
    $textarea tag bind breakpoint_$newID <Leave> [list unhighlightbptinbptsgui $newID]

    set bptsprops($newID,funname) $nameoffun
    set bptsprops($newID,funline) $lineinfun
    set bptsprops($newID,funphysline) [expr {$lineinfun + $contlines}]
    set bptsprops($newID,enable) true
    set bptsprops($newID,expression) $condexpr
    set bptsprops($newID,curexpvalue) ""
    set bptsprops($newID,conditiontype) istrue
    set bptsprops($newID,watched) false
    set bptsprops($newID,hitcount) 0
    set bptsprops($newID,hitcountcondition) always
    set bptsprops($newID,hitcountthreshold) 1
    addbptingui $newID
}

proc deletebreakpoint {textarea bpttag nameoffun lineinfun} {
# forget about breakpoint tagged as $bpttag in $textarea, and erase the
# corresponding entries in the bptsprops array
    global bptsprops

    # the tag can be deleted and not simply removed since it will never
    # be used later
    $textarea tag delete $bpttag
    set ID [where2bptID $nameoffun $lineinfun]

    # WARNING: the -textariable linked to bptsprops in proc delbptingui silently
    # prevents from unsetting these attributes here: there is no error, the unset
    # is just not done. Therefore it is very important that proc delbptingui:
    #   - destroys the widgets (and not just grid forget or grid remove them)
    #   - be called before the unsets below
    delbptingui $ID
    unset bptsprops($ID,funname)
    unset bptsprops($ID,funline)
    unset bptsprops($ID,funphysline)
    unset bptsprops($ID,enable)
    unset bptsprops($ID,expression)
    unset bptsprops($ID,curexpvalue)
    unset bptsprops($ID,conditiontype)
    unset bptsprops($ID,watched)
    unset bptsprops($ID,hitcount)
    unset bptsprops($ID,hitcountcondition)
    unset bptsprops($ID,hitcountthreshold)
}

proc insertremove_bp {{buf "current"}} {
# insert or remove a breakpoint on the cursor line
# this proc makes sure that the cursor line can receive a breakpoint, i.e.
# is not a nocode line and is not a function definition line, and there is no
# same function already breakpointed, perhaps in another buffer
# the breakpoint is not sent to / removed from Scilab, unless when already
# in debug mode, and in this case the job is done by proc insertremovedebug_bp
    if {$buf == "current"} {
        set textarea [gettextareacur]
    } else {
        set textarea $buf
    }
    $textarea see insert
    if {[getdbstate] == "DebugInProgress"} {
        insertremovedebug_bp $textarea
    } elseif {![isnocodeline $textarea insert]} {
        set i1 [getrealstartofcontline $textarea "insert linestart"]
        set i2 [$textarea index "$i1 lineend"]
        # the following is to prevent from breakpointing the function
        # definition line (would need to say later setbpt("foo",0)
        # which is forbidden)
        set canbreakpoint true
        set infun [whichfun [$textarea index "$i1+1c"] $textarea]
        if {$infun != {}} {
            set nameoffun [lindex $infun 0]
            set lineinfun [lindex $infun 1]
            set contlines [lindex $infun 4]
            if {$lineinfun == 1} {
                set canbreakpoint false
            }
        } else {
            # not in a Scilab function
            set canbreakpoint false
        }
        # a breakpoint is uniquely identified by its ID or by the couple
        # (funname,line#infunname), thus duplicate functions are not allowed
        if {[checkforduplicateorunterminatedfuns]} {
            set canbreakpoint false
        }
        if {$canbreakpoint} {
            set bpttaghere [isbreakpointedplace $textarea $i1]
            if {$bpttaghere == ""} {
                # this place is not already breakpointed, then create a new breakpoint
                createbreakpoint $textarea $i1 $i2 $nameoffun $lineinfun $contlines "%t"
            } else {
                # there is an existing breakpoint here, then delete it
                deletebreakpoint $textarea $bpttaghere $nameoffun $lineinfun
            }
            updatebptcomplexityindicators_bp
        } else {
            showinfo [mc "No breakpoint here!"]
        }
    } else {
        showinfo [mc "No breakpoint here!"]
    }
}

proc insertremovedebug_bp {textarea} {
# during a debug session, insert or remove a breakpoint on the cursor line
# this proc makes sure that the cursor line can receive a breakpoint, i.e.
# is not a nocode line and is not a function definition line
# the breakpoint is sent to / removed from Scilab
    global setbptonreallybreakpointedlinescmd
    # no need to check for Scilab busy - breakpoints can be set/unset even
    # when busy
    set i1 [getrealstartofcontline $textarea "insert linestart"]
    set i2 [$textarea index "$i1 lineend"]
    if {![isnocodeline $textarea $i1] &&
        [lsearch [$textarea tag names $i1] "db_wrapper"] == -1} {
        # no need for duplicate functions check since in state "DebugInProgress"
        # no code editing is allowed, and the duplicate functions test has been
        # already performed when entering the debug
        set infun [whichfun [$textarea index $i1] $textarea]
        if {$infun != {} } {
            # during debug, because .sce files debug uses a wrapper function,
            # and because no buffer modification is allowed, $infun is almost
            # always non empty and contains valid function data - the only case
            # where this is wrong is when the user tries to breakpoint the
            # function declaration line
            set nameoffun [lindex $infun 0]
            set lineinfun [lindex $infun 1]
            set contlines [lindex $infun 4]
            set setbptlineinfun [expr {[condloglinetophyslineinfun $nameoffun $lineinfun] - 1}]
            set bpttaghere [isbreakpointedplace $textarea $i1]
            if {$bpttaghere == ""} {
                # this place is not already breakpointed, then create a new breakpoint
                createbreakpoint $textarea $i1 $i2 $nameoffun $lineinfun $contlines "%t"
                set setbpcomm "setbpt(\"$nameoffun\",$setbptlineinfun);"
                append setbptonreallybreakpointedlinescmd $setbpcomm
                ScilabEval_lt $setbpcomm "seq"
            } else {
                # there is an existing breakpoint here, then delete it
                deletebreakpoint $textarea $bpttaghere $nameoffun $lineinfun
                set delbpcomm "delbpt(\"$nameoffun\",$setbptlineinfun);"
                # <TODO> process string setbptonreallybreakpointedlinescmd in order to
                #        remove the existing corresponding setbpt command instead of
                #        always adding a delbpt because this ends up in very long lines
                #        just by repeatedly adding/removing the same breakpoint during
                #        the debug -  note: if this is done here, then no need to do a
                #        similar processing for setbpt just above
                append setbptonreallybreakpointedlinescmd $delbpcomm
                ScilabEval_lt $delbpcomm  "seq"
            }
            updatebptcomplexityindicators_bp
        } else {
            # the user tried to breakpoint the function declaration line
            showinfo [mc "No breakpoint here!"]
        }
    } else {
        showinfo [mc "No breakpoint here!"]
    }
}

proc removeallbpt_level0_scipad_bp {} {
# remove all breakpoints set in level zero code from all
# the opened buffers
# in fact this searches for breakpoints set in the wrapper function,
# and it must therefore be called before cleaning this wrapper
# (see proc scedebugcleanup_bp) 
# this is used to clean the breakpoints the user has set during .sce debugging
# possibly existing breakpoints in Scilab are not touched, unless in
# a debug session
    global listoftextarea

    foreach textarea [filteroutpeers $listoftextarea] {
        set saveinsert [$textarea index insert]
        set tagranges [getbreakpointtagranges $textarea]
        foreach {bp_start bp_stop} $tagranges {
            set infun [whichfun $bp_start $textarea]
            set funname [lindex $infun 0]
            if {[regexp -- {db_wrapper_[[:digit:]]+_db} $funname]} {
                $textarea mark set insert $bp_start
                insertremove_bp $textarea
            }
        }
        $textarea mark set insert $saveinsert
    }
}

proc removeallbpt_scipad_bp {} {
# remove all breakpoints from all the opened buffers
# possibly existing breakpoints in Scilab are not touched, unless in
# a debug session
    global pad listoftextarea

    if {[countallbreakpointedlines] > 0} {

        if {[isscilabbusy 5]} {return}

        # ask for confirmation since it's so easy to confuse the bindings:
        # Shift-F9 is Delete all, while Ctrl-F9 is Open properties...
        set tit [mc "Delete all breakpoints"]
        set mes [mc "Are you sure you want to delete all the existing breakpoints?"]
        set answ [tk_messageBox -message $mes -type yesno -icon question -title $tit -parent $pad]

        if {$answ == yes} {
            foreach textarea [filteroutpeers $listoftextarea] {
                removebpt_scipad $textarea
            }
            showinfo [mc "All breakpoints deleted"]
        } else {
            showinfo [mc "No action taken"]
        }

    } else {
        showinfo [mc "No breakpoint!"]
    }
}

proc removebpt_scipad {textarea} {
# remove all breakpoints from buffer $textarea
# possibly existing breakpoints in Scilab are not touched, unless in
# a debug session
    set saveinsert [$textarea index insert]
    set tagranges [getbreakpointtagranges $textarea]
    foreach {bp_start bp_stop} $tagranges {
        $textarea mark set insert $bp_start
        insertremove_bp $textarea
    }
    $textarea mark set insert $saveinsert
}

proc removeallbpt_scilab {outp} {
# if $outp != "no_output", remove all the breakpoints set in Scilab
# otherwise just return the command that would do that
# note: breakpoints possibly set in Scipad are not touched

    global funnames

    # if $outp != "no_output", no need to check isscilabbusy since this
    # has been done in the calling procs (goonwo_bp and canceldebug_bp)
    # if $outp == "no_output", no need to check isscilabbusy anyway

    set delbpcomm ""
    if {$funnames != ""} {
        set delbpcomm "delbpt();"
        if {$outp != "no_output"} {
            ScilabEval_lt "$delbpcomm" "seq"
        }
    } else {
        # <TODO> .sce case if some day the parser uses pseudocode noops
    }
    return $delbpcomm
}

proc reshape_bp {} {
# when editing textareas containing lines tagged as breakpoints, it can happen
# that breakpointed lines must be reshaped, for instance when the user hits
# return in the middle of a breakpointed line
# this is precisely what this proc does, in all the textareas (because some
# actions such as dnd between buffers might change more than one single
# buffer at a time)

    global bptsprops listoftextarea

    # save current bptsprops array, so that breakpoint properties are not lost
    # when updating them later
    array set oldbptsprops [array get bptsprops]

    # 1. Suppress breakpoint tags that could now be on nocode lines
    #    This could happen because the user might have commented out a breakpointed line
    set usedIDsinarray [getusedIDsfrombptprops]
    foreach ID $usedIDsinarray {
        foreach ta [filteroutpeers $listoftextarea] {
            set done false
            foreach {tstart tstop} [$ta tag ranges breakpoint_$ID] {
                if {[isnocodeline $ta $tstart]} {
                    $ta tag remove breakpoint_$ID $tstart $tstop
                    set done true
                }
            }
            if {$done} {
                # the tag breakpoint_$ID can be in only one textarea, so we an break here
                break
            }
        }
    }

    # 2. "Concatenate" breakpoint tags that could now be on the same line (actually
    #    keep only one of them and delete the others
    #    This could happen because from a situation where two consecutive lines
    #    are breakpointed, the user might have deleted the \n between them
    foreach ta [filteroutpeers $listoftextarea] {
        set tagranges [getbreakpointtagranges $ta]
        set i 1
        foreach {tstart tstop} $tagranges {
            scan $tstart "%d.%d" linenum dropthis
            set remainingtags [lreplace $tagranges 0 $i]
            incr i 2
            foreach {rtstart rtstop} $remainingtags {
                scan $rtstart "%d.%d" rlinenum dropthis
                if {$rlinenum == $linenum} {
                    set infun [whichfun [$ta index "$rtstart+1c"] $ta]
                    if {$infun != {}} {
                        # here assert triggers in where2bptID (more than a single
                        # breakpoint on a given line) but it doesn't matter which
                        # breakpoint tag is kept
                        set ID [where2bptID [lindex $infun 0] [lindex $infun 1]]
                        $ta tag remove breakpoint_$ID $tstart $tstop
                    } else {
                        # not supposed to happen: bpts are always in functions
                    }
                } else {
                    # nothing to do, breakpoints are on different lines
                }
            }
        }
    }

    # 3. Suppress bptsprops entries having an ID that no longer exists among
    #    the breakpoint tags found in all the textareas
    #    Reason: an area containing breakpointed lines could have been deleted
    # and
    # 4. Suppress duplicate tags
    #    Reason: a tag might have been split by an editing action
    foreach ID $usedIDsinarray {
        set ranges_ID [list ]
        foreach ta [filteroutpeers $listoftextarea] {
            set ta_ranges_ID [$ta tag ranges breakpoint_$ID]
            if {[llength $ta_ranges_ID] > 0} {
                lappend ranges_ID $ta [lindex $ta_ranges_ID 0] [lindex $ta_ranges_ID 1]
                # the tag breakpoint_$ID can be in only one textarea, so we an break here
                break
            }
        }
        if {[llength $ranges_ID] == 0} {
            # suppress bptsprops entries corresponding to deleted breakpoints
            # deletebreakpoints deletes tag breakpoint_$ID that has already disappeared
            # but this is not an error cause
            deletebreakpoint $ta breakpoint_$ID $bptsprops($ID,funname) $bptsprops($ID,funline)
        } else {
            # a tag might have become split, or changed in other ways
            # perhaps because of pasting some text with \n in the middle
            # in any case, reshape the tag by shrinking it to its first line
            foreach {ta tstart tstop} $ranges_ID {
                $ta tag remove breakpoint_$ID $tstart $tstop
            }
            set firstta [lindex $ranges_ID 0]
            set firststart [lindex $ranges_ID 1]
            $firstta tag add breakpoint_$ID "$firststart linestart" "$firststart lineend"
        }
    }

    # 5. Check that breakpoints are in functions (if not, remove them), and
    #    update entries in bptsprops for each ID
    #    Reason: function name or line number in function could have changed
    #    because of an editing action
    set usedIDsinarray [getusedIDsfrombptprops] ; # *must* be refreshed here!
    foreach ID $usedIDsinarray {
        foreach ta [filteroutpeers $listoftextarea] {
            set ta_ranges_ID [$ta tag ranges breakpoint_$ID]
            if {[llength $ta_ranges_ID] > 0} {
                set tawithID $ta
                foreach {tstart tstop} $ta_ranges_ID {}
                # the tag breakpoint_$ID can be in only one textarea, so we break here
                break
            }
        }
        set infun [whichfun [$tawithID index "$tstart+1c"] $tawithID]
        if {$infun == {}} {
            # the editing action broke the function structure, probably the function definition line
            # the breakpoint is no longer in a function and must be removed
            set oldnameoffun $oldbptsprops($ID,funname)
            set oldlineinfun $oldbptsprops($ID,funline)
            deletebreakpoint $tawithID breakpoint_$ID $oldnameoffun $oldlineinfun
        } else {
            # the breakpoint is still in a function, maybe its name changed,
            # or the line number changed
            set nameoffun [lindex $infun 0]
            set lineinfun [lindex $infun 1]
            set contlines [lindex $infun 4]
            # here the assignment of the new value to bptsprops($ID,funname)
            # should be done only if the new value is different from the current one,
            # and if it is the case the bpts gui must be sorted!!
            #   --> for the funname change only
            #   --> is there any edit action that would change the order of the line numbers?
            if {$nameoffun ne $bptsprops($ID,funname)} {
                set bptsprops($ID,funname) $nameoffun
                sortbptsgui $nameoffun
            }
            set bptsprops($ID,funline) $lineinfun
            set bptsprops($ID,funphysline) [expr {$lineinfun + $contlines}]
            # bptsprops($newID,enable), bptsprops($ID,expression), bptsprops($ID,conditiontype),
            # bptsprops($ID,watched), bptsprops($ID,hitcount), bptsprops($ID,hitcountcondition)
            # and bptsprops($ID,hitcountthreshold) don't need to be updated
        }
    }

    # 6. Refresh active breakpoint tags (needed after line editings)
    set tacur [gettextareacur]
    set acttagranges [$tacur tag ranges activebreakpoint]
    foreach {tstart tstop} $acttagranges {
        $tacur tag remove activebreakpoint $tstart $tstop
        $tacur tag add activebreakpoint "$tstart linestart" "$tstart lineend"
    }

    # 7. Recount the breakpoints for display in the watch window
    updatewatch_bp
}

proc countallbreakpointedlines {} {
# return the number of breakpointed lines in all the opened buffers
    return [llength [getusedIDsfrombptprops]]
}

proc countallbreakpointedmacros {} {
# return the number of macros that contain breakpointed lines
# all the opened buffers are taken into account
    return [llength [getfunnamesfrombptsprops]]
}

proc saveallconditionsvalues {} {
# for all breakpoints currently set, call proc saveoneconditionvalue
    foreach ID [getusedIDsfrombptprops] {
        saveoneconditionvalue $ID
    }
}

proc saveoneconditionvalue {fnamorID {lin -1}} {
# update bptsprops($ID,curexpvalue) with the current value of
# $bptsprops(ID,expression) as evaluated by Scilab
# a breakpoint is supposed to exist at the position in argument
# if the conditional expression evaluation triggers an error, then
# bptsprops($ID,curexpvalue) is set to the empty string
# this proc can be called either with one or two input arguments:
#   1 arg: it's directly a breakpoint ID
#   2 args: breakpoint is identified through function name $fnamorID
#     and a *logical* line number in that function
# condition values are formatted by FormatStringsForWatch before being
# stored, so that anything coming from Scilab can be saved without
# worrying about its type. Condition values are not displayed anyway,
# for such a need there is the "Watched" checkbox in the breakpoints gui

    if {$lin != "-1"} {
        # breakpoint identified by a name of function and a line number
        set fnam $fnamorID
        set ID "\"+TCL_EvalStr(\"where2bptID $fnam $lin\",\"scipad\")+\""
    } else {
        # breakpoint identified by its ID
        set ID $fnamorID
    }

    set rawhitcondition "evstr(TCL_GetVar(\"\"bptsprops($ID,expression)\"\",\"\"scipad\"\"))"
    set evalerrorproofedhitcondition "\[db_hitcondresult,db_evstrierr\]=evstr(\"$rawhitcondition\");if db_evstrierr<>0 then db_hitcondresult=emptystr();lasterror(%t);end"
    set savecurrentconditionvalue "TCL_SetVar(\"bptsprops($ID,curexpvalue)\",FormatStringsForWatch(db_hitcondresult),\"scipad\");"

    ScilabEval_lt "$evalerrorproofedhitcondition ; $savecurrentconditionvalue" "seq"
}

proc resetallhitcounts {} {
# reset to zero the hit count associated to all breakpoints
    foreach ID [getusedIDsfrombptprops] {
        resetonehitcount $ID
    }
}

proc resetonehitcount {ID} {
# reset to zero the hit count associated to breakpoint $ID
    global bptsprops
    set bptsprops($ID,hitcount) 0
}
