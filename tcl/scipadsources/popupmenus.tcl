#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2013 - Francois Vogel
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

proc showpopup_contextual {} {
# popup a contextual menu at the mouse cursor position
# if there is no debug session, the popup menu contains the entries of
# both the exec menu and the edit menu
# otherwise it is the debug menu, unless the mouse is over a selection
# in which case the add watch menu may pop up
 
    global pad mouseoversel snRE

    set numx [winfo pointerx $pad]
    set numy [winfo pointery $pad]

    if {[getdbstate] eq "NoDebug"} {

        tk_popup [concatmenues [list $pad.filemenu.exec $pad.filemenu.edit]] $numx $numy

    } else {

        set ta [gettextareacur]
        # if there is a selection, and if the selected trimmed string matches
        # a regexp (constructed from help names in Scilab) then the selection
        # is probably a valid variable to watch and the quick add watch menu
        # should pop up
        # if the selected trimmed string doesn't match the regexp, then it is
        # proposed for addition in the generic expression area
        # about block selections: they are collapsed to their first range
        # (line) before trying to match them against the regexp
        if {$mouseoversel} {
            set selindices [gettaselind $ta single]
            set trimmedseltext [string trim [gettatextstring $ta $selindices]]
            regexp "\\A$snRE\\Z" $trimmedseltext validwatchvar
            if {[info exists validwatchvar]} {
                showpopupdebugwsel $validwatchvar "watchvariable"
            } else {
                showpopupdebugwsel $trimmedseltext "genericexpression"
            }
        } else {
            tk_popup $pad.filemenu.debug $numx $numy
        }
    }
}

proc showpopupdebugwsel {texttoadd typeofquickadd} {
# ancillary for proc showpopup_contextual
    global pad menuFont
    set numx [winfo pointerx $pad]
    set numy [winfo pointery $pad]
    catch {destroy $pad.popdebugwsel}
    menu $pad.popdebugwsel -tearoff 0 -font $menuFont
    if {$typeofquickadd eq "watchvariable"} {
        set plabel [mc AddWatch $texttoadd]
    } else {
        # $typeofquickadd eq "genericexpression"
        set plabel [mc AddGenExp $texttoadd]
    }
    $pad.popdebugwsel add command -label $plabel\
        -command "quickAddWatch_bp {$texttoadd} $typeofquickadd"
    tk_popup $pad.popdebugwsel $numx $numy
}

proc showpopup_options {} {
# popup the options menu at the mouse cursor position
    global pad
    set numx [winfo pointerx $pad]
    set numy [winfo pointery $pad]
    tk_popup $pad.filemenu.options $numx $numy
}

proc showpopup_navigation {ta x y} {
# popup a menu with
#   open source of...
#   jump to...
#   jump to (open file)...
# if this is a possible action
# $ta is a textarea to work with

    global pad menuFont words

    focustextarea $ta
    $ta mark set insert @$x,$y
    set insertcursorind [$ta index insert]

    set knownwordtype true
    set tagname ""
    if       {[lsearch [$ta tag names $insertcursorind] "libfun" ] != -1} {
        set tagname libfun
    } elseif {[lsearch [$ta tag names $insertcursorind] "scicos" ] != -1} {
        set tagname scicos
    } elseif {[lsearch [$ta tag names $insertcursorind] "userfun"] != -1} {
        set tagname userfun
    } else {
        set knownwordtype false
    }

    set numx [winfo pointerx $pad]
    set numy [winfo pointery $pad]
    catch {destroy $pad.popnav}
    menu $pad.popnav -tearoff 0 -font $menuFont

    if {$knownwordtype} {

        # deal with a userfun, libfun or scicos word

        # note: this code could probably be removed since these tags are now
        #       directly clickable and it duplicates a feature available
        #       though a different triggering mechanism: open libfon/scicos
        #       and jump to userfun is currently triggered by two different
        #       processes (control-shift-Button-3 and control-click, the
        #       latter being much more obvious due to the visual cue (underline
        #       the linked text when the mouse is hovering above it)
        #       let's however keep this perhaps for backward compatibility
        #       reasons (this is documented in help Scipad)
        #       the case "unknown word" below however must be kept since
        #       there is no same feature elsewhere

        set lrange [$ta tag prevrange $tagname "$insertcursorind + 1 c"]
        if {$lrange eq ""} {
            set lrange [$ta tag nextrange $tagname $insertcursorind]
        }
        set curterm [$ta get [lindex $lrange 0] [lindex $lrange 1]]

        if {[info exists curterm]} {
            set curterm [string trim $curterm]
            if {$curterm ne ""} {

                if {$tagname eq "userfun"} {

                    # userfuns can be reached just by a call to gotoline
                    set nameinitial [string range $curterm 0 0]
                    set candidates $words(scilab.$tagname.$nameinitial)
                    for {set i 0} {$i<[llength $candidates]} {incr i} {
                        if {[lindex [lindex $candidates $i] 0] eq $curterm} {
                            set plabel [concat [mc "Jump to"] $curterm ]
                            set sourcecommand \
                                "dogotoline physical 1 function [list [lindex $candidates $i]]"
                            break
                        }
                    }

                } else {

                    # scicos or libfun can be reached by opening their source file
                    set plabel [concat [mc "Open the source of"] $curterm ]
                    set sourcecommand "opensourcecommand $tagname $curterm"

                }

                $pad.popnav add command -label $plabel -command $sourcecommand
           }
        }

    } else {

        # unknown word

        # try to find a file named "word.knownext" in the same directory
        # as the file displayed in $ta, and if there is one propose a menu
        # item to open it

        foreach {tapath taext} [getpathandext $ta] {}

        if {$tapath eq ""} {

            # file is a new file (not yet saved), and is not yet tied to
            # any specific directory - do nothing (i.e: no menu item to add)

        } else {

            # create the list of file extensions to search for
            set allexts [knownextensions]
            set allexts [lappend allexts $taext]
            set allexts [lsort -unique $allexts] ; # to remove duplicates

            # get the word itself, which will be the filename to search for
            # note that this specifically takes into accound $tcl_wordchars
            # and $tcl_nonwordchars
            set leadingpart  [$ta get "$insertcursorind linestart" $insertcursorind]
            set trailingpart [$ta get $insertcursorind "$insertcursorind lineend"  ]
            set wordstart [tcl_wordBreakBefore $leadingpart  end]
            set wordstop  [tcl_wordBreakAfter  $trailingpart 0  ]

            if {$wordstart != -1 && $wordstop != -1} {

                # word boundaries found
                set wordstartind [$ta index "$insertcursorind - [expr {[string length $leadingpart] - $wordstart}] c"]
                set wordstopind  [$ta index "$insertcursorind + $wordstop c"]
                set filename [$ta get $wordstartind $wordstopind]

                # check existence of each possible file in turn,
                # and add a menu item for each found one
                foreach ext $allexts {
                    # only existence of matching files is tested, not readability
                    # (readability is tested later when trying to open the file)
                    set filenameandext "$filename$ext"
                    set fullfilepath [file join $tapath $filenameandext]
                    if {[file exists $fullfilepath]} {
                        $pad.popnav add command -label [concat [mc "Jump to (open file)"] $filenameandext] \
                            -command "openfileifexists [list $fullfilepath]"
                    }
                }

            } else {

                # no word boundaries found, do nothing (i.e: no menu item to add)

            }

        }

    }

    tk_popup $pad.popnav $numx $numy
}

proc opensourcecommand {tagname curterm} {
# ancillary for proc showpopup_navigation
    if {![isscilabbusy 0]} {
        doopenfunsource $tagname $curterm
    }
}

proc showpopup_tiletitle {w} {
# popup a menu with items targeted to dealing with a tile

	global pad menuFont

    set numx [winfo pointerx $pad]
    set numy [winfo pointery $pad]

	set ta [gettafromwidget [winfo parent $w]]

    # focustextarea required in order to close or split the right textarea
    focustextarea $ta

    catch {destroy $pad.poppanetitle}

    menu $pad.poppanetitle -tearoff 0 -font $menuFont
    $pad.poppanetitle add command -label [mc "Close all but this"] \
        -command "closeallbutcurrentfileclosepeers"
    $pad.poppanetitle add separator
    $pad.poppanetitle add command -label [mc "Copy full path and filename"] \
        -command "copyfullfilepathtoclipboard $ta"
    $pad.poppanetitle add separator
    $pad.poppanetitle add command -label [mcra "Sp&lit file"] \
        -command {splitwindow vertical "" file}
    $pad.poppanetitle add command -label [mcra "Spl&it file (side by side)"] \
        -command {splitwindow horizontal "" file}
    tk_popup $pad.poppanetitle $numx $numy
}
