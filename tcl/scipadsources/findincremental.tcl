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

proc showincremfindcontrols {} {
# display the incremental find controls
# and initiate the incremental search (i.e. set the start point)

    global pad textFont menuFont
    global normalentryforeground normalentryselectforeground
    global incfindtextcombolistvar

    set incfind $pad.incfind

    # don't allow simultaneous incremental search and normal
    # dialog search
    if {[istoplevelopen find]} {
        cancelfind
    }

    # set the starting point of the incremental search
    # this is the position of the insert cursor in the
    # current textarea
    setincsearchstartpoint

    frame $incfind
    label $incfind.label -text [mc "Find what:"] \
        -font $menuFont
    # -textvariable is intentionally NOT SearchString from the
    # find dialog, so that the two searches have nothing in common
    # (opening one of them closes the other one)
    combobox $incfind.combo -textvariable incsearchstring -font $textFont \
        -editable true -listvar incfindtextcombolistvar -command sortcombolistboxMRUfirst
    [$incfind.combo subwidget entry] configure \
        -validate key -validatecommand "launchnewincsearch %P" 

    checkbutton $incfind.mcase -text [mcra "Match &case"] \
        -variable incmatchcase -onvalue "-exact" -offvalue "-nocase" \
        -anchor w \
        -command "launchnewincsearch_newopt" -font $menuFont
    checkbutton $incfind.wholeword -text [mcra "Match &whole word only"] \
        -variable incwholeword \
        -anchor w \
        -command "launchnewincsearch_newopt" -font $menuFont

    set tgactionsiconsdirtouse [gettgactionsiconsdirtouse]
    image create photo icon_go_previous  -file [file join $tgactionsiconsdirtouse "go-previous.gif"]
    image create photo icon_go_next      -file [file join $tgactionsiconsdirtouse "go-next.gif"]
    image create photo icon_process_stop -file [file join $tgactionsiconsdirtouse "process-stop.gif"]
    button $incfind.buttonPrev -text [mcra "&Previous"] -image icon_go_previous \
        -command "incsearchprevious" -font $menuFont
    button $incfind.buttonNext -text [mcra "&Next"]     -image icon_go_next \
        -command "incsearchnext" -font $menuFont
    button $incfind.buttonClose -text [mcra "&Close"]   -image icon_process_stop \
        -command "closeincremfindcontrols" -font $menuFont

    pack $incfind.label $incfind.combo \
        -side left -padx 6
    pack $incfind.buttonClose $incfind.buttonNext $incfind.buttonPrev \
        -side right -padx 6
    pack $incfind.mcase $incfind.wholeword \
        -side left -padx 6
    pack configure $incfind.combo -expand 1 -fill x

    pack $incfind -side top -expand 0 -fill x -before $pad.pw0

    # document some bindings using tooltips
    bind $incfind.buttonPrev  <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \
        \[concat [mcra "&Previous"] [findbinding incsearchprevious]\] true"
    bind $incfind.buttonPrev  <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \
        \[concat [mcra "&Previous"] [findbinding incsearchprevious]\] true"
    bind $incfind.buttonNext  <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \
        \[concat [mcra "&Next"]     [findbinding incsearchnext]\]     true"
    bind $incfind.buttonNext  <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \
        \[concat [mcra "&Next"]     [findbinding incsearchnext]\]     true"
    bind $incfind.buttonClose <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \
        \[concat [mcra "&Close"]    [mc "<Esc>"]\]                    true"
    bind $incfind.buttonClose <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \
        \[concat [mcra "&Close"]    [mc "<Esc>"]\]                    true"

    # additional usability bindings
    bind $incfind.combo <Return>       {updateincfindcombolistbox ; incsearchnext}
    bind $incfind.combo <Shift-Return> {updateincfindcombolistbox ; incsearchprevious}
    bind $incfind.combo <Escape>       {closeincremfindcontrols ; break}
    bind $incfind.combo <MouseWheel>   {
                                        if {![isanycomboboxopened $pad.incfind]} { 
                                            [gettextareacur] yview scroll [expr {-(%D/3)}] pixels
                                        }
                                       }

    focusincsearchentry

    # get the normal background color
    # do this once only, when opening the incremental find controls for
    # the first time - if we would do this at each opening we could get
    # the wrong color if the previous search did not find any match
    if {![info exists normalentryforeground]} {
        set normalentryforeground       [[$incfind.combo subwidget entry] cget -foreground]
        set normalentryselectforeground [[$incfind.combo subwidget entry] cget -selectforeground]
    }
}

proc focusincsearchentry {} {
# set the focus to the search term in the incremental search dialog
# and select this whole search term
    global pad
    set incfind $pad.incfind
    focus $incfind.combo
    $incfind.combo selection range 0 end
    $incfind.combo icursor end
}

proc incsearchsetvisualcuenomatch {} {
# set a visual cue so that the user realizes the incremental
# search did not find any match
    global pad
    set incfind $pad.incfind
    [$incfind.combo subwidget entry] configure -foreground red \
                             -selectforeground red
}

proc incsearchsetvisualcueamatch {} {
# set a visual cue so that the user realizes the incremental
# search did find at least one match
    global pad normalentryforeground normalentryselectforeground
    set incfind $pad.incfind
    [$incfind.combo subwidget entry] configure -foreground $normalentryforeground \
                             -selectforeground $normalentryselectforeground
}

proc resetincsearch {} {
# reset incremental search results and reposition the insert
# cursor where it was at the beginning of the previous search

    # reset the search data (current buffer)
    forgetlistofmatch

    repositiontoincsearchstartpoint
}

proc launchnewincsearch {searchedstr} {
# launch a launchnewincsearch command in background
# launchnewincsearch is a bit long for very large buffers
# if many launchnewincsearch are waiting for execution, there can be many
# launchnewincsearch commands pending -> first delete them since they
# are now pointless and launch only the latest command
# launchnewincsearch is catched to deal more easily with buffers that
# were closed before the command could be processed

    global backgroundtasksallowed
    global launchnewincsearch_command_id

    if {$backgroundtasksallowed} {

        if {![info exists launchnewincsearch_command_id]} {
            set launchnewincsearch_command_id [list ]
        }

        after cancel $launchnewincsearch_command_id

        set launchnewincsearch_command_id \
                [after 500 [list after 1 [list catch [list dolaunchnewincsearch $searchedstr] ] ]]

    } else {

        dolaunchnewincsearch $searchedstr

    }

    return true ; # because launchnewincsearch is a -validatecommand
}

proc dolaunchnewincsearch {searchedstr} {
# run an incremental search from the starting point, with a new
# search string $searchstr
# output value is always true (this is a -validatecommand proc)

    resetincsearch

    incsearchfindit $searchedstr "forwards"
}

proc launchnewincsearch_newopt {} {
# run an incremental search from the starting point, taking into
# account any new option (match case or regexp match) that could
# have just been set (these are global variables retrieved in
# proc incsearchfindit)

    global incsearchstring

    launchnewincsearch $incsearchstring
}

proc incsearchprevious {} {
# show the previous match in the current incremental search

    global pad incsearchstring

    set incfind $pad.incfind
    if {![winfo exists $incfind]} {
        # incremental find controls not yet displayed, show them
        showincremfindcontrols
    }

    # use the selection, if there is one, as preset search term
    set ta [gettextareacur]
    set selindices [gettaselind $ta single]

    if {$selindices != ""} {

        foreach {sta sto} $selindices {}
        set incsearchstring [$ta get $sta $sto]
        $ta tag remove sel 1.0 end
        # launching proc incsearchfindit not to be done, it will
        # automatically trigger by changing $incsearchstring
        # because the entry field has -textvariable incsearchstring
        # and -validate key -validatecommand "launchnewincsearch %P"

        # <TODO>: There is a problem here!
        #         Select some text, then Shift-F3: the search is
        #         run _forwards_ instead of backwards
        #         This is because, as per above comment, proc
        #         launchnewincsearch is run, which eventually runs 
        #         incsearchfindit $searchedstr "forwards"
        #         Further Shift-F3 however do not go through this
        #         path and are OK.
        #         For the moment this is an acceptable drawback in
        #         regard of the benefit of having the selection
        #         used as search term

    } else {

        incsearchfindit $incsearchstring "backwards"

    }

    focusincsearchentry
}

proc incsearchnext {} {
# show the next match in the current incremental search

    global pad incsearchstring

    set incfind $pad.incfind
    if {![winfo exists $incfind]} {
        # incremental find controls not yet displayed, show them
        showincremfindcontrols
    }

    # use the selection, if there is one, as preset search term
    set ta [gettextareacur]
    set selindices [gettaselind $ta single]

    if {$selindices != ""} {

        foreach {sta sto} $selindices {}
        set incsearchstring [$ta get $sta $sto]
        $ta tag remove sel 1.0 end
        # launching proc incsearchfindit not to be done, it will
        # automatically trigger by changing $incsearchstring
        # because the entry field has -textvariable incsearchstring
        # and -validate key -validatecommand "launchnewincsearch %P"

    } else {

        incsearchfindit $incsearchstring "forwards"

    }

    focusincsearchentry
}

proc incsearchfindit {tosearchfor dir} {
# do find the first (or next) match for incremental search

    global pad incsearchstartpoint
    global incmatchcase incwholeword
    global buffermodifiedsincelastsearch

    # no point in searching for an empty string
    if {$tosearchfor eq ""} {
        removeallfindreplacetags
        return
    }

    if {$buffermodifiedsincelastsearch} {
        resetincsearch
    }

    set ta [lindex $incsearchstartpoint 0]

    set findres [findit thiswidgetdoesnotexist $pad false $ta \
                        $tosearchfor $incmatchcase "standard" \
                        false $incwholeword [list ] $dir]

    set totalnumberofmatches [expr {[llength [$ta tag ranges anyfoundtext]] / 2}]
    showinfo "$totalnumberofmatches [mc "matches found"]"

    if {$findres ne "nomatchatall"} {
        # there was a match
        incsearchsetvisualcueamatch
    } else {
        # no match found
        incsearchsetvisualcuenomatch
    }
}

proc closeincremfindcontrols {} {
# remove the incremental search controls from the display
# if they are currently shown
    global pad

    set incfind $pad.incfind
    if {[winfo exists $incfind]} {
        destroy $incfind
    }

    removeallfindreplacetags
    focustextarea [gettextareacur]
}

proc setincsearchstartpoint {} {
# save a new start position for the later incremental searches
# (this is the insert cursor position in the current textarea)
# also, remove any tag related to find/replace from all buffers

    global incsearchstartpoint

    set ta [gettextareacur]
    set sta [$ta index insert]
    set incsearchstartpoint [list $ta $sta]

    removeallfindreplacetags
}

proc repositiontoincsearchstartpoint {} {
# reposition the insert cursor to its position saved at the
# beginning of the incremental search

    global incsearchstartpoint

    # set the starting point of the search
    set ta  [lindex $incsearchstartpoint 0]
    set sta [lindex $incsearchstartpoint 1]
    $ta mark set insert $sta
}

proc updateincfindcombolistbox {} {
# update the combo listbox of the incremental find dialog bar with the content of the entry
    global pad
    set incfind $pad.incfind
    if {[winfo exists $incfind]} {
        insertentrycontentincombolistbox $incfind.combo
        setcombolistboxwidthtolargestcontent $incfind.combo
    } else {
        # incremental find dialog bar not open (should never happen)
        # nothing to do
    }
}

