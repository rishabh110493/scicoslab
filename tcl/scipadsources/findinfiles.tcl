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

proc findinfiles {tosearchfor cas reg whword initdir globpat recursesearchindir searchforfilesonly} {
# search in the selected directory, in all the files that match
# the selected pattern, taking into account all the possible options (case
# type, regexp/standard, whole word, recurse search)
# if $searchforfilesonly is true, then files themselves are searched wrt
# to matching the glob pattern
    global searchinfo pausesearchflag cancelsearchflag
    global openerrorfiles readerrorfiles searchinfilesalreadyrunning
    global nbsearchedfiles
	global globalsearchID findresultsinnewwindow matchres
    global pad

    set searchinfilesalreadyrunning 1

    if {![info exists globalsearchID]} {
        set globalsearchID 1
    } else {
        if {$findresultsinnewwindow} {
            incr globalsearchID
        } else {
            # re-use the most recent match results window, if there is
            # one still open: find the highest globalsearchID value
            # such that the corresponding window is still open
            for {set i $globalsearchID} {$i >= 1} {incr i -1} {
                if {[winfo exists $matchres($i)]} {
                    set globalsearchID $i
                    break
                }
            }
            # if no such window exists, we're here with an unmodified
            # $globalsearchID which is just fine
        }
    }
    set searchID $globalsearchID

    # create a toplevel window where the matches will be displayed
    displaymatchresultswin $searchID
    setstateofsearchresultsbuttons_init $searchID
    set pausesearchflag($searchID) 0
    set cancelsearchflag($searchID) 0
    set nbsearchedfiles($searchID) 0
    update

    # expand SCI or SCIHOME, if present
    # note that ~ (shortcut for the user home directory) is supported directly
    # with no specific code in Scipad to handle it, and that this is true on
    # both Linux and Windows
    set initdir [expandSCI $initdir]

    # create the list of files to search in
    if {![direxists $initdir]} {
        tk_messageBox -title [mc "Directory access issue"] -icon warning -parent $pad \
            -message [mc "The directory you specified cannot be reached. The search won't bring any result."]
    }
    set openerrorfiles($searchID) {}
    set readerrorfiles($searchID) {}
    set filenames [getallfilenames $searchID $initdir $globpat $recursesearchindir]

    if {!$cancelsearchflag($searchID)} {
        # Scipad has not been closed during filenames list creation
        set searchinfo($searchID,allthematches) {}
        set searchinfo($searchID,tosearchfor) $tosearchfor
        set searchinfo($searchID,cas) $cas 
        set searchinfo($searchID,reg) $reg
        set searchinfo($searchID,whword) $whword
        setstateofsearchresultsbuttons_searchinprogress $searchID
        if {!$searchforfilesonly} {
            # search for matches in each file
            foreach filename $filenames {
                updatematchrestitle $searchID [concat [mc "Searching in file:"] "$filename"]
                # findinonefile will populate $searchinfo($searchID,allthematches)
                findinonefile $searchID $filename $tosearchfor $cas $reg $whword
                if {$cancelsearchflag($searchID)} {break}
                if {$pausesearchflag($searchID)} {tkwait variable pausesearchflag($searchID)}
            }
        } else {
            # search for files themselves - display the matched files
            foreach filename $filenames {
                updatematchrestitle $searchID [concat [mc "Searching in file:"] "$filename"]
                lappend searchinfo($searchID,allthematches) [constructfilematchresult $searchID $filename]
                update
                if {$cancelsearchflag($searchID)} {break}
                if {$pausesearchflag($searchID)} {tkwait variable pausesearchflag($searchID)}
            }
        }
        if {!$searchforfilesonly} {
            updatematchrestitle $searchID [concat [mc "End of file search:"] [llength $searchinfo($searchID,allthematches)] [mc "matches found"] "-" $nbsearchedfiles($searchID) [mc "searched files"]]
        } else {
            updatematchrestitle $searchID [concat [mc "End of file search:"] [llength $searchinfo($searchID,allthematches)] [mc "matches found"]]
        }
        if {$openerrorfiles($searchID) != {}} {
            set nlopenerrorfiles ""
            foreach fil $openerrorfiles($searchID) {
                set nlopenerrorfiles "$nlopenerrorfiles$fil\n"
            }
            tk_messageBox -message [concat \
                [mc "Some directories or files could not be open and were ignored during search.\n\
                     You might miss read access to them, or this is a race condition.\n\n\
                     The following ones were ignored"] ":\n\n$nlopenerrorfiles"] \
                -icon warning -title [mc "Ignored files"] -type ok -parent $pad
        }
        if {$readerrorfiles($searchID) != {}} {
            set nlreaderrorfiles ""
            foreach {fil lin errmsg} $readerrorfiles($searchID) {
                set nlreaderrorfiles "$nlreaderrorfiles$fil"
                append nlreaderrorfiles " (" [mc "was only read up to line"] " " $lin " - " $errmsg ")\n"
            }
            tk_messageBox -message [concat \
                [mc "Scipad experienced problems while searching in some files.\n\
                     Usually this is due to files suddenly vanishing due to a race condition.\n\n\
                     Affected files were"] ":\n\n$nlreaderrorfiles"] \
                -icon warning -title [mc "Access error while reading"] -type ok -parent $pad
        }
    }
    setstateofsearchresultsbuttons_searchfinished $searchID
    set searchinfilesalreadyrunning 0
}

proc getallfilenames {searchID initdir globpat recursesearch} {
# return all the file names matching $globpat in directory $initdir
    global pausesearchflag cancelsearchflag
    global searchhiddenfiles openerrorfiles

    set fnames {}

    # convert path separators to forward slashes - avoids glob side effects
    set initdir [file normalize $initdir]

    updatematchrestitle $searchID [concat [mc "Constructing file list:"] "$initdir"]

    # deal with files first
    foreach gp $globpat {
        set filematches [list ]
        if {[catch {glob -nocomplain -directory "$initdir" -types {f} -- "$gp"} filematches] != 0} {
            lappend openerrorfiles($searchID) [file join "$initdir" "$gp"]
            continue
        } else {
            if {$searchhiddenfiles} {
                # no need to check again for read access rights (by catching)
                # this was done before when searching for non hidden files
                set hiddenfilematches [glob -nocomplain -directory "$initdir" -types {f hidden} -- "$gp"]
                foreach ahiddenfile $hiddenfilematches {
                    lappend filematches $ahiddenfile
                }
            }
        }
        if {$filematches != {}} {
            # avoid duplicates (can happen for instance when $globpat is "* *.*")
            foreach fil $filematches {
                if {[lsearch -exact $fnames $fil] == -1} {
                    lappend fnames $fil
                }
            }
        }
    }

    # now deal with directories and the recurse case
    if {$recursesearch} {
        # keep the GUI responsive
        # (for cancel button, but also for all the Scipad functions)
        update
        set dirmatches [list ]
        if {[catch {glob -nocomplain -directory "$initdir" -types {d} -- "*"} dirmatches] != 0} {
            lappend openerrorfiles($searchID) [file join "$initdir" "*"]
        } else {
            if {$dirmatches != {}} {
                foreach adir $dirmatches {
                    eval lappend fnames [getallfilenames $searchID $adir $globpat $recursesearch]
                    if {$cancelsearchflag($searchID)} {break}
                    if {$pausesearchflag($searchID)} {tkwait variable pausesearchflag($searchID)}
                }
            }
        }
    }
    return $fnames
}

proc findinonefile {searchID fname str cas reg whword} {
# find the string $str in file $fname (which must exist), and return
# match results
# to take advantage of the procs related to find/replace in opened buffers,
# a temporary text widget is created in the background, but not displayed.
# this text widget contains one line at a time of the file into which the
# search is performed. this allows to search into huge files without loading
# them first entirely in memory, at the expense of a slight performance
# slowdown
# each match is displayed in a search results window
# there is no return value: the result of the search is to append matches
#   to the global variable searchinfo($searchID,allthematches)
#   this way of providing the results with no return value is intentional:
#   it allows to use the Next/Previous buttons of the match results window
#   during the search, for any match as soon as it is found
#   this results window is populated with textual results in the present
#   proc findinonefile. If this proc would return the matches in the searched
#   file at once at the end of the search, then there would be a period of
#   time (especially for large files) during which clicking on the bottom
#   matches in the results window would link to nowhere since interpretation
#   of the click does not parse the text in the match results window, but
#   use the contents of $searchinfo($searchID,allthematches)
#   another approach would have been to properly return a list of matches
#   and populate both the results window and $searchinfo($searchID,allthematches)
#   at the caller level and at the same time (which really is the point),
#   but this would have deferred visualization of matches in a file to
#   the end of the search in that file, which is not desirable

    global pad matchres pausesearchflag cancelsearchflag
    global openerrorfiles readerrorfiles
    global nbsearchedfiles searchinfo

    # open file
    if {[catch {open $fname r} fid] != 0} {
        # error on opening the file, maybe because it was erased
        # since the file list was built (race condition), or due
        # to lack of read permissions
        lappend openerrorfiles($searchID) $fname
        return
    }

    # the number of searched files is increased every time the opening
    # succeeded, because $nbsearchedfiles is potentially different from
    # [llength [getallfilenames]]
    incr nbsearchedfiles($searchID)

    # create a temporary text widget
    text $pad.fake$searchID

    set linenumber 0

    # read first line - check that the file can still be reached since when
    # the file list was built
    if {[catch {gets $fid line} nbcharread] != 0} {
        # race condition triggered: the file became out of reach since
        # Scipad built the file list - perhaps erased by another process
        # in this case $nbcharread contains the error message
        lappend readerrorfiles($searchID) $fname [expr {$linenumber + 1}] $nbcharread
        # $pad.fake$searchID must not already exist when reading next file
        # this is catched because of possible Scipad closure during search,
        # in which case $pad.fake$searchID may have already been destroyed
        catch {destroy $pad.fake$searchID}
        return
    } else {
        # loop on file lines and search for matches on each single line
        while {$nbcharread >= 0} {
            $pad.fake$searchID insert 1.0 $line
            set listoflinematch [searchforallmatches $pad.fake$searchID $str $cas $reg 0 $whword [list ]]
            incr linenumber
            foreach amatch $listoflinematch {
                scan [lindex $amatch 0] "%d.%d" ypos xpos
                set pos "[expr {$ypos + $linenumber - 1}].$xpos"
                set len [lindex $amatch 1]
                set zero [lindex $amatch 2]
                lappend searchinfo($searchID,allthematches) [list $fname $pos $len $zero]
                $matchres($searchID).f1.resarea configure -state normal
                set prependedtext "$fname\($linenumber\):"
                $matchres($searchID).f1.resarea insert end "$prependedtext$line\n"
                $matchres($searchID).f1.resarea configure -state disabled
                # highlight the position of the match in the line
                scan [$matchres($searchID).f1.resarea index end] "%d.%d" lastline junk
                incr lastline -2
                incr xpos [string length "$prependedtext"]
                $matchres($searchID).f1.resarea tag add anyfoundtext "$lastline.$xpos" "$lastline.[expr {$xpos + $len}]"
            }
            $pad.fake$searchID delete 1.0 end
            # let the user see the progress, and keep the GUI responsive
            # (for cancel button, but also for all the Scipad functions)
            update
            if {$cancelsearchflag($searchID)} {break}
            if {$pausesearchflag($searchID)} {tkwait variable pausesearchflag($searchID)}
            if {[catch {gets $fid line} nbcharread] != 0} {
                # race condition triggered: the file became out of reach while
                # Scipad was reading it - perhaps erased by another process
                # in this case $nbcharread contains the error message
                lappend readerrorfiles($searchID) $fname [expr {$linenumber + 1}] $nbcharread
                # $pad.fake$searchID must not already exist when reading next file
                # this is catched because of possible Scipad closure during search,
                # in which case $pad.fake$searchID may have already been destroyed
                catch {destroy $pad.fake$searchID}
                return
            }
        }
    }

    # do the cleaning
    close $fid
    # catched because might already be destroyed when the user
    # closes Scipad during a search in files
    catch {destroy $pad.fake$searchID}

    return
}

proc constructfilematchresult {searchID fname} {
# output is a match, i.e. a list of 4 elements:
#    - the full file name that matched the glob pattern
#    - 1.0 (index of first character in file)
#    - 0 (length of the match - to fool the display match procs)
#    - 0 (match not yet replaced - not used for find in files)
# each match is displayed in a search results window
    global pad matchres
    set pos "1.0"
    set len 0
    set zero 0
    set filematchlist [list $fname $pos $len $zero]
    $matchres($searchID).f1.resarea configure -state normal
    $matchres($searchID).f1.resarea insert end "$fname\n"
    $matchres($searchID).f1.resarea configure -state disabled
    return $filematchlist
}

proc pauseresumesearchinfiles {searchID} {
# set a flag used to pause search in files
    global pausesearchflag matchres
    if {!$pausesearchflag($searchID)} {
        set pausesearchflag($searchID) 1
        $matchres($searchID).f2.buttonPause configure -relief sunken
    } else {
        set pausesearchflag($searchID) 0
        $matchres($searchID).f2.buttonPause configure -relief raised
    }
}

proc cancelsearchinfiles {searchID} {
# set a flag used to cancel search in files
    global cancelsearchflag pausesearchflag
    set cancelsearchflag($searchID) 1
    # if cancel is pressed while in pause mode, resuming search
    # will make cancel be executed immediately
    if {[info exists pausesearchflag($searchID)]} {
        if {$pausesearchflag($searchID)} {
            pauseresumesearchinfiles $searchID
        }
    } else {
        # proc cancelsearchinfiles has been called without having previously
        # searched in files, which happens for instance when Scipad is exited
        # in this case, there is nothing more to do here
    }
}

proc displaymatchresultswin {searchID} {
# show the match results window, or just clean it if already open
    global pad matchres textFont menuFont
    global SELCOLOR FGCOLOR BGCOLOR CURFOUNDTEXTCOLOR ANYFOUNDTEXTCOLOR
    global Tk85

    set matchres($searchID) $pad.matchres$searchID

    if {[winfo exists $matchres($searchID)]} {
        raise $matchres($searchID)
        $matchres($searchID).f1.resarea configure -state normal
        $matchres($searchID).f1.resarea delete 1.0 end
        $matchres($searchID).f1.resarea configure -state disabled

    } else {
        catch {destroy $matchres($searchID)}
        toplevel $matchres($searchID)
        wm withdraw $matchres($searchID)
        setscipadicon $matchres($searchID)
        updatematchrestitle $searchID ""
        # prevent from closing using the upper right cross
        wm protocol $matchres($searchID) WM_DELETE_WINDOW {#}
        wm resizable $matchres($searchID) 1 1
 
        # this is for the text results area and the scrollbars
        frame $matchres($searchID).f1

        # results area
        text $matchres($searchID).f1.resarea -wrap none -exportselection 0 -font $textFont \
                -fg $FGCOLOR -bg $BGCOLOR -selectbackground $SELCOLOR 
        $matchres($searchID).f1.resarea configure -state disabled

        # scrollbars association with the results area
        scrollbar $matchres($searchID).f1.yscroll -command "$matchres($searchID).f1.resarea yview" \
            -takefocus 0
        scrollbar $matchres($searchID).f1.xscroll -command "$matchres($searchID).f1.resarea xview" \
            -takefocus 0 -orient horizontal
        pack $matchres($searchID).f1.yscroll -side right  -expand 0 -fill y
        pack $matchres($searchID).f1.xscroll -side bottom -expand 0 -fill x
        pack $matchres($searchID).f1.resarea -side left   -expand 1 -fill both
        $matchres($searchID).f1.resarea configure -xscrollcommand "$matchres($searchID).f1.xscroll set"
        $matchres($searchID).f1.resarea configure -yscrollcommand "$matchres($searchID).f1.yscroll set"
        $matchres($searchID).f1.xscroll set [lindex [$matchres($searchID).f1.resarea xview] 0] [lindex [$matchres($searchID).f1.resarea xview] 1]
        $matchres($searchID).f1.yscroll set [lindex [$matchres($searchID).f1.resarea yview] 0] [lindex [$matchres($searchID).f1.resarea yview] 1]

        # command buttons
        frame $matchres($searchID).f2
        eval "button $matchres($searchID).f2.buttonPrev [bl "&Previous"] \
            -command \"openprevmatch $searchID $matchres($searchID).f1.resarea\" \
            -font \[list $menuFont\] "
        eval "button $matchres($searchID).f2.buttonNext [bl "&Next"] \
            -command \"opennextmatch $searchID $matchres($searchID).f1.resarea\" \
            -font \[list $menuFont\] "
        eval "button $matchres($searchID).f2.buttonOpenallfiles [bl "&Open all matching files"] \
            -command \"openallmatchingfiles $searchID\" \
            -font \[list $menuFont\] "
        eval "button $matchres($searchID).f2.buttonPause [bl "Pau&se"] \
            -command \"pauseresumesearchinfiles $searchID\" \
            -font \[list $menuFont\] "
        eval "button $matchres($searchID).f2.buttonCancel [bl "Cance&l"] \
            -command \"cancelsearchinfiles $searchID\" \
            -font \[list $menuFont\] "
        eval "button $matchres($searchID).f2.buttonClose [bl "&Close"] \
            -command \"destroy $matchres($searchID)\" \
            -font \[list $menuFont\] "
        grid $matchres($searchID).f2.buttonPrev         -row 0 -column 0 -sticky we -padx 20
        grid $matchres($searchID).f2.buttonNext         -row 0 -column 1 -sticky we -padx 20
        grid $matchres($searchID).f2.buttonOpenallfiles -row 0 -column 2 -sticky we -padx 20
        grid $matchres($searchID).f2.buttonPause        -row 0 -column 3 -sticky we -padx 20
        grid $matchres($searchID).f2.buttonCancel       -row 0 -column 4 -sticky we -padx 20
        grid $matchres($searchID).f2.buttonClose        -row 0 -column 5 -sticky we -padx 20
        grid columnconfigure $matchres($searchID).f2 0 -uniform 1
        grid columnconfigure $matchres($searchID).f2 1 -uniform 1
        grid columnconfigure $matchres($searchID).f2 2 -uniform 1
        grid columnconfigure $matchres($searchID).f2 3 -uniform 1
        grid columnconfigure $matchres($searchID).f2 4 -uniform 1
        grid columnconfigure $matchres($searchID).f2 5 -uniform 1
        if {$Tk85} {
            grid anchor $matchres($searchID).f2 center
        }

        # make all this visible (order matters wrt to clipping on external resizing)
        pack $matchres($searchID).f2 -side bottom -expand 0 -fill x
        pack $matchres($searchID).f1 -side top -expand 1 -fill both

        # buttons bindings
        bind $matchres($searchID) <Alt-[fb $matchres($searchID).f2.buttonPrev]>         "openprevmatch $searchID $matchres($searchID).f1.resarea"
        bind $matchres($searchID) <Alt-[fb $matchres($searchID).f2.buttonNext]>         "opennextmatch $searchID $matchres($searchID).f1.resarea"
        bind $matchres($searchID) <Alt-[fb $matchres($searchID).f2.buttonOpenallfiles]> "openallmatchingfiles $searchID"
        bind $matchres($searchID) <Alt-[fb $matchres($searchID).f2.buttonPause]>        "pauseresumesearchinfiles $searchID"
        bind $matchres($searchID) <Alt-[fb $matchres($searchID).f2.buttonCancel]>       "cancelsearchinfiles $searchID"
        bind $matchres($searchID) <Alt-[fb $matchres($searchID).f2.buttonClose]>        "after 0 destroy $matchres($searchID)"

        # define the behaviour of the results area
        $matchres($searchID).f1.resarea tag configure curfoundtext -background $CURFOUNDTEXTCOLOR
        $matchres($searchID).f1.resarea tag configure anyfoundtext -background $ANYFOUNDTEXTCOLOR
        $matchres($searchID).f1.resarea tag raise curfoundtext anyfoundtext
        bind $matchres($searchID).f1.resarea <Double-Button-1>                          "openpointedmatch $searchID %W %x %y ; break"
        bind $matchres($searchID).f1.resarea <<Modified>> {break}
        bind $matchres($searchID).f1.resarea <Control-c>                                "copytextfrommatchreswin %W"

        # prevent unwanted Text class bindings from triggering
        bind $matchres($searchID).f1.resarea <Button-3> {break}
        bind $matchres($searchID).f1.resarea <Shift-Button-3> {break}
        bind $matchres($searchID).f1.resarea <Control-Button-3> {break}
        bind $matchres($searchID).f1.resarea <ButtonRelease-2> {break}

        wm deiconify $matchres($searchID)

        # place the results window on screen, taking window decoration into
        # account so as to prevent the window from leaking on the neighbour
        # screen
        set myx 0
        set myw [winfo screenwidth $pad]
        set myh [expr {[winfo screenheight $pad] / 5}]
        set myy [expr {[winfo screenheight $pad] * 2/3}]
        wm geometry $matchres($searchID) "=$myw\x$myh+$myx+$myy"
        update
        wm geometry $matchres($searchID) [totalGeometryInv $matchres($searchID) $myw $myh $myx $myy]
    }
}

proc setstateofsearchresultsbuttons_init {searchID} {
# disable buttons of the search results window
# (used during the step where the list of files to search in is built)
    global matchres
    $matchres($searchID).f2.buttonClose        configure -state disabled
    $matchres($searchID).f2.buttonPause        configure -state normal
    $matchres($searchID).f2.buttonCancel       configure -state normal
    $matchres($searchID).f2.buttonOpenallfiles configure -state disabled
}

proc setstateofsearchresultsbuttons_searchinprogress {searchID} {
# disable buttons of the search results window
# (used during search)
    global matchres
    $matchres($searchID).f2.buttonClose        configure -state disabled
    $matchres($searchID).f2.buttonPause        configure -state normal
    $matchres($searchID).f2.buttonCancel       configure -state normal
    $matchres($searchID).f2.buttonOpenallfiles configure -state normal
}

proc setstateofsearchresultsbuttons_searchfinished {searchID} {
# re-enable buttons of the search results window
# (used after search end or cancel)
    global matchres
    if {[winfo exists $matchres($searchID)]} {
        $matchres($searchID).f2.buttonClose        configure -state normal
        $matchres($searchID).f2.buttonPause        configure -state disabled
        $matchres($searchID).f2.buttonCancel       configure -state disabled
        $matchres($searchID).f2.buttonOpenallfiles configure -state normal
    } else {
        # scipad has been closed during a search in files
        # there is nothing to do
    }
}

proc updatematchrestitle {searchID tit} {
# change the title of the match results window to $tit preceded by
# the translation of "Scipad search results ($searchID)" in the current locale
    global matchres
    if {[winfo exists $matchres($searchID)]} {
        wm title $matchres($searchID) "[mc "Scipad search results"] ($searchID) - $tit"
    } else {
        # scipad has been closed during a search in files
        # there is nothing to do
    }
}

proc openpointedmatch {searchID w x y} {
# display the match that was found in a file
# the match is selected by mouse click
    set posinresarea [$w index "@$x,$y"]
    # double-clicking on the last (empty) line is ignored
    if {[$w compare $posinresarea != [$w index "end-1c"]]} {
        openamatch $searchID $w $posinresarea
    }
}

proc opennextmatch {searchID w} {
# display the match that was found in a file
# the match is selected by button next
    set curmatch [$w tag nextrange curfoundtext 1.0]
    if {$curmatch == ""} {
        set ypos 0
    } else {
        scan $curmatch "%d.%d" ypos xpos
    }
    set posinresarea "[expr {$ypos + 1}].0"
    if {$posinresarea == [$w index "end - 1l linestart"]} {
        set posinresarea 1.0
    }
    if {[$w get $posinresarea] != "\n"} {
        openamatch $searchID $w $posinresarea
    }
}

proc openprevmatch {searchID w} {
# display the match that was found in a file
# the match is selected by button previous
    set curmatch [$w tag nextrange curfoundtext 1.0]
    if {$curmatch == ""} {
        set ypos 1
    } else {
        scan $curmatch "%d.%d" ypos xpos
    }
    set posinresarea "[expr {$ypos - 1}].0"
    if {$posinresarea == "0.0"} {
        set posinresarea [$w index "end - 2l linestart"]
    }
    if {[$w get $posinresarea] != "\n"} {
        openamatch $searchID $w $posinresarea
    }
}

proc openamatch {searchID w posinresarea} {
# display the match that was found in a file
# posinresarea is the text widget index position in the results window
# of the match to open
# the file is opened if not already open, the cursor is placed at the match
# position, and the match is highlighted
    global pad searchinfo

    # The test on ismapped fixes shrinking of Scipad window under Win7 from
    # full screen height to the previous geometry
    # (this did not happen when the Scipad window is full screen, only when
    # it is full height on Win7 - this is a new display mode of Win7)
    if {![winfo ismapped $pad]} {
    wm deiconify $pad
    }

    # highlight the selected match in the search results list
    $w tag remove curfoundtext 1.0 end
    $w tag add curfoundtext "$posinresarea linestart" "$posinresarea lineend"
    $w see $posinresarea

    # retrieve match coordinates
    scan $posinresarea "%d.%d" linenum xpos
    set thematch [lindex $searchinfo($searchID,allthematches) [expr {$linenum - 1}]]

    # open the file (or display it if already open), and highlight the match
    if {[openfileifexists [lindex $thematch 0]]} {

        set ta [gettextareacur]
        set matchstart [lindex $thematch 1]
        set matchstop [$ta index "$matchstart + [lindex $thematch 2] char"]

        if {![ispastmatchstillamatch $searchID $ta $matchstart $matchstop]} {

            # there must have been some editing action in the file between the time
            # the search was performed and the time the search results are browsed
            # or clicked

            set tit [mc "Outdated match"]
            set mes [mc "This match result is no longer valid, probably due to some editing action in the file since the search was performed."]
            append mes "\n" [mc "You should run a new search to update the match results."]
            tk_messageBox -message $mes -type ok -icon warning -title $tit -parent $pad

        } else {

            # the match found when performing the search is still a match, show it

            $ta mark set insert $matchstart
            keyposn $ta
            $ta tag remove sel 1.0 end
            $ta tag remove curfoundtext 1.0 end
            $ta tag add curfoundtext $matchstart $matchstop
            # show $matchstop first then $matchstart: this increases the chances
            # of seeing the complete match when the textarea occupies a limited space
            $ta see $matchstop
            $ta see $matchstart

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
            # finally, we must carefully escape % substitution in $bindtext when the
            # binding fires here - however substitution must occur when the binding
            # triggered by the binding fires - this is achieved by string mapping
            # the percent character to a double percent: the substitution in the first
            # binding removes a percent, and the binding launched by the first binding
            # performs substitution. Yes, it's tricky.
            set bindtext [bind $ta <KeyPress>]
            set bindtext [string map {"%" "%%"} $bindtext]
            if {[string first " tag remove curfoundtext 1.0 end" $bindtext] == -1} {
                bind $ta <KeyPress> "+%W tag remove curfoundtext 1.0 end ; bind %W <KeyPress> [list $bindtext]"
            }
            set bindtext [bind $ta <ButtonPress>]
            set bindtext [string map {"%" "%%"} $bindtext]
            if {[string first " tag remove curfoundtext 1.0 end" $bindtext] == -1} {
                bind $ta <ButtonPress> "+%W tag remove curfoundtext 1.0 end ; bind %W <ButtonPress> [list $bindtext]"
            }
            set bindtext [bind $ta <Button-1>]
            set bindtext [string map {"%" "%%"} $bindtext]
            if {[string first " tag remove curfoundtext 1.0 end" $bindtext] == -1} {
                bind $ta <Button-1> "+%W tag remove curfoundtext 1.0 end ; bind %W <Button-1> [list $bindtext]"
            }

        }

    } else {
        # file was deleted between the time when the match was found and the
        # time when it was clicked in the dialog
        # depending on the user's answer, a new file is created or not, anyway
        # there is nothing to highlight
    }
}

proc ispastmatchstillamatch {searchID ta sta sto} {
# check that the text in $ta between $sta and $sto really matches
# the previously searched string (taking into account any search options),
# i.e. if this text that was a match result at the time the search was
# performed still is a match result or not
#   if the textarea has been modified since running the search, it is
# possible that the answer is no (e.g. run the search in files, delete
# a line in the textarea between the first two matches, the second match
# in $searchinfo($searchID,allthematches) does not point to the correct
# line)
#   this check is done by using a fake textarea to which the candidate
# text (extracted from the file at the supposedly matching positions)
# is fed, no more no less text, and in which an actual search is run.
# If the result of this search is exactly the candidate text in totality,
# then the match is supposed to be still valid. Note that this approach
# is not completely bulletproof: if the editing actions between clicked
# matches are such that the candidate text still matches the text from
# the file, then this test does not help. Example with a single line
# file:
#         here I proudly write my own wonderful text, another text, nice!
#     run a search on "text", delete 14 chars at the beginning of the
#     file so that it looks like:
#          write my own wonderful text, another text, nice!
#     the second word "text" is exactly at the same position as the first
#     occurrence was before deletion, thus this test will say this is
#     a match, and the second occurrence of the word "text" will be
#     highlighted instead of the first one when clicking the first
#     mathc result, despite the precautions taken by using this check
#     nevertheless, let's say that this is good enough!
    global pad searchinfo

    set candtext [$ta get $sta $sto]

    text $pad.fakecheck$searchID
    $pad.fakecheck$searchID insert 1.0 $candtext

    set listoflinematchinfakecheck [searchforallmatches $pad.fakecheck$searchID \
                                                        $searchinfo($searchID,tosearchfor) \
                                                        $searchinfo($searchID,cas) \
                                                        $searchinfo($searchID,reg) \
                                                        0 \
                                                        $searchinfo($searchID,whword) \
                                                        [list ] \
                                    ]

    set stillamatch true

    # there must be only one match
    if {[llength $listoflinematchinfakecheck] != 1} {
        set stillamatch false
    } else {
        # the match must start at the first char of the fakecheck textarea
        set thematch [lindex $listoflinematchinfakecheck 0]
        set matchsta [lindex $thematch 0]
        if {[$pad.fakecheck$searchID compare $matchsta != "1.0"]} {
            set stillamatch false
        } else {
            # the match must end at the least char of the fakecheck textarea
            set matchsto [$pad.fakecheck$searchID index "$matchsta + [lindex $thematch 1] char"]
            if {[$pad.fakecheck$searchID compare $matchsto != [$pad.fakecheck$searchID index "end - 1 c"]]} {
                set stillamatch false
            }
        }
    }

    destroy $pad.fakecheck$searchID

    return $stillamatch
}

proc openallmatchingfiles {searchID} {
# sequentially open all files from the find in files search results
    global pad searchinfo

    wm deiconify $pad

    foreach amatch $searchinfo($searchID,allthematches) {
        set filename [lindex $amatch 0]
        # proc openfileifexists deals with already opened files, however
        # in such a case the effect is as if the user would have hit the
        # corresponding entry in the windows menu, therefore perhaps
        # switching the focus (in tile mode) toward unwanted tiles
        # for this reason, already opened files are filtered here first
        # and since we are here duplicate filenames are filtered as well
        # (since only the first match in a not yet opened file will actually
        # result in opening the file)
        if {![isfilealreadyopen $filename]} {
            if {[openfileifexists $filename]} {
                # everything is fine, nothing more to do
            } else {
                # file was deleted between the time when the match was found and the
                # time when the "open all files" button was clicked in the dialog
                # depending on the user's answer, a new file is created or not, anyway
                # there is nothing more to do
            }
        }
    }
}

proc copytextfrommatchreswin {w} {
# copy the selected text from the match results window and place it in the clipboard
    foreach {sta sto} [$w tag ranges sel] {}
    sendtoclipboard $w [$w get $sta $sto]
}
