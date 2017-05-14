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

proc findit {w pw mulfilcontext textarea tosearchfor cas reg sinsel whword tags sdirec} {
# find a match in $textarea and display this match
# input variables are:
#   w            : name of the find dialog
#   pw           : the window pathname that will be used as parent for
#                  the messageboxes, if any should pop up
#   mulfilcontext: if true then the search in $textarea is happening in the
#                  context of a multiple files search (this is used to decide
#                  what output result to return, see below the possible values)
#   textarea     : the textarea in which the search shall happen
#   tosearchfor  : the string to search for (Tcl special characters
#                  are already escaped in this string)
#   cas          : case flag ("-exact": case matching, "-nocase": ignore
#                  case)
#   reg          : regexp flag ("regexp": regexp matching, "standard":
#                  no regexp matching)
#   sinsel       : search in selection flag (true: search in the selection
#                  only, false: search the entire textarea)
#   whword       : whole word flag (true: search for whole words only,
#                  false: search for partial words as well)
#   tags         : list of tag names, an element of which a match candidate
#                  shall match to really match the search string
#   sdirec       : search direction ("forwards" or "backwards")
# output result can be:
#   "nomatchatall":
#      there is no match whatsoever in this buffer
#   "nomatchinsel":
#      the search was limited to the selection and there was no match
#      in that selection
#      (this cannot be returned when searching in multiple files)
#   "mustswitchnow_nomorematches":
#      a buffer switch followed by a search should be performed now
#     (this can be returned when searching in one buffer or in multiple files)
#   "mustswitchnow_looped":
#      a buffer switch followed by a search should be performed now
#     (this cannot be returned when searching in one single buffer)
#   "looped":
#      the search looped, there is no more match to look for in this buffer
#   "searchagain":
#      a further search will provide a new result in the same buffer

    global listofmatch listoftextarea
    global buffermodifiedsincelastsearch

    set buffermodifiedsincelastsearch false

    # do the search and get the match positions and the length of the matches
    # and do it only once (per buffer) in a search session
    if {![info exists listofmatch]} {
        set listofmatch [searchforallmatches $textarea $tosearchfor \
                             $cas $reg $sinsel $whword $tags]
    }

    highlightallnotreplacedmatches $textarea $listofmatch

    # analyze the search results:
    #   look if the search failed and ask for extending if possible
    if {$listofmatch == {}} {
        # no match has been found

        $textarea tag remove curfoundtext 1.0 end

        # switch to next buffer if the search has to be done on all buffers
        if {$mulfilcontext} {
            return "mustswitchnow"
        }

        # single buffer search, no match: inform the user that the search has failed
        if {!$sinsel} {
            # no match in whole buffer
            return "nomatchatall"
        } else {
            # no match in the selection
            return "nomatchinsel"
        }
    }

    # analyze the search results:
    #    if we did not return before this point, then there is at least one match

    # select the match to display from the list of matches
    foreach {mpos mlen wraparound looped alreadyreplaced} \
            [getnextmatch $textarea $sdirec $sinsel] {}

    if {$alreadyreplaced} {
        return "mustswitchnow_nomorematches"
    }

    # if search looped, then we have already displayed
    # all the matches in this textarea
    # if we're searching in a single file, just go on redisplaying matches
    # otherwise return so that a new textarea can be searched
    if {$looped && $mulfilcontext} {
        # return here to avoid processing of the repeated match
        return "mustswitchnow_looped"
    }

    # if search wrapped, tell the user
    if {$wraparound} {
        showinfo [mc "Wrapped around"]
    } else {
        delinfo
    }

    # arrange for this match to be visible and tag it
    foreach ta [filteroutpeers $listoftextarea] {
        # this must be done for each ta, not only for $textarea
        # because of the switch buffer case in tile mode
        # however since this is only playing with tags, there is
        # no need to do it for peers
        $ta tag remove curfoundtext 1.0 end
        $ta tag remove replacedtext 1.0 end
    }
    set mepos [$textarea index "$mpos + $mlen char"]
    $textarea tag add curfoundtext $mpos $mepos
    $textarea tag raise curfoundtext anyfoundtext
    # show the end of match then the start of it to increase the
    # chances of seeing it entirely even in small areas in tile mode
    $textarea see $mepos
    $textarea see $mpos
    $textarea mark set insert $mpos

    # the following three bindings are required to remove the curfoundtext tag
    # after a find next triggered by Ctrl-F3. In order to erase them after use,
    # the binding is redefined in the bound script itself to what this script
    # was before bound instructions are added (+ statement) here
    # the curfoundtext tag removal instruction is also prevented from cumulating
    # (e.g. when hitting Ctrl-F3 repeatedly with no action in the textarea in
    # between)
    # last note, this must be done for KeyPress and ButtonPress of course, but
    # also for Button-1 since:
    #    a. this event is more specific than ButtonPress and will therefore be
    #       triggered when the user clicks Button-1
    #    b. the bound script for Button-1 contains a {break}, which is needed
    #       for dnd but prevents here the wanted ButtonPress binding to trigger
    # also we must do the same for the anyfoundtext tag
    set bindtext [bind $textarea <KeyPress>]
    set bindtext [string map {"%" "%%"} $bindtext]
    if {[string first " tag remove curfoundtext 1.0 end" $bindtext] == -1} {
        bind $textarea <KeyPress> "+%W tag remove curfoundtext 1.0 end ; %W tag remove anyfoundtext 1.0 end ; bind %W <KeyPress> [list $bindtext]"
    }
    set bindtext [bind $textarea <ButtonPress>]
    set bindtext [string map {"%" "%%"} $bindtext]
    if {[string first " tag remove curfoundtext 1.0 end" $bindtext] == -1} {
        bind $textarea <ButtonPress> "+%W tag remove curfoundtext 1.0 end ; %W tag remove anyfoundtext 1.0 end ; bind %W <ButtonPress> [list $bindtext]"
    }
    set bindtext [bind $textarea <Button-1>]
    set bindtext [string map {"%" "%%"} $bindtext]
    if {[string first " tag remove curfoundtext 1.0 end" $bindtext] == -1} {
        bind $textarea <Button-1> "+%W tag remove curfoundtext 1.0 end ; %W tag remove anyfoundtext 1.0 end ; bind %W <Button-1> [list $bindtext]"
    }

    # prevent the dialog box from hiding the match string
    if {[winfo exists $w]} {
        MoveDialogIfTaggedTextHidden $w $textarea curfoundtext
    }

    # update status bar data
    keyposn $textarea

    if {$looped} {
        set findres "bufferdone"
    } else {
        set findres "searchagain"
    }
    return $findres
}

proc replaceit {w pw mulfilcontext textarea tosearchfor cas reg sinsel whword tags sdirec replacestr {replacesingle 1}} {
# if there is no current match, find one and show it
# otherwise replace the currently found match and find the next one
# input variables:
#   w pw mulfilcontext textarea tosearchfor cas reg sinsel whword tags sdirec: see proc findit
#   replacestr: the string with which matches shall be replaced
#   $replacesingle toggles the popup messageboxes and infos in the
#                  status bar, as well as the background colorization
#                  of user functions and keyposn (all this do not need
#                  to be done for each single replace of a replace all)
# output result can be:
#   "nomatchatall", "nomatchinsel", "mustswitchnow_nomorematches",
#   "mustswitchnow_looped", "looped", "searchagain": see proc findit

    global listofmatch listoftextarea
    global buffermodifiedsincelastsearch

    set buffermodifiedsincelastsearch false

    # if there is no already found matching text,
    # perform a search first
    # and do it only once (per buffer) in a search session
    if {![info exists listofmatch]} {
        return [findit $w $pw $mulfilcontext $textarea $tosearchfor \
                       $cas $reg $sinsel $whword $tags $sdirec]
    }

    # analyze the existing search results
    #   look if the search failed
    if {$listofmatch == {}} {
        # no match has been found

        # switch to next buffer if the search has to be done on all buffers
        if {$mulfilcontext} {
            return "mustswitchnow_looped"
        }

        # single buffer search, no match: inform the user that the search has failed
        if {!$sinsel} {
            # no match in whole buffer
            return "nomatchatall"
        } else {
            # no match in the selection
            return "nomatchinsel"
        }
    }

    # analyze the search results:
    #    if we did not return before this point, then there is at least one match

    # select the match to replace from the list of matches
    set foundtextrange [$textarea tag ranges curfoundtext]
    if {$foundtextrange == {}} {
        # there is no current match in the text
        # therefore get next match
        foreach {mpos mlen wraparound looped alreadyreplaced} \
            [getnextmatch $textarea $sdirec $sinsel] {}
    } else {
        # there is a current match in the text
        # therefore take this one for the replace process
        foreach {mpos mlen wraparound looped alreadyreplaced} \
            [getcurrentmatch $textarea] {}
    }

    # if we have already replaced all the matches in this textarea,
    # we don't want to replace further therefore just return so that
    # a new textarea can be searched
    if {$alreadyreplaced} {
        # return here to avoid processing of the repeated match
        return "mustswitchnow_nomorematches"
    }

    # if search wrapped, tell the user when replacing items one by one only
    if {$wraparound && $replacesingle} {
        showinfo [mc "Wrapped around"]
    } else {
        delinfo
    }

    # arrange for this match to be visible, replace it, colorize it and tag it
    # note: there is no need to explicitely guard against modifications
    #       that could be made in binary files because the corresponding
    #       textareas have -state disabled, which prevents any modification
    #       of their contents while still not triggering any error when
    #       attempting things like $textarea insert $pos $newtext
    setmarksatmatchespositions $textarea
    set mepos [$textarea index "$mpos + $mlen char"]
    # show the end of match then the start of it to increase the
    # chances of seeing it entirely even in small areas in tile mode
    $textarea see $mepos
    $textarea see $mpos
    set sepflag [startatomicedit $textarea]
    set replacestr [compilespecialreplacechars $replacestr $tosearchfor [$textarea get $mpos $mepos] $reg]
    $textarea delete $mpos $mepos
    # the test on replacestr shouldn't be needed and is only here to
    # work around Tk bug 1275237 (still unfixed in Tk8.4.15 and Tk 8.5a6)
    if {$replacestr != ""} {
        $textarea insert $mpos $replacestr
    }
    endatomicedit $textarea $sepflag
    set uplimit [$textarea index "$mpos linestart"]
    set nbofslashn_r [regexp -all -- "\n" $replacestr]
    set dnlimit [$textarea index "$mpos + $nbofslashn_r l lineend"]
    set uplimit_cl [getstartofcolorization $textarea $mpos]
    set dnlimit_cl [getendofcolorization $textarea $dnlimit]
    colorize $textarea $uplimit $dnlimit $uplimit_cl $dnlimit_cl
    if {$replacesingle} {
        backgroundcolorizetasks
    }
    tagcontlines $textarea
    setunsavedmodifiedline $textarea $uplimit $dnlimit
    $textarea mark set insert $mpos
    foreach ta [filteroutpeers $listoftextarea] {
        # this must be done for each ta, not only for $textarea
        # because of the switch buffer case in tile mode
        # however since this is only playing with tags, there is
        # no need to do it for peers
        $ta tag remove curfoundtext 1.0 end
        $ta tag remove replacedtext 1.0 end
    }
    set lenR [string length $replacestr]
    $textarea tag add replacedtext $mpos  "$mpos + $lenR char"
    # if replacement occurred starting at the first selected character or
    # up to the last selected character, then fakeselection should be extended
    # by hand since tags have no gravity in Tcl - this is performed by using
    # the marks fakeselectionstart$i and fakeselectionstop$i which were placed,
    # with their adequate gravity, for exactly that purpose
    set allmarks [$textarea mark names]
    set fakeselectionstartmarks [lsearch -all -inline $allmarks fakeselectionstart*]
    set fakeselectionstopmarks  [lsearch -all -inline $allmarks fakeselectionstop*]
    foreach fssta $fakeselectionstartmarks fssto $fakeselectionstopmarks {
        $textarea tag add fakeselection $fssta $fssto
    }

    # tag the current match as now being replaced, and correct the
    # position of the matches in $listofmatch according to the
    # replacement that has just happened
    setcurmatchasreplaced $textarea

    # prevent the dialog box from hiding the match string
    MoveDialogIfTaggedTextHidden $w $textarea replacedtext

    # update status bar data
    if {$replacesingle} {
        keyposn $textarea
    }

    # update breakpoint tags
    reshape_bp

    # search for next match (i.e. prepare for next replace)
    findit $w $pw $mulfilcontext $textarea $tosearchfor \
           $cas $reg $sinsel $whword $tags $sdirec

    if {$looped} {
        set replres "bufferdone"
    } else {
        set replres "searchagain"
    }
    return $replres
}

proc replaceall {w pw mulfilcontext textarea searchstr tosearchfor cas reg sinsel whword tags replacestr} {
# find all matches in $textarea, and replace these matches
# input variables:
#   w pw mulfilcontext textarea searchstr tosearchfor cas reg sinsel whword tags: see proc findit
#   replacestr: see proc replaceit
# output result:
#   the number of replacements performed

    global listofmatch
    global listoffile
    global buffermodifiedsincelastsearch
    global pad
    global findreplaceboxalreadyopen

    set buffermodifiedsincelastsearch false

    set nbofreplaced 0

    # initialize progress bar
    # note that efficiency is maintained: $listofmatch is
    # computed here and only once (it won't be done later
    # in proc replaceit, even not during the first call)
    set replprogressbar [Progress $pad.rpb]
    pack $replprogressbar -fill both -expand 0 -before $pad.pw0 -side bottom
    set listofmatch [searchforallmatches $textarea $tosearchfor \
                         $cas $reg $sinsel $whword \
                         $tags]
    set nbofmatches [llength $listofmatch]
    if {$nbofmatches == 0} {
        # avoid division by zero error in the progress bar computations
        set nbofmatches 1
    }

    # loop on matches and update progress bar
    set prevfindres "searchagain"
    # the test on $findreplaceboxalreadyopen is to handle cancellation
    # of a long replace operation
    while {$prevfindres eq "searchagain" && $findreplaceboxalreadyopen} {
        set prevfindres [replaceit $w $pw $mulfilcontext $textarea $tosearchfor \
                                   $cas $reg $sinsel $whword $tags "forwards" $replacestr 0]
        SetProgress $replprogressbar $nbofreplaced $nbofmatches $listoffile("$textarea",displayedname)
        update
        incr nbofreplaced
    }
    incr nbofreplaced -1

    destroy $replprogressbar

    if {!$mulfilcontext} {
        showinfo "$nbofreplaced [mc "replacements done"]"
        if {$nbofreplaced == 0} {
            notfoundmessagebox $searchstr $textarea $pw "Replace"
        }
        # userfun and uservar colorization must be done here because replacement
        # might have changed a user function or variable - do it only once,
        # not after each single replacement of a replace all, even not
        # after each buffer in which replace all occurs (if $multiplefiles,
        # this is also called in proc multiplefilesreplaceall)
        backgroundcolorizetasks
        # update status bar data - do it once only, same as above
        keyposn $textarea
    }

    # erase listofmatch so that the next call to a find/replace command
    # will reconstruct it - needed if for instance the user hits find next
    # after a replace all: find next gets the next match regardless of its
    # "alreadyreplaced" status
    forgetlistofmatch

    return $nbofreplaced
}

proc searchforallmatches {textarea str cas reg ssel whword listoftags} {
# search for the matches in the provided $textarea for the string $str
# taking into account the case argument $cas, the regexp argument $reg
# and the "whole word" flag
# the search occurs in the selection if $ssel == 1, or in the full
# textarea otherwise
# block selection search is supported
# all matches are returned in a list, and always in the "forwards" order
# each element of the return list follows the format described in proc
# doonesearch
# an empty $matchlist return result means there is no match in $textarea 

    set matchlist {}

    foreach {start stop} [getsearchlimits $textarea $ssel] {

        set match [doonesearch $textarea $start $stop $str "forwards" $cas $reg $whword $listoftags]
        while {[lindex $match 0] != ""} {
            lappend matchlist $match
            set mleng [lindex $match 1]
            if {$mleng == 0} {
                # a match was found but its length is zero - can happen while
                # searching for a regexp, for instance ^ or \A
                # in that case, let's artificially set match length to 1 (only
                # in this loop) to avoid endless loop
                set mleng 1
            }
            set start [$textarea index "[lindex $match 0] + $mleng c"]
            # $ta search with $start == $stop == [$ta index end] wraps around
            # this is not wanted (and contrary to the Tcl man page for text)
            # this is Tk bug 1513517:
            # http://sourceforge.net/tracker/index.php?func=detail&aid=1513517&group_id=12997&atid=112997
            # once this bug is fixed, the three lines below can be removed
            # status: does not happen with Tk 8.5, closed as Wont Fix for Tk 8.4
            # due to no longer supported Tk version
            if {[$textarea compare $start == $stop]} {
                break
            }
            set match [doonesearch $textarea $start $stop $str "forwards" $cas $reg $whword $listoftags]
        }

    }

    return $matchlist
}

proc getsearchlimits {textarea ssel} {
# decide about the start and stop positions of a forwards search:
# if there is no selection, then start = 1.0 and stop = last char of
# $textarea, and return a 2-elements list with start and stop
# if there is a selection, then return [$textarea tag ranges fakeselection]
# block selection is therefore supported as well as single range selection
    if {!$ssel} {
        # there is no existing selection (or the user asked not to search
        # in selection)
        set sta 1.0
        set sto [$textarea index end]
        set selranges [list $sta $sto]
    } else {
        set selranges [$textarea tag ranges fakeselection]
    }
    return $selranges
}

proc doonesearch {textarea sta sto str dir cas reg whword listoftags} {
# perform one search operation in $textarea between start position $sta
# and stop position $sto, taking into account the case argument $cas,
# the regexp argument $reg, the direction $dir and the "whole word" flag
# the searched string is $str
# return value: a list containing:
#   if found:
#     the position of the match, the length of the match in character counts
#     and the number 0 (this flag is used by replaceit and is set to 1 when
#     the match has been replaced)
#   if not found:
#     the three elements "" 0 0
# note:
#   the match length is specific to each match and cannot be considered as
#   a constant for all the matches - for instance, regexp searching for
#   \m(\w)*\M (i.e. any word) can provide different match lengths
    global Tk85

    # create the options list
    set optlist [list $cas -$dir -count MatchLength]
    if {$reg == "regexp"} {
        lappend optlist -regexp
    }
    if {$Tk85} {
        # this option doesn't work as expected before Tk cvs of 10/10/05
        # see http://groups.google.fr/group/comp.lang.tcl/browse_thread/thread/e80f2586408ab598/2a3660c107cd21ba?lnk=raot&hl=fr#2a3660c107cd21ba
        # and Tk bug 1281228 - solved in the final 8.5 release
        lappend optlist -strictlimits
    }

    # [list ] around $str is mandatory to find strings that include spaces,
    # or strings containing characters that have a meaning in a Tcl string
    set MatchPos [ eval [concat "$textarea search $optlist --" [list $str] "$sta $sto" ] ]

    if {$MatchPos != ""} {
        # check if the match found satisfies the required constraints
        while {![arefindconstraintssatisfied $whword $listoftags $textarea $MatchPos $MatchLength]} {
            set sta [$textarea index "$MatchPos + $MatchLength c"]
            set MatchPos [ eval [concat "$textarea search $optlist --" [list $str] "$sta $sto" ] ]
            if {$MatchPos == ""} {
                # no match candidates left
                break
            }
        }
    }

    # if no match found, return zero length
    if {$MatchPos == ""} {
        set MatchLength 0
    }
    return [list $MatchPos $MatchLength 0]
}

proc arefindconstraintssatisfied {whword listoftags textarea MatchPos MatchLength} {
# check if some or all find constraints below are satisfied or not
# 1 - whole word
#     if $whword is true, then the whole word constraint is checked
# 2 - tagged text
#     if listoftags is non empty, then the tagged text constraint is checked
# return true or false

    set OK false

    if {!$whword} {
        # normal search mode (no whole word)

        if {[llength $listoftags] == 0} {
            # neither whole word, nor tagged text
            set OK true
        } else {
            # not whole word, but tagged text
            if {[istagged $textarea $MatchPos $MatchLength $listoftags]} {
                set OK true
            }
        }

    } else {
        # whole word search mode

        if {[llength $listoftags] == 0} {
            # whole word, but not tagged text
            if {[iswholeword $textarea $MatchPos $MatchLength]} {
                set OK true
            }
        } else {
            # whole word and tagged text
            if {[iswholeword $textarea $MatchPos $MatchLength] && \
                [istagged $textarea $MatchPos $MatchLength $listoftags]} {
                set OK true
            }
        }

    }

    return $OK
}

proc getcurrentmatch {textarea} {
# get current match position and length in an already existing (non empty) list
# of matches
# return value is a list:
#    { match_position match_length has_wrapped_flag has_looped_flag alreadyreplaced_flag}
#    has_wrapped_flag is always false
#    has_looped_flag is always false
    global listofmatch indoffirstmatch indofcurrentmatch
    set currentmatch [lindex $listofmatch $indofcurrentmatch]
    set curmatchpos [lindex $currentmatch 0]
    set curmatchlen [lindex $currentmatch 1]
    set haswrapped false
    set haslooped false
    set alreadyreplaced [lindex $currentmatch 2]
    return [list $curmatchpos $curmatchlen $haswrapped $haslooped $alreadyreplaced]
}

proc getnextmatch {textarea dir ssel} {
# get next match position and length in an already existing (non empty) list
# of matches. Only matches that are not yet tagged as already replaced ones
# are returned
# direction $dir of searching is taken into account, as well as the possibly
# existing selection ($ssel is 1 if there is a selection and the user asked
# for searching in it)
# return value is a list:
#    { match_position match_length has_wrapped_flag has_looped_flag alreadyreplaced_flag}
#    has_wrapped_flag is true if and only if to get the next match we had
#        to pass the end of the file or selection ("forwards" case), or the
#        beginning of the file or selection ("backwards" case)
#    has_looped_flag is true if and only if the entire list of matches has
#        been traversed. In this case $match_position is again the first
#        match position
#    alreadyreplaced_flag is 1 if and only if there is no more not yet
#        replaced matches in $listofmatch - in this case the other output
#        values should be ignored by the calling procedure

    foreach {mpos mlen alreadyreplaced wraparound looped} \
            [getnextmatchany $textarea $dir $ssel] {}

    set firstpos $mpos
    while {$alreadyreplaced} {
        foreach {mpos mlen alreadyreplaced wraparound looped} \
                [getnextmatchany $textarea $dir $ssel] {}
        if {$mpos == $firstpos} {
            break
        }
    }

    return [list $mpos $mlen $wraparound $looped $alreadyreplaced]
}

proc getnextmatchany {textarea dir ssel} {
# return the next match and ignores the alreadyreplaced tag value
# see proc getnextmatch for details
    global listofmatch indoffirstmatch indofcurrentmatch haswrappedbefore

    if {![info exists indoffirstmatch]} {
        # this is the first request for a match in the listofmatch

        # get the match located just after or before...
        if {!$ssel} {
            #... the insertion cursor if there is no selection
            set pos [$textarea index insert]
        } else {
            #... the selection (first range) start or (last range) end if
            # there is a selection
            if {$dir == "forwards"} {
                set pos [$textarea index fakeselection.first]
            } else {
                set pos [$textarea index fakeselection.last]
            }
        }

        set indoffirstmatch [getnexteltid $textarea $pos $listofmatch $dir]
        set haswrapped false
        set haswrappedbefore false

        if {$indoffirstmatch == [llength $listofmatch]} {
            set indoffirstmatch 0
            set haswrapped true
        }
        if {$indoffirstmatch == -1} {
            set indoffirstmatch [expr {[llength $listofmatch] - 1}]
            set haswrapped true
        }

        if {$haswrapped} {
            set haswrappedbefore true
        }

        set indofcurrentmatch $indoffirstmatch
        set haslooped false

    } else {
        # this is not the first request for a match in the listofmatch

        set haswrapped false
        if {$dir == "forwards"} {
            incr indofcurrentmatch
            if {$indofcurrentmatch == [llength $listofmatch]} {
                set indofcurrentmatch 0
                set haswrapped true
            }
        } else {
            incr indofcurrentmatch -1
            if {$indofcurrentmatch == -1} {
                set indofcurrentmatch [expr {[llength $listofmatch] - 1}]
                set haswrapped true
            }
        }

        set haslooped false
        if {$indofcurrentmatch == $indoffirstmatch} {
            set haslooped true
        }

        # haswrappedbefore is now used to set haslooped
        # the test on $indofcurrentmatch above is not enough when playing
        # with the Find Next button during a replace session
        if {$haswrappedbefore && $haswrapped} {
            set haslooped true
        }

        if {$haswrapped} {
            set haswrappedbefore true
        }

    }

    set currentmatch [lindex $listofmatch $indofcurrentmatch]
    set curmatchpos [lindex $currentmatch 0]
    set curmatchlen [lindex $currentmatch 1]
    set curmatchrep [lindex $currentmatch 2]
    return [list $curmatchpos $curmatchlen $curmatchrep $haswrapped $haslooped]
}

proc getnexteltid {textarea aval alist dir} {
# get the index in $alist of the element that comes after or before $aval
# (depending on the search direction $dir: respectively "forwards" and
# "backwards")
# comparison is performed with .text compare, i.e. as text widget indices
# $alist has the format described in proc searchforallmatches, it is already
# ordered by match position in forward order
# $aval does not need to be an element of $alist
    if {$dir == "forwards"} {
        set id 0
        set lval [lindex [lindex $alist $id] 0]
        set compres [$textarea compare $aval >= $lval]
        while {$compres == 1 && $id < [expr {[llength $alist] - 1}]} {
            incr id
            set lval [lindex [lindex $alist $id] 0]
            set compres [$textarea compare $aval >= $lval]
        }
        if {$compres == 0} {
            return $id
        } else {
            # for all the elements of $alist, $aval >= $lval is wrong
            return [expr {$id + 1}] ; # i.e. [llength $alist]
        }
    } else {
        set id [expr {[llength $alist] - 1}]
        set lval [lindex [lindex $alist $id] 0]
        set compres [$textarea compare $aval <= $lval]
        while {$compres == 1 && $id > 0} {
            incr id -1
            set lval [lindex [lindex $alist $id] 0]
            set compres [$textarea compare $aval <= $lval]
        }
        if {$compres == 0} {
            return $id
        } else {
            # for all the elements of $alist, $aval <= $lval is wrong
            return [expr {$id - 1}] ; # i.e. -1
        }
    }
}

proc setmarksatmatchespositions {ta} {
# set a mark at each position of $ta listed in $listofmatch
# these marks are used (and removed) in proc setcurmatchasreplaced
    global listofmatch
    set i 1
    foreach amatch $listofmatch {
        set amatchpos [lindex $amatch 0]
        $ta mark set tmpmatchmark$i $amatchpos
        $ta mark gravity tmpmatchmark$i right
        incr i
    }
}

proc setcurmatchasreplaced {ta} {
# tag the current match as now being replaced, and correct the
# position of the matches in $listofmatch according to the
# replacement that has just happened
    global listofmatch indofcurrentmatch

    # tag the current match as a replaced match

    set curmatch [lindex $listofmatch $indofcurrentmatch]
    set curmatch [lreplace $curmatch 2 2 1]
    set listofmatch [lreplace $listofmatch $indofcurrentmatch $indofcurrentmatch $curmatch]

    # adjust position of the matches in $listofmatches

    set allmarks [$ta mark names]
    set tmpmatchmarks [lsearch -all -inline $allmarks tmpmatchmark*]
    set tmpmatchmarks [lsort -dictionary $tmpmatchmarks]
    set i 0
    foreach atmpmatchmark $tmpmatchmarks amatch $listofmatch {
        set markind [$ta index $atmpmatchmark]
        set amatchind [lindex $amatch 0]
        if {[$ta compare $markind != $amatchind]} {
            set adjustedamatch [lreplace $amatch 0 0 $markind]
            set listofmatch [lreplace $listofmatch $i $i $adjustedamatch]
        }
        incr i
        $ta mark unset $atmpmatchmark
    }
}

proc forgetlistofmatch {} {
# reset the find/replace settings to their initial default values
# so that the next find or replace will scan the buffer(s) again
# and create a new list of matches
    global listofmatch indoffirstmatch indofcurrentmatch
    # reset the search data
    unset -nocomplain -- listofmatch
    unset -nocomplain -- indoffirstmatch
    unset -nocomplain -- indofcurrentmatch
}

proc iswholeword {textarea mpos mlen} {
# return true if the match given in argument is a "whole word", i.e.
# if the character before it and the character after it is a blank
# character (space or tab), or a newline, or beginning or end of the text

    set OKleft 0
    set OKright 0

    # the pattern against which the match will be checked for its
    # wholewordness is a basic one that is probably what the user means
    # when asking for "whole word" search: delimiters are any blanks
    # and that's it!
    # this pattern is quite different from the ones used for selection
    # through double-clicking (which are additionally language scheme
    # dependent), which are represented by regular expressions stored
    # in $tcl_wordchars and $tcl_nonwordchars (see details for instance
    # in proc updatedoubleclickscheme)
    set pat "\[ \n\t\]"

    set prevc [$textarea index "$mpos - 1 c"]
    set nextc [$textarea index "$mpos + $mlen c"]

    # check if the match starts at the first character of the textarea
    if {[$textarea compare $prevc == $mpos]} {
        set OKleft 1
    }

    # check if the match ends just before the last character of the
    # textarea (which is always a \n located at index $ta index end)
    # this is in fact not needed because when the match ends just
    # before the final \n then the test below checking if the character
    # after the match is of the right class will be successful,
    # therefore setting OKright to 1 correctly
    # this is however dependent on $pat including "\n" in its value,
    # therefore keep this check for good
    if {[$textarea compare $nextc == [$textarea index "end - 1 c"]]} {
        set OKright 1
    }

    # check previous character against "whole word" boundaries class
    if {[string match $pat [$textarea get $prevc]]} {
        set OKleft 1
    }

    # check next character against "whole word" boundaries class
    if {[string match $pat [$textarea get $nextc]]} {
        set OKright 1
    }

    if {$OKleft && $OKright} {
        return 1
    } else {
        return 0
    }
}

proc istagged {textarea MatchPos MatchLength listoftags} {
# check if the match found is correctly and entirely tagged as expected, i.e.
# that each character of the match is tagged by at least one element of
# $listoftags
# return true or false
# if $listoftags is an empty list, always return true

    # make the check quicker when not searching for tagged text
    if {[llength $listoftags] == 0} {
        return true
    }

    set OK true
    set i 0
    while {$i<$MatchLength} {
        set pos [$textarea index "$MatchPos + $i c"]
        set tagsatpos [$textarea tag names $pos]
        # look at the intersection of the two lists of tags
        set emptyintersect true
        foreach tag $tagsatpos {
            if {[lsearch -exact $listoftags $tag] != -1} {
                set emptyintersect false
                # as soon as the intersection is not void, it's enough to
                # know that the current character of the match is OK and
                # there is no need to compute the entire intersection set
                break
            }
        }
        if {$emptyintersect} {
            set OK false
            # no need to check the remaining characters of the match
            break
        }
        incr i
    }

    return $OK
}

proc MoveDialogIfTaggedTextHidden {w textarea tagname} {
# this proc checks whether the intersection between a dialog and a rectangular
# area of text is empty or not
# if the intersection is empty, it does nothing
# otherwise it moves the dialog in such a way that it does not hide the tagged
# text anymore
# the dialog is identified by its pathname $w
# the text area is identified by its textarea name and a tag name, and this tag
# *must* extend onto a single line - this is currently not a problem because this
# proc is called with either $tagname == curfoundtext or $tagname == replacedtext,
# and, at least with Tk 8.4 find/replace does not cross newlines for matching -
# warning: this will change with Tk 8.5
# it is assumed that only one contiguous portion of text is tagged with $tagname
# if no character in $textarea is tagged by $tagname, then the text span
# considered defaults to the insertion cursor location
    global pad textFont

    # coordinates of the _d_ialog - left, right, top, bottom - screen coordinate system
    foreach {ww wh wdl wdt} [totalGeometry $w] {}
    set ld $wdl
    set rd [expr {$wdl + $ww}]
    set td $wdt
    set bd [expr {$wdt + $wh}]

    # get _t_agged text area coordinates relative to the $textarea coordinate system
    if {[catch {set taggedlcoord [$textarea dlineinfo $tagname.first]} ]} {
        set taggedlcoord [$textarea dlineinfo insert]
    }
    foreach {taggedtextpos taggedtextend} [$textarea tag ranges $tagname] {}
    if {![info exists taggedtextpos]} {
        set taggedtextpos [$textarea index insert]
        set taggedtextend $taggedtextpos
    }
    scan $taggedtextpos "%d.%d" ypos xpos
    set taggedtext  [$textarea get $taggedtextpos $taggedtextend]
    set startofline [$textarea get $ypos.0 $taggedtextpos]
    set taggedtextwidth  [font measure $textFont $taggedtext]
    set startoflinewidth [font measure $textFont $startofline]
    set lineheight [lindex $taggedlcoord 3]
    set lt1 [expr {[lindex $taggedlcoord 0] + $startoflinewidth}]
    set rt1 [expr {$lt1 + $taggedtextwidth}]
    set tt1 [lindex $taggedlcoord 1]
    set bt1 [expr {$tt1 + $lineheight}]

    # convert tagged text coordinates into screen coordinate system
    set lta [winfo rootx $textarea]
    set tta [winfo rooty $textarea]
    set lt [expr {$lt1 + $lta}]
    set rt [expr {$rt1 + $lta}]
    set tt [expr {$tt1 + $tta}]
    set bt [expr {$bt1 + $tta}]

    # check if the dialog overlaps the tagged text (intersection of two rectangles)
    if { ! ( ($ld > $rt) || ($lt > $rd) || ($td > $bt) || ($tt > $bd) ) } {
        # the two rectangles intersect, move the dialog
        set newx [expr {$ld - ($rd - $ld)}]
        if {$newx < 1} {
            set newx [expr {[winfo screenwidth $w] - ($rd - $ld)}]
        }
        set newy [expr {$td - ($bd - $td)}]
        if {$newy < 1} {
            set newy [expr {[winfo screenheight $w] - ($bd - $td)}]
        }
        wm geometry $w "+$newx+$newy"
    }
}

proc highlightallnotreplacedmatches {textarea listofmatches} {
# $listofmatches being a result of proc searchforallmatches
# (either a list of results from proc doonesearch, or the empty list),
# highlight all the search results in $textarea that were not yet
# replaced

    $textarea tag remove anyfoundtext 1.0 end

    foreach amatch $listofmatches {
        set alreadyreplaced [lindex $amatch 2]
        if {!$alreadyreplaced} {
            set pos [lindex $amatch 0]
            set len [lindex $amatch 1]
            $textarea tag add anyfoundtext $pos "$pos + $len c"
        }
    }
}

proc removeallfindreplacetags {} {
# remove any tag related to find/replace from all buffers
    global listoftextarea
    foreach textarea [filteroutpeers $listoftextarea] {
        $textarea tag remove anyfoundtext 1.0 end
        $textarea tag remove curfoundtext 1.0 end
        $textarea tag remove replacedtext 1.0 end
    }
}

proc compilespecialreplacechars {replstr searchstr matchingtext regexpsearch} {
# for regexp replacements, manage the "n'th parenthesized subexpression"
# case (see help regsub)
# in addition, regexp or standard replacements, replace escaped characters
# in $replstr by their actually corresponding characters, e.g. the 2-letter
# substring \n is replaced by a single newline character
# test cases:
#   standard replacement, with special characters \n and \t:
#       compilespecialreplacechars {ab\ncd\n\nfgh\t\tij\k} "" "" "standard"
#               --> returns:  "ab
#                              cd
#
#                              fgh		ij\k"
#   regexp replacement, with n'th parenthesized subexpression substitution:
#       compilespecialreplacechars {\1ico is better} {tex(mex) I like} "texmex I like" "regexp"
#               --> returns:  "mexico is better"
#       compilespecialreplacechars {\1 \3 \2} {a(b(cd)e(f)g)h} "abcdefgh" "regexp"
#               --> returns:  "bcdefg f cd"
#   both at the same time:
#       compilespecialreplacechars {Wow!\n\1ico is\t\tbetter} {tex(mex) I like} "texmex I like" "regexp"
#               --> returns:  "Wow!
#                              mexico is		better"

    global specialreplchars
    if {$specialreplchars} {
        if {$regexpsearch eq "regexp"} {
            set replstr [regsub -all -- $searchstr $matchingtext $replstr]
        }
        # at this point there is no longer any \1, \2 ... in $replstr
        # except in case these are vanilla strings to use for replace
        # in the standard i.e. non-regexp case
        # in this case however they shall not be substituted
        foreach {pat droppedname} [regexpsforreplace] {
            if {![string match {\\[0-9]} $pat]} {
                set key $pat
                set value [subst -nocommands -novariables $pat]
                set replstr [string map [list $key $value] $replstr]
            }
        }
    }
    return $replstr
}
