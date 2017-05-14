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

proc update_bubble_uservar {type widgetname mousexy textarea} {
# Manage the popup bubbles that display user variables content
    global bubbletextuservar show_displaybusystate
    global showuservartooltips
    if {$showuservartooltips eq "never"} {
        return
    }
    if {$showuservartooltips eq "debug" && [getdbstate] ne "DebugInProgress"} {
        return
    }
    if {[getdbstate] ne "DebugInProgress"} {
        if {[isscilabbusy]} {
            # One must not send  ScilabEval seq  when Scilab is waiting in xclick()
            # This would be happening when Scipad is used by plotprofile:
            # plotprofile uses xclick, and when xclick waits for a mouse
            # event the ScilabEvals seq are sometimes just not executed, or become
            # interruptible (bug!)
            # This buggy behavior may trigger an error during plotprofile, thus
            # improperly terminating profiling on an error triggered by Scipad
            # but that is originating from xclick()
            # The error usually is:
            # er .scipad.new2 {851 201} $bubbletextuservar true","scipad"); TCL_EvalStr("set show_displaybusystate true","scipad")
            #                                                              !--error 999
            # TCL_EvalStr, can't read "bubbletextuservar": no such variable at line 1
            # while executing a callback
            # at line     112 of function plotprofile called by :
            # plotprofile(foobar)
            return
        }
    }
    if {$type eq "enter"} {
        foreach {x y} $mousexy {}
        set xt [winfo rootx $textarea]
        set yt [winfo rooty $textarea]
        set x [expr {$x - $xt}]
        set y [expr {$y - $yt}]
        set ind [$textarea index @$x,$y]
        set varrangeinta [$textarea tag prevrange uservar "$ind + 1 c"]
        foreach {sta sto} $varrangeinta {}
        set varname [$textarea get $sta $sto]
        set show_displaybusystate false
        getonewatchvarfromshell_forbubble $varname
        set comm1 "TCL_EvalStr(\"update_bubble $type $widgetname [list $mousexy] \$bubbletextuservar true\",\"scipad\");"
        set comm2 "TCL_EvalStr(\"set show_displaybusystate true\",\"scipad\");"
        set fullcomm [concat $comm1 $comm2]
        ScilabEval_lt $fullcomm seq
    } else {
        set varname ""
       update_bubble $type $widgetname [list ] ""
    }
}

proc update_bubble_panetitle {type widgetname mousexy textarea} {
# Manage the popup bubbles that display the fullname of a textarea packed in a pane
    global listoffile filenamesdisplaytype
    if {$filenamesdisplaytype ne "full" || [ispanetitletruncated $textarea]} {
        update_bubble $type $widgetname $mousexy $listoffile("$textarea",fullname)
    }
}

proc update_bubble_watch {type butnum mousexy} {
# Wrapper for generic_update_bubble_watch (all but step by step icons)
    global pad watchwinicons
    generic_update_bubble_watch $type $butnum $mousexy \
            $watchwinicons $pad.filemenu.debug
}

proc update_bubble_watch_step {type butnum mousexy} {
# Wrapper for generic_update_bubble_watch (step by step icons)
    global pad watchwinstepicons
    generic_update_bubble_watch $type $butnum $mousexy \
            $watchwinstepicons $pad.filemenu.debug.step
}

proc generic_update_bubble_watch {type butnum mousexy watchwiniconslist menutosearchin} {
# Manage the popup bubbles that display the name and accelerator of the watch
# window icons
    set butname [lindex $watchwiniconslist $butnum]
    set txt [$menutosearchin entrycget $butnum -label]
    set acc [$menutosearchin entrycget $butnum -accelerator]
    if {$acc != ""} { set txt "$txt ($acc)" }
    update_bubble $type $butname $mousexy $txt
}

proc update_bubble_watchvar {w type mousexy} {
# Manage the popup bubbles that display the type and size of the watched
# variables
# Because there is no <Enter> and <Leave> events for listbox individual
# entries, some gymnastics must be done here to update the bubble when
# the mouse is hovering over a new entry
    global pad watchvarsprops
    global go_on_update_bubble_watchvar hovereditem_update_bubble_watchvar

    if {$type == "enter" && $go_on_update_bubble_watchvar} {

        # no bubble should show up if the mouse is below the last watched var
        set ycoordinw [expr {[winfo pointery $pad] - [winfo rooty $w]}]
        set bboxoflast [$w bbox end]
        if  {$bboxoflast == ""} {
            # last element not visible, i.e. the listbox area is full - nothing to do
        } else {
            set ylast [lindex $bboxoflast 1]
            set hlast [lindex $bboxoflast 3]
            if {$ycoordinw > [expr {$ylast + $hlast}]} {
                # delete bubble now
                update_bubble_watchvar $w leave [list ]
                # and check again later
                after 100 "update_bubble_watchvar $w $type \[winfo pointerxy $pad\]"
                return
            }
        }
        set hovereditem [$w nearest $ycoordinw]

        # if the new hovered item is the same as in the previous call to this
        # proc, just reschedule a check for later
        if {[info exists hovereditem_update_bubble_watchvar]} {
            if {$hovereditem == $hovereditem_update_bubble_watchvar} {
                after 100 "update_bubble_watchvar $w $type \[winfo pointerxy $pad\]"
                return
            } else {
                set hovereditem_update_bubble_watchvar $hovereditem
            }
        } else {
            set hovereditem_update_bubble_watchvar $hovereditem
        }

        # a new item is hovered, retrieve the corresponding watch variable name
        set wvar [$w get $hovereditem]
        if {$wvar == ""} {
            return
        }

        # prevent from bubble vanishing because of a previous call to destroy
        # while the mouse was hovering something else
        cancel_bubble_deletion $w

        # destroy the previous bubble and create the new one
        update_bubble leave $w [list ] ""
        update_bubble enter $w $mousexy $watchvarsprops($wvar,tysi)

        # wait a bit and play the game again
        after 100 "update_bubble_watchvar $w $type \[winfo pointerxy $pad\]"

    } else {
        # $type == "leave" or $go_on_update_bubble_watchvar is false,
        # then delete the bubble immediately
        update_bubble leave $w [list ] ""
        unset -nocomplain -- hovereditem_update_bubble_watchvar
    }
}


proc update_bubble_if_needed {type widgetname mousexy bubbletxt {longontimeflag false}} {
# show/delete a bubble tooltip if the text displayed in $widgetname is larger
# than what the widget can display without truncation
# if $widgetname is anything else than an entry widget, update_bubble is called
# irrespective of what is displayed in the widget
    if {[winfo class $widgetname] eq "Entry"} {
        set pixwidth [winfo width $widgetname]
        if {[font measure [$widgetname cget -font] [$widgetname get]] > $pixwidth} {
            set callit true
        } else {
            set callit false
        }
    } else {
        set callit true
    }
    if {$callit} {
        update_bubble $type $widgetname $mousexy $bubbletxt $longontimeflag
    }
}

proc update_bubble {type widgetname mousexy bubbletxt {longontimeflag false}} {
# generic bubble window handler
    global menuFont
    set bubble $widgetname.bubble
    catch {destroy $bubble}
    if {$type=="enter"} {
        update idletasks
        after 100
        toplevel $bubble -relief solid -bg PaleGoldenrod -bd 1
        wm overrideredirect $bubble 1
        wm transient $bubble
        wm withdraw $bubble
        catch {wm attributes $bubble -topmost 1}
        label $bubble.txt -text $bubbletxt -relief flat -bd 0 \
                          -highlightthickness 0 -bg PaleGoldenrod \
                          -font $menuFont -justify left
        # catched since not all widgets support the -state option (e.g. frame)
        catch {
            if {[$widgetname cget -state] eq "disabled"} {
                $bubble.txt configure -state disabled
            }
        }
        pack $bubble.txt -side left
        update idletasks
        if {![winfo exists $bubble]} {return}
        set  scrwidth  [winfo vrootwidth  .]
        set  scrheight [winfo vrootheight .]
        set  width     [winfo reqwidth  $bubble]
        set  height    [winfo reqheight $bubble]
        set x [lindex $mousexy 0]
        set y [lindex $mousexy 1]
        incr y 12
        incr x 8
        if { $x+$width > $scrwidth } {
            set x [expr {$scrwidth - $width}]
        }
        if { $y+$height > $scrheight } {
            set y [expr {$y - 12 - $height}]
        }
        wm geometry  $bubble "+$x+$y"
        update idletasks
        if {![winfo exists $bubble]} {return}
        wm deiconify $bubble
        raise $bubble
        if {!$longontimeflag} {
            set delaybeforeoff 2000
       } else {
            # normally there should be no need to manually delete the tooltip
            # since this should be bound to the <Leave> event, however sometimes
            # when moving the mouse quickly the <Leave> event apparently does not fire
            set delaybeforeoff 10000
        }
        set cmd [list destroy $bubble]
        after $delaybeforeoff $cmd
    }
}

proc cancel_bubble_deletion {widgetname} {
    after cancel [list destroy $widgetname.bubble]
}

proc show_matching_char {type whereintextarea textarea} {
# highlight the character matching the one denoted by $whereintextarea,
# or stop highlighting (when type eq "leave")
# $whereintextarea either is a list of two integers, in which case it's a mouse x,y position
# or it is a direct index in $textarea

    global highlightmatchingchars

    if {$type eq "enter" && $highlightmatchingchars ne "never"} {

        if {[llength $whereintextarea] == 2} {
            # compute index below the mouse, which is also the index of the character
            # for which a matching character will be searched for
            foreach {x y} $whereintextarea {}
            set xt [winfo rootx $textarea]
            set yt [winfo rooty $textarea]
            set x [expr {$x - $xt}]
            set y [expr {$y - $yt}]
            set indofbs [$textarea index @$x,$y]
        } else {
            # [llength $whereintextarea] should be 1
            set indofbs $whereintextarea
        }

        # brace character        
        set brace [$textarea get $indofbs]

        # should never happen that this proc be triggered for anything else than
        # a parenthesis, a bracket or a brace, but anyway...
        if {[string first $brace "\{\}\[\]\(\)"] == -1} {
            return
        }

        foreach {findbs bs dir} [getfindbsregexpcorrbscharandsearchdir $brace] {}
        set indofcorrbs [getindofsymbol2 $textarea $indofbs $dir $findbs $bs true]

        if {$indofcorrbs ne ""} {
            $textarea tag add highlighted_matching_char $indofbs
            $textarea tag add highlighted_matching_char $indofcorrbs
            # the following two lines are only needed the first time Scipad highlights, but
            # it does not eat much performance to do it always
            $textarea tag configure highlighted_matching_char -borderwidth 1
            $textarea tag configure highlighted_matching_char -relief solid
        } else {
            # don't do anything if no matching character could be found
        }

    } else {
        # $type eq "leave"  or  $highlightmatchingchars eq "never"
        $textarea tag remove highlighted_matching_char 1.0 end
    }
}

proc show_matching_char_at_cursor {w ind} {
# highlight the character matching the one at the right of the position $ind
# in textarea $w, or stop highlighting

    global highlightmatchingchars

    if {$highlightmatchingchars eq "both" || $highlightmatchingchars eq "cursor"} {
        set tagsatind [$w tag names $ind]
        set pattern {parenthesis|bracket|brace|Modelica_parenthesis|Modelica_bracket|Modelica_brace}
        # show_matching_char catched because textarea $w may become closed
        # during execution, which would otherwise throw an error
        # the reason why this may happen is that the binding triggering
        # proc show_matching_char_at_cursor may fire *after* a click on
        # the close button of a textarea
        if {[regexp -- $pattern $tagsatind] == 1} {
            # there is an interesting tag (i.e. from $pattern) at index $ind
            catch {show_matching_char leave $ind $w}
            catch {show_matching_char enter $ind $w}
        } else {
            catch {show_matching_char leave $ind $w}
        }
    } else {
        # $highlightmatchingchars eq "never" || $highlightmatchingchars eq "hover"
        # do nothing ("hover" is handled by a bindings from proc TextStyles)
    }
}

proc show_matching_char_at_mouse {type w} {
# highlight the character matching the one below the mouse
# in textarea $w, or stop highlighting

    global pad highlightmatchingchars

    set mousexy [winfo pointerxy $pad]
    if {$highlightmatchingchars eq "both" || $highlightmatchingchars eq "hover"} {
        # show_matching_char catched because textarea $w may become closed
        # during execution, which would otherwise throw an error
        # the reason why this may happen is that the binding triggering
        # proc show_matching_char_at_mouse may fire *after* a click on
        # the close button of a textarea
        catch {show_matching_char $type $mousexy $w}
    } else {
        # $highlightmatchingchars eq "never" || $highlightmatchingchars eq "cursor"
        # do nothing ("cursor" is handled by a call from proc dokeyposn)
    }
}
