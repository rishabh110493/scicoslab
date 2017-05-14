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

proc findtextdialog {typ} {
# display the find or replace dialog box
    global find pad textFont menuFont
    global SearchString SearchDir ReplaceString caset regexpcase
    global searchinsel wholeword multiplefiles indoffirstmatch
    global listoftextarea
    global searchindir initdir fileglobpat searchinfilesalreadyrunning
    global searchforfilesonly
    global listoftagsforfind searchintagged
    global findreplaceboxalreadyopen
    global findtextcombolistvar replacetextcombolistvar
    global glopatterncombolistvar indirectorycombolistvar
    global specialreplchars

    if {[IsBufferEditable] eq "No" && $typ eq "replace"} {return}

    if {$findreplaceboxalreadyopen} {
        tk_messageBox -message [mc "Dialog box already open!"] -icon warning -parent $find
        return
    }
    set findreplaceboxalreadyopen true

    # don't allow simultaneous incremental search and normal
    # dialog search
    closeincremfindcontrols

    set find $pad.find
    catch {destroy $find}
    toplevel $find -class Dialog
    wm transient $find $pad
    wm withdraw $find
    setscipadicon $find
    wm title $find [mc "Find"]
    # cancelfind must be called when closing the dialog with the upper right
    # cross, otherwise the fakeselection tag is not deleted
    wm protocol $find WM_DELETE_WINDOW {cancelfind}

    # save the possibly existing selection
    # fakeselection is a copy of the sel tag, required because the sel tag
    # is not visible when focus is out of $pad, which is particularly
    # annoying when it is in the find dialog!
    # note wrt Tk85:
    #   using -inactiveselectbackground (Tk8.5 only) instead of using a fake
    #   selection tag that mimics the real selection (sel tag) could have been
    #   a good idea. However, there are currently good reasons for clearing
    #   the selection when switching buffers so that Scipad can have only one
    #   (possibly block) selection at a time. Even with the -inactiveselectbackground
    #   option set, there would therefore be no visible selection
    #   in any non focussed buffer
    set selindices [gettaselind [gettextareacur] any]
    if {$selindices != ""} {
        # there is a selection
        set tacur [gettextareacur]
        eval "$tacur tag add fakeselection $selindices"
        $tacur tag raise anyfoundtext fakeselection
        $tacur tag raise curfoundtext fakeselection
        $tacur tag raise replacedtext fakeselection
        set i 0
        foreach {selsta selsto} $selindices {
            $tacur mark set     fakeselectionstart$i $selsta
            $tacur mark gravity fakeselectionstart$i left
            $tacur mark set     fakeselectionstop$i  $selsto
            $tacur mark gravity fakeselectionstop$i  right
            incr i
        }
        set seltexts [gettatextstring [gettextareacur] $selindices]
    } else {
        set seltexts ""
    }

    # combo fields
    frame $find.u
    label $find.u.label -text [mc "Find what:"] \
        -font $menuFont
    combobox $find.u.combo -textvariable SearchString -font $textFont \
        -editable true -listvar findtextcombolistvar -command sortcombolistboxMRUfirst
    menubutton $find.u.mb -indicatoron 0 -text ">" \
        -font $menuFont
    menu $find.u.mb.om1 -tearoff 0 -font $menuFont
    $find.u.mb configure -menu $find.u.mb.om1
    foreach {pattern label} [regexpsforfind] {
        $find.u.mb.om1 add command -font $menuFont \
            -label "$label      $pattern" \
            -command [list insertregexpforfind $pattern]
    }
    grid $find.u.label -row 0 -column 0 -sticky we
    grid $find.u.combo -row 0 -column 1 -sticky we
    grid $find.u.mb    -row 0 -column 2
    bind [$find.u.combo subwidget entry] <Enter> "update_bubble_if_needed enter %W \[winfo pointerxy $pad\] \[set SearchString\] true"
    bind [$find.u.combo subwidget entry] <Leave> "update_bubble_if_needed leave %W \[winfo pointerxy $pad\] \[set SearchString\] true"
    if {$typ eq "replace"} {
        label $find.u.label2 -text [mc "Replace with:"] \
            -font $menuFont
        combobox $find.u.combo2 -textvariable ReplaceString -font $textFont \
            -editable true -listvar replacetextcombolistvar -command sortcombolistboxMRUfirst
        menubutton $find.u.mb2 -indicatoron 0 -text ">" \
            -font $menuFont
        menu $find.u.mb2.om1 -tearoff 0 -font $menuFont
        $find.u.mb2 configure -menu $find.u.mb2.om1
        foreach {pattern label} [regexpsforreplace] {
            $find.u.mb2.om1 add command -font $menuFont \
                -label "$label      $pattern" \
                -command [list insertregexpforreplace $pattern]
        }
        grid $find.u.label2 -row 1 -column 0 -sticky we
        grid $find.u.combo2 -row 1 -column 1 -sticky we
        grid $find.u.mb2    -row 1 -column 2
        bind [$find.u.combo2 subwidget entry] <Enter> "update_bubble_if_needed enter %W \[winfo pointerxy $pad\] \[set ReplaceString\] true"
        bind [$find.u.combo2 subwidget entry] <Leave> "update_bubble_if_needed leave %W \[winfo pointerxy $pad\] \[set ReplaceString\] true"
    } else {
        # no additional widgets to create, but add tooltip bubble only if $typ ne "replace"
        # because no search/replace directly in files is implemented
        bind $find.u.label <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \[mc \"Fill in to search in files, leave empty to search for files in a directory\"\] true"
        bind $find.u.label <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \[mc \"Fill in to search in files, leave empty to search for files in a directory\"\] true"
    }
    grid columnconfigure $find.u 0 -weight 0
    grid columnconfigure $find.u 1 -weight 1
    grid columnconfigure $find.u 2 -weight 0

    # buttons
    frame $find.f2
    eval "button $find.f2.button1 [bl "Find &Next"] \
        -command \"multiplefilesfindreplace $find findit\" \
        -font \[list $menuFont\] "
    eval "button $find.f2.button2 [bl "Cance&l"] \
        -command \"cancelfind\" \
        -font \[list $menuFont\] "
    if {$typ eq "replace"} {
        eval "button $find.f2.button3 [bl "Re&place"] \
            -command \"multiplefilesfindreplace $find replaceit\" \
            -font \[list $menuFont\] "
        eval "button $find.f2.button4 [bl "Replace &All"] \
            -command \"multiplefilesreplaceall $find\" \
            -font \[list $menuFont\] "
        grid $find.f2.button1 -row 0 -column 0 -sticky we -pady 5
        grid $find.f2.button3 -row 1 -column 0 -sticky we -pady 5
        grid $find.f2.button4 -row 2 -column 0 -sticky we -pady 5
        grid $find.f2.button2 -row 3 -column 0 -sticky we -pady 5
    } else {
        grid $find.f2.button1 -row 0 -column 0 -sticky we -pady 5
        grid $find.f2.button2 -row 3 -column 0 -sticky we -pady 5
    }

    pack $find.u -expand 1 -fill x

    frame $find.l

    frame $find.l.f4

    frame $find.l.f4.f1

    # up/down radiobutton
    labelframe $find.l.f4.f1.f1 -borderwidth 2 -relief groove \
        -text [mc "Direction"] -font $menuFont
    eval "radiobutton $find.l.f4.f1.f1.up [bl "&Upwards"] \
        -variable SearchDir -value \"backwards\" \
        -command \"unset -nocomplain -- indoffirstmatch\" \
        -font \[list $menuFont\] "
    eval "radiobutton $find.l.f4.f1.f1.down [bl "&Downwards"] \
        -variable SearchDir -value \"forwards\" \
        -command \"unset -nocomplain -- indoffirstmatch\" \
        -font \[list $menuFont\] "
    pack $find.l.f4.f1.f1.up $find.l.f4.f1.f1.down -anchor w

    # tagged text options
    labelframe $find.l.f4.f1.f2 -borderwidth 2 -relief groove \
        -text [mc "Text types"] -font $menuFont
    frame $find.l.f4.f1.f2.f1
    set searchtagslb $find.l.f4.f1.f2.f1.lb
    scrollbar $find.l.f4.f1.f2.sbx -command "$searchtagslb xview" \
        -orient horizontal
    scrollbar $find.l.f4.f1.f2.f1.sby -command "$searchtagslb yview"
    listbox $searchtagslb -height 4 -width 15 -font $menuFont -takefocus 1 \
        -xscrollcommand "$find.l.f4.f1.f2.sbx set" \
        -yscrollcommand "$find.l.f4.f1.f2.f1.sby set" \
        -selectmode extended -exportselection 0 -activestyle none
    pack $searchtagslb $find.l.f4.f1.f2.f1.sby -side left -padx 1
    pack $find.l.f4.f1.f2.f1 $find.l.f4.f1.f2.sbx -side top -pady 1
    pack configure $searchtagslb -expand 1 -fill both 
    pack configure $find.l.f4.f1.f2.sbx    -fill x
    pack configure $find.l.f4.f1.f2.f1.sby -fill y
    # populate the listbox with the available tags
    $searchtagslb delete 0 end
    foreach tagname [tagnamesforfind] {
        $searchtagslb insert end $tagname
    }
    # remember what was selected previously in the tags listbox
    if {[llength $listoftagsforfind] > 0} {
        set i 0
        foreach tag [tagsforfind "all"] {
            if {[lsearch $listoftagsforfind $tag] != -1} {
                $searchtagslb selection set $i
            }
            incr i
        }
    }
    # update the global value of what is selected in the tags listbox
    # every time it has perhaps changed: update every time the mouse
    # clicked in the listbox, or every time the listbox looses focus
    # (in case the keyboard is used to change the listbox content)
    bind $searchtagslb <ButtonRelease-1> \
        {set listoftagsforfind [tagsforfind "onlyselected"] ; \
         resetfind \
        }
    bind $searchtagslb <FocusOut> \
        {set listoftagsforfind [tagsforfind "onlyselected"] ; \
         resetfind \
        }
    pack $find.l.f4.f1.f1 $find.l.f4.f1.f2 -side top -anchor nw
    pack configure $find.l.f4.f1.f1 -anchor nw -expand 1 -fill x

    # whole word, case, regexp, all files, in selection, and in directory checkboxes
    labelframe $find.l.f4.f5 -borderwidth 2 -relief groove \
        -text [mc "Find options"] -font $menuFont
    eval "checkbutton $find.l.f4.f5.cbox0 [bl "Match &whole word only"] \
        -variable wholeword  \
        -command \"resetfind\" \
        -font \[list $menuFont\] "
    eval "checkbutton $find.l.f4.f5.cbox1 [bl "Match &case"] \
        -variable caset -onvalue \"-exact\" -offvalue \"-nocase\" \
        -command \"resetfind\" -font \[list $menuFont\] "
    eval "checkbutton $find.l.f4.f5.cbox2 [bl "&Regular expression"] \
        -variable regexpcase  -onvalue \"regexp\" -offvalue \"standard\" \
        -command \"resetfind ; setregexpstatesettings \" \
        -font \[list $menuFont\] "
    eval "checkbutton $find.l.f4.f5.cbox3 [bl "In all &opened files"] \
        -variable multiplefiles \
        -command \"resetfind ; \
                   $find.l.f4.f5.cbox4 deselect ; \
                   if {[string compare $typ find] == 0} { \
                       $find.l.f4.f5.cbox5 deselect ; searchindirdisabled ; \
                   } ; \
                   setsearchintagsettings\" \
         -font \[list $menuFont\] "
    eval "checkbutton $find.l.f4.f5.cbox4 [bl "In &selection only"] \
        -variable searchinsel \
        -command \"togglesearchinsel $typ\" \
        -font \[list $menuFont\] "
    eval "checkbutton $find.l.f4.f5.cbox7 [bl "In typed te&xt"] \
        -variable searchintagged \
        -command \"resetfind ; setsearchintagsettings\" -font \[list $menuFont\] "
    if {$typ eq "find"} {
        eval "checkbutton $find.l.f4.f5.cbox5 [bl "In a director&y"] \
            -variable searchindir \
            -command \"resetfind ; togglesearchindir\" \
            -font \[list $menuFont\] "
    }
    if {$typ eq "find"} {
        pack $find.l.f4.f5.cbox0 $find.l.f4.f5.cbox1 $find.l.f4.f5.cbox2 \
            $find.l.f4.f5.cbox3 $find.l.f4.f5.cbox4 $find.l.f4.f5.cbox7 \
            $find.l.f4.f5.cbox5 \
            -anchor w -expand 1 -fill y
    } else {
        pack $find.l.f4.f5.cbox0 $find.l.f4.f5.cbox1 $find.l.f4.f5.cbox2 \
            $find.l.f4.f5.cbox3 $find.l.f4.f5.cbox4 \
            $find.l.f4.f5.cbox7 \
            -anchor w -expand 1 -fill y
    }

    if {$typ eq "find"} {
        # settings for search in files
        labelframe $find.b -borderwidth 2 -relief groove \
            -text [mc "Find in files search options"] -font $menuFont

        frame $find.b.f0
        eval "checkbutton $find.b.f0.cbox6 [bl "Directory r&ecurse search"] \
            -variable recursesearchindir \
            -command \"resetfind\" \
            -font \[list $menuFont\] "
        eval "checkbutton $find.b.f0.cbox8 [bl "Include &hidden files"] \
            -variable searchhiddenfiles \
            -onvalue true -offvalue false \
            -font \[list $menuFont\] "
        pack $find.b.f0.cbox6 $find.b.f0.cbox8 -side left -anchor w \
            -fill x -expand 1
        pack configure $find.b.f0.cbox6 -fill none
        pack $find.b.f0 -anchor w -fill x -expand 1

        frame $find.b.f
        label $find.b.f.labelt -text [mc "In files/file types:"] \
            -font $menuFont
        combobox $find.b.f.combot -textvariable fileglobpat -font $textFont \
            -editable true -listvar glopatterncombolistvar -command sortcombolistboxMRUfirst
        menubutton $find.b.f.mbselectpat -text ">" -indicatoron 0 \
            -relief raised -font $menuFont
        menu $find.b.f.mbselectpat.pat -tearoff 0 -font $menuFont
        $find.b.f.mbselectpat configure -menu $find.b.f.mbselectpat.pat
        set predefsearchinfilespatterns [knowntypes]
        foreach item $predefsearchinfilespatterns {
            foreach {patname patlist} $item {
                $find.b.f.mbselectpat.pat add command -label $patname \
                -font $menuFont -command "getsearchpattern [list $patlist]"
            }
        }
        label $find.b.f.labeld -text [mc "In directory:"] \
            -font $menuFont
        combobox $find.b.f.combod -textvariable initdir -font $textFont \
            -editable true -listvar indirectorycombolistvar -command sortcombolistboxMRUfirst
        button $find.b.f.buttonselectdir -text "..." \
            -command \"getinitialdirforsearch\" \
            -font $menuFont
        grid $find.b.f.labelt          -row 0 -column 0 -sticky we
        grid $find.b.f.combot          -row 0 -column 1 -sticky we
        grid $find.b.f.mbselectpat     -row 0 -column 2 -sticky we
        grid $find.b.f.labeld          -row 1 -column 0 -sticky we
        grid $find.b.f.combod          -row 1 -column 1 -sticky we
        grid $find.b.f.buttonselectdir -row 1 -column 2 -sticky we
        grid columnconfigure $find.b.f 0 -weight 0
        grid columnconfigure $find.b.f 1 -weight 1
        grid columnconfigure $find.b.f 2 -weight 0
        pack $find.b.f -expand 1 -fill x
        bind $find.b.f.labeld <Enter> "update_bubble enter %W \[winfo pointerxy $pad\] \[mc \"Supported shortcuts: SCI, SCIHOME, ~ (user home directory)\"\] true"
        bind $find.b.f.labeld <Leave> "update_bubble leave %W \[winfo pointerxy $pad\] \[mc \"Supported shortcuts: SCI, SCIHOME, ~ (user home directory)\"\] true"
        bind [$find.b.f.combot subwidget entry] <Enter> "update_bubble_if_needed enter %W \[winfo pointerxy $pad\] \[set fileglobpat\] true"
        bind [$find.b.f.combot subwidget entry] <Leave> "update_bubble_if_needed leave %W \[winfo pointerxy $pad\] \[set fileglobpat\] true"
        bind [$find.b.f.combod subwidget entry] <Enter> "update_bubble_if_needed enter %W \[winfo pointerxy $pad\] \[set initdir\] true"
        bind [$find.b.f.combod subwidget entry] <Leave> "update_bubble_if_needed leave %W \[winfo pointerxy $pad\] \[set initdir\] true"

        eval "checkbutton $find.b.cbox9 [bl "Resul&ts in a new window"] \
            -variable findresultsinnewwindow \
            -onvalue true -offvalue false \
            -font \[list $menuFont\] "
        pack $find.b.cbox9 -side left -anchor w -expand 1 -fill none
    } else {
        labelframe $find.b -borderwidth 2 -relief groove \
            -text [mc "Replace options"] -font $menuFont
        eval "checkbutton $find.b.cbox1 [bl "Sp&ecial characters"] \
            -variable specialreplchars \
            -command \"setspecialcharsstatesettings\" \
            -font \[list $menuFont\] "
        pack $find.b.cbox1 -anchor w -expand 1 -fill y
    }

    pack $find.l.f4.f5 $find.l.f4.f1 -side left -padx 5 -anchor n -expand 1 -fill y
    pack $find.l.f4 -pady 5 -anchor w
    pack $find.l $find.f2 -side left -padx 1
    if {$typ eq "replace"} {
        pack $find.b -before $find.l.f4 -side bottom -padx 5 -pady 4 -anchor w \
            -expand 1 -fill x
    }

    bind $find <Return> "multiplefilesfindreplace $find findit"
    bind $find <Alt-[fb $find.f2.button1]> "multiplefilesfindreplace $find findit"
    if {$typ eq "replace"} {
        bind $find <Alt-[fb $find.f2.button3]> "multiplefilesfindreplace $find replaceit"
        bind $find <Alt-[fb $find.f2.button4]> "multiplefilesreplaceall $find"
    }
    bind $find <Alt-[fb $find.l.f4.f5.cbox0]> { $find.l.f4.f5.cbox0 invoke }
    bind $find <Alt-[fb $find.l.f4.f5.cbox1]> { $find.l.f4.f5.cbox1 invoke }
    bind $find <Alt-[fb $find.l.f4.f5.cbox2]> { $find.l.f4.f5.cbox2 invoke }
    bind $find <Alt-[fb $find.l.f4.f5.cbox3]> { $find.l.f4.f5.cbox3 invoke }
    bind $find <Alt-[fb $find.l.f4.f5.cbox4]> { $find.l.f4.f5.cbox4 invoke }
    bind $find <Alt-[fb $find.l.f4.f5.cbox7]> { $find.l.f4.f5.cbox7 invoke }
    if {$typ eq "find"} {
        bind $find <Alt-[fb $find.l.f4.f5.cbox5]> { $find.l.f4.f5.cbox5 invoke }
        bind $find <Alt-[fb $find.b.f0.cbox6]> { $find.b.f0.cbox6 invoke }
        bind $find <Alt-[fb $find.b.f0.cbox8]> { $find.b.f0.cbox8 invoke }
        bind $find <Alt-[fb $find.b.cbox9]> { $find.b.cbox9 invoke }
    } else {
        bind $find <Alt-[fb $find.b.cbox1]> { $find.b.cbox1 invoke }
    }
    bind $find <Alt-[fb $find.l.f4.f1.f1.up]>   { $find.l.f4.f1.f1.up    invoke }
    bind $find <Alt-[fb $find.l.f4.f1.f1.down]> { $find.l.f4.f1.f1.down  invoke }
    bind $find <Escape> "cancelfind"
    # after 0 in the following Alt binding is mandatory for Linux only
    # This is Tk bug 1236306 (still unfixed in Tk8.4.15 and Tk 8.5a6)
    bind $find <Alt-[fb $find.f2.button2]> "after 0 cancelfind"

    focus $find.u.combo
    update

    # instead of setting a grab on $find, which would prevent interacting
    # with Scipad such as using the scrollbars, better let the user go
    # out of the find/replace dialog without closing it and, when the user
    # comes back in, just reset the find process so that the possible
    # changes made in the buffer will be taken into account (new search
    # will be triggered) - much more user friendly!
    bind $find <FocusIn> {
                          if {"%W" eq $find} {
                              if {$buffermodifiedsincelastsearch} {
                                  resetfind
                              }
                           }
                         }

    # make mouse wheel work in the text area with the find/replace dialog,
    # but only if no combobox in this dialog is opened (otherwise when
    # using the mouse wheel on an opened combobox, scrolling happens both
    # in the opened combo and in the underlying textarea)
    bind $find <MouseWheel> {
                             if {![isanycomboboxopened $find]} {
                                 [gettextareacur] yview scroll [expr {-(%D/3)}] pixels
                             }
                            }

    setwingeom $find
    wm deiconify $find

    # the directory entry box is a drop target for text/plain content
    if {$typ eq "find"} {
        dndbinddirentrybox $find.b.f.combod
    }

    # the listbox of the "In directory" combobox is enlarged to the width
    # of its largest content since paths are easily longer than the default
    # width of the combo
    if {$typ eq "find"} {
        setcombolistboxwidthtolargestcontent $find.b.f.combod
    }

    # initial settings for direction
    $find.l.f4.f1.f1.down invoke

    # initial settings for searching in selection
    if {$seltexts eq ""} {
        # there is no selection, find in selection must be disabled
        $find.l.f4.f5.cbox4 deselect
        $find.l.f4.f5.cbox4 configure -state disabled
    } else {
        # there is a selection
        # if the selection is more than one line,
        #   preselect the find in selection box
        # otherwise
        #   use that selection as the string to search for
        if {[regexp {\n} $seltexts]} {
            # this is a multiline single selection,
            # or a block selection (i.e. multiple ranges)
            $find.l.f4.f5.cbox4 select
        } else {
            # this is a single line single selection
            $find.l.f4.f5.cbox4 deselect
            $find.u.combo delete 0 end
            $find.u.combo insert 0 $seltexts
        }
    }

    # this must be done here and not before because the validatecommand is
    # called and resetfind uses the searchinsel value set by the tests on
    # $seltexts above
    # the -validate option is used to reset the find process whenever
    # the content of the SearchString changes - if this is not done,
    # when changing $SearchString and clicking Find Next Scipad would
    # search for the previous content of $SearchString
    # the combobox does not directly support -validate, however it is made
    # of an entry supporting this option
    set findtextcomboentryname [$find.u.combo subwidget entry]
    $findtextcomboentryname configure -validate key \
        -validatecommand {resetfind ; return 1}

    # initial settings for searching in multiple files
    if {$seltexts != ""} {
        $find.l.f4.f5.cbox3 deselect
    }
    if {[llength [filteroutpeers $listoftextarea]] == 1} {
        $find.l.f4.f5.cbox3 configure -state disabled
    }

    # initial settings for search in files from a directory
    if {$typ eq "find"} {
        if {$fileglobpat eq ""} {
            $find.b.f.mbselectpat.pat invoke 0
        }
        if {$initdir eq ""} {
            set initdir [file normalize "."]
        }
        if {$searchindir} {
            searchindirenabled
        } else {
            searchindirdisabled
        }
        if {$multiplefiles || $searchinsel || $searchinfilesalreadyrunning} {
            $find.l.f4.f5.cbox5 deselect ; searchindirdisabled
        }
        if {$searchinfilesalreadyrunning} {
            $find.l.f4.f5.cbox5 configure -state disabled
        }
    } else {
        # needed otherwise searchindir does not exist when hitting Find Next
        # in the replace box
        set searchindir 0
    }
    set searchforfilesonly 0

    # initial settings for regexp generator state
    setregexpstatesettings

    # initial settings for special replace characters generator state
    if {$typ eq "replace"} {
        setspecialcharsstatesettings
    }

    # initial settings for search in typed (tagged) text
    setsearchintagsettings

    # preselect the combo entry field
    $find.u.combo selection range 0 end

    # arrange for the combo entries selection to be erased before pasting
    bind $find.u.combo <Control-v> { \
        if {[%W selection present]} { \
            %W delete sel.first sel.last \
        } ; \
        # no need to event generate %W <<Paste>> since Tk does it for us (class binding)! \
    }
    if {$typ eq "replace"} {
        bind $find.u.combo2 <Control-v> [bind $find.u.combo <Control-v>]
    }
    if {$typ eq "find"} {
        bind $find.b.f.combot <Control-v> [bind $find.u.combo <Control-v>]
        bind $find.b.f.combod <Control-v> [bind $find.u.combo <Control-v>]
    }

    # initialize all the remaining startup settings
    resetfind
}

proc tryrestoreseltag {textarea} {
# restore the sel tag in $textarea if there is a fakeselection in
# this textarea, and if the search in selection checkbox is checked
    global searchinsel
    if {$searchinsel} {
        set fsrange [$textarea tag ranges fakeselection]
        if {$fsrange != {}} {
            eval "$textarea tag add sel $fsrange"
        }
    }
}

proc setregexpstatesettings {} {
    global find regexpcase
    if {$regexpcase == "regexp"} {
        $find.u.mb configure -state normal -relief ridge
    } else {
        $find.u.mb configure -state disabled -relief flat
    }
}

proc setspecialcharsstatesettings {} {
    global find specialreplchars
    if {$specialreplchars} {
        $find.u.mb2 configure -state normal -relief ridge
    } else {
        $find.u.mb2 configure -state disabled -relief flat
    }
}

proc setnosearchinsel {typ} {
    global searchinsel
    set searchinsel false
    togglesearchinsel $typ
}

proc togglesearchinsel {typ} {
    global find
    tryrestoreseltag [gettextareacur]
    resetfind
    if {[winfo exists $find]} {
        $find.l.f4.f5.cbox3 deselect
        if {[string compare $typ find] == 0} {
            $find.l.f4.f5.cbox5 deselect
            searchindirdisabled
        }
    }
}

proc setsearchintagsettings {} {
    global find searchintagged listoftagsforfind
    global multiplefiles listoffile listoftextarea

    set candoit false
    if {$multiplefiles} {
        # to allow for searching in tagged text, one must have at least one file
        # with scilab language scheme, and with colorization switched on
        # since these attributes are the same for all peers of a textarea
        # we can narrow the search to the filtered list of textareas
        foreach ta [filteroutpeers $listoftextarea] {
            if {$listoffile("$ta",language) eq "scilab" && \
                $listoffile("$ta",colorize) } {
                set candoit true
                break
            }
        }
    } else {
        # the current file must be of scilab scheme with colorization switched on
        if {$listoffile("[gettextareacur]",language) eq "scilab" && \
            $listoffile("[gettextareacur]",colorize) } {
            set candoit true
        }
    }

    if {$searchintagged && $candoit} {
        $find.l.f4.f1.f2.f1.lb configure -state normal
    } else {
        # clearing the selection in the tags listbox is needed so that
        #   tagsforfind "onlyselected"  returns the empty list when
        # $searchintagged is false
        $find.l.f4.f1.f2.f1.lb selection clear 0 end
        set listoftagsforfind [list ]
        $find.l.f4.f1.f2.f1.lb configure -state disabled
    }
    if {!$candoit} {
        $find.l.f4.f5.cbox7 deselect
        $find.l.f4.f5.cbox7 configure -state disabled
    }
}

proc togglesearchindir {} {
    global searchindir
    if {$searchindir} {
        searchindirenabled
    } else {
        searchindirdisabled
    }
}

proc searchindirenabled {} {
    global find
    $find.l.f4.f5.cbox3 deselect
    $find.l.f4.f5.cbox4 deselect
    $find.b.f0.cbox6 configure -state normal
    $find.b.f0.cbox8 configure -state normal
    $find.b.f.labelt configure -state normal
    $find.b.f.combot configure -state normal
    $find.b.f.mbselectpat configure -state normal
    $find.b.f.labeld configure -state normal
    $find.b.f.combod configure -state normal
    $find.b.f.buttonselectdir configure -state normal
    $find.l.f4.f1.f1.up configure -state disabled
    $find.l.f4.f1.f1.down invoke
    $find.l.f4.f5.cbox7 deselect
    $find.l.f4.f5.cbox7 configure -state disabled
    $find.l.f4.f1.f2.f1.lb selection clear 0 end
    $find.l.f4.f1.f2.f1.lb configure -state disabled
    pack $find.b -before $find.l -side bottom -padx 5 -pady 4 -anchor w \
        -expand 1 -fill x
    setsearchintagsettings
}

proc searchindirdisabled {} {
    global find 
    $find.b.f0.cbox6 configure -state disabled
    $find.b.f0.cbox8 configure -state disabled
    $find.b.f.labelt configure -state disabled
    $find.b.f.combot configure -state disabled
    $find.b.f.mbselectpat configure -state disabled
    $find.b.f.labeld configure -state disabled
    $find.b.f.combod configure -state disabled
    $find.b.f.buttonselectdir configure -state disabled
    $find.l.f4.f5.cbox7 configure -state normal
    $find.l.f4.f1.f1.up configure -state normal
    $find.l.f4.f1.f2.f1.lb configure -state normal
    pack forget $find.b
    setsearchintagsettings
}

proc getinitialdirforsearch {} {
    global find initdir
    set oldinitdir $initdir
    set initdir [tk_chooseDirectory -parent $find -mustexist 1 -initialdir $oldinitdir]
    if {$initdir == ""} {
        # the user clicked Cancel in the choose directory dialog
        set initdir $oldinitdir
    }
}

proc getsearchpattern {pat} {
    global fileglobpat
    set fileglobpat "$pat"
}

proc togglesearchdir {} {
    global SearchDir
    if {$SearchDir == "forwards"} {
        set SearchDir "backwards"
    } else {
        set SearchDir "forwards"
    }
}

proc updatefindreplacecomboslistboxes {w} {
# update the combos listboxes with the content of their entries
# $w should be $find
    if {[winfo exists $w]} {
        insertentrycontentincombolistbox $w.u.combo        ; # "Find what" combo
        if {[winfo exists $w.u.combo2]} {
            insertentrycontentincombolistbox $w.u.combo2   ; # "Replace with" combo
        }
        if {[winfo exists $w.b.f.combot]} {
            insertentrycontentincombolistbox $w.b.f.combot ; # "File types" (glob pattern) combo
        }
        if {[winfo exists $w.b.f.combod]} {
            insertentrycontentincombolistbox $w.b.f.combod ; # "In directory" combo
            setcombolistboxwidthtolargestcontent $w.b.f.combod
        }
    } else {
        # find/replace dialog not open (case of search triggered by Ctrl-F3)
        # nothing to do
    }
}

proc reversefindnext {} {
    togglesearchdir
    findnext
    togglesearchdir
}

proc findnext {} {
# proc for find next without opening the dialog if possible
# (only for find in already opened files)
    global SearchString find searchindir
    global buffermodifiedsincelastsearch


    if {[info exists SearchString] && [info exists searchindir]} {
        # the find dialog had been opened in the past
        if {$SearchString != "" && !$searchindir && \
                !$buffermodifiedsincelastsearch} {
            # don't allow simultaneous incremental search and normal
            # dialog search
            closeincremfindcontrols
            multiplefilesfindreplace $find findit
        } else {
            findtextdialog "find"
        }
    } else {
        findtextdialog "find"
    }
}

proc multiplefilesfindreplace {w frit} {
# search and maybe replace in all the opened buffers, or in the current one
# depending on the state of the "search in all files" checkbox
# $frit contains either "findit" (only find will happen)
#                    or "replaceit" (replace will happen)
    global SearchString ReplaceString SearchDir caset regexpcase searchinsel wholeword
    global listoftagsforfind
    global multiplefiles listoftextarea indofcurrentbuf listoftextarea_nopeers
    global prevfindres
    global find searchindir recursesearchindir fileglobpat initdir
    global searchinfilesalreadyrunning searchforfilesonly

    # update comboboxes listboxes content with their entries fields (unless empty)
    updatefindreplacecomboslistboxes $w

    set pw [setparentwname $w]

    # get rid of the empty search string case
    if {$SearchString == ""} {
        if {$searchindir} {
            # an empty search string with search in files/dir set means that
            # we want to search for files themselves, not for a string in files
            # let's put a message box for confirmation since I myself forgot that feature...
            set answ [tk_messageBox -icon question -type yesno -parent $pw \
                    -title [mc "Search for file names"] \
                    -message [mc "You have given an empty search string. Are you sure you want to search among file names?"] ]
            switch -- $answ {
                yes { set searchforfilesonly 1 }
                no  { return }
            }
        } else {
            searchstringemptymessagebox $pw
            return
        }
    }

    set tosearchfor $SearchString

    # check if the regexp given or constructed is valid
    if {$regexpcase == "regexp" && ![isregexpstringvalid $tosearchfor $pw]} {
        return
    }

    if {$searchindir && !$searchinfilesalreadyrunning} {
        # search in files from a directory
        cancelfind
        findinfiles $tosearchfor $caset $regexpcase $wholeword $initdir $fileglobpat $recursesearchindir $searchforfilesonly
        return
    }

    if {!$multiplefiles} {

        # search/replace in current buffer only

        if {$frit eq "findit"} {
            set prevfindres [findit $w $pw $multiplefiles [gettextareacur] $tosearchfor \
                                    $caset $regexpcase $searchinsel $wholeword \
                                    $listoftagsforfind $SearchDir]
            set mbtitle "Find"
        } else {
            set prevfindres [replaceit $w $pw $multiplefiles [gettextareacur] $tosearchfor \
                                       $caset $regexpcase $searchinsel $wholeword \
                                       $listoftagsforfind $SearchDir $ReplaceString]
            set mbtitle "Replace"
        }

        switch -- $prevfindres {

            "nomatchatall" {
                # no match exists in this buffer
                notfoundmessagebox $SearchString [gettextareacur] $pw $mbtitle
            }

            "nomatchinsel" {
                # no match in selection, ask for extending search
                set answer [tk_messageBox -message \
                    [concat [mc "No match found in the selection for"] $SearchString \
                            [mc "\nWould you like to look for it in the entire text?"] ] \
                    -parent $pw -title [mc $mbtitle] -type yesno -icon question]
                if {$answer == "yes"} {
                    # extend search simply by removing the selection tag in the textarea
                    # therefore the next call to findit will do a search in the full buffer
                    # the selection will be restored later on by proc cancelfind
                    # or by checking again the "search in selection only" box
                    [gettextareacur] tag remove sel 1.0 end
                    # no search in selection allowed once search has been extended
                    setnosearchinsel $w
                    resetfind
                    multiplefilesfindreplace $w $frit
                } else {
                    # don't extend search, nothing to do
                }
            }

            "mustswitchnow_nomorematches" {
                showinfo [mc "No more matches in this file"]
                bell
            }

            "mustswitchnow_looped" {
            }

            "bufferdone" {
            }

            "searchagain" {
            }
        }

        return
    }

    # if we did not return before this point, we are searching in all the
    # opened buffers for a non-empty string

    if {![info exists indofcurrentbuf]} {
        # this is the first search in multiple buffers

        # create list of textareas without any peers, and ensure that the
        # current textarea is kept and is the first element of the list
        # note: $listoftextarea_nopeers is only used in this proc and is not
        #       maintained elsewhere even if it is a global
        #       It must not be used anywhere else since it is not ordered
        #       as listoftextarea
        set listoftextarea_nopeers [shiftlistofta $listoftextarea [gettextareacur]]
        set listoftextarea_nopeers [filteroutpeers $listoftextarea_nopeers]

        # start from the current buffer, which is #0 because of
        # the call to shiftlistofta above
        set indofcurrentbuf 0

    } else {
        # this is not the first search in multiple buffers

        # switch to next buffer if there is no more match in this one
        if {$prevfindres != "searchagain"} {
            incr indofcurrentbuf
            if {$indofcurrentbuf == [llength $listoftextarea_nopeers] } {
                set indofcurrentbuf 0
                # the search has looped on all the buffers
                set tit [mc "Search in all opened files"]
                set mes [mc "Back at the first file searched!"]
                append mes "\n\n" [mc "Do you want the search to go on?"]
                set answ [tk_messageBox -message $mes -icon info -title $tit -type yesno -parent $pw]
                switch -- $answ {
                    yes { }
                    no  { resetfind ; return }
                }
            }
            set newta [lindex $listoftextarea_nopeers $indofcurrentbuf]
            # Warning!! This call to showtext, among useful things, triggers
            #           proc forgetlistofmatch in order to work around a bug!
            # <TODO>: Fix the bug properly and remove the call to proc forgetlistofmatch
            #         The bug is that without this call, find next highlights
            #         wrong matches after having switched buffers (whatever
            #         the method: click, close current buffer, ...)
            showtext $newta
            # set insertion cursor at the beginning or end of buffer
            # this is required when looping through buffers for proc
            # getnextmatch to work correctly: on first match search in
            # a buffer, when there is no selection (which is the case
            # when searching multiple files) getnextmatch returns the
            # first match after the insertion cursor
            if {$SearchDir == "forwards"} {
                $newta mark set insert 1.0
            } else {
                $newta mark set insert end
            }
            # erase listofmatch so that the next call to findit or replaceit will
            # reconstruct it
            forgetlistofmatch
        }

    }

    # perform a search

    set buftosearchin [lindex $listoftextarea_nopeers $indofcurrentbuf]

    if {$frit eq "findit"} {
        set prevfindres [findit $w $pw $multiplefiles $buftosearchin $tosearchfor \
                                $caset $regexpcase $searchinsel $wholeword \
                                $listoftagsforfind $SearchDir]

        set mbtitle "Find"
    } else {
        set prevfindres [replaceit $w $pw $multiplefiles $buftosearchin $tosearchfor \
                                   $caset $regexpcase $searchinsel $wholeword \
                                   $listoftagsforfind $SearchDir $ReplaceString]
        set mbtitle "Replace"
    }

    switch -- $prevfindres {

        "nomatchatall" {
            # no match exists in this buffer
            notfoundmessagebox $SearchString [gettextareacur] $pw $mbtitle
        }

        "nomatchinsel" {
            # can't happen when searching in multiple files, which is the case
            # in this part of the code
            # therefore, do nothing
        }

        "mustswitchnow_nomorematches" {
            showinfo [mc "No more matches in this file"]
            bell
            multiplefilesfindreplace $w findit
        }

        "mustswitchnow_looped" {
            multiplefilesfindreplace $w findit
        }

        "bufferdone" {
        }

        "searchagain" {
        }

    }

}

proc multiplefilesreplaceall {w} {
# search and replace all matches in all the opened buffers, or in the current one
# depending on the state of the "search in all files" checkbox
    global SearchString ReplaceString multiplefiles caset regexpcase
    global searchinsel wholeword listoftagsforfind
    global listoftextarea
    global prevfindres
    global findreplaceboxalreadyopen

    # update comboboxes listboxes content with their entries fields (unless empty)
    updatefindreplacecomboslistboxes $w

    set pw [setparentwname $w]

    # get rid of the empty search string case
    if {$SearchString == ""} {
        searchstringemptymessagebox $pw
        return
    }

    set tosearchfor $SearchString

    # check if the regexp given or constructed is valid
    if {$regexpcase == "regexp" && ![isregexpstringvalid $tosearchfor $pw]} {
        return
    }

    # grey out the controls (except cancel) since replacing all may last some time
    foreach wid [list $w.f2.button1 $w.f2.button3 $w.f2.button4] {
        $wid configure -state disabled
    }
    
    if {!$multiplefiles} {
        # search in current buffer only
        replaceall $w $pw $multiplefiles [gettextareacur] $SearchString $tosearchfor \
                   $caset $regexpcase $searchinsel $wholeword \
                   $listoftagsforfind $ReplaceString
    } else {

        # if we did not return before this point, we are replacing a non-empty
        # string in all the opened buffers (but ignoring peers)

        set totreplaced 0
        foreach ta [filteroutpeers $listoftextarea] {
            incr totreplaced [replaceall $w $pw $multiplefiles $ta $SearchString $tosearchfor \
                                         $caset $regexpcase $searchinsel $wholeword \
                                         $listoftagsforfind $ReplaceString]
            if {!$findreplaceboxalreadyopen} {
                # user cancelled before the end of the replace all operation
                break
            }
        }

        showinfo "$totreplaced [mc "replacements done"]"
        if {$totreplaced == 0} {
            notfoundinallmessagebox $SearchString $pw "Replace"
        }

        # userfun and uservar colorization must be done here because replacement
        # might have changed a user function or variable - do it only once,
        # not after each single replacement of a replace all, even not
        # after each buffer in which replace all occurs
        backgroundcolorizetasks

        # update status bar data - do it once only, same as above
        keyposn [gettextareacur]
    }

    # ungrey the controls, if the dialog is still here (otherwise user cancelled
    # during the replace, and the dialog is anyway destroyed)
    if {$findreplaceboxalreadyopen} {
        foreach wid [list $w.f2.button1 $w.f2.button3 $w.f2.button4] {
            $wid configure -state normal
        }
    }
}

proc resetfind {} {
# reset the find/replace settings to their initial default values
# so that the next find or replace will scan the buffer(s) again
# and create a new list of matches
# also reset the buffer counter used during search among multiple
# files
    global indofcurrentbuf

    # reset the search data (current buffer)
    forgetlistofmatch

    # reset the search data (multi-buffer search)
    unset -nocomplain -- indofcurrentbuf
}

proc cancelfind {} {
# end of a find/replace session
    global pad listoftextarea find
    global listoftagsforfind
    global findreplaceboxalreadyopen

    removeallfindreplacetags

    foreach textarea [filteroutpeers $listoftextarea] {
        set fsrange [$textarea tag ranges fakeselection]
        if {$fsrange != {}} {
            # there was a selection at the time the find dialog was opened, restore it
            eval "$textarea tag add sel $fsrange"
            $textarea tag remove fakeselection 1.0 end
        }
    }

    # save the selected tags to be able to restore it later
    # when opening again the find dialog
    set listoftagsforfind [tagsforfind "onlyselected"]

    destroy $find
    set findreplaceboxalreadyopen false
}

proc setparentwname {w} {
# set the window pathname that will be used as parent for the messageboxes
    # if the dialog is open (this is always true for replace or replaceall
    # but may be false for find because of the Ctrl-F3 - Find Next case)...
    global pad
    if {[winfo exists $w]} {
        #... use it as parent for the messageboxes
        set pw $w
    } else {
        #... else use the toplevel
        set pw $pad
    }
    return $pw
}

proc isregexpstringvalid {tosearchfor pw} {
# possible errors in regexp compilation are detected at this point
# this can happen easily since the user can enter any expression and
# call for a regexp search

    # attempt to regexp search
    # what is inside the catch{} should be identical (i.e. the eval is needed)
    # to the line actually performing the search in proc doonesearch
    if {[catch { eval [concat "[gettextareacur] search -regexp --" [list $tosearchfor] " 1.0 end" ] } ]} {
        tk_messageBox -message \
            [mc "The string to regexp search for cannot be compiled by Tcl.\nCheck again, maybe certain characters should be escaped."] \
            -parent $pw -title [mc "Find"] -icon error
        return 0
    } else {
        return 1
    }
}

proc searchstringemptymessagebox {pw} {
# display a message box telling that the string to search for is empty
    tk_messageBox -message [mc "You are searching for an empty string!"] \
                  -parent $pw -title [mc "Find"]
}

proc notfoundmessagebox {str textarea pw mbtitle} {
# display a message box telling that the searched string could not be found
    global listoffile
    tk_messageBox -message \
        [concat [mc "The string"] $str [mc "could not be found in"] \
                $listoffile("$textarea",fullname) ] \
        -parent $pw -title [mc $mbtitle]
}

proc notfoundinallmessagebox {str pw mbtitle} {
# display a message box telling that the searched string could not be found
# in any opened buffers
    tk_messageBox -message \
        [concat [mc "The string"] $str \
                [mc "could not be found in any of the opened files !"] ] \
        -parent $pw -title [mc $mbtitle]
}

proc regexpsforfind {} {
# return the following flat list:
#   {regexppattern1 name1 regexppattern2 name2 ... }
# with localized names
# this list is used in the find/replace box to insert ready cooked regexps
# in the find combo entry place
# note that it is useless to add regexps that would match across text lines
# because the text widget search -regexp engine does only support matching
# inside single lines of text (well, this is true for Tk 8.4 and should
# change with Tk 8.5)
    global scommRE_rep scilabnameREpat dotcontlineRE_rep
    global floatingpointnumberREpat_rep rationalnumberREpat_rep
    return [list \
        {.} [mc "Any single character"] \
        {*} [mc "Zero or more"] \
        {+} [mc "One or more"] \
        {?} [mc "Zero or one"] \
        {[]} [mc "Any one character in the set"] \
        {[^]} [mc "Any one character not in the set"] \
        {()} [mc "Subexpression"] \
        {|} [mc "Or"] \
        {^} [mc "Beginning of line"] \
        {$} [mc "End of line"] \
        {\m} [mc "Beginning of word"] \
        {\M} [mc "End of word"] \
        {[[:alpha:]]} [mc "A letter"] \
        {[[:digit:]]} [mc "A decimal digit"] \
        {[[:alnum:]]} [mc "An alphanumeric (letter or digit)"] \
        {[[:blank:]]} [mc "A space or tab character"] \
        $rationalnumberREpat_rep [mc "A rational number"] \
        $floatingpointnumberREpat_rep [mc "A floating point number"] \
        $scommRE_rep [mc "A Scilab comment"] \
        $scilabnameREpat [mc "A Scilab name"] \
        $dotcontlineRE_rep [mc "A Scilab continued line (with dots)"] \
    ]
}

proc regexpsforreplace {} {
# return the following flat list:
#   {regexppattern1 name1 regexppattern2 name2 ... }
# with localized names
# this list is used in the find/replace box to insert ready cooked special
# characters in the replace combo entry place
    return [list \
        {\n} [mc "Newline"] \
        {\t} [mc "Tab"] \
        {\1} [mc "1st parenthesized subexpression"] \
        {\2} [mc "2nd parenthesized subexpression"] \
        {\3} [mc "3rd parenthesized subexpression"] \
    ]
}

proc insertregexpforfind {pat} {
# insert input argument $pat (a regexp pattern) in the "Search for"
# combo entry place of the find/replace dialog
    global find
    if {[$find.u.combo selection present]} {
        $find.u.combo delete sel.first sel.last
    }
    $find.u.combo insert insert $pat
    # on windows at least, when clicking on the menubutton and maintaining
    # mouse button down while selecting the menu option, then the button
    # does not return to the flat state automatically (the buttonrelease
    # event must be directed to the wrong widget, which is the menu
    # attached to the menubutton) - therefore generate the adequate event
    # by hand
    event generate $find.u.mb <ButtonRelease-1>
}

proc insertregexpforreplace {pat} {
# insert input argument $pat (a special character pattern) in the "Replace with"
# combo entry place of the find/replace dialog
    global find
    if {[$find.u.combo2 selection present]} {
        $find.u.combo2 delete sel.first sel.last
    }
    $find.u.combo2 insert insert $pat
    # on windows at least, when clicking on the menubutton and maintaining
    # mouse button down while selecting the menu option, then the button
    # does not return to the flat state automatically (the buttonrelease
    # event must be directed to the wrong widget, which is the menu
    # attached to the menubutton) - therefore generate the adequate event
    # by hand
    event generate $find.u.mb2 <ButtonRelease-1>
}

proc tagsandtagnamesforfind {} {
# return the following flat list:
#   {internaltagname1 tagnametodisplay1 internaltagname2 tagnametodisplay2 ... }
# with localized tagnametodisplay
# this list is used in the find/replace box to search in tagged text only
# only tags useful for a text search are returned here, not all tags of the
# textarea
    return [list \
        textquoted  [mc "QTXTCOLOR"] \
        rem2        [mc "REMCOLOR"] \
        xmltag      [mc "XMLCOLOR"] \
        number      [mc "NUMCOLOR"] \
        intfun      [mc "INTFCOLOR"] \
        command     [mc "COMMCOLOR"] \
        predef      [mc "PDEFCOLOR"] \
        libfun      [mc "LFUNCOLOR"] \
        userfun     [mc "USERFUNCOLOR"] \
        uservar     [mc "USERVARCOLOR"] \
        scicos      [mc "SCICCOLOR"] \
    ]
}

proc tagnamesforfind {} {
# return the ordered list of all tag names from proc tagsandtagnamesforfind
    set tagnames [list ]
    foreach {tag tagname} [tagsandtagnamesforfind] {
        lappend tagnames $tagname
    }
    return $tagnames
}

proc tagsforfind {onlyselected} {
# return the ordered list of tags from proc tagsandtagnamesforfind
# if $onlyselected == "onlyselected", then only tags selected in
#    the find dialog listbox are returned
# otherwise all tags are returned
    global find
    set tags [list ]
    set i 0
    foreach {tag tagname} [tagsandtagnamesforfind] {
        if {$onlyselected == "onlyselected"} {
            if {[$find.l.f4.f1.f2.f1.lb selection includes $i]} {
                lappend tags $tag
            }
        } else {
            lappend tags $tag
        }
        incr i
    }
    return $tags
}
