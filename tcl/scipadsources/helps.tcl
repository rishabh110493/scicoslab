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

proc aboutme {} {
# about box
    global applicationname ScipadVersion ScipadprojectatSourceForgeURL
    global standaloneScipad Scilab5 Scilab4 Scicoslab
    global moduledir
    if {$standaloneScipad} {
        set envir [mc "in standalone mode."]
    } elseif {$Scilab5} {
        set envir [mc "in a Scilab 5 environment."]
    } elseif {$Scicoslab} {
        set envir [mc "in a Scicoslab environment."]
    } elseif {$Scilab4} {
        set envir [mc "in a Scilab 4 environment."]
    } else {
        # should never happen
        set envir [mc "in an unknown environment."]
    }
    set mes [concat $applicationname $ScipadVersion]
    append mes "\n\n"
    append mes [concat [mc "Running on"] "Tcl/Tk [info patchlevel] $envir"]
    append mes "\n\n"
    append mes [concat [mc "Source code:"] $moduledir]
    append mes "\n\n"
    append mes [mc authors_message]
    append mes "\n\n"
    append mes [mc credits_message]
    append mes "\n\n"
    append mes [mc credits_translations_message]
    append mes "\n\n"
    append mes [mc Scipad_is_released_under_GPL]
    append mes "\n\n"
    append mes [concat [mc "Please visit the Scipad project page at"] $ScipadprojectatSourceForgeURL]
    tk_messageBox -title [mc "About"] -type ok -message $mes
}

proc helpme {} {
# help
    if {[isscilabbusy 0]} {return}
    ScilabEval_lt "help scipad"
}

proc helpword {} {
    if {[isscilabbusy 0]} {return}
    set textareacur [gettextareacur]
    # if there is a block selection, collapse it to its first range
    set selindices [gettaselind $textareacur single]
    if {$selindices == {}} {
        # if there is no selection in the current textarea,
        # select the word at the cursor position
        set i1 [$textareacur index insert]
        $textareacur tag add sel [$textareacur index "$i1 wordstart"] \
                                 [$textareacur index "$i1 wordend"]
        set selindices [gettaselind $textareacur single]
    }
    set cursel [string trim [gettatextstring $textareacur $selindices]]
    # get only the first word of the selection (or a symbol)
    regexp {(\A\w*\M|\A\W)} $cursel curterm
    if {[info exists curterm]} {
        set curterm [string trim $curterm]
        set curterm [duplicatechars $curterm "\""]
        set curterm [duplicatechars $curterm "'"]
        if {$curterm!=""} {
            ScilabEval_lt "help \"$curterm\""
        }
    }
}

proc textbox {textfile {wtitle ""}} {
# a generic scrollable messagewindow, which displays the content of a text file
    global pad menuFont textFont
    global defaultencoding
    if {$wtitle == ""} {set wtitle $textfile}
    set tbox $pad.textbox
    catch {destroy $tbox}
    toplevel $tbox
    wm withdraw $tbox
    setscipadicon $tbox
    wm title $tbox $wtitle
    frame $tbox.f1
    text $tbox.text -font $textFont
    set newnamefile [open $textfile r]
    fconfigure $newnamefile -encoding $defaultencoding
    while {![eof $newnamefile]} {
            $tbox.text insert end [read -nonewline $newnamefile ] 
    }
    close $newnamefile
if {0} {
    set thetext [$tbox.text get 1.0 end]
    regsub -all -- { *\n *([^-\nA-Z=])} $thetext { \1} thetext
    $tbox.text delete 1.0 end
    $tbox.text insert 1.0 $thetext
    $tbox.text configure -wrap word
}
    $tbox.text configure -state disabled -yscrollcommand \
           "managescroll $tbox.sb"
    pack $tbox.text -in $tbox.f1 -side left -expand 1 -fill both
    scrollbar $tbox.sb -command "$tbox.text yview" -takefocus 0
    $tbox.sb set [lindex [$tbox.text yview] 0] [lindex [$tbox.text yview] 1]
    pack $tbox.sb -in $tbox.f1 -side right -expand 0 -fill y \
            -before $tbox.text
    pack $tbox.f1 -expand 1 -fill both
    frame $tbox.f2
    button $tbox.f2.button -text [mc "Close"] \
            -command "destroy $tbox" \
            -font $menuFont
    pack $tbox.f2.button -in $tbox.f2
    pack configure $tbox.f2 -pady 4 -after $tbox.f1 -expand 0 -fill both
    pack $tbox.f2 -in $tbox -side bottom -before $tbox.f1
    focus $tbox.f2.button
    bind $tbox <Up> "$tbox.text yview scroll -1 units"
    bind $tbox <Down> "$tbox.text yview scroll 1 units"
    bind $tbox <Home> "$tbox.text yview moveto 0"
    bind $tbox <End> "$tbox.text yview moveto 1"
    bind $tbox <Prior> "$tbox.text yview scroll -1 pages"
    bind $tbox <Next> "$tbox.text yview scroll 1 pages"
    bind $tbox <Return> "destroy $tbox"
    bind $tbox <KP_Enter> "destroy $tbox"
    bind $tbox <Escape> "destroy $tbox"
    # prevent unwanted Text class bindings from triggering
    bind $tbox.text <Button-3> {break}
    bind $tbox.text <Shift-Button-3> {break}
    bind $tbox.text <Control-Button-3> {break}
    bind $tbox.text <ButtonRelease-2> {break}
    bind $tbox.text <Return> "destroy $tbox;break"
    bind $tbox.text <KP_Enter> "destroy $tbox;break"
    update idletasks
    setwingeom $tbox
    wm resizable $tbox 1 1
    wm deiconify $tbox
}

proc followlink {ta x y} {
# get the url that the mouse cursor is currently hovering
# and invoke the external browser with this url as parameter
    global mouseoverlink words

    # the content of the variable mouseoverlink is a string starting
    # by "mouseover" immediately followed by a text tag name
    set nbmatched [scan $mouseoverlink "mouseover%s" tagname]
    if {$nbmatched <= 0} {
        # should only happen when no link was hovered before,
        # (in this case $mouseoverlink is "" as set in defaults.tcl)
        return
    }

    # get the tagged text, this is the link to follow
    set linkrange [$ta tag prevrange $tagname @$x,$y]
    foreach {sta sto} $linkrange {}
    set linkedtext [$ta get $sta $sto]

    switch -- $mouseoverlink {

        mouseoverurl {
            invokebrowser $linkedtext
        }

        mouseoverlibfun -

        mouseoverscicos {
            opensourcecommand $tagname $linkedtext
        }

        mouseoveruserfun {
            set nameinitial [string range $linkedtext 0 0]
            set candidates $words(scilab.userfun.$nameinitial)
            for {set i 0} {$i<[llength $candidates]} {incr i} {
                if {[lindex [lindex $candidates $i] 0] eq $linkedtext} {
                    # after idle needed to execute first the binding on
                    # <ButtonRelease-1>, which repositions the insert cursor
                    # and would mask the gotoline result otherwise
                    after idle "dogotoline physical 1 function [list [lindex $candidates $i]]"
                    break
                }
            }
        }

        default {
            # should never happen, unless programming error
            return
        }

    }
}

proc invokebrowser {url} {
# launch an internet browser with $url
# this proc was adapted from Cameron Laird's original version
# at  http://wiki.tcl.tk/557

    global pad tcl_platform

    switch $tcl_platform(platform) {
        "windows" {
                   set command "[auto_execok start] {} \"[list $url]\""
                   # Substitute & with ^&
                   # Use case: http://core.tcl.tk/tk/vdiff?from=core-8-5-14&to=core-8-5-15
                   # Otherwise, it will only open http://core.tcl.tk/tk/vdiff?from=core-8-5-14
                   # which will... fail!
                   # Fix: start is an internal command to cmd.exe, and in cmd.exe
                   #      & is a special character that needs to be escaped
                   #      ^ is the escape character to use 
                   regsub -all "&" $command "^&" command
                  }
        "unix"   {
                   foreach browser {firefox mozilla netscape iexplorer opera lynx
                                    rekonq epiphany galeon konqueror amaya
                                    browsex links elinks w3m mosaic} {
                       set executable [auto_execok $browser]
                       if {[string length $executable]} {
                           set command [list $executable $url]
                           break
                       }
                   }
                  }
        "default" {
                  }
    }

    if {[info exists command]} {
        if {[catch {eval exec "$command" &} err]} {
            set tit [mc "View URL"]
            set mes [mc "An error happened when launching your browser."]
            append mes "\n\n" [mc "Command launched:"] "\n    " $command
            append mes "\n\n" [mc "Error message:"] "\n    " $err
            tk_messageBox -message $mes -icon error -title $tit -type ok -parent $pad
        } else {
            # do nothing: everything is OK!
        }
    } else {
        set tit [mc "View URL"]
        set mes [mc "Sorry, no browser found for platform:"]
        append mes " $tcl_platform(os), $tcl_platform(platform)"
        tk_messageBox -message $mes -icon error -title $tit -type ok -parent $pad
    }
}
