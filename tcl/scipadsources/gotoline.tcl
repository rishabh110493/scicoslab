#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2014 - Francois Vogel
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

proc gotoline {} {
# Pop up the go to line dialog
    global pad textFont menuFont unklabel
    global physlogic linetogo curfileorfun funtogoto
    global gotolinefunnamecombolistvar  ; # must be global because setcombolistboxwidthtolargestcontent is used (calls getcombolistvarcontent)
    global Tk85

    # gotoline cannot be executed since it uses getallfunsintextarea
    # which needs the colorization results
    if {[colorizationinprogress]} {return}

    set funtogotolist [getlistofallfunidsinalltextareas]

    # Set default values for the other choices of the box
    if {![info exists linetogo]} {
        set linetogo 1
    }
    if {![info exists funtogoto]} {
        set funtogoto [list $unklabel 0 0]
    } else {
        # Do not propose a function defined in a closed buffer (in case
        # the goto box is reopened after a buffer has been closed)
        set stillexists false
        foreach {fn ta fsl} $funtogotolist {
            if {($fn  eq [lindex $funtogoto 0]) && \
                ($ta  eq [lindex $funtogoto 1]) && \
                ($fsl eq [lindex $funtogoto 2])} {
                set stillexists true
                break
            }
        }
        if {!$stillexists} {
            set funtogoto [list $unklabel 0 0]
        }
    }

    # Create dialog geometry and pack widgets
    set gotln $pad.gotln
    catch {destroy $gotln}
    toplevel $gotln -class Dialog
    wm transient $gotln $pad
    wm withdraw $gotln
    setscipadicon $gotln
    wm title $gotln [mc "Goto Line?"]

    label $gotln.l1 -text [mc "Go to:"] -font $menuFont
    pack $gotln.l1 -anchor w -pady 5 -padx 3

    frame $gotln.f1
    frame $gotln.f1.f1l
    eval "radiobutton $gotln.f1.f1l.rbut1 [bl "&logical line"]  \
            -variable physlogic -value \"logical\" \
            -command \"updateOKbuttonstategoto $gotln\" \
            -anchor w -font \[list $menuFont\] "
    eval "radiobutton $gotln.f1.f1l.rbut2 [bl "&physical line"] \
            -variable physlogic -value \"physical\" \
            -command \"updateOKbuttonstategoto $gotln\" \
            -anchor w -font \[list $menuFont\] "
    entry $gotln.f1.en1 -textvariable linetogo \
            -justify center \
            -width 8 -font $textFont
    grid $gotln.f1.f1l.rbut1 -row 0 -column 0 -sticky w
    grid $gotln.f1.f1l.rbut2 -row 1 -column 0 -sticky w
    pack $gotln.f1.en1 -side right
    pack $gotln.f1.f1l
    pack $gotln.f1 -anchor w

    frame $gotln.f2
    eval "radiobutton $gotln.f2.rbut3 [bl "in &function"]  \
            -variable curfileorfun -value \"function\" \
            -command \"updateOKbuttonstategoto $gotln\" \
            -anchor w -font \[list $menuFont\] "
    eval "radiobutton $gotln.rbut4 [bl "in &current file"] \
            -variable curfileorfun -value \"current_file\" \
            -command \"updateOKbuttonstategoto $gotln\" \
            -anchor w -font \[list $menuFont\] "
    set gotolinefunnamecombolistvar [list ]
    set allfunnames [getallfunnamesfromalltextareas]
    foreach {funname ta funstartline} $funtogotolist {
        lappend gotolinefunnamecombolistvar [stringifyfunid [list $funname $ta $funstartline] $allfunnames]
    }
    combobox $gotln.f2.combo -value [stringifyfunid $funtogoto $allfunnames] \
        -font $textFont -editable false -listvar gotolinefunnamecombolistvar
    # do configure -command only know instead of directly in the previous line,
    # otherwise strange errors happen, apparently due to widgets not yet built
    $gotln.f2.combo configure -command updatefuntogotowithselectedfunincombo
    setcombolistboxwidthtolargestcontent $gotln.f2.combo
    pack $gotln.f2.rbut3 $gotln.f2.combo -side left -anchor w
    pack $gotln.f2 $gotln.rbut4 -anchor w

    frame $gotln.f3
    button $gotln.f3.ok -text [mc "OK"] -font $menuFont \
            -command "dogotoline ; destroy $gotln"
    button $gotln.f3.cancel -text [mc "Cancel"] -font $menuFont \
            -command "destroy $gotln"
    grid $gotln.f3.ok     -row 0 -column 0 -sticky we -padx 10
    grid $gotln.f3.cancel -row 0 -column 1 -sticky we -padx 10
    grid columnconfigure $gotln.f3 0 -uniform 1
    grid columnconfigure $gotln.f3 1 -uniform 1
    if {$Tk85} {
        grid anchor $gotln.f3 center
    }
    pack $gotln.f3 -expand 1 -fill x

    update idletasks
    setwingeom $gotln
    wm deiconify $gotln

    focus $gotln.f1.en1
    grab $gotln

    $gotln.f1.en1 selection range 0 end

    bind $gotln <Return> {if {[[winfo toplevel %W].f3.ok cget -state] ne "disabled"} { \
                              dogotoline ; destroy [winfo toplevel %W] \
                          }}
    bind $gotln <Escape> {destroy [winfo toplevel %W]}

    bind $gotln <Alt-[fb $gotln.f1.f1l.rbut1]> \
        {[winfo toplevel %W].f1.f1l.rbut1 invoke}
    bind $gotln <Alt-[fb $gotln.f1.f1l.rbut2]> \
        {[winfo toplevel %W].f1.f1l.rbut2 invoke}
    bind $gotln <Alt-[fb $gotln.f2.rbut3]> \
        {[winfo toplevel %W].f2.rbut3 invoke}
    bind $gotln <Alt-[fb $gotln.rbut4]> \
        {[winfo toplevel %W].rbut4 invoke}

    # Default choices
    if {$physlogic    eq ""} {
        $gotln.f1.f1l.rbut1 invoke
    }
    if {$curfileorfun eq ""} {
        $gotln.f2.rbut3 invoke
    }
    if {$funtogotolist eq {}} {
        # preselect physical line in buffer if there is no function definition
        $gotln.f1.f1l.rbut2 invoke
        $gotln.rbut4 invoke
    }

    # validation of the line number entry to prevent the user to enter nasty things
    $gotln.f1.en1 configure -validate all -vcmd "updateOKbuttonstategoto $gotln %P"

    # if there is exactly one function, then preselect it
    # the test on $funtogoto is here to make this happen only the first
    # time the gotoline is opened
    if {[llength $allfunnames] == 1 && [stringifyfunid $funtogoto] eq $unklabel} {
        $gotln.f2.combo select 0
    }
}

proc updatefuntogotowithselectedfunincombo {comboname selectedvalue} {
# update variable funtogoto when the user selects an item in the listbox
# associated to the function name combobox of the goto line dialog
#    listbox item  ==>  funtogoto value updated

    global unklabel

    global funtogoto
    set funtogoto [parsefunidstring $selectedvalue]

    if {$selectedvalue eq $unklabel || $selectedvalue eq ""} {
        # happens on creation of the combobox, and also
        # when there is no function in any buffer and the user
        # clicks in the single (empty) item in the listbox of $comboname

        # the combobox must receive $unklabel (was erased by the combobox
        # package when user selected the empty item in the listbox)
        #   - do this generically: use stringifyfunid instead of
        #     just $comboname configure -value $unklabel
        #   - switch -commandstate option off before changing the value
        #     of the combobox, otherwise it triggers another evaluation
        #     of the present proc and this is an infinite loop!
        $comboname configure -commandstate disabled
        $comboname configure -value [stringifyfunid $funtogoto]
        $comboname configure -commandstate normal
    } else {
        # normal case, when the user selects an item in the listbox of the combobox
        # usability stuff
        # if a function has been selected it is likely that goto will use it,
        # hence invoke the "in function" choice rather than keep "in buffer"
        set dialogname [winfo toplevel $comboname]
        $dialogname.f2.rbut3 invoke
        updateOKbuttonstategoto $dialogname
    }
}

proc updateOKbuttonstategoto {w {entryfieldvalue "not_given"}} {
# Prevent from launching gotos with inconsistent choices, and do some
# minimal controls on the user input
# Note: Scheme or $listoffile("$textarea",language) does not need to be checked since
# getallfunsintextarea deals with it and does not return functions from anything else
# than a Scilab scheme buffer
    global unklabel physlogic curfileorfun linetogo Scheme
    if {$entryfieldvalue == "not_given"} {set entryfieldvalue $linetogo}
    if {($curfileorfun == "current_file" && $physlogic == "logical" && $Scheme != "scilab") || \
        ($curfileorfun == "function" && [$w.f2.combo get] == $unklabel) || \
        ($entryfieldvalue <= 0) || ![string is integer -strict $entryfieldvalue] } {
        $w.f3.ok configure -state disabled
    } else {
        $w.f3.ok configure -state normal
    }
    # Validation of the entry widget always succeeds, so that the textvariable
    # is updated. The validation result is made known by the OK button state
    return 1
}

proc dogotoline {{physlogic_ "useglobals"} {linetogo_ ""} {curfileorfun_ ""} {funtogoto_ ""}} {
# Actually perform a go to line number ... taking into account all the possible
# choices from the user in the dialog box. These choices are known by the four
# global variables below (this is required and sufficient)

    global physlogic linetogo curfileorfun funtogoto
    global linenumberstype

    # if no input parameter is given, use the globals
    if {$physlogic_ == "useglobals"} {
        set physlogic_ $physlogic
        set linetogo_ $linetogo
        set curfileorfun_ $curfileorfun
        set funtogoto_ $funtogoto
    }

    if {$curfileorfun_ == "current_file"} {
        if {$physlogic_ == "physical"} {
            # go to physical line in current file
            set ta [gettextareacur]
            $ta mark set insert "$linetogo_.0"
            catch {keyposn $ta}
            $ta see insert

        } else {
            # go to logical line in current file
            # this option enabled in the goto line dialog only for scilab scheme files
            set ta [gettextareacur]
            set endpos [$ta index end]
            set offset 0
            set curphysline 1.0
            set curlogicline $curphysline
            while {$linetogo_ != $curlogicline && [$ta compare $curphysline < $endpos]} {
                incr offset
                set curphysline [$ta index "$offset.0"]
                if {$linenumberstype eq "logical"} {
                    set contlines [countcontlines $ta 1.0 $curphysline]
                } else {
                    # $linenumberstype eq "logical_ignorecontlines"
                    set contlines 0
                }
                set curlogicline [$ta index "$curphysline - $contlines l"]
            }
            $ta mark set insert $curphysline
            catch {keyposn $ta}
            $ta see insert

        }

    } else {
        if {$physlogic_ == "physical"} {
            # go to physical line in function
            set textarea [lindex $funtogoto_ 1]
            set absoluteline [$textarea index "[lindex $funtogoto_ 2] + 1c + $linetogo_ lines -1l"]
            # check that the end of the function is after the position to go to
            set infun [whichfun $absoluteline $textarea]
            if {$infun == {}} {
                # target line is before function definition line - should never
                # happen when called from the goto dialog since negative or
                # null line numbers are forbidden in the entry widget!
                # however, whichfun says (correctly) that $absoluteline is
                # outside of function when $absoluteline is on the same
                # line as the keyword function, but before it because of
                # indentation - this is not an error and Scipad goes to
                # the correct line
                set absoluteline [$textarea index [lindex $funtogoto_ 2]]
            } else {
                # target line is after the beginning of the function definition
                if {[lindex $infun 0] != [lindex $funtogoto_ 0]} {
                    # target line is either after the end of the function definition,
                    # or we're going to line 1 of a function nested in another one (with
                    # indentation)
                    # we will jump to the start of the function definition in both cases
                    # but the showinfo message shall show up only in the first case
                    if {$linetogo_ != 1} {
                        showinfo [mc "Outside of function definition"]
                    }
                    set absoluteline [$textarea index [lindex $funtogoto_ 2]]
                } else {
                    # target position is between function and endfunction lines (inclusive)
                    set absoluteline [$textarea index "[lindex $funtogoto_ 2] + $linetogo_ lines -1l"]
                }
            }
            showtext $textarea
            $textarea mark set insert $absoluteline
            catch {keyposn $textarea}
            $textarea see insert

        } else {
            # go to logical line in function
            set textarea [lindex $funtogoto_ 1]
            set funstart [lindex $funtogoto_ 2]
            set offset 0
            set nbcl 0
            while {[expr {$offset - $nbcl + 1}] != $linetogo_} {
                incr offset
                if {$linenumberstype eq "logical"} {
                    set nbcl [countcontlines $textarea $funstart "$funstart + $offset l"]
                } else {
                    # $linenumberstype eq "logical_ignorecontlines"
                    set nbcl 0
                }
            }
            set infun [whichfun [$textarea index "$funstart + $offset l"] $textarea]
            if {[lindex $infun 0] == [lindex $funtogoto_ 0]} {
                # target logical line is between function and endfunction
                set targetline [$textarea index "$funstart + $offset l"]
            } else {
                # target logical line is after the endfunction,
                # we will jump to the start of the function definition instead
                showinfo [mc "Outside of function definition"]
                set targetline [$textarea index $funstart]
            }
            showtext $textarea
            $textarea mark set insert $targetline
            catch {keyposn $textarea}
            $textarea see insert

        }
    }

}
