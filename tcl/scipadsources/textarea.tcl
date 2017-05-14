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

if {[catch {rename ::tk::TextClosestGap ::tk::TextClosestGap_original} dropthis] == 0 } {

    # ::tk::TextClosestGap from Tk is now known as ::tk::TextClosestGap_original
    # Now redefine ::tk::TextClosestGap so that it no longer gives the position
    # in $w which is closest to the point where the mouse was when clicked,
    # but so that it is now just [$w index @$x,$y], but only when TextClosestGap_original
    # results in a change of line
    # This is wanted in normal editing, because the following behavior is
    # not desired:
    #      say there is a line with text not filling the entire display
    #      width of the textarea. Click on that line between the last
    #      character and the right border of the textarea. If the click
    #      occurred closer to the last character than to the right border
    #      then the cursor is placed right after the last character (correct).
    #      Otherwise the cursor jumps to character zero of next line, which
    #      is surprising. This is the behavior of ::tk::TextClosestGap_original.
    # By redefining ::tk::TextClosestGap here, this is avoided because on button-1
    # mouse click the Text class binding (bind Text <Button-1>) fires, which
    # launches tk::TextButton1 %W %x %y, which in turn uses ::tk::TextClosestGap
    # to set the insert position in the textarea. Redefining the latter allows to
    # "fix" the unwanted (but standard) behaviour with no further action since
    # it's the redefined proc that will be launched by tk::TextButton1
    # The original ::tk::TextClosestGap from Tk is still available under its
    # new name ::tk::TextClosestGap_original, and this is used when clicking
    # does not result (through TextClosestGap_original) in a change of line,
    # and also for block selections in TextClosestGap_scipad 
    # Other procs in the Tk text widget that use the original ::tk::TextClosestGap
    # are ::tk::TextSelectTo and ::tk::TextPasteSelection: using the redefined
    # ::tk::TextClosestGap instead of the original one looks beneficial as well
    # for these two procs

    proc ::tk::TextClosestGap {w x y} {
        set TCGorig_pos [$w index [::tk::TextClosestGap_original $w $x $y]]
        set at_pos      [$w index @$x,$y]
        if {[$w compare [$w index "$TCGorig_pos linestart"] == [$w index "$at_pos linestart"]]} {
            return $TCGorig_pos
        } else {
            return $at_pos
        }
    }

    proc TextClosestGap_scipad {w x y} {
    # this is a bulletproof wrapper to the Tk private function
    # ::tk::TextClosestGap which is useful for block selections
    # since ::tk::TextClosestGap is not part of the public interface
    # of the text widget, a fallback using only public interface
    # functions must exist to guard against private functions changes
    # in Tk
    # The bulletproofing is done in the catch above in the if statement,
    # therefore this proc is just:
        return [::tk::TextClosestGap_original $w $x $y]
    }

} else {

    # ::tk::TextClosestGap does not exist (I doubt there is any Tk version
    # fulfilling this condition, but in this case don't make any attempt around it!)

    proc TextClosestGap_scipad {w x y} {
    # see comments in the other branch of this if statement
        return [$w index @$x,$y]
    }
}

proc setTextAnchor_scipad {w} {
# this sets the anchor of textarea $w at the insert cursor position
# it contains a bulletproof wrapper to the Tk private function
# ::tk::TextAnchor which gets the anchor mark name of textarea $w
# (which is not the same for all peers for instance)
# this wrapper takes care of private functions changes that
# can happen since ::tk::TextAnchor is not part of the public
# interface of the text widget
    if {[catch {::tk::TextAnchor $w} anchorname] == 0} {
        $w mark set $anchorname insert
        # gravity of anchor mark left unchanged - see
        # proc ::tk::TextButton1 for how to manage it if needed
    } else {
        # no fallback if ::tk::TextAnchor does no longer exist
        # in the Tk version running Scipad
    }
}


proc gettextareacur {} {
    global textareacur
    return $textareacur
}

proc settextareacur {val} {
    global textareacur
    set textareacur $val
}

# nondefOpts - return a list of options with values 
#              that are different than the default value.
#
# ARGUMENTS:
#	widget	the widget whose options are to be constructed
#
# RETURN VALUE:
#	a list with option/value pairs
#
# NOTES
#	The configure message to a widget returns either an option
#	description:
#		{argvName dbName dbClass defValue curValue}
#	or a synonym description:
#		{argvName dbName}
#
proc nondefOpts {widget} {
    set options {}
    foreach i [$widget configure] {
        if {[llength $i] != 2} {
            set optname [lindex $i 0]
            set defval [lindex $i 3]
            set curval [lindex $i 4]
            #if [string compare $defval $curval] {
                lappend options $optname $curval
                #}
        }
    }
    return $options
}

# dupWidget - make a copy of a widget.
#
# ARGUMENTS:
#	widget	the widget to be duplicated
#	name	the name for the new widget
#
# RETURN VALUE:
#	a new widget
#
proc dupWidgetOption {widget name} {
    return [eval  \
           "[string tolower [winfo class $widget]] $name [nondefOpts $widget]"]
}

proc TextStyles {t} {
    global colorpref
    foreach c1 $colorpref {global $c1}
    global actbptextFont textunderlinedFont
    global linenumbersmargin modifiedlinemargin
    global pad listoffile

    set REPLACEDTEXTCOLOR $CURFOUNDTEXTCOLOR
    set FAKESELCOLOR $SELCOLOR

    $t configure -foreground $FGCOLOR -insertbackground $CURCOLOR \
                 -selectbackground $SELCOLOR -selectforeground [blackorwhite $SELCOLOR]

    # if $t shows a binary file, set to disabled textarea so that no modification can happen
    if {$listoffile("$t",binary)} {
        set contrastingcolor [blackorwhite $BGCOLOR]
        $t configure -state disabled \
                     -background [shade $BGCOLOR $contrastingcolor 0.1]
    } else {
        $t configure -state normal \
                     -background $BGCOLOR
    }

    $t tag configure parenthesis -foreground $PARCOLOR
    $t tag configure bracket -foreground $BRAKCOLOR
    $t tag configure brace -foreground $BRACCOLOR
    $t tag configure punct -foreground $PUNCOLOR
    $t tag configure intfun -foreground $INTFCOLOR
    $t tag configure command -foreground $COMMCOLOR
    $t tag configure libfun -foreground $LFUNCOLOR
    $t tag configure userfun -foreground $USERFUNCOLOR
    $t tag configure uservar -foreground $USERVARCOLOR
    $t tag configure scicos -foreground $SCICCOLOR
    $t tag configure predef -foreground $PDEFCOLOR
    $t tag configure operator -foreground $OPCOLOR
    $t tag configure textquoted -foreground $QTXTCOLOR
    $t tag configure rem2 -foreground $REMCOLOR
    $t tag configure xmltag -foreground $XMLCOLOR
    $t tag configure number -foreground $NUMCOLOR

    tagconfigurebreakpointbackground_textarea $t
    $t tag configure activebreakpoint -background $BREAKPOINTCOLOR
    $t tag configure activebreakpoint -font $actbptextFont \
        -relief raised -borderwidth 2

    $t tag configure anyfoundtext -background $ANYFOUNDTEXTCOLOR
    $t tag configure curfoundtext -background $CURFOUNDTEXTCOLOR
    $t tag configure replacedtext -background $REPLACEDTEXTCOLOR
    $t tag configure fakeselection -background $FAKESELCOLOR

    taglowerbreakpoint $t activebreakpoint
    $t tag raise sel activebreakpoint

    $t tag configure Modelica_punct       -foreground $MODELICAPUNCOLOR
    $t tag configure Modelica_parenthesis -foreground $MODELICAPARCOLOR
    $t tag configure Modelica_bracket     -foreground $MODELICABRAKCOLOR
    $t tag configure Modelica_brace       -foreground $MODELICABRACCOLOR
    $t tag configure Modelica_operator    -foreground $MODELICAOPCOLOR
    $t tag configure Modelica_number      -foreground $MODELICANUMBERCOLOR
    $t tag configure Modelica_keyword     -foreground $MODELICAKEYWORDCOLOR
    $t tag configure Modelica_introp      -foreground $MODELICAINTROPCOLOR
    $t tag configure Modelica_string      -foreground $MODELICASTRINGCOLOR
    $t tag configure Modelica_comment     -foreground $MODELICACOMMENTCOLOR

    if {[isdisplayed $t]} {
        set tapwfr [getpaneframename $t]
        if {$linenumbersmargin ne "hide"} {
            $tapwfr.marginln configure -background $BGLNMARGCOLOR -foreground $FGLNMARGCOLOR
        }
        if {$modifiedlinemargin ne "hide"} {
            $tapwfr.propagationoffframe.marginml configure -background $BGMLMARGCOLOR
            $tapwfr.propagationoffframe.marginml tag configure unsavedmodifiedline -background $FGUSMLMARGCOLOR
            $tapwfr.propagationoffframe.marginml tag configure   savedmodifiedline -background $FGSMLMARGCOLOR
        }
    }

    $t tag configure clickablelink -font $textunderlinedFont -foreground $CLICKABLELINKCOLOR

    # bindings for user variable content display in a tooltip
    $t tag bind uservar <Enter> "update_bubble_uservar enter %W \[winfo pointerxy $pad\] $t"
    $t tag bind uservar <Leave> "update_bubble_uservar leave %W \[winfo pointerxy $pad\] $t"

    # bindings for showing the matching parenthesis when hovering the mouse over them
    # the <Motion> event is needed to trigger highlighting of adjacent characters, e.g. (((abcde)))
    $t tag bind parenthesis <Enter>  "show_matching_char_at_mouse enter $t"
    $t tag bind parenthesis <Motion> "show_matching_char_at_mouse leave $t; \
                                      show_matching_char_at_mouse enter $t"
    $t tag bind parenthesis <Leave>  "show_matching_char_at_mouse leave $t"
    $t tag bind bracket     <Enter>  "show_matching_char_at_mouse enter $t"
    $t tag bind bracket     <Motion> "show_matching_char_at_mouse leave $t; \
                                      show_matching_char_at_mouse enter $t"
    $t tag bind bracket     <Leave>  "show_matching_char_at_mouse leave $t"
    $t tag bind brace       <Enter>  "show_matching_char_at_mouse enter $t"
    $t tag bind brace       <Motion> "show_matching_char_at_mouse leave $t; \
                                      show_matching_char_at_mouse enter $t"
    $t tag bind brace       <Leave>  "show_matching_char_at_mouse leave $t"
    $t tag bind Modelica_parenthesis <Enter>  "show_matching_char_at_mouse enter $t"
    $t tag bind Modelica_parenthesis <Motion> "show_matching_char_at_mouse leave $t; \
                                               show_matching_char_at_mouse enter $t"
    $t tag bind Modelica_parenthesis <Leave>  "show_matching_char_at_mouse leave $t"
    $t tag bind Modelica_bracket     <Enter>  "show_matching_char_at_mouse enter $t"
    $t tag bind Modelica_bracket     <Motion> "show_matching_char_at_mouse leave $t; \
                                               show_matching_char_at_mouse enter $t"
    $t tag bind Modelica_bracket     <Leave>  "show_matching_char_at_mouse leave $t"
    $t tag bind Modelica_brace       <Enter>  "show_matching_char_at_mouse enter $t"
    $t tag bind Modelica_brace       <Motion> "show_matching_char_at_mouse leave $t; \
                                               show_matching_char_at_mouse enter $t"
    $t tag bind Modelica_brace       <Leave>  "show_matching_char_at_mouse leave $t"

    # bindings for clickable items tooltipping (URLs, library functions, scicos functions)
    $t tag bind url     <Enter> {clickableitem_enter %W %x %y url}
    $t tag bind url     <Leave> {clickableitem_leave %W url}
    $t tag bind libfun  <Enter> {clickableitem_enter %W %x %y libfun}
    $t tag bind libfun  <Leave> {clickableitem_leave %W libfun}
    $t tag bind scicos  <Enter> {clickableitem_enter %W %x %y scicos}
    $t tag bind scicos  <Leave> {clickableitem_leave %W scicos}
    $t tag bind userfun <Enter> {clickableitem_enter %W %x %y userfun}
    $t tag bind userfun <Leave> {clickableitem_leave %W userfun}
}

proc clickableitem_enter {w x y tagname} {
    global pad mouseoverlink
    $w configure -cursor hand2
    set stasto [$w tag prevrange $tagname @$x,$y]
    if {$stasto eq ""} {
        # happened once to me, must be due to a race condition
        return
    }
    foreach {sta sto} $stasto {}
    $w tag add clickablelink $sta $sto
    set mouseoverlink "mouseover$tagname"
    update_bubble enter $w [winfo pointerxy $pad] [mc "Ctrl+click to follow the link"] true
}

proc clickableitem_leave {w tagname} {
    global pad mouseoverlink
    $w configure -cursor xterm
    $w tag remove clickablelink 1.0 end
    set mouseoverlink ""
    update_bubble leave $w [winfo pointerxy $pad] [mc "Ctrl+click to follow the link"] true
}

proc getwindowsmenusortedlistofta {talist} {
# $talist is a flat list of textareas
# this proc returns a list of elements, each element being itself a list of
# three elements: {textarea displayedname modifiedtime}
# the point is that the output list is sorted according to the option
# selected for sorting the Windows menu

    global windowsmenusorting listoffile

    set li [list ]
    foreach ta $talist {
        if {$listoffile("$ta",thetime) == "0"} {
            # a new unsaved file has thetime = 0
            # change it to a large value (around year 2034)
            # this saves from computing the max
            # note: 2000000000 works in lsort, but not 3000000000
            # there must be some internal limit wrt numbers coding
            # (probably 31 bits + sign ; 2^31 = 2147483648)
            set thetime "2000000000"
        } else {
            set thetime $listoffile("$ta",thetime)
        }
        lappend li [list $ta $listoffile("$ta",displayedname) $thetime]
    }
    switch -- $windowsmenusorting {
        openorder {
            # nothing to do, switching order is already OK
        }
        alphabeticorder {
            set li [lsort -dictionary -index 1 $li]
        }
        MRUorder {
            set li [lsort -decreasing -integer -index 2 $li]
        }
        default {
            # can't happen in principle
            tk_messageBox -message "Unexpected sort scheme in proc getwindowsmenusortedlistofta ($windowsmenusorting): please report"
        }
    }
    return $li
}

proc highlighttextarea {textarea} {
# Set the visual hint such that $textarea can be recognized as being the
# active buffer
    global pad
    foreach pw [getlistofpw] {
        foreach pa [$pw panes] {
            $pa configure -background gray
        }
    }
    if {[isdisplayed $textarea]} {
# <TODO> must fix bug 2648 - 06/05/08: Think it's fixed, but let's see in the future...
#        there seems to be a race condition here. [isdisplayed $textarea] returns true,
#        i.e [getpaneframename $textarea] does return something different from "none"
#        but nevertheless the subsequent call to the same [getpaneframename $textarea]
#        just below returns "none" !!!
#        07/10/09: Further fixed possible race conditions due to binding triggering
#        on <ButtonRelease-1>
        [getpaneframename $textarea] configure -background black
    } else {
        # should never happen because highlighttextarea is supposed
        # to be called only with a currently visible textarea argument
        # however, at least one case is still not solved that will trigger
        # the "invalid command name "none"" bug, but I couldn't reproduce
        # yet: it has to do with clicking Button-1 in Scipad while a dnd is
        # processed - Detailed error message is:
        #
        # invalid command name "none"
        # invalid command name "none"
        #     while executing
        # "[getpaneframename $textarea] configure -background black"
        #     (procedure "highlighttextarea" line 10)
        #     invoked from within
        # "highlighttextarea $textarea"
        #     (procedure "focustextarea" line 19)
        #     invoked from within
        # "focustextarea .scipad.new4 "
        #     invoked from within
        # "if {$dndinitiated} {  set dndinitiated false ;  } else {  if {[info exists listoffile(".scipad.new4",fullname)]} {  focustextarea .scipad....}}"
        #     (command bound to event)
        #
        tk_messageBox -message "Unexpected condition triggered in proc highlighttextarea for $textarea. Clicking OK in this dialog will display the full error message. Please report and detail precisely what you were doing when this happened."
        # trigger the error
        [getpaneframename $textarea] configure -background black
    }
}

proc togglewordwrap {} {
    global wordWrap listoftextarea
    foreach ta $listoftextarea {
        $ta configure -wrap $wordWrap
    }
    if {$wordWrap != "none"} {        
        # remove x scrollbars
        foreach ta $listoftextarea {
            if {[isdisplayed $ta]} {
                set tapwfr [getpaneframename $ta]
                pack forget $tapwfr.xscroll
                destroy $tapwfr.xscroll
                pack forget $tapwfr.pwbottom.bottom
                destroy $tapwfr.pwbottom.bottom
                pack forget $tapwfr.pwbottom
                destroy $tapwfr.pwbottom
            }
        }
    } else {
        # display x scrollbars
        foreach ta $listoftextarea {
            if {[isdisplayed $ta]} {
                set tapwfr [getpaneframename $ta]
                panedwindow $tapwfr.pwbottom -borderwidth 0 -opaqueresize false -sashrelief raised \
                        -sashwidth 10 -orient horizontal
                frame $tapwfr.pwbottom.bottom
                frame $tapwfr.pwbottom.emptyframe -height 0 -borderwidth 0
                $tapwfr.pwbottom add $tapwfr.pwbottom.emptyframe
                $tapwfr.pwbottom add $tapwfr.pwbottom.bottom
                $tapwfr.pwbottom sash place 0 0 0
                bind $tapwfr.pwbottom <Button-1>        {focustaabouttobesplit %W}
                bind $tapwfr.pwbottom <B1-Motion>       {after idle {clampproxy %W}}
                bind $tapwfr.pwbottom <ButtonRelease-1> {after idle {splitfromsash %W tile}}
                bind $tapwfr.pwbottom <Button-2>        {focustaabouttobesplit %W}
                bind $tapwfr.pwbottom <ButtonRelease-2> {after idle {splitfromsash %W file}}
                pack $tapwfr.pwbottom -side bottom -expand 0 -fill both
                scrollbar $tapwfr.xscroll -command "$ta xview" \
                    -takefocus 0 -orient horizontal
                pack $tapwfr.xscroll -in $tapwfr.pwbottom.bottom -side bottom \
                    -expand 1 -fill x
            }
        }
    }
}

proc intmiddleind {ta low high} {
# return the index in $ta corresponding to the beginning of
# line having index int(($low + $high)/2) in textarea $ta
    # no validity check for $low and $high: speed is more important
    scan $low  "%d." lowl
    scan $high "%d." highl
    # int() function intentionally used here, don't change
    # without knowing what you do!
    set midl [expr {int(($lowl + $highl) / 2)}]
    set mid [$ta index "$midl.0"]
    return $mid
}


if {!$Tkbug3288113_shows_up} {

    # This is used in recent Tk versions having bug 3288113 fixed!

proc getmarknames {ta sta sto} {
# return the list of all mark names in textarea $ta that can be
# found between the gap just before index $sta (inclusive, even
# if this mark has gravity left) and the gap just before index
# $sto (not included)
# multiple marks at the same index are returned, not just the first
# mark of a given index
# the naive implementation:
#    foreach amark [$ta mark names]
#        if mark index is between $sta and $sto then
#            add it to the return list of mark names
#        else
#        end
#    end
# is very inefficient when there is a large number of marks
# and only a small part (compared to its full size) of $ta
# shall be searched (i.e. when $sta and $sto are close to
# each other)
# therefore, in such a case, it is better to use the following
# implementation based on  $ta mark next $index

    # normalize indices
    set sta [$ta index $sta]
    set sto [$ta index $sto]
    # favor performance: no check that $sta < $sto for instance

    set listofmarks [list ]

    # get first mark of the requested range, use *index* $sta
    set amark [$ta mark next $sta]
    if {$amark ne {}} {
        set indofamark [$ta index $amark]
        # now loop on marks until after $sto
        while {[$ta compare $indofamark < $sto]} {
            lappend listofmarks $amark
            # get next mark, use *mark name* $amark, thus retrieving
            # further marks possibly at the same index
            set amark [$ta mark next $amark]
            if {$amark ne {}} {
                set indofamark [$ta index $amark]
            } else {
                # no mark anymore in the text widget $ta,
                # go out of the while loop
                set indofamark $sto
            }
        }
    }

    return $listofmarks
}


} else {

    # This is used in older Tk versions still exhibiting bug 3288113!

proc getmarknames {ta sta sto} {
# get all marks from text widget $ta and from all its peers,
# and return a list without duplicates
#
# This should not be needed but due to Tk bug 3288113, unfortunately
# one cannot count on  $ta mark next $ind  when $ta has peers from
# which marks have been set
# getmarknames_onepeer is called for each peer and the results from
# all of them get merged
# note1: getmarknames_onepeer is exactly getmarknames above for the
#        case "Tk bug 3288113 fixed"
# note2: getmarknames_onepeer is sometimes still not enough - test case:
#        missing modified line tag in the following case:
#          . fresh scipad, no previous session layout
#          . ctrl+alt+(shift+)2 to tile vertically the initial textarea
#          . type any character in the new tile (the modified line tag
#            shows up in both tiles)
#          . push the close button of the tile
#         ---> the modified line tag is not shown in the initial tile
#         This is due to $ta mark next $i in proc getmarknames_onepeer
#         not returning the expected mark (while $ta mark names does),
#         i.e. this is Tk bug #3288113:
#         http://sourceforge.net/tracker/?func=detail&aid=3288113&group_id=12997&atid=112997

    set listofmarks [list ]
    foreach apeer [getfullpeerset $ta] {
        foreach amark [getmarknames_onepeer $apeer $sta $sto] {
            lappend listofmarks $amark
        }
    }
    # sorting is to benefit from the -unique option,
    # which removes duplicates
    set listofmarks [lsort -unique $listofmarks]
    return $listofmarks
}

proc getmarknames_onepeer {ta sta sto} {
# return the list of all mark names in textarea $ta that can be
# found between the gap just before index $sta (inclusive, even
# if this mark has gravity left) and the gap just before index
# $sto (not included)
# multiple marks at the same index are returned, not just the first
# mark of a given index
# the naive implementation:
#    foreach amark [$ta mark names]
#        if mark index is between $sta and $sto then
#            add it to the return list of mark names
#        else
#        end
#    end
# is very inefficient when there is a large number of marks
# and only a small part (compared to its full size) of $ta
# shall be searched (i.e. when $sta and $sto are close to
# each other)
# therefore, in such a case, it is better to use the following
# implementation based on  $ta mark next $index

    # normalize indices
    set sta [$ta index $sta]
    set sto [$ta index $sto]
    # favor performance: no check that $sta < $sto for instance

    set listofmarks [list ]

    # get first mark of the requested range, use *index* $sta
    set amark [$ta mark next $sta]
    if {$amark ne {}} {
        set indofamark [$ta index $amark]
        # now loop on marks until after $sto
        while {[$ta compare $indofamark < $sto]} {
            lappend listofmarks $amark
            # get next mark, use *mark name* $amark, thus retrieving
            # further marks possibly at the same index
            set amark [$ta mark next $amark]
            if {$amark ne {}} {
                set indofamark [$ta index $amark]
            } else {
                # no mark anymore in the text widget $ta,
                # go out of the while loop
                set indofamark $sto
            }
        }
    }

    return $listofmarks
}

    # this is the naive implementation, which works always since
    # it is based on $ta mark names and not on $ta mark next
    # BUT it is deadly slow when there is a large number of marks
    # and since proc updatemodifiedlinemargin calls it repeatedly
    # with "$pos $pos+1c" arguments
#    proc getmarknames {ta sta sto} {
#        set sta [$ta index $sta]
#        set sto [$ta index $sto]
#        set listofmarks [list ]
#        foreach amark [$ta mark names] {
#            if {[$ta compare $amark >= $sta] && [$ta compare $amark <= $sto]} {
#                lappend listofmarks $amark
#            }
#        }
#        return $listofmarks
#    }

}
