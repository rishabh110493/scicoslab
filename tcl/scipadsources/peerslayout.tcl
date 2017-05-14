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

#####################################################################
#
# About the implementation of paned windows:
#
#   $textareaid
#       This is the unique identifier of the text widget displaying
#       the content of a given file.
#       When a new textarea is created, it is given the $winopened
#       value in $textareaid
#       Peer text widgets are just normal textareas, with their
#       textareaid value
#
#   $pad.new$textareaid
#       Buffer name. This is the unique pathname of the text widget
#       displaying the content of a file. This is usually referred to
#       as $textarea, or $ta for short, sometimes just $w
#       Peer text widgets are just normal textareas
#
#   A main paned window is created in mainwindow.tcl, whose name is
#   $pad.pw0. This panedwindow is the root of the paned windows tree
#   and is never destroyed
#
#   At the time a textarea must be packed (displayed in Scipad), it
#   is packed in an existing pane of an existing paned window (proc
#   packbuffer). More precisely, the textarea is packed into a frame
#   which was previously added as a pane of the panedwindow
#
#   On invocation of the Split or Tile commands, textareas are packed
#   in new panes (more precisely frames added as panes) of possibly
#   new paned windows. These new paned windows are nested in the
#   existing hierarchy (proc packnewbuffer). Nesting paned windows
#   is required because a panedwindow has a single orientation which
#   is common to all its panes
#
#   The hierarchy is partially coded in a global array: pwframe
#   This array is such that $pwframe($textarea) contains the widget
#   into which $textarea is packed. This is always a frame (that was
#   itself added as a pane in a panedwindow)
#   There is no variable fully describing the hierarchical tree: this
#   is managed by the packing algorithm of Tk. This tree can however
#   be retrieved in a nested list (proc getpwtree), which is used during
#   the merging process of the panedwindows, i.e. during removal of
#   superfluous nest levels of panedwindows
#   Also, proc getfullpwstructureinfo provides the layout structure
#   attached to all the visible textareas, for later rebuild on next
#   Scipad session
#
#   proc getpaneframename allows to retrieve the frame name in which
#   a textarea is currently packed. It returns "none" if the textarea
#   passed as argument is not visible (displayed). This allows for an
#   easy check of whether a textarea is displayed or not (proc isdisplayed)
#   or to get the total number of panes in Scipad (proc gettotnbpanes)
#
#   proc getpwname allows to retrieve the paned window name in which
#   a widget is packed. This widget is usually a frame (pane) of a
#   panedwindow in which a textarea is packed, but it can also be a
#   full panedwindow
#
#   proc createpaneframename constructs the frame name in which a
#   textarea is to be packed and stores this name in pwframe. If
#   possible, $pad.new$textareaid will be packed in a frame whose
#   name is $targetpw.f$textareaid
#
#   Example:
#   Consider a simple tiling of Scipad: one upper pane, and a lower
#   pane itself divided into two horizontal panes:
#
#       -------------------------------------------------
#       |                Upper pane                     |
#       |                                               |
#       ------------------------------------------------- 
#       |                Lower pane                     |
#       |-----------------------|-----------------------|
#       ||  Lower left pane     |   Lower right pane   ||
#       ||                      |                      ||
#       |-----------------------------------------------|
#       -------------------------------------------------
#
#   $pad.pw0 contains the whole thing. It has a vertical orientation and
#   contains two panes:
#      $pad.pw0.f1
#         This ends with f$textareaid, therefore this is a frame.
#         It is the frame added to $pad.pw0 as the first pane
#         It displays a textarea since it is a frame, and this frame is
#         $pad.new1 since $pwframe($pad.new1)=$pad.pw0.f1
#      $pad.pw0.pw1
#         This ends with pw$somenumber, therefore this is a panedwindow.
#         It was added as the second pane of $pad.pw0. It is not a frame
#         but a nested paned window whose orientation is horizontal. This
#         paned window contains again two panes:
#            $pad.pw0.pw1.f2
#               This is a frame containing $pad.new2 since
#               $pwframe($pad.new2)=$pad.pw0.pw1.f2
#            $pad.pw0.pw1.f3
#               This is again a frame containing $pad.new3 since
#               $pwframe($pad.new3)=$pad.pw0.pw1.f3
#
#   Note that in this example $pad.pw0.pw1.f$X contains $pad.new$Y
#   where $X == $Y, but this is not always the case
#
#####################################################################

proc packnewbuffer {textarea targetpw forcetitlebar {whereafter ""} {wherebefore ""}} {
# this packs a textarea buffer in a new pane that will be added in an existing panedwindow
    global pad textfontsize menuFont wordWrap showclosureXcross
    global linenumbersmargin modifiedlinemargin
    global Tk85

    # everything is packed in a frame whose name is provided by createpaneframename
    set tapwfr [createpaneframename $textarea $targetpw]

    # create frames for widget layout
    # this is the main frame that is added as a pane
    frame $tapwfr -borderwidth 2

    # this is for the top bar containing the pane title (file name)
    # and the hide and close buttons
    frame $tapwfr.topbar
    frame $tapwfr.topbar.f
    button $tapwfr.topbar.f.clbutton -text [mc "Close"] \
        -font $menuFont \
        -command "buttonclosetile $textarea"
    grid $tapwfr.topbar.f.clbutton -row 0 -column 0 -sticky we
    button $tapwfr.topbar.f.hibutton -text [mc "Hide"] -font $menuFont \
        -command "hidetext $textarea"
    grid $tapwfr.topbar.f.hibutton -row 0 -column 1 -sticky we
    grid columnconfigure $tapwfr.topbar.f 0 -uniform 1
    grid columnconfigure $tapwfr.topbar.f 1 -uniform 1
    if {$Tk85} {
        # not absolutely mandatory because $tapwfr.topbar.f is already packed
        # with -expand 0 -fill none (and not -expand 1 -fill x), but does not hurt
        grid anchor $tapwfr.topbar.f center
    }
    pack $tapwfr.topbar.f -side right -expand 0 -fill none

    # this is for the text widget, its margin, the close cross and the y scroll bar
    frame $tapwfr.top
    pack $tapwfr.top -side top -expand 1 -fill both

    # this is where the text widget and its margin are packed
    frame $tapwfr.topleft
    pack $tapwfr.topleft   -in $tapwfr.top    -side left   -expand 1 -fill both

    # a panedwindow is used since it provides the sash, the moving of which
    # splits the window vertically ("Split" feature)
    panedwindow $tapwfr.pwright -borderwidth 0 -opaqueresize false -sashrelief raised \
            -sashwidth 10 -orient vertical
    # this is where the close cross and the y scrollbar are packed
    frame $tapwfr.pwright.topright
    # this empty frame is needed because there must be two panes for the sash to be drawn
    frame $tapwfr.pwright.emptyframe -height 0 -borderwidth 0
    $tapwfr.pwright add $tapwfr.pwright.emptyframe
    $tapwfr.pwright add $tapwfr.pwright.topright
    $tapwfr.pwright sash place 0 0 0
    # "after idle" mandatory in <ButtonRelease-x> to control order of execution
    # between class binding and widget binding: class binding shall execute first
    # so that the panedwindow widget handles the sash drag/release properly *before*
    # bindings proper to $tapwfr.pwright since this may no longer exist after
    # window splitting
    bind $tapwfr.pwright <Button-1>        {focustaabouttobesplit %W}
    bind $tapwfr.pwright <B1-Motion>       {after idle {clampproxy %W}}
    bind $tapwfr.pwright <ButtonRelease-1> {after idle {splitfromsash %W tile}}
    bind $tapwfr.pwright <Button-2>        {focustaabouttobesplit %W}
    bind $tapwfr.pwright <ButtonRelease-2> {after idle {splitfromsash %W file}}
    pack $tapwfr.pwright -in $tapwfr.top    -side right  -expand 0 -fill both 

    # this is for the x scroll bar at the bottom of the pane
    if {$wordWrap == "none"} {
        # a panedwindow is used since it provides the sash, the moving of which
        # splits the window horizontally ("Split" feature)
        panedwindow $tapwfr.pwbottom -borderwidth 0 -opaqueresize false -sashrelief raised \
                -sashwidth 10 -orient horizontal
        frame $tapwfr.pwbottom.bottom
        frame $tapwfr.pwbottom.emptyframe -height 0 -borderwidth 0
        $tapwfr.pwbottom add $tapwfr.pwbottom.emptyframe
        $tapwfr.pwbottom add $tapwfr.pwbottom.bottom
        $tapwfr.pwbottom sash place 0 0 0
        bind $tapwfr.pwbottom <Button-1>        {focustaabouttobesplit %W}
        # binding to proc clampproxy needed only for <B1-Motion>
        # (limits are respected by Tk for <B2-Motion>)
        bind $tapwfr.pwbottom <B1-Motion>       {after idle {clampproxy %W}}
        bind $tapwfr.pwbottom <ButtonRelease-1> {after idle {splitfromsash %W tile}}
        bind $tapwfr.pwbottom <Button-2>        {focustaabouttobesplit %W}
        bind $tapwfr.pwbottom <ButtonRelease-2> {after idle {splitfromsash %W file}}
        pack $tapwfr.pwbottom -before $tapwfr.top -side bottom -expand 0 -fill both
    }

    $targetpw add $tapwfr -minsize [expr {$textfontsize * 2}]
    if {$Tk85} {
        $targetpw paneconfigure $tapwfr -stretch always
    }

    if {$targetpw == "$pad.pw0"} {
        pack $targetpw -side top -expand 1 -fill both
    }

    $targetpw paneconfigure $tapwfr -after $whereafter -before $wherebefore

    # a canvas is used to draw the little cross allowing to close files
    canvas $tapwfr.clcanvas -width 18 -height 18 -background lightgrey
    $tapwfr.clcanvas create line 6 6 14 14 -width 2
    $tapwfr.clcanvas create line 6 14 14 6 -width 2
    bind $tapwfr.clcanvas <Button-1> "crossclosefile $textarea"

    bind $tapwfr.clcanvas  <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \[mc \"Close file (all tiles)\"\]"
    bind $tapwfr.clcanvas  <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \[mc \"Close file (all tiles)\"\]"

    scrollbar $tapwfr.yscroll -command "$textarea yview" -takefocus 0
    if {$wordWrap == "none"} {
        scrollbar $tapwfr.xscroll -command "$textarea xview" -takefocus 0 \
            -orient horizontal
    }

    label $tapwfr.panetitle -font $menuFont
    bind $tapwfr.topbar    <ButtonRelease-1> "focustextarea $textarea"
    bind $tapwfr.panetitle <ButtonRelease-1> "focustextarea $textarea"
    bind $tapwfr.topbar    <Double-Button-1> "focustextarea $textarea; \
                                              $pad.filemenu.wind invoke 1"
    bind $tapwfr.panetitle <Double-Button-1> "focustextarea $textarea; \
                                              $pad.filemenu.wind invoke 1"
    bind $tapwfr.topbar             <Button-2>        {switchbuffersinpane %W "forward"}
    bind $tapwfr.panetitle          <Button-2>        {switchbuffersinpane %W "forward"}
    bind $tapwfr.topbar             <Shift-Button-2>  {switchbuffersinpane %W "backward"}
    bind $tapwfr.panetitle          <Shift-Button-2>  {switchbuffersinpane %W "backward"}
    bind $tapwfr.topbar             <Button-3>        {showpopup_tiletitle %W}
    bind $tapwfr.panetitle          <Button-3>        {showpopup_tiletitle %W}
    bind $tapwfr.panetitle          <Enter> "update_bubble_panetitle enter %W \[winfo pointerxy $pad\] $textarea"
    bind $tapwfr.panetitle          <Leave> "update_bubble_panetitle leave %W \[winfo pointerxy $pad\] $textarea"
    bind $tapwfr.topbar.f.clbutton  <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \[mc \"Close this tile\"\]"
    bind $tapwfr.topbar.f.clbutton  <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \[mc \"Close this tile\"\]"
    bind $tapwfr.topbar.f.hibutton  <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \[mc \"Close this tile, keep content\"\]"
    bind $tapwfr.topbar.f.hibutton  <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \[mc \"Close this tile, keep content\"\]"
    pack $tapwfr.panetitle -in $tapwfr.topbar -expand 1 -fill none

    pack $textarea            -in $tapwfr.topleft  -side left   -expand 1 -fill both
    if {$showclosureXcross} {
        pack $tapwfr.clcanvas -in $tapwfr.pwright.topright -side top    -expand 0
    }
    pack $tapwfr.yscroll      -in $tapwfr.pwright.topright -side right  -expand 1 -fill y
    if {$wordWrap == "none"} {
        pack $tapwfr.xscroll  -in $tapwfr.pwbottom.bottom  -side bottom -expand 1 -fill x
    }

    if {[gettotnbpanes] > 1 || $forcetitlebar == 1} {
        pack $tapwfr.topbar -side top -expand 0 -fill both -in $tapwfr -before $tapwfr.top
    }

    $textarea configure -xscrollcommand "managescroll $tapwfr.xscroll"
    $textarea configure -yscrollcommand "managescroll $tapwfr.yscroll"

    if {$linenumbersmargin ne "hide"} {
        addlinenumbersmargin $textarea
    }

    if {$modifiedlinemargin ne "hide"} {
        addmodifiedlinemargin $textarea
    }
}

proc packbuffer {textarea} {
# this packs a textarea buffer in an existing pane of an existing panedwindow
# this pane is always the current one
# the text widget is packed in the frame that contained the current textarea
    global pad pwframe wordWrap

    # remove scrollbars commands so that an unpacked textarea does not later
    # update the scrollbar, which depending on the order these commands are
    # launched, can lead to wrong scrollbars sizes and scrollbars flashes
    if {[winfo exists [gettextareacur]]} {
        [gettextareacur] configure -xscrollcommand ""
        [gettextareacur] configure -yscrollcommand ""
    }

    pack forget [gettextareacur]
    set curtapwfr [getpaneframename [gettextareacur]]
    unset pwframe([gettextareacur])

    $curtapwfr.yscroll configure -command "$textarea yview"
    if {$wordWrap == "none"} {
        $curtapwfr.xscroll configure -command "$textarea xview"
    }

    $curtapwfr.topbar.f.clbutton configure -command "buttonclosetile $textarea"
    $curtapwfr.topbar.f.hibutton configure -command "hidetext $textarea"
    bind $curtapwfr.clcanvas  <Button-1> "crossclosefile $textarea"

    bind $curtapwfr.clcanvas  <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \[mc \"Close file (all tiles)\"\]"
    bind $curtapwfr.clcanvas  <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \[mc \"Close file (all tiles)\"\]"

    bind $curtapwfr.topbar    <ButtonRelease-1> "focustextarea $textarea"
    bind $curtapwfr.panetitle <ButtonRelease-1> "focustextarea $textarea"
    bind $curtapwfr.topbar    <Double-Button-1> "focustextarea $textarea; \
                                                 $pad.filemenu.wind invoke 1"
    bind $curtapwfr.panetitle <Double-Button-1> "focustextarea $textarea; \
                                                 $pad.filemenu.wind invoke 1"
    bind $curtapwfr.topbar             <Button-2>        {switchbuffersinpane %W "forward"}
    bind $curtapwfr.panetitle          <Button-2>        {switchbuffersinpane %W "forward"}
    bind $curtapwfr.topbar             <Button-3>        {showpopup_tiletitle %W}
    bind $curtapwfr.panetitle          <Button-3>        {showpopup_tiletitle %W}
    bind $curtapwfr.panetitle          <Enter> "update_bubble_panetitle enter %W \[winfo pointerxy $pad\] $textarea"
    bind $curtapwfr.panetitle          <Leave> "update_bubble_panetitle leave %W \[winfo pointerxy $pad\] $textarea"
    bind $curtapwfr.topbar.f.clbutton  <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \[mc \"Close this tile\"\]"
    bind $curtapwfr.topbar.f.clbutton  <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \[mc \"Close this tile\"\]"
    bind $curtapwfr.topbar.f.hibutton  <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \[mc \"Close this tile, keep content\"\]"
    bind $curtapwfr.topbar.f.hibutton  <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \[mc \"Close this tile, keep content\"\]"

    pack $textarea -in $curtapwfr.topleft -side left -expand 1 -fill both

    $textarea configure -xscrollcommand "managescroll $curtapwfr.xscroll"
    $textarea configure -yscrollcommand "managescroll $curtapwfr.yscroll"

    set pwframe($textarea) $curtapwfr
}

proc toggleclosureXcross {} {
# toggle show/hide the closure X cross of each displayed textarea
    global showclosureXcross listoftextarea
    if {$showclosureXcross} {
        # display
        foreach ta $listoftextarea {
            if {[isdisplayed $ta]} {
                set tapwfr [getpaneframename $ta]
                pack $tapwfr.clcanvas -in $tapwfr.pwright.topright -side top -expand 0
                pack configure $tapwfr.yscroll -in $tapwfr.pwright.topright -side right -expand 1 -fill y
            }
        }
    } else {
        # hide
        foreach ta $listoftextarea {
            if {[isdisplayed $ta]} {
                set tapwfr [getpaneframename $ta]
                pack forget $tapwfr.clcanvas
            }
        }
    }
}

proc focustaabouttobesplit {pwsplit} {
# force the current textarea to be the one aside the sash of $pwsplit,
# and set limits of the move span for the proxy
    global hrs_maxheightproxyspan hrs_maxwidthproxyspan
    global hrs_mineffxproxymove
    global linenumbersmargin modifiedlinemargin
    set ta [gettafromwidget [winfo parent $pwsplit]]
    focustextarea $ta
    set tapwfr [getpaneframename $ta]
    set hrs_maxheightproxyspan [winfo height $ta]
    set hrs_maxwidthproxyspan  [winfo width  $ta]
    set hrs_mineffxproxymove 1
    if {$linenumbersmargin ne "hide"} {
        set width1 [winfo width $tapwfr.marginln]
        incr hrs_maxwidthproxyspan $width1
        incr hrs_mineffxproxymove $width1
    }
    if {$modifiedlinemargin ne "hide"} {
        set width2 [winfo width $tapwfr.propagationoffframe]
        incr hrs_maxwidthproxyspan $width2
        incr hrs_mineffxproxymove $width2
    }
}

proc clampproxy {pwsplit} {
# allow the proxy to move only within the textarea pane size
# this proc is needed to work around Tk bug
#    http://core.tcl.tk/tk/tktview?name=d7bad57c43
#    (panedwindow proxy can be displayed outside the panedwindow limits)
    global hrs_maxheightproxyspan hrs_maxwidthproxyspan

    if {[$pwsplit cget -orient] eq "vertical"} {
        set curpos [lindex [$pwsplit proxy coord] 1]
        set maxsize $hrs_maxheightproxyspan
    } else {
        set curpos [lindex [$pwsplit proxy coord] 0]
        set maxsize $hrs_maxwidthproxyspan
    }
    if {$curpos >= $maxsize} {
        $pwsplit proxy place $maxsize $maxsize
    }
}

proc splitfromsash {pwsplit splitmode} {
# this proc is called when releasing the sash of $pwsplit allowing to split the file
# displayed on its left (or top), it:
#  - splits the file, taking into account $splitmode: "tile" or "file" (for 8.5+ only,
#    on 8.4 do always "tile")
#  - resets the sash position to the top (or left), giving all the space to the closure
#    cross and scrollbar (for vertical case, or just scrollbar for horizontal case) 
# however, if the sash is close to the upper (or left) end position then do nothing (this
# implements sort of cancel action when the user moves the sash, changes his mind and
# puts it back on top (or left))
    global pad Tk85
    global hrs_mineffxproxymove

    if {[$pwsplit cget -orient] eq "vertical"} {
        set sashcoord [lindex [$pwsplit sash coord 0] 1]
        if {$splitmode eq "file" && $Tk85} {
            set splitcommand {splitwindow vertical "" file nosasharrange}
        } else {
            set splitcommand {splitwindow vertical "" tile nosasharrange}
        }
        set mineffectivemove 1

    } else {
        set sashcoord [lindex [$pwsplit sash coord 0] 0]
        if {$splitmode eq "file" && $Tk85} {
            set splitcommand {splitwindow horizontal "" file nosasharrange}
        } else {
            set splitcommand {splitwindow horizontal "" tile nosasharrange}
        }
        set mineffectivemove $hrs_mineffxproxymove
    }

    # this must be done now, before calling the splitting command, because splitting
    # may reorganize the panedwindow structure and $pwsplit may not exist later
    $pwsplit sash place 0 0 0

    if {$sashcoord <= $mineffectivemove} {
        return
    }

    # launch splitting and adjust sash position according to where the moved sash
    # was released

    set ta [gettafromwidget [winfo parent $pwsplit]]

    eval $splitcommand

    # textarea $ta must now still be visible, get the panedwindow name now showing it
    # (it might have changed by execution of the splitting command above
    set tapwfr [getpaneframename $ta]
    set pwname [getpwname $tapwfr]

    # get the index of the sash separating $ta and the "next" (below or to the right)
    # textarea (after the splitting process, there is always at least one sash in
    # the panedwindow and $ta cannot be the last one), and the total pixel size of
    # the panes located before the one that was just split
    foreach {sashindex offset} [getsashfollowing $pwname $tapwfr] {}

    set pos [expr {$offset + $sashcoord}]

    update idletasks
    $pwname sash place $sashindex $pos $pos
}

proc montretext {textarea} {
# old name of showtext, left for compatibility (backporting)
# with plotprofile.sci of BUILD_4 branch of Scilab (and Scicoslab)
  showtext $textarea
}

proc showtext {textarea} {
# if $textarea is not currently visible, pack it in the current pane,
# and make this textarea the current one
# if $textarea is already visible in some other pane than the
# current one, simply switch to this textarea
# WARNING: this proc is called from outside Scipad (plotprofile.sci)
#          changes here should be assessed with their full consequences...

    if {![isdisplayed $textarea]} {
        packbuffer $textarea
    }

    focustextarea $textarea
    backgroundcolorizetasks
}

proc hidetext {textarea} {
# hide a textarea currently packed
# this is different from closing a tile since hiding keeps the textarea
# entry in the windows menu (and in listoftexarea)
# it is purely an unpacking action

    global pad listoftextarea pwframe
    global restorelayoutrunning tileprocalreadyrunning

    if {$restorelayoutrunning} {return}
    if {$tileprocalreadyrunning} {return}

    disablemenuesbinds

    # unpack the textarea
    destroypaneframe $textarea

    # place as current textarea the last one that is already visible
    $pad.filemenu.wind invoke [getlastvisibletextareamenuind]

    # remove tile title if there is a single pane
    if {[gettotnbpanes] == 1} {
        set visibletapwfr [lindex [array get pwframe] 1]
        pack forget $visibletapwfr.topbar
    }

    restoremenuesbinds
}

proc focustextarea {textarea} {
# Set all the settings such that $textarea becomes the current one
    global pad Scheme ColorizeIt listoffile textareaid
    global buffermodifiedsincelastsearch
    global currentencoding

    # clear the selection when leaving a buffer - check first that the
    # textarea still exists because it might have been destroyed when
    # focustextarea is called after closure of the current file
    set oldta [gettextareacur]
    if {[winfo exists $oldta]} {
        if {($oldta ne $textarea) && [gettaselind $oldta any] != ""} {
            $oldta tag remove sel 1.0 end
        }
    }

    # when switching buffers, the find process shall be reset
    # (but not when just clicking in the current textarea)
    # if this is not done then searching in a buffer then
    # switching then find next highlights in the second textarea
    # at the position of the match in the first textarea,
    # which is obviously wrong
    # warning: this is not a resetfind, but a forgetlistofmatch
    # because indofcurrentbuf must not be erased otherwise find
    # in multiple files will not work
    if {$oldta ne $textarea} {
        forgetlistofmatch
    }

    # set the new buffer as current
    # try to do only what is really needed, e.g. be clever about
    # whether we're switching to a new textarea or not - this has large
    # performance impact since proc focustextarea is called really often
    settextareacur $textarea
    modifiedtitle $textarea
    focus $textarea
    keyposn $textarea
    if {$oldta ne $textarea} {
        set Scheme $listoffile("$textarea",language)
        set ColorizeIt $listoffile("$textarea",colorize)
        set currentencoding $listoffile("$textarea",encoding)
        schememenus $textarea
        TextStyles $textarea
        set textareaid [gettaidfromwidgetname $textarea]
    }
    # let's do it in any case, since sometimes (proc tileallbuffers) it
    # is needed because *all* textareas were removed from the display
    # whereas the current textarea did not change
    highlighttextarea $textarea

    # buffer were switched (even when clicking in the same buffer),
    # therefore the start point of incremental search must be reset
    # to the insert cursor position in the current textarea
    setincsearchstartpoint
}

proc maximizebuffer {} {
    global pad listoftextarea tileprocalreadyrunning

    if {$tileprocalreadyrunning} {return}
    disablemenuesbinds

    set curta [gettextareacur]

    # Remove the existing tiling
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {
            destroypaneframe $ta
        }
    }

    # Pack the current buffer only
    packnewbuffer $curta $pad.pw0 0
    focustextarea $curta

    restoremenuesbinds
}

proc splitwindow {neworient tatopack {splitmode tile} {mustarrangesashes sasharrange}} {
# split current window:
#    add a vertical pane if $neworient is "vertical"
#    add an horizontal pane if $neworient is "horizontal"
# splitting always starts from the current textarea, i.e
# everything appears to happen as if the *current* textarea
# is split
# if $tatopack != "" then the textarea $tatopack will be packed in the new
# pane, otherwise:
#    - with Tk 8.5: behaviour depends on $splitmode as follows:
#        - if $splitmode == "file", a new peer is created
#        - if $splitmode == "tile", the last hidden textarea is used, and if
#          there is none an empty textarea is created (Tk 8.4 behaviour)
#    - with Tk 8.4: the last hidden textarea is used, and if there is none
#      an empty textarea is created
# if $mustarrangesashes eq "sasharrange", then the sashes of the panedwindow
# showing the window that was just split are spaced evenly after splitting
    global pad pwmaxid textfontsize listoftextarea tileprocalreadyrunning
    global Tk85

    if {$tileprocalreadyrunning} {return}
    disablemenuesbinds

    # retrieve the orientation of the pane in which the current textarea is packed
    set tacur [gettextareacur]
    set tapwfr [getpaneframename $tacur]
    set pwname [getpwname $tapwfr]
    set curorient [$pwname cget -orient]

    # if there is a single existing pane, this prevents from creating an unnecessary
    # level of nested panedwindows
    if {$curorient != $neworient && [llength [$pwname panes]] == 1} {
        set curorient $neworient
        $pwname configure -orient $curorient
    }

    if {$curorient == $neworient} {
        # no need for a new panedwindow, just add a pane with the textarea whose
        # name was provided as argument, or:
        #     a hidden buffer, or an empty file if there is none (Tk 8.4)
        #     create and pack a new peer of the current textarea (Tk 8.5)

        # make sure that the possibly single pane before now shows its title bar
        pack $tapwfr.topbar -side top -expand 0 -fill both -in $tapwfr -before $tapwfr.top
        modifiedtitle $tacur "panesonly"

        # select the buffer to pack
        if {$tatopack != ""} {
            # if the name of the textarea to pack was provided, use it
            # this happens with the commands from the file menu
            set newta $tatopack
        } else {
            # the name of of the textarea to pack was not provided,
            # this happens with the commands from the windows menu
            if {$Tk85 && $splitmode == "file"} {
                # create a peer text widget
                set newta [createpeertextwidget $tacur]
            } else {
                # Tk 8.4 case, or $splitmode == "tile" in Tk 8.5
                if {[llength $listoftextarea] > [gettotnbpanes]} {
                    # if there is a hidden buffer, use it
                    set newta $pad.new[getlasthiddentextareaid]
                } else {
                    # otherwise create an empty textarea
                    set newta [createnewemptytextarea]
                }
            }
        }

        # pack it
        packnewbuffer $newta $pwname 1 $tapwfr
        if {$mustarrangesashes eq "sasharrange"} {
            spacesashesevenly $pwname
        }
        focustextarea $newta

    } else {
        # a new panedwindow is needed

        # save position and geometry of current textarea, then remove it
        set ind [expr {[lsearch [$pwname panes] $tapwfr] - 1}]
        if {$ind != -1} {
            set aftopt [lindex [$pwname panes] $ind]
            set befopt ""
        } else {
            set aftopt ""
            set befopt [lindex [$pwname panes] 1]
        }
        set panewidth [winfo width $tapwfr]
        set paneheigth [winfo height $tapwfr]
        destroypaneframe $tacur nohierarchydestroy

        # create the new panedwindow, and pack it at the right position
        incr pwmaxid
        set newpw $pwname.pw$pwmaxid
        panedwindow $newpw -orient $neworient -opaqueresize true
        $pwname paneconfigure $newpw -after $aftopt -before $befopt \
            -width $panewidth -height $paneheigth -minsize [expr {$textfontsize * 2}]

        # pack the previously existing textarea first, then the textarea whose
        # name was provided as argument, or:
        #     a hidden buffer, or an empty file if there is none (Tk 8.4)
        #     create and pack a new peer of the current textarea (Tk 8.5)

        packnewbuffer $tacur $newpw 1
        focustextarea $tacur

        # select the buffer to pack
        if {$tatopack != ""} {
            # if the name of the textarea to pack was provided, use it
            # this happens with the commands from the file menu
            set newta $tatopack
        } else {
            # the name of of the textarea to pack was not provided,
            # this happens with the commands from the windows menu
            if {$Tk85 && $splitmode == "file"} {
                # create a peer text widget
                set newta [createpeertextwidget $tacur]
            } else {
                # Tk 8.4 case, or $splitmode == "tile" in Tk 8.5
                if {[llength $listoftextarea] > [gettotnbpanes]} {
                    # if there is a hidden buffer, use it
                    set newta $pad.new[getlasthiddentextareaid]
                } else {
                    # otherwise create an empty textarea
                    set newta [createnewemptytextarea]
                }
            }
        }

        # pack it
        packnewbuffer $newta $newpw 1
        if {$mustarrangesashes eq "sasharrange"} {
            spacesashesevenly $newpw
        }
        focustextarea $newta
    }

    if {$Tk85 && $splitmode == "file"} {
        # adjust the view of the new peer so that it fits the
        # view of the textarea from which it was created
        $newta see [$tacur index insert]
    }

    updatepanestitles
    backgroundcolorizetasks
    restoremenuesbinds
}

proc createnewemptytextarea {} {
# this is a partial copy of proc filesetasnew
# it creates a new empty textarea
    global winopened listoffile
    global listoftextarea pad
    global defaultencoding

    # ensure that the cursor is changed to the default cursor
    event generate [gettextareacur] <Leave>

    incr winopened

    set ta $pad.new$winopened

    dupWidgetOption [gettextareacur] $ta

    set listoffile("$ta",fullname) [mc "Untitled"]$winopened.sce
    set listoffile("$ta",displayedname) [mc "Untitled"]$winopened.sce
    set listoffile("$ta",new) 1
    set listoffile("$ta",thetime)  0
    set listoffile("$ta",disksize) 0
    set listoffile("$ta",language) "scilab"
    setlistoffile_colorize $ta ""
    set listoffile("$ta",readonly) 0
    set listoffile("$ta",binary) 0
    set listoffile("$ta",undostackdepth) 0
    set listoffile("$ta",redostackdepth) 0
    set listoffile("$ta",undostackmodifiedlinetags) [list ]
    set listoffile("$ta",redostackmodifiedlinetags) [list ]
    set listoffile("$ta",progressbar_id) ""
    set listoffile("$ta",encoding) $defaultencoding
    set listoffile("$ta",eolchar) [platformeolchar]
    lappend listoftextarea $ta

    addwindowsmenuentry $winopened $listoffile("$ta",displayedname)

    newfilebind
    showinfo [mc "New script"]
    return $ta
}

proc createpeertextwidget {ta} {
# create a new peer text widget of $ta
    global winopened listoffile
    global listoftextarea pad

    # ensure that the cursor is changed to the default cursor
    event generate [gettextareacur] <Leave>

    # the "original" text widget receives peer id <1>, so that
    # any text widget that has peers has a peer id <X>
    # note that this should however not be used directly in order
    # to detect which textareas are or have peers - use of the
    # if {[getpeerlist $ta] == {}} contraption below is the
    # recommended way to know this
    if {[getpeerlist $ta] == {}} {
        # the peer to create is the first one - add a peerid tag to the
        # existing textarea
        set listoffile("$ta",displayedname) [appendpeerid $listoffile("$ta",displayedname) 1]
    } else {
        # nothing to do on the existing textarea name, the peer to create
        # is not the first one, there is already a buffer with the <1> peer
        # id tag
    }

    incr winopened

    set newta [$ta peer create $pad.new$winopened]

    eval "$newta configure [nondefOpts $ta]"

    # create peer displayedname
    set dispname [appendpeerid $listoffile("$ta",displayedname) \
            [expr {[llength [getpeerlist $ta]] + 1}]]

    set listoffile("$newta",fullname) $listoffile("$ta",fullname)
    set listoffile("$newta",displayedname) $dispname
    set listoffile("$newta",new) $listoffile("$ta",new)
    set listoffile("$newta",thetime)  $listoffile("$ta",thetime)
    set listoffile("$newta",disksize) $listoffile("$ta",disksize)
    set listoffile("$newta",language) $listoffile("$ta",language)
    set listoffile("$newta",colorize) $listoffile("$ta",colorize)
    set listoffile("$newta",readonly) $listoffile("$ta",readonly)
    set listoffile("$newta",binary) $listoffile("$ta",binary)
    set listoffile("$newta",undostackdepth) $listoffile("$ta",undostackdepth)
    set listoffile("$newta",redostackdepth) $listoffile("$ta",redostackdepth)
    set listoffile("$newta",undostackmodifiedlinetags) $listoffile("$ta",undostackmodifiedlinetags)
    set listoffile("$newta",redostackmodifiedlinetags) $listoffile("$ta",redostackmodifiedlinetags)
    set listoffile("$newta",progressbar_id) $listoffile("$ta",progressbar_id)
    set listoffile("$newta",encoding) $listoffile("$ta",encoding)
    set listoffile("$newta",eolchar) $listoffile("$ta",eolchar)
    lappend listoftextarea $newta

    addwindowsmenuentry $winopened $listoffile("$newta",displayedname)

    newfilebind
    showinfo [mc "New view on the same file"]

    return $newta
}

proc tileallbuffers {tileorient} {
    global pad listoftextarea tileprocalreadyrunning
    global Tkbug53f8fc9c2f_shows_up

    if {$tileprocalreadyrunning} {return}
    disablemenuesbinds

    # Remove the existing tiling
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {
            destroypaneframe $ta
        }
    }

    # Configure the main panedwindow for the new orientation of panes
    $pad.pw0 configure -orient $tileorient

    # Decide whether the tile title should be displayed
    if {[llength $listoftextarea] == 1} {
        set showtiletitle 0
    } else {
        set showtiletitle 1
    }

    # Arrange the list of textareas in such a way that the current one
    # will be packed first
    set tacur [gettextareacur]
    set talisttopack [shiftlistofta $listoftextarea $tacur]

    # Pack the new panes
    foreach ta $talisttopack {
        packnewbuffer $ta $pad.pw0 $showtiletitle
        # Oddity here!
        # It should not be needed to call spacesashesevenly for each iteration
        # of the loop - once, at the end, should be enough. But experience
        # proves it does not work. proc spacesashesevenly is definitely
        # correct, when called separately it does indeed what is intended. For
        # some reason, calling several times packnewbuffer and then
        # spacesashesevenly once only does not work
        # it turns out this is bug  53f8fc9c2f - incorrect management of panes geometry
        # http://core.tcl.tk/tk/info/53f8fc9c2f
        if {$Tkbug53f8fc9c2f_shows_up} {
            spacesashesevenly $pad.pw0
        }
    }
    spacesashesevenly $pad.pw0
    focustextarea $tacur
    updatepanestitles

    backgroundcolorizetasks
    restoremenuesbinds
}

proc shiftlistofta {intalist ta} {
# arrange the list $intalist in such a way that element $ta
# comes first. Example: If $ta is the 3rd one:
#     input  ($intalist) : a b c d e f
#     output ($outtalist): c d e f a b
# $ta must be an element of $intalist
    set posta [lsearch -sorted $intalist $ta]
    set outtalist [lrange $intalist $posta end]
    set eltstomove [lrange $intalist 0 [expr {$posta - 1}]]
    foreach elt $eltstomove {
        lappend outtalist $elt
    }
    return $outtalist
}

proc getpwname {tapwfr} {
# get the paned window name in which the widget $tapwfr is packed
# tapwfr is usually a frame (pane) of a panedwindow in which a textarea is
# packed, but it can also be a full panedwindow
# in fact this proc takes a widget name as an input and returns the winfo
# parent widget:
#          .wid1.wid2.wid3.wid4  -->  .wid1.wid2.wid3
# however, the implementation below is preferred since winfo parent returns
# errors when the parent has already been destroyed by proc destroypaneframe
# destroying an already destroyed widget causes no error and this simplifies
# the hierarchy destruction (see destroypaneframe)
    return [string replace $tapwfr [string last . $tapwfr] end]
}

proc getpaneframename {textarea} {
# get the frame name in which $textarea is currently packed
# or "none" if $textarea is not packed
    global pwframe
    if {[info exists pwframe($textarea)]} {
        return $pwframe($textarea)
    } else {
        return "none"
    }
}

proc gettafromwidget {w} {
# get the textarea name that is currently packed into $w
# (if $w is a frame, otherwise return "none")
    global pwframe listoftextarea
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {
            if {$pwframe($ta) == $w} {
                return $ta
            }
        }
    }
    return "none"
}

proc gettaidfromwidgetname {w} {
# parse the widget name $w to extract the textarea id, which is the trailing
# number in the widget name
# $w is supposed (this is not checked) to be a text widget (named $pad.newX)
# return value is number X
    global pad
    set taid ""
    scan $w $pad.new%d taid
    if {$taid == ""} {
        tk_messageBox -message "Unexpected widget was received by proc gettaidfromwidgetname: $w"
    }
    return $taid
}

proc ispanetitletruncated {ta} {
# return true if and only if the pane title is truncated, i.e. when it
# cannot be seen because the Scipad window is not large enough
    set tapwfr [getpaneframename $ta]
    if {[winfo rootx $tapwfr.topbar] < [winfo rootx $tapwfr.panetitle]} {
        return false
    } else {
        return true
    }
}

proc createpaneframename {textarea targetpw} {
# construct the frame name in which $textarea is to be packed
# and store this name in the global array pwframe
    global pad pwframe
    set id [gettaidfromwidgetname $textarea]
    set paneframename $targetpw.f$id
    while {[winfo exists $paneframename]} {
        incr id
        set paneframename $targetpw.f$id
    }
    set pwframe($textarea) $paneframename
    return $paneframename
}

proc destroypaneframe {textarea {hierarchy "destroyit"}} {
# forget about the frame and pane in which $textarea is packed
# i.e. this destroys the packing of $textarea without destroying
# the textarea itself
# the optional argument $hierarchy might be "destroyit" or
# "nohierarchydestroy", the former being the normal mode, and the
# latter being used when repacking to tell this proc not to destroy
# the containing panedwindow itself if there is no remaining pane
    global pad pwframe

    # remove scrollbars commands so that an unpacked textarea does not
    # update the scrollbar, which depending on the order these commands
    # are launched, can lead to wrong scrollbars sizes and scrollbars flashes
    $textarea configure -xscrollcommand ""
    $textarea configure -yscrollcommand ""

    set tapwfr [getpaneframename $textarea]
    set pwname [getpwname $tapwfr]
    $pwname forget $tapwfr
    destroy $tapwfr

    if {$hierarchy == "destroyit"} {
        # the containing (parent) panedwindow itself must be destroyed if
        # there is no remaining panes, but don't destroy the main panedwindow
        # this check is made up to the main level of paned window
        while {[$pwname panes] == "" && $pwname != "$pad.pw0"} {
            destroy $pwname
            set pwname [getpwname $pwname]
        }
    }

    unset pwframe($textarea)

    if {$hierarchy == "destroyit"} {
        mergepanedwindows1 $pwname
        mergepanedwindows2 $pwname
    }
}

proc mergepanedwindows1 {pwname} {
# merge remaining panedwindows according to the new geometry
# because otherwise after many open/close of tiled buffers the grey
# borders do accumulate
#
# Step 1: this proc merges panedwindows in the sense that it removes
# superfluous levels of panedwindow nesting
#
# Example:
#   If getpwtree outputs:
# {.scipad.pw0.pw1 horizontal {{.scipad.pw0.pw1.f2 .scipad.new2}
#                              {.scipad.pw0.pw1.f3 .scipad.new3}}}
#   then it means that there is a single panedwindow pw1 that is
# packed in $pad.pw0. This level pw1 can (must) be removed and this
# is what this proc is performing by repacking directly in pw0 all
# what was in pw1

    set pa [$pwname panes]
    if {[llength $pa] == 1} {
        # merge only when there is one single pane

        set pa [lindex $pa 0]
        if {[isapanedwindow $pa]} {
            # and only when this single pane contains a panedwindow (not a frame)

            $pwname configure -orient [$pa cget -orient]

            # create list of impacted widgets, i.e. those that need to be repacked
            set torepack [getpwtree $pa]

            # save the sashes positions from all paned windows contained in $pa
            set sashesrelpos [getrelsashespositionallpw $pa]

            # forget the old packing
            foreach w $torepack {
                destroywidget $w
            }

            # forget the superfluous level
            $pwname forget $pa
            destroy $pa

            # pack in the panedwindow one level above
            foreach w $torepack {
                repackwidget $w $pwname
            }

            # restore sashes positions by setting them in $pwname
            setrelsashespositionallpw $pwname $sashesrelpos
        }
    }
}

proc mergepanedwindows2 {pwname} {
# merge remaining panedwindows according to the new geometry
# because otherwise after many open/close of tiled buffers the grey
# borders do accumulate
#
# Step 2: this proc merges panedwindows in the sense that it removes
# superfluous panedwindows
#
# Example:
#   If getpwtree outputs:
# {.scipad.pw0.pw1 horizontal {{.scipad.pw0.pw1.f2 .scipad.new2}}}
# {.scipad.pw0.pw2 horizontal {{.scipad.pw0.pw2.f1 .scipad.new1}}}
#   then it means that there are two panedwindows pw1 and pw2 that are
# packed in $pad.pw0. These levels pw1 and pw2 can be removed because
# they contain each one single pane. Removal of pw1 and pw2 and
# repacking their content directly into $pad.pw0 is what this proc is
# performing

    global pad

    # merge only when [$pwname panes] contains simple elements, i.e
    # frames or panedwindows with one single pane
    set pwinside false
    set doit true
    foreach pa [$pwname panes] {
        if {[isapanedwindow $pa]} {
            set pwinside true
            if {[llength [$pa panes]] != 1} {
                set doit false
                break
            }
        } else {
            # $pa is a frame, nothing to do, keep $doit value
        }
    }

    # if there is no panedwindow in $pwname children list,
    # and if there is more than one pane,
    # i.e. if all the children are frames and if there is more than one child,
    # then don't merge
    if {!$pwinside && [llength [$pwname panes]] != 1} {
        set doit false
    }

    # determine parent panedwindow name
    set parpw [getpwname $pwname]
    if {$parpw == $pad} {
        set doit false
    }

    if {$doit} {
        # save position (in the packing order) of the panedwindow to destroy
        set ind [expr {[lsearch [$parpw panes] $pwname] - 1}]
        if {$ind != -1} {
            set aftopt [lindex [$parpw panes] $ind]
            set befopt ""
        } else {
            set aftopt ""
            set befopt [lindex [$parpw panes] 1]
        }

        # create list of impacted widgets, i.e. those that need to be repacked
        set torepack [getpwtree $pwname]

        # save the sashes positions from all paned windows contained in $parpw
        set sashesrelpos [getrelsashespositionallpw $parpw]

        # forget the old packing
        foreach w $torepack {
            destroywidget $w
        }

        # forget the superfluous level
        $parpw forget $pwname
        destroy $pwname

        # pack in the panedwindow one level above
        foreach w $torepack {
            repackwidget $w $parpw $aftopt $befopt
        }

        # restore sashes positions by setting them in $parpw
        setrelsashespositionallpw $parpw $sashesrelpos
    }
}

proc destroywidget {w} {
# recursive ancillary for proc mergepanedwindows1 and mergepanedwindows2

    if {[llength $w] == 2 && [isaframe [lindex $w 0]]} {
        # $w is a frame node list
        destroypaneframe [gettafromwidget [lindex $w 0]] nohierarchydestroy

    } elseif {[llength $w] == 3 && [isapanedwindow [lindex $w 0]]} {
        # $w is a panedwindow node list (see format in getpwtree)
        foreach sw [lindex $w 2] {
            destroywidget $sw
        }

    } else {
        # can't happen in principle
        tk_messageBox -message "Unexpected widget in proc destroywidget ($w): please report"
    }
}

proc repackwidget {w pwname {aftopt ""} {befopt ""}} {
# recursive ancillary for proc mergepanedwindows1 and mergepanedwindows2
# $w is the name of the widget (a frame or a panedwindow) to repack in
# the panedwindow $pwname after $aftopt and before $befopt panes
    global pwmaxid textfontsize

    if {[llength $w] == 2 && [isaframe [lindex $w 0]]} {
        # $w is a frame node list, just pack it
        set ta [lindex $w 1]
        packnewbuffer $ta $pwname 1 $aftopt $befopt
        spacesashesevenly $pwname
        focustextarea $ta

    } elseif {[llength $w] == 3 && [isapanedwindow [lindex $w 0]]} {
        # $w is a panedwindow node list (see format in getpwtree)

        # insert a new paned window after last existing pane in current paned window
        set lastexistingpane [lindex [$pwname panes] end]
        incr pwmaxid
        set newpw $pwname.pw$pwmaxid
        panedwindow $newpw -orient [lindex $w 1] -opaqueresize true
        $pwname paneconfigure $newpw -after $lastexistingpane -minsize [expr {$textfontsize * 2}]

        # repack anything that was previously in this paned window
        foreach sw [lindex $w 2] {
            repackwidget $sw $newpw
        }

    } else {
        # can't happen in principle
        tk_messageBox -message "Unexpected widget in proc repackwidget ($w): please report"
    }
}

proc getrelsashespositionallpw {pwname} {
# recursive ancillary for proc mergepanedwindows1 and mergepanedwindows2
# this proc produces a nested list of sashes positions, first for the
# given paned window, then recursively for all paned windows packed in it
    set sashesrelpos [list [getrelsashesposition $pwname]]
    foreach w [$pwname panes] {
        if {[isapanedwindow $w]} {
            lappend sashesrelpos [getrelsashespositionallpw $w]
        }
    }
    return $sashesrelpos
}

proc setrelsashespositionallpw {pwname sashesrelpos} {
# recursive ancillary for proc mergepanedwindows1 and mergepanedwindows2
# this proc uses a list $sashesrelpos created by proc getrelsashespositionallpw
# and applies these sashes positions to the given paned window $pwname and
# the paned windows packed in it
    set i 0
    setrelsashesposition $pwname [lindex $sashesrelpos $i]
    foreach w [$pwname panes] {
        if {[isapanedwindow $w]} {
            incr i
            setrelsashespositionallpw $w [lindex $sashesrelpos $i]
        }
    }
}

proc getpwtree {{root ""}} {
# get the panedwindow hierarchical (sub-)tree in a nested list whose
# elements are either:
#    a list with two elements: { frame_name textarea } if the child 
# is a frame;
# or a list of three elements: { pw_pathname orientation {sub-nodes} }
# in case the child is a paned window.
# The tree traversal starts from the panedwindow node $root and is
# ordered thanks to the use of [$root panes] ([winfo children $root]
# does not order the children in the packing order!)

    global pad
    if {$root == ""} {set root $pad.pw0}
    set res {}
    foreach w [$root panes] {
        if {[isapanedwindow $w]} {
            lappend res [list $w [$w cget -orient] [getpwtree $w]]
        } elseif {[isaframe $w]} {
            lappend res [list $w [gettafromwidget $w]]
        } else {
            # sub-elements of a frame, such as panetitle, they are not
            # interesting parts of the tree - nothing to do, just go on
            tk_messageBox -message "Unexpected widget in proc getpwtree ($w): please report"
        }
    }
    return $res
}

proc isaframe {w} {
# check whether the widget passed as an argument is a frame or not
# return 1 if yes, or 0 otherwise
    return [isasomething $w f]
}

proc isapanedwindow {w} {
# check whether the widget passed as an argument is a paned window or not
# return 1 if yes, or 0 otherwise
    return [isasomething $w pw]
}

proc isasomething {w something} {
# check whether the widget passed as an argument is a "something" or not
# return 1 if yes, or 0 otherwise
# "something" can be "pw" for a paned window, or "f" for a frame
# well, I could have used [winfo class ] instead...
    set lastelt [lindex [split $w .] end]
    scan $lastelt $something%d somethingid
    if {[info exists somethingid]} {
        return 1
    } else {
        return 0
    }
}

proc isdisplayed {textarea} {
# check whether $textarea is currently packed, i.e. visible
# return 1 if yes, or 0 otherwise
    if {[getpaneframename $textarea] != "none"} {
        return 1
    } else {
        return 0
    }
}

proc getlistofhiddenta {} {
# retrieve the list of currently hidden textareas (including peers)
    global listoftextarea
    set listofhidden {}
    foreach ta $listoftextarea {
        if {![isdisplayed $ta]} {
            lappend listofhidden $ta
        }
    }
    return $listofhidden
}

proc isfilehidden {ta} {
# a file is displayed in one (or more (peers)) textareas
# a file is hidden if all the textareas containing it are hidden
# return true if the file contained in $ta is hidden, i.e.
#             if $ta and all his peers are hidden
# return false otherwise
    foreach apeer [getfullpeerset $ta] {
        if {[isdisplayed $apeer]} {
            return false
        }
    }
    return true
}

proc getlistoftacontaininghiddenfiles {} {
# a file is displayed in one (or more (peers)) textareas
# a file is hidden if all the textareas containing it are hidden
# this proc retrieves the list of textareas (including peers) that contain hidden files
    global listoftextarea
    set listofta {}
    foreach ta [filteroutpeers $listoftextarea] {
        if {[isfilehidden $ta]} {
            foreach apeer [getfullpeerset $ta] {
                lappend listofta $apeer
            }
        }
    }
    return $listofta
}

proc getlistoftanotcontainingfileshowninta {ta} {
# retrieve the list of textareas (including peers) that do not contain
# the file that is displayed in textarea $ta
    global listoftextarea
    set allpeersofta [getfullpeerset $ta]
    set listofwanted {}
    foreach ta $listoftextarea {
        if {[lsearch -exact $allpeersofta $ta] == -1} {
            lappend listofwanted $ta
        }
    }
    return $listofwanted
}

proc getlistoftacontainingfile {fullfilepath} {
# return the list of textareas (including peers) containing the file
# with full name $file
# if there is none, return the empty list
    global listoftextarea listoffile
    set targetta {}
    foreach ta $listoftextarea {
        if {$listoffile("$ta",fullname) eq $fullfilepath} {
            lappend targetta $ta
        } else {
        }
    }
    return $targetta
}

proc getlistoftacontainingfiletail {filetail} {
# return the list of textareas (including peers) containing the file
# with file tail $filetail
# if there is none, return the empty list
    global listoftextarea listoffile
    set targetta {}
    foreach ta $listoftextarea {
        if {[file tail $listoffile("$ta",fullname)] eq $filetail} {
            lappend targetta $ta
        } else {
        }
    }
    return $targetta
}

proc gettotnbpanes {} {
# compute the total number of panes displaying a textarea
    global listoftextarea
    set tot 0
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {incr tot}
    }
    return $tot
}

proc getlistofpw {{root ""}} {
# create the list of used paned windows
    global pad
    if {$root == ""} {set root $pad.pw0}
    set res $root
    foreach w [$root panes] {
        if {[isapanedwindow $w]} {
            set res [concat $res [getlistofpw $w]]
        }
    }
    return $res
}

proc getpeerlist {ta} {
# wrapup to [$ta peer names] taking into account the fact that peers are
# available only from Tk 8.5
# warning: [$ta peer names] returns a list that does NOT contain $ta itself
# this proc is designed so that code such as
#    foreach peer [getpeerlist $ta] {
#        do_the_right_thing
#    }
# will work either with Tk 8.4 or 8.5 without the need to test for the
# value of $Tk85. In 8.4 since there is no peer the loop above will just
# do nothing because the return value of proc getpeerlist is {}
    global Tk85
    if {$Tk85} {
        return [$ta peer names]
    } else {
        return [list ]
    }
}

proc getfullpeerset {ta} {
# return the full peers set, i.e. a flat list composed of $ta itself first,
# plus [getpeerlist $ta] appended
# this proc is designed so that code such as
#    foreach ta1 [getfullpeerset $ta] {
#        do_the_right_thing
#    }
# will work either with Tk 8.4 or 8.5 without the need to test for the
# value of $Tk85. In 8.4 since there is no peer the loop above will just
# execute once because the return value of [getfullpeerset $ta] is $ta
    return [linsert [getpeerlist $ta] 0 $ta]
}

proc filteroutpeers {talist} {
# $talist being a list of textareas, return a list of textareas where
# no peer shows up
# this is done by descending $talist and checking whether each element
# is a peer of a preceding one or not, which is decided based on getpeerlist
# (i.e. [$ta peer names]), and NOT on the presence of the peer id tag <X>
# in the displayedname
# there is no such thing as the "original" text widget from which peers
# are deduced. All peers are equivalent, including the first textarea
# from which the first peer was created
# in the algorithm below, the first item in $talist that has not yet
# been identified as a peer is kept in $outlist
    set nopeertalist [list ]
    set peertalist [list ]
    foreach ta $talist {
        foreach ta1 [getpeerlist $ta] {
            lappend peertalist $ta1
        }
        if {[lsearch -exact $peertalist $ta] == -1} {
            lappend nopeertalist $ta
        }
    }
    return $nopeertalist
}

proc appendpeerid {fname peerid} {
# append peer identifier to $fname, i.e. if fname contains
# "dir1/dir2/helloworld.sci", return "dir1/dir2/helloworld.sci <X>"
# where X is a (potentially multiple characters) number
# X is the given $peerid parameter if this value is greater than
# zero (otherwise it is ignored, which is very useful to avoid to
# test on $peerid != -1 elsewhere in the code before calling proc
# appendpeerid)
# if $fname already contains a peer identifier, it is first removed
    global Tk85
    if {!$Tk85} {
        return $fname
    } else {
        foreach {peerfname oldpeerid} [removepeerid $fname] {}
        if {$peerid > 0} {
            append peerfname " <$peerid>"
        }
        return $peerfname
    }
}

proc removepeerid {fname} {
# remove peer identifier prepended to $fname, i.e. if fname contains
# the string "dir1/dir2/helloworld.sci <3>"
# then return the list {dir1/dir2/helloworld.sci 3}
# if $fname does not contain a peer identifier, then return {$fname -1}
    global Tk85
    if {!$Tk85} {
        return [list $fname -1]
    } else {
        set pos1 [string last " <" $fname]
        if {$pos1 == -1} {
            # no peer id in $fname
            return [list $fname -1]
        } else {
            set filename [string replace $fname $pos1 end]
            set peerid [string replace $fname 0 "$pos1+1"]
            set peerid [string replace $peerid end end]
            return [list $filename $peerid]
        }
    }
}

proc spaceallsashesevenly {} {
# space evenly all the sashes of all the existing paned windows
    foreach pw [getlistofpw] {
        spacesashesevenly $pw
    }
}

proc spacesashesevenly {pwname} {
# space evenly the sashes attached to the panes of paned window $pwname
    update
    set nbpanes [llength [$pwname panes]]
    set paneheight [expr {[winfo height $pwname] / $nbpanes}]
    set panewidth  [expr {[winfo width  $pwname] / $nbpanes}]
    for {set i 0} {$i < [expr {$nbpanes - 1}]} {incr i} {
        set paneposx [expr {$panewidth  * ($i + 1)}]
        set paneposy [expr {$paneheight * ($i + 1)}]
        $pwname sash place $i $paneposx $paneposy
        update idletasks
    }
}

proc spaceallsasheskeeprelsizes {} {
# space all the sashes of all the existing paned windows
# while keeping their relative sizes in each panedwindow
# this proc is only used with Tk < 8.5 since in Tk 8.5
# this behavior is better obtained with -stretch always
# option for all panes

    set pwlist [getlistofpw]

    # save the current sashes positions before updating the display
    foreach pw $pwlist {
        set nbpanes($pw) [llength [$pw panes]]
        for {set i 0} {$i < [expr {$nbpanes($pw) - 1}]} {incr i} {
            set sashxy($pw,$i) [$pw sash coord $i]
        }
        set pwheight($pw) [winfo height $pw]
        set pwwidth($pw)  [winfo width  $pw]
    }

    update

    # set new panes sizes and sashes positions
    foreach pw $pwlist {
        set pwheight2 [winfo height $pw]
        set pwwidth2  [winfo width  $pw]
        # warning: here a case where expr must not be braced
        set incfacty [expr $pwheight2. / $pwheight($pw)]
        set incfactx [expr $pwwidth2.  / $pwwidth($pw) ]
        for {set i 0} {$i < [expr {$nbpanes($pw) - 1}]} {incr i} {
            set newx [expr {round([lindex $sashxy($pw,$i) 0] * $incfactx)}]
            set newy [expr {round([lindex $sashxy($pw,$i) 1] * $incfacty)}]
            $pw sash place $i $newx $newy
            update idletasks
        }
    }

}

proc getrelsashesposition {pwname} {
# return a list containing the positions of the sashes of the given paned window
# $pwname, measured relatively to the size of the panedwindow
    set res {}
    set orient [$pwname cget -orient]
    for {set sashind 0} {$sashind < [expr {[llength [$pwname panes]] - 1}]} {incr sashind} {
        set sashcoords [$pwname sash coord $sashind]
        foreach {sashx sashy} $sashcoords {}
        if {$orient eq "horizontal"} {
            set pwsize [winfo width $pwname]
            set relsashx [expr {1.0 * $sashx / $pwsize}]
            set relsashy $sashy
        } else {
            set pwsize [winfo height $pwname]
            set relsashx $sashx
            set relsashy [expr {1.0 * $sashy / $pwsize}]
        }
        lappend res [list $relsashx $relsashy]
    }
    return $res
}

proc setrelsashesposition {pwname sashesrelpos} {
# set the sashes positions in paned window $pwname by using the relative
# sashes positions $sashesrelpos (these are supposed to be measured
# relatively to the size of $pwname)
    if {$sashesrelpos eq {}} {
        return
    }
    set orient [$pwname cget -orient]
    for {set sashind 0} {$sashind < [expr {[llength [$pwname panes]] - 1}]} {incr sashind} {
        set sashrelcoords [lindex $sashesrelpos $sashind]
        foreach {relsashx relsashy} $sashrelcoords {}
         if {$orient eq "horizontal"} {
            set pwsize [winfo width $pwname]
            set sashx [expr {round(1.0 * $relsashx * $pwsize)}]
            set sashy $relsashy
        } else {
            set pwsize [winfo height $pwname]
            set sashx $relsashx
            set sashy [expr {round(1.0 * $relsashy * $pwsize)}]
        }
       $pwname sash place $sashind $sashx $sashy
    }
}

proc getsashfollowing {pwname w} {
# return a list of two elements:
#   - the index of the sash separating pane $w and its next neighbour
#     in panedwindow $pwname
#   - the total size of the panes before (and not including) $w
# hypothesis (unchecked in this proc):
#   - there is more than one pane in the panedwindow (thus there is at least one sash)
#   - $w is not the last pane
    set allpanesinpwname [$pwname panes]
    if {[$pwname cget -orient] eq "vertical"} {
        set heightwidth "height"
    } else {
        set heightwidth "width"
    }
    set sashsize [expr {[$pwname cget -sashwidth] + [$pwname cget -sashpad]}]
    set totsize 0
    for {set sashind 0} {$sashind < [llength $allpanesinpwname]} {incr sashind} {
        set curpane [lindex $allpanesinpwname $sashind]
        if {$curpane eq $w} {
            return [list $sashind $totsize]
        }
        incr totsize [expr {[winfo $heightwidth $curpane] + $sashsize}]
    }
    return [list "none" "none"]
}

proc getlayoutstructure {} {
# create a list representing the complete textarea layout structure,
# for all saved files (i.e. ignoring "UntitledX.sce" files)
# this list has the following structure:
#   at first level there are two elements:
#     { hidden fileinfo1 fileinfo2 ... } { visible pwstruct }
#   one level deeper:
#     the first element has information about hidden textareas
#     the second element has information about packed textareas
#   one level deeper:
#     fileinfoi is a (flat) list whose structure is described in proc constructtainfo
#     pwstruct is a (nested) list whose structure is described in proc getfullpwstructureinfo

    set res {}

    # first, get information about all hidden textareas
    set res_h {}
    lappend res_h "hidden"
    foreach ta [getlistofhiddenta] {
        set tainfo [constructtainfo $ta]
        if {$tainfo ne {}} {
            lappend res_h $tainfo
        }
    }

    # second, get information about all visible textareas
    set res_v {}
    lappend res_v "visible"
    set pwstruct [getfullpwstructureinfo]
    lappend res_v $pwstruct

    # construct full final information result
    return [list $res_h $res_v]
}

proc constructtainfo {ta} {
# return a flat list containing certain information about what is
# contained in textarea $ta
# if $ta contains an unsaved file, the output list is empty
# otherwise the output format is:
#   { "tainfo" fullname encoding insertcursorposition }

    global listoffile
    set listoftainfo {}
    if {$listoffile("$ta",new) == 0} {
        # file was opened from disk, and can be restored later (maybe)
        lappend listoftainfo "tainfo"
        lappend listoftainfo $listoffile("$ta",fullname)
        lappend listoftainfo $listoffile("$ta",encoding)
        lappend listoftainfo [$ta index insert]
        lappend listoftainfo [gettaselind $ta any] 
    } else {
        # new unsaved files ("UntitledX.sce") are ignored
    }
    return $listoftainfo
}

proc getfullpwstructureinfo {{root ""}} {
# return a list structure containing information about all packed textareas
#
# the panedwindow hierarchical (sub-)tree is traversed and its content is
# processed
# the tree traversal starts from the panedwindow node $root and is
# ordered thanks to the use of [$root panes]
# this proc is inspired from proc getpwtree but returns a different list
#
# the returned list has exactly three elements:
#    1. the orientation of the given paned window $root
#    2. a list of elements, each of which being either
#          a tainfo (see proc constructtainfo)
#       or
#          a list having the same structure as the output list of the
#          present proc, or an empty list, and that gives information
#          about a panedwindow nested in $root
#          this list describes the nested panedwindow informations, and is
#          the same structure as the one for $root, but this time it gives
#          information about a child panedwindow of $root
#    3. the list of sashes {x y} positions of the given paned window $root
#       (measured relatively to the size of the paned window), if all panes
#       contain either a non-new textarea or a nested paned window, otherwise
#       the empty list

    global pad
    if {$root == ""} {
        set root $pad.pw0
    }
    set res1 {}
    set curorient [$root cget -orient]
    set sashflag true
    foreach w [$root panes] {
        if {[isapanedwindow $w]} {
            lappend res1 [getfullpwstructureinfo $w]
        } elseif {[isaframe $w]} {
            set tainfo [constructtainfo [gettafromwidget $w]]
            if {$tainfo ne {}} {
                lappend res1 $tainfo
            } else {
                # unsaved textareas, which produce {} as a result from
                # proc constructtainfo, are ignored, therefore do nothing
                # in the $res1 result list, but trace this fact for later
                # construction of $res2
                set sashflag false
            }
        } else {
            # should never happen
            tk_messageBox -message "Unexpected widget in proc getfullpwstructureinfo ($w): please report"
        }
    }
    if {$sashflag} {
        # the given paned window $root does only contain saved textareas
        set res2 [getrelsashesposition $root]
    } else {
        set res2 {}
    }
    return [list $curorient $res1 $res2]
}

proc restorelayoutstructure {struct} {
# parse the layout structure $struct and recreate it
# assert: Scipad has just been launched, and only has
#         the empty initial textarea
#         OR
#         there is only a single empty textarea open,
#         which is the case for instance after a call
#         to closeallreallyall

    global Tk85 pad restorelayoutrunning closeinitialbufferallowed

    set restorelayoutrunning true

    set hidden [lindex $struct 0]
    set hidden [lreplace $hidden 0 0]
    set therearehiddenta [expr {[llength $hidden] > 0}]
    set visible [lindex $struct 1]
    set visible [lindex $visible 1]
    set therearevisibleta [expr {[lindex $visible 1] ne {}}]

    set listofnotfoundfiles {}

    # a temporary textarea is used for packing all the files
    # this textarea always corresponds to the first pane of the root ($pad.pw0) panedwindow
    if {$therearehiddenta || $therearevisibleta} {
        # owing to code genericity, the temporary "sandboxta" in which everything
        # is rebuilt must not be the initial empty textarea with its special
        # auto-close feature
        # therefore, closure of the initial empty textarea is done here
        # which is wanted because it has to be controlled (as opposed
        # to left to the first openfile encountered in the process
        # that follows)
        if {$closeinitialbufferallowed} {
            filesetasnew "NoRestoreLayoutRunningCheck"
        }
        set sandboxta [gettextareacur]
    }

    # restore all hidden textareas
    if {$therearehiddenta} {
        foreach {listofhiddennotfoundfiles stilltherearehiddenta} [repackhiddenlayout $hidden $sandboxta] {}
        foreach fil $listofhiddennotfoundfiles {
            lappend listofnotfoundfiles $fil
        }
    } else {
        set stilltherearehiddenta false
    }

    # repack all visible textareas
    if {$therearevisibleta} {
        foreach {listofvisiblenotfoundfiles stilltherearevisibleta \
                 sashesrepositioninfo restoreselinfo} \
                [repackvisiblelayout $visible $pad.pw0 $sandboxta] {}
        foreach fil $listofvisiblenotfoundfiles {
            lappend listofnotfoundfiles $fil
        }
    } else {
        set stilltherearevisibleta false
        set restoreselinfo [list ]
    }

    # must be before closecurfile below,
    # otherwise closecurfile does nothing
    set restorelayoutrunning false

    # delete the temporary textarea and its associated pane
    if {$stilltherearehiddenta || $stilltherearevisibleta} {
        # at least one file could be reopened
        # visibility of $sandboxta (in the first pane of the root
        # ($pad.pw0) panedwindow) is preserved by proc repackhiddenlayout
        # and proc repackvisiblelayout, therefore focustextarea is
        # used instead of showtext (that would mess up the layout
        # if $sandboxta would be hidden)
        focustextarea $sandboxta
        closecurfile "NoSaveQuestion"
        if {$stilltherearehiddenta && $stilltherearevisibleta} {
            hidetext [gettextareacur]
        }
        if {$restoreselinfo ne {}} {
            set tawithsel [lindex $restoreselinfo 0]
            set selranges [lindex $restoreselinfo 1]
            update
            focustextarea $tawithsel
            eval "$tawithsel tag add sel $selranges"
            set startofselind [lindex $selranges 0]
            $tawithsel see $startofselind
            $tawithsel mark set insert $startofselind
        }
    }

    set restorelayoutrunning true

    updatepanestitles
    backgroundcolorizetasks

    # report about files that could not be found
    # and were therefore not restored
    if {$listofnotfoundfiles ne {}} {
        set notfoundfiles ""
        foreach fil $listofnotfoundfiles {
            set notfoundfiles "$notfoundfiles$fil\n"
        }
        tk_messageBox -message [concat \
            [mc "Some files that were opened when Scipad previously exited could not be reopened and were ignored.\n\
                 You might now miss read access to them, or maybe they do not exist anymore.\n\n\
                 The following files were ignored"] ":\n\n$notfoundfiles"] \
            -icon warning -title [mc "Ignored files"] -type ok -parent $pad
    }

    set restorelayoutrunning false
}

proc repackhiddenlayout {hiddennodes sandboxta} {
# ancillary for proc restorelayoutstructure
# this proc repacks the files identified as hidden
# at the time the last scipad session exited

    global Tk85

    set listofnotfoundfiles {}

    set couldopenatleastonefile false

    foreach fileinfo $hiddennodes {

        foreach {dropthis fullna enc insertcursorpoint selranges} $fileinfo {}
        set listoftahavingfile [getlistoftacontainingfile $fullna]

        if {$listoftahavingfile eq {}} {

            # the file is not yet open, open it in current tile
            # [file exist ...] must be tested because proc openfile
            # creates a new buffer if the requested file does not
            # exist, which is not the desired behaviour
            if {[file exists $fullna]} {
                set openactionsuccess [openfile $fullna currenttile $enc]
            } else {
                set openactionsuccess false
            }
            if {!$openactionsuccess} {
                lappend listofnotfoundfiles $fullna
            } else {
                set newta [gettextareacur]
                $newta mark set insert $insertcursorpoint
                $newta see insert
                # hidden textareas never have selections, therefore
                # $selranges is always the empty list thus of no use
                set couldopenatleastonefile true
                # done once only at the end of this proc
                #showtext $sandboxta
            }

        } else {

            # the file is already open, create a peer from any existing
            # peer (which is the first peer found)
            if {$Tk85} {
                # at this point there is always at least one element in $listoftahavingfile
                set ta [lindex $listoftahavingfile 0]
                showtext $ta
                splitwindow vertical "" file
                maximizebuffer
                set newta [gettextareacur]
                $newta mark set insert $insertcursorpoint
                $newta see insert
                # hidden textareas never have selections, therefore
                # $selranges is always the empty list thus of no use
                set couldopenatleastonefile true
                # done once only at the end of this proc
                #showtext $sandboxta
            } else {
                # if we're here it means that Scipad when last closed was
                # running on Tk 8.5 and had peers open, and that Scipad is
                # now running on Tk 8.4 (happens during Scipad development)
                # with Tk8.4 one cannot create peers, so just ignore these
                # entries of the layout structure
            }
        }
    }

    # when exiting this proc, $sandboxta must be the active textarea
    showtext $sandboxta

    return [list $listofnotfoundfiles $couldopenatleastonefile]
}

proc repackvisiblelayout {subnode parentpwname sandboxta} {
# recursive ancillary for proc restorelayoutstructure
# this proc repacks the files identified as visible
# at the time the last scipad session exited

    global Tk85 pad pwmaxid textfontsize

    set listofnotfoundfiles {}
    set sashesrepositioninfo {}

    set orientat   [lindex $subnode 0]
    set panesinfos [lindex $subnode 1]
    set sashinfos  [lindex $subnode 2]

    set restoreselinfo [list ]

    # create a new panedwindow and add it as the currently last pane
    # of the parent panedwindow
    incr pwmaxid
    set pwname $parentpwname.pw$pwmaxid
    panedwindow $pwname -orient $orientat -opaqueresize true
    $parentpwname add $pwname
    $parentpwname paneconfigure $pwname -minsize [expr {$textfontsize * 2}]

    # tricky: this is needed to have a very small first pane of the main
    # panedwindow so that the second pane that was added two lines above
    # has the largest possible room, which in turn results in placing
    # sashes correctly (at the end of the present proc) with no "clamping"
    # issue resulting in wrong sashes positions in some cases
    # this problem was seen in the following case:
    # . layout file (test.lay):
    #   {hidden {tainfo {C:/Users/francois/Documents/Development/Divers bazar/runtcltkcomp-fossil debug.bat} cp1252 3.27 {}} {tainfo {C:/Users/francois/Documents/Development/Documents Scilab/Compilation/Compilation scicoslab cygwin+mingw/Compil scicoslab.txt} cp1252 23.10 {}}} {visible {vertical {{tainfo C:/Users/francois/Documents/Development/scipad-svn/trunk/tools/installScipadInScilab5.sce cp1252 7.26 {}} {horizontal {{tainfo {C:/Users/francois/Documents/Development/Divers bazar/Tk workflow with fossil.txt} cp1252 1.0 {}} {tainfo C:/Users/francois/Documents/Development/scipad-svn/trunk/src/readme.txt cp1252 4.6 {}}} {{0.09932885906040269 1}}}} {{1 0.9202551834130781}}}}
    # . load this layout from Scipad: OK
    # . load again the same layout from Scipad: sashes position wrong
    # . again: OK
    # . again: sashes position wrong
    # . ...and so on, it was OK once over two tries
    # the three lines below fix this issue
    if {$parentpwname eq "$pad.pw0"} {
        $parentpwname sash place 0 0 0
    }
    # <TODO>: a better fix for this issue would be to restore sashes position
    #         after full reconstruction of the panedwindow tree, instead of
    #         restoring the sashes positions after reconstruction of each nested
    #         level

    set couldopenatleastonefile false

    # $sashinfos (saved positions of the sashes) will be used for restoring
    # these sash positions only if:
    #    - it is not the empty list (which was caused at saving time by non-saved
    #      files, which are not restored when reopening Scipad, therefore sash positions
    #      as they were when leaving Scipad are meaningless at reopen time)
    #  and
    #    - all content of the given subnode could be reopened, i.e.
    #        ~ all files in the subnode could be reopened
    #        ~ for each panedwindow of the subnode, at least one file of this panedwindow
    #          could be reopened
    if {$sashinfos ne {}} {
        set canusesashinfos true
    } else {
        set canusesashinfos false
    }

    # pack each element in the newly created panedwindow $pwname
    foreach apane $panesinfos {
 
        if {[lindex $apane 0] eq "tainfo"} {

            # this element is a tainfo
            foreach {dropthis fullna enc insertcursorpoint selranges} $apane {}
            set listoftahavingfile [getlistoftacontainingfile $fullna]

            if {$listoftahavingfile eq {}} {

                # the file is not yet open, open it
                #focustextarea $sandboxta  ; # useless since already the case
                # [file exist ...] must be tested because proc openfile
                # creates a new buffer if the requested file does not
                # exist, which is not the desired behaviour
                if {[file exists $fullna]} {
                    set openactionsuccess [openfile $fullna currenttile $enc]
                } else {
                    set openactionsuccess false
                }
                if {!$openactionsuccess} {
                    lappend listofnotfoundfiles $fullna
                    set canusesashinfos false
                } else {
                    # pack it at the correct place
                    set newta [gettextareacur]
                    showtext $sandboxta
                    packnewbuffer $newta $pwname 1
                    spacesashesevenly $pwname
                    $newta mark set insert $insertcursorpoint
                    $newta see insert
                    if {$selranges ne {}} {
                        # $selranges ne {}  may be true for at most one textarea
                        # (or for several peer textareas, thus $selranges is the
                        # same for all of them)
                        set restoreselinfo [list $newta $selranges]
                    }
                    focustextarea $sandboxta
                    set couldopenatleastonefile true
                }

            } else {

                # the file is already open,
                # either in a hidden textarea or in a visible one
                # create a peer
                if {$Tk85} {
                    # at this point there is always at least one element in $listoftahavingfile
                    set taalreadyhavingfile [lindex $listoftahavingfile 0]
                    set splitfrominitiallyvisibleta [isdisplayed $taalreadyhavingfile]
                    if {$splitfrominitiallyvisibleta} {
                        focustextarea $taalreadyhavingfile
                        set tapwfratouse [getpaneframename $taalreadyhavingfile]
                        set pwnametouse [getpwname $tapwfratouse]
                        set orienttouse [$pwnametouse cget -orient]
                    } else {
                        set firstpaneofrootpw [lindex [$pad.pw0 panes] 0]
                        set tainfirstpaneofpw0 [gettafromwidget $firstpaneofrootpw]
                        focustextarea $tainfirstpaneofpw0
                        showtext $taalreadyhavingfile
                        set orienttouse [$pad.pw0 cget -orient]
                    }
                    splitwindow $orienttouse "" file
                    set newta [gettextareacur]
                    destroypaneframe $newta nohierarchydestroy
                    packnewbuffer $newta $pwname 1
                    spacesashesevenly $pwname
                    $newta mark set insert $insertcursorpoint
                    $newta see insert
                    if {$selranges ne {}} {
                        # $selranges ne {}  may be true for at most one textarea
                        # (or for several peer textareas, thus $selranges is the
                        # same for all of them)
                        set restoreselinfo [list $newta $selranges]
                    }
                    if {$splitfrominitiallyvisibleta} {
                        focustextarea $sandboxta
                     } else {
                        # arrange for having again $sandboxta in the first pane
                        # of the root panedwindow, and let this textarea be the active one
                        set firstpaneofrootpw [lindex [$pad.pw0 panes] 0]
                        set tainfirstpaneofpw0 [gettafromwidget $firstpaneofrootpw]
                        focustextarea $tainfirstpaneofpw0
                        showtext $sandboxta
                     }
                    set couldopenatleastonefile true
                } else {
                    # if we're here it means that Scipad when last closed was
                    # running on Tk 8.5 and had peers open, and that Scipad is
                    # now running on Tk 8.4
                    # with Tk8.4 one cannot create peers, so just ignore these
                    # entries of the layout structure
                }
            }

        } else {

            # this element is a nested panedwindow
            # (a list structure as returned by proc getfullpwstructureinfo)
            foreach {recurselistofnotfoundfiles recursecouldopenatleastonefile \
                     recursesashesrepositioninfo recurserestoreselinfo} \
                    [repackvisiblelayout $apane $pwname $sandboxta] {}
            foreach fil $recurselistofnotfoundfiles {
                lappend listofnotfoundfiles $fil
            }
            if {$recursecouldopenatleastonefile} {
                set couldopenatleastonefile true
            } else {
                set canusesashinfos false
            }
            foreach recsashrepinfo $recursesashesrepositioninfo {
                lappend sashesrepositioninfo $recsashrepinfo
            }
            if {$recurserestoreselinfo ne {}} {
                set restoreselinfo $recurserestoreselinfo
            }
        }
    }

    if {!$couldopenatleastonefile} {

        $parentpwname forget $pwname
        set sashesrepositioninfo {}

    } else {

        # restore previously saved positions of sashes if this makes sense
        if {$canusesashinfos} {
            setrelsashesposition $pwname $sashinfos
        } else {
            spacesashesevenly $pwname
        }

    }

    # when exiting this proc, $sandboxta must be the active textarea
    #focustextarea $sandboxta  ; # useless since already the case

    return [list $listofnotfoundfiles $couldopenatleastonefile \
                 $sashesrepositioninfo $restoreselinfo]
}

proc managescroll {scrbar a b} {
# this is primarily to add a catch to the command normally used
# this catch is required because the text widget may trigger scroll commands
# automatically when it is not packed in a pane,
# e.g. on $textarea configure -someoption
# note: this seems to happen because textareas are not yet destroyed when they
# have just been unpacked. Therefore the binding to the scrollbar might still
# be alive at this point for hidden textareas
# 2nd benefit, thanks to this proc, updating the margin does not need
# to redefine a lot of bindings relative to the textarea view adjustment
# such as MouseWheel, Key-Return, Key-Down, etc - quick and elegant
# solution
    global listoftextarea
    global linenumbersmargin modifiedlinemargin
    global restorelayoutrunning

    # boost Scipad startup a bit
    if {$restorelayoutrunning} {return}

    catch {$scrbar set $a $b}

    # a. proc managescroll might be called when scrolling text widgets other
    #    than textareas, for instance the info box of the help menu. In such
    #    a case, do not attempt to update line numbers
    # b. this proc is usually called twice, once for xscroll, once for yscroll
    #    but this part here should be executed only for yscroll since there is
    #    anyway no change in the line numbers when xscroll is called, therefore
    #    for performance's sake avoid useless work
    # c. catched for the same reason as above
    catch {
        if {[string range $scrbar end-6 end] eq "yscroll"} {
            set ta [gettafromwidget [winfo parent $scrbar]]
            if {[lsearch -exact $listoftextarea $ta] != -1} {
                if {$linenumbersmargin ne "hide"} {
                    updatelinenumbersmargin $ta
                }
                if {$modifiedlinemargin ne "hide"} {
                    updatemodifiedlinemargin $ta
                }
            }
        }
    }
}

proc switchbuffersinpane {w dir} {
# switch buffers inside a single pane - only the hidden buffers are switched
# the cycling happens in an order that depends on the sorting scheme selected
# for the windows menu, the scan direction being given by $dir (either
# "forward" or anything else that will be interpreted as "backward")
# $w either is "current" meaning the current textarea shall be switched,
# or is the name of a widget that is part of the title bar of the currently
# active tile

    if {$w ne "current"} {
        # do as if the user had clicked inside the textarea corresponding to $w
        # which makes it the current one
        event generate $w <ButtonRelease-1>
    }

    # select what hidden textarea to display
    set talist [getlistofhiddenta]
    set tacur [gettextareacur]
    lappend talist $tacur
    set talist [lsort $talist]
    set li [getwindowsmenusortedlistofta $talist]
    set talist []
    foreach item $li {
        foreach {ta lab mtim} $item {}
        lappend talist $ta
    }
    if {$dir eq "forward"} {
		set toshow [expr {[lsearch $talist $tacur] + 1}]
		if {$toshow == [llength $talist]} {
			set toshow 0
		}
    } else {
		set toshow [expr {[lsearch $talist $tacur] - 1}]
		if {$toshow == -1} {
			set toshow [expr {[llength $talist] - 1}]
		}
    }

    # switch to the selected one
    showtext [lindex $talist $toshow]
}

proc nextbuffer {type} {
# switch to the next buffer
# $type is either "all" or "visible"
    global pad listoftextarea listoffile
    global FirstBufferNameInWindowsMenu
    set nbuf [expr {[llength $listoftextarea] + $FirstBufferNameInWindowsMenu}]
    set ta [gettextareacur]
    set curbuf [extractindexfromlabel $pad.filemenu.wind $listoffile("$ta",displayedname)]
    set initialcurbuf $curbuf
    incr curbuf
    if {$curbuf >= $nbuf} {
        set curbuf $FirstBufferNameInWindowsMenu
    }
    set found false
    while {!$found && $curbuf!=$initialcurbuf} {
        if {$type == "visible"} {
            set candidatetaid [$pad.filemenu.wind entrycget $curbuf -value]
            if {[isdisplayed $pad.new$candidatetaid]} {
                set found true
            } else {
                incr curbuf
                if {$curbuf >= $nbuf} {
                    set curbuf $FirstBufferNameInWindowsMenu
                }
            }
        } else {
            set found true
        }
    }
    if {$found} {
        $pad.filemenu.wind invoke $curbuf
    }
}

proc prevbuffer {type} {
# switch to the previous buffer
# $type is either "all" or "visible"
    global pad listoftextarea listoffile
    global FirstBufferNameInWindowsMenu
    set nbuf [expr {[llength $listoftextarea] + $FirstBufferNameInWindowsMenu - 1}]
    set ta [gettextareacur]
    set curbuf [extractindexfromlabel $pad.filemenu.wind $listoffile("$ta",displayedname)]
    set initialcurbuf $curbuf
    incr curbuf -1
    if {$curbuf < $FirstBufferNameInWindowsMenu} {
        set curbuf $nbuf
    }
    set found false
    while {!$found && $curbuf!=$initialcurbuf} {
        if {$type == "visible"} {
            set candidatetaid [$pad.filemenu.wind entrycget $curbuf -value]
            if {[isdisplayed $pad.new$candidatetaid]} {
                set found true
            } else {
                incr curbuf -1
                if {$curbuf < $FirstBufferNameInWindowsMenu} {
                    set curbuf $nbuf
                }
            }
        } else {
            set found true
        }
    }
    if {$found} {
        $pad.filemenu.wind invoke $curbuf
    }
}
