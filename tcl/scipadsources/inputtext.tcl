#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2011 - Francois Vogel
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

proc blinkchars {w sta sto} {
# blink characters in $w between indices $sta and $sto
# $sta is supposed to be before $sto in $w
    $w tag add sel $sta $sto
    $w see $sto
    update idletasks
    after 300
    $w tag remove sel $sta $sto
    $w see insert
}

proc getindofsymbol2 {w indofsymbol1 dir findbs bs {ignorecommentsandstrings false}} {
# find index in $w of symbol character $bs corresponding to the symbol at
# index $indofsymbol1 in $w
# the search is done in direction $dir, which is "-backwards" or "-forwards"
# $findbs is a regular expression describing the symbols to match and is used
# to detect nested constructs
# if no matching symbol is found then return an empty string
# if the optional $ignorecommentsandstrings is true, then only the matching symbols
# outside of comments and strings are considered (default: all matches are considered)
    global listoffile

    switch -- $listoffile("$w",language) {
        scilab   {set cmttag rem2; set strtag textquoted}
        modelica {set cmttag Modelica_comment; set strtag Modelica_string}
        default  {set cmttag rem2; set strtag textquoted}
    }

    set p [$w index $indofsymbol1]
    set d 1

    while {$d > 0} {

        if {$dir == "-backwards"} {
            set p [$w search $dir -regexp $findbs $p 1.0]
        } else {
            set p [$w search $dir -regexp $findbs "$p+1c" end]
        }

        if {$p eq ""} {
            # no corresponding symbol found, end of search algorithm
            set d -1

        } else {
            if {"[$w get $p $p+1c]" eq "$bs"} {
                # the search matched symbol2, e.g. closure ) if symbol1 is opening (
                if {$ignorecommentsandstrings} {
                    set tagshere [$w tag names $p]
                    if {[lsearch $tagshere $cmttag] != -1 || [lsearch $tagshere $strtag] != -1} {
                        # ignore this match, it's in a string or in a comment
                        # no change to do to $d
                    } else {
                        # match is not in a string nor in a comment
                        incr d -1
                    }
                } else {
                    incr d -1
                }
            } else {
                # the search matched symbol1, e.g. opening ( if symbol1 is also opening (
                if {$ignorecommentsandstrings} {
                    set tagshere [$w tag names $p]
                    if {[lsearch $tagshere $cmttag] != -1 || [lsearch $tagshere $strtag] != -1} {
                        # ignore this match, it's in a string or in a comment
                        # no change to do to $d
                    } else {
                        # match is not in a string nor in a comment
                        incr d 1
                    }
                } else {
                    incr d 1
                }
            }
        }

    }

    if {$d == 0} {
        return $p
    } else {
        return ""
    }
}

proc getfindbsregexpcorrbscharandsearchdir {brace} {
    switch $brace {
        \{ { set findbs {[{}]}; set bs "\}"; set dir {-forwards}  }
        \} { set findbs {[{}]}; set bs "\{"; set dir {-backwards} }
        \[ { set findbs {[][]}; set bs "\]"; set dir {-forwards}  }
        \] { set findbs {[][]}; set bs "\["; set dir {-backwards} }
        \( { set findbs {[()]}; set bs "\)"; set dir {-forwards}  }
        \) { set findbs {[()]}; set bs "\("; set dir {-backwards} }
    }
    return [list $findbs $bs $dir]
}

proc blinkbrace {w pos brace} {
# blink an entity delimited by matching brackets, braces or parenthesis
# $pos is the index position just *after* the entity for which a matching
# character will be blinked

    # in very special cases, $brace contains two characters
    # this happens for instance when typing ^( : both characters appear
    # at the same time in $brace, and this would produce a Tcl error
    # "couldn't compile regexp" in blinkbrace because ^ has a meaning as a
    # regexp - this is fixed by retaining only the last character of $brace
    set brace [string range $brace end end]

    # do not consider anything else than a parenthesis, a bracket or a brace
    # this was needed to work around bug 1542 http://bugzilla.scilab.org/show_bug.cgi?id=1542
    # note: originally this was   if {[regexp \\$brace "\{\}\[\]\(\)"] == 0} {...}
    #       but this suffered from interpretation of escapes, e.g. what if $brace is the letter p?
    #       we would get regexp \p "\{\}\[\]\(\)", and since \p is not a valid escape sequence
    #       for a regexp, this triggers "couldn't compile regexp" Tcl error
    if {[string first $brace "\{\}\[\]\(\)"] == -1} {
        return
    }

    foreach {findbs bs dir} [getfindbsregexpcorrbscharandsearchdir $brace] {}

    set indofcorrbs [getindofsymbol2 $w "$pos-1c" $dir $findbs $bs]

    if {$indofcorrbs ne ""} {
        if {$dir == "-backwards"} {
            blinkchars $w $indofcorrbs $pos
        } else {
            blinkchars $w $pos-1c $indofcorrbs+1c
        }
    } else {
        showinfo [concat [mc "No corresponding <"] $bs [mc "> found!"] ]
    }
}

proc blinkquote {w pos char} {
# blink quotes that define a character string
# <TODO>: scilab scheme: - take care of quotes inside comments
#                        - blink single quotes (beware of the transpose case)
#         support modelica scheme
    global listoffile

    if {$listoffile("$w",language) ne "scilab"} {
        return
    }

    if {[string first $char "\""] == -1} {
        return
    }

    set sta [getrealstartofcontline $w $pos]
    set sto [getrealendofcontline   $w $pos]
    set i [$w index "$pos - 1 c"]

    set pat {"[^"]*(?:""[^"]*)*"}

    proc tryright {w pat i pos sto} {
    # try to find and blink a closing quote (i.e. at the right of the
    # quote that was just typed)
        set allind1 [regexp -all -indices -inline -- $pat [$w get $i $sto]]
        set allind2 [regexp -all -indices -inline -- $pat [$w get $pos $sto]]

        if {[llength $allind1] == 0} {
            # no closing quote found
            return
        } else {
            # a closing quote has been found after the
            # quote that was just typed
            set p [$w index "$i + [lindex [lindex $allind1 0] 1] c + 1 c"]
            blinkchars $w $i $p
        }
    }

    # try first to find an opening quote matching the quote
    # that was just typed (i.e. try towards the left)
    set allind1 [regexp -all -indices -inline -- $pat [$w get $sta $pos]]
    set allind2 [regexp -all -indices -inline -- $pat [$w get $sta $i]]

    if {[llength $allind1] == 0} {
        # the quote just typed is an opening quote
        # search for the closing quote
        tryright $w $pat $i $pos $sto
        return
    }

    if {[llength $allind1] != [llength $allind2]} {
        # the quote just typed closes a string
        # that starts before this quote
        set p [$w index "$sta + [lindex [lindex $allind1 end] 0] c"]
        blinkchars $w $p $pos
    } else {
        foreach {i1 j1} [lindex $allind1 end] {}
        foreach {i2 j2} [lindex $allind2 end] {}
        if {$i1 == $i2} {
            if {$j1 == $j2} {
                # the quote just typed is an opening quote
                # search for the closing quote
                tryright $w $pat $i $pos $sto
            } else {
                # the quote just typed closes a string
                # that contains a quote, e.g. "abc""def"
                set p [$w index "$sta + $i1 c"]
                blinkchars $w $p $pos
            }
        } else {
            # shouldn't happen
            tk_messageBox -message "Impossible case #1 in blinkquote"
        }
    }
}

proc insblinkbrace {w brace} {
# this proc gets called when the user types a brace, one of ()[]{}
    if {[IsBufferEditable] == "No"} {return}
    puttext $w $brace "replaceallowed"
    blinkbrace $w insert $brace 
}

proc insblinkquote {w quote} {
    if {[IsBufferEditable] == "No"} {return}
    puttext $w $quote "replaceallowed"
    blinkquote $w insert $quote 
}

proc allindentkeywords {w} {
# return the list of keywords that, on hitting enter, will create
# a forward indentation on next line, and the list of keywords
# that will create a backward indentation (UnIndent) on current line
# the return value of this proc is a list containing the two lists,
#     first  the list of keywords for forward  indentation
#     second the list of keywords for backward indentation
# the list of indent keywords is retrieved based on the language scheme
# of the textarea $w passed as an argument
    global listoffile
    switch -- $listoffile("$w",language) {
        scilab {
            set fwindentkwlist [list \
                    for while \
                    if else elseif \
                    select case \
                    function \
                    try \
                    ]
            set bwindentkwlist [list \
                    else elseif \
                    end \
                    endfunction \
                    catch \
                    ]
        }
        modelica {
            set fwindentkwlist [list \
                    encapsulated partial \
                    class model record block expandable connector package function operator \
                    protected public \
                    algorithm equation external annotation \
                    if when \
                    for while \
                    ]
            set bwindentkwlist [list \
                    protected public \
                    algorithm equation external annotation \
                    else elseif elsewhen \
                    end \
                    ]
        }
        xml {
            set fwindentkwlist [list ]
            set bwindentkwlist [list ]
        }
        default {
            set fwindentkwlist [list ]
            set bwindentkwlist [list ]
        }
    }
    return [list $fwindentkwlist $bwindentkwlist]
}

proc insertnewline {w} {
    global buffermodifiedsincelastsearch
    global tabinserts indentspaces usekeywordindent

    if {[IsBufferEditable] == "No"} {return}

    # get the list of keywords that will create a forward indentation
    # (Indent) on next line, and the list of keywords that will create
    # a backward indentation (UnIndent) on current line
    foreach {fwindentkwlist bwindentkwlist} [allindentkeywords $w] {}

    # get the leading indentation characters on the line where
    # the cursor is at the time enter is pressed
    set n {}
    $w mark set p1 {insert linestart}
    set c [$w get p1 {p1+1c}]
    while {$c == { } || $c == "\t"} {
        $w mark set p1 {p1+1c}
        set c [$w get p1 {p1+1c}]
    }
    set n [$w get {insert linestart} p1]

    if {$usekeywordindent} {
        # get the first word of the line where enter has been pressed
        set endind [$w index {p1 wordend}]
        if {[$w compare $endind > insert]} {
            set endind insert
        }
        set kw [$w get p1 $endind]
        $w mark unset p1
    }

    # so only one undo is required to undo indentation
    set sepflag [startatomicedit $w]

    # insert a CR char and insert the same indentation as the previous line
    # note that if there is a block selection, puttext will first collapse
    # it to its first range (line)
    # note further that the insert mode must be forced, otherwise there is no
    # means to create a new line while in replace mode
    puttext $w "\n$n" "forceinsert"

    # remove possible indentation chars located after the insertion above
    set c [$w get insert "insert+1c"]
    while {$c == " " || $c == "\t"} {
        $w delete insert "insert+1c"
        set c [$w get insert "insert+1c"]
    }

    if {$usekeywordindent} {

        # if the starting keyword should destroy one indentation chunk
        if {[lsearch -exact $bwindentkwlist $kw] != -1} {
            # remove one indentation from the line on which the cursor was
            # when the user hit enter
            $w mark set p1 insert
            $w mark set insert "insert - 1 l linestart"
            UnIndentSel
            $w tag remove sel 1.0 end
            $w mark set insert p1
            $w mark unset p1
            # remove one indentation from the current line also
            if {$tabinserts == "spaces"} {
                set maxbackspace $indentspaces
            } else {
                set maxbackspace 1
            }
            for {set i 0} {$i<$maxbackspace} {incr i} {
                # don't cross the start of line boundary while erasing chars
                if {[$w compare insert > "insert linestart"]} {
                    backspacetext
                }
            }
        }

        # if the starting keyword should create one indentation chunk
        if {[lsearch -exact $fwindentkwlist $kw] != -1} {
            # if the line after insertion of \n$n above is not a blank line,
            # i.e. if the user did hit enter in the middle of a line, then
            # indent, otherwise insert a tab char (or indentation spaces)
            if {[string trim [selectline]] != ""} {
                IndentSel
            } else {
                # remove selection is useful when line contains only blanks
                $w tag remove sel 1.0 end
                inserttab $w
            }
            $w tag remove sel 1.0 end
       }
    }

    endatomicedit $w $sepflag

    set buffermodifiedsincelastsearch true
}

proc inserttab {w} {
# if there is a selection in $w, and if this selection starts at column 0,
# then indent this selection
# otherwise insert a "tab", i.e. either (depending on the option selected)
# a real tab character or a sufficient number of spaces to go to the next
# tab stop
# note: block selection is supported: if there is a block selection, the
# behaviour is always to indent

    global tabsizeinchars tabinserts buffermodifiedsincelastsearch

    if {[IsBufferEditable] == "No"} {return}

    set taselind [gettaselind $w any]

    if {$taselind != {}} {
        # there is a selection, put 1st column of selection in col
        scan [lindex $taselind 0] "%d.%d" line col
    } else {
        # there is no selection
        set col -1
    }

    if {$col == 0 || [llength $taselind] > 2} {
        # there is a selection starting at the 1st column, or the
        # selection is a block selection
        IndentSel
    } else {
        # there is no selection
        if {$tabinserts eq "spaces"} {
            # insert spaces up to the next tab stop
            set curpos [$w index insert]
            scan $curpos "%d.%d" curline curcol
            set nexttabstop [expr {($curcol / $tabsizeinchars + 1) * $tabsizeinchars}]
            set nbtoinsert [expr {$nexttabstop - $curcol}]
            set toinsert [string repeat " " $nbtoinsert]
            puttext $w $toinsert "replaceallowed"
        } else {
            # insert a tab character
            puttext $w "\x9" "replaceallowed"
        }
    }

    set buffermodifiedsincelastsearch true
}

proc transposechars {} {
# transpose the characters on either side of the insertion cursor in the
# current textarea, unless the cursor is at the end of the line
# in this case transpose the two characters to the left of the cursor
# in any case, the cursor ends up to the right of the transposed characters
# (this is a reimplementation of the native procedure ::tk::TextTranspose
# from which this code is inspired and augmented)
# the selection, if any, is cleared

    set ta [gettextareacur]

    set pos insert

    # move the insert cursor just after the two chars to transpose
    if {[$ta compare $pos != "$pos lineend"]} {
        set pos [$ta index "$pos + 1 char"]
    }

    # abort if too close from the beginning of the textarea
    if {[$ta compare "$pos - 1 char" == 1.0]} {
        return
    }

    # abort if too close from the beginning of the line, i.e.
    # don't transpose first character of a line with the last
    # character of the previous line (my personal taste!)
    if {[$ta compare "$pos - 2 char linestart" != "$pos linestart"]} {
        return
    }

    set new [$ta get "$pos - 1 char"][$ta get  "$pos - 2 char"]

    $ta tag remove sel 1.0 end
    $ta tag add sel "$pos - 2 char" $pos
    puttext $ta $new "forceinsert"

}

proc puttext {w text insertorreplace} {
# input text $text in textarea $w
# note: existing block selection, if any, gets collapsed in the process
# and then deleted resulting in the apparent (desired) result that the text
# passed to this proc replaced the first line (range) of the block selection
# only
# the parameter $insertorreplace allows to:
#   - ignore the replace mode if set to "forceinsert"
#   - let replace happen (when in this mode) if set to "replaceallowed"

    global buffermodifiedsincelastsearch
    global Tk85
    global textinsertmode

    if {[IsBufferEditable] == "No"} {return}

    # stop/restorecursorblink is primarily to fix bug 2239
    # but:
    # We want that when typing in a widget the line numbers in its margin be
    # updated automatically, i.e. we want that proc managescroll (which calls
    # updatelinenumbersmargin) be called automatically by Tk for each peer
    # To achieve this, we need to perform a configure action with any option
    # on all the peer text widgets, i.e. we must use $ta configure -anyoption xxx
    # This is quite easily done by stopping and restoring cursor blinking, that
    # does precisely $ta configure -insertofftime xx
    # Note that we must in principle do it only for peers since typing in a widget
    # cannot change the content of any other non-peer text widget, but it's easier
    # to do it for all textareas, and it's also needed to fix bug 2239
    stopcursorblink

    # so only one undo is required to undo text replacement
    set sepflag [startatomicedit $w]

    # check whether a selection exists, collapse any block selection
    # and delete it
    if {[gettaselind $w single] != ""} {
        $w delete sel.first sel.last
        set aselectionwasdeleted true
    } else {
        set aselectionwasdeleted false
    }

    set i1 [$w index insert]

    if {$textinsertmode || $insertorreplace!="replaceallowed"} {

        $w insert insert $text

    } else {

        # if there was initially a selection, then no further delete should occur
        if {$aselectionwasdeleted} {
            set replacelength 0
        } else {
            set replacelength [string length $text]
        }
        # don't span the \n at the end of the line
        if {[$w compare "insert + $replacelength c" > "insert lineend"]} {
            set replaceendind "insert lineend"
        } else {
            set replaceendind "insert + $replacelength c"
        }
        # do the replace
        if {$Tk85} {
            $w replace insert $replaceendind $text
        } else {
            # emulate the .text replace command of Tk8.5 with 8.4 commands only
            $w delete insert $replaceendind
            $w insert insert $text
        }

    }

    # properly set anchor in textarea to follow the insert cursor
    # otherwise next Shift-Button-1 click creates a selection from
    # the previous anchor point (last Button-1 click usually)
    setTextAnchor_scipad $w

    set i2 [$w index insert]

    set uplimit [$w index "$i1 linestart"]
    set dnlimit [$w index "$i2 lineend"]
    set uplimit_cl [getstartofcolorization $w $i1]
    set dnlimit_cl [getendofcolorization $w $i2]
    colorize $w $uplimit $dnlimit $uplimit_cl $dnlimit_cl
    backgroundcolorizetasks
    tagcontlines $w
    setunsavedmodifiedline $w $uplimit $dnlimit

    reshape_bp

    $w see insert

    endatomicedit $w $sepflag

    set buffermodifiedsincelastsearch true

    restorecursorblink ; # see comments above
}

proc printtime {} {
# procedure to set the time
# change %R to %I:%M for 12 hour time display
# Note: this proc is never called
    global listoffile buffermodifiedsincelastsearch
    if {[IsBufferEditable] == "No"} {return}
# <TODO>: use puttext here instead of manually inserting text
#         it will also take care of all colorization and undo/redo
#         aspects, that are anyway not dealt with here
    set sepflag [startatomicedit [gettextareacur]]
    [gettextareacur] tag remove sel 1.0 end
    [gettextareacur] insert insert [clock format [clock seconds] \
                    -format "%R %p %D"]
    endatomicedit $ta [gettextareacur]
    set buffermodifiedsincelastsearch true
}

proc IsBufferEditable {} {
    if {[getdbstate]=="DebugInProgress"} {
        showinfo [mc "Code editing is not allowed during debug!"]
        bell
        return "No"
    } else {
        return "Yes"
    }
}

proc toggleinsertreplacemode {} {
# switch insert mode to replace mode in textareas, or vice versa
# the visual appearance of the text cursor is also changed
    global Tk85 textinsertmode
    global textinsertcursorwidth textreplacecursorwidth
    global textinsertcursorborderwidth textreplacecursorborderwidth
    global listoftextarea

    set textinsertmode [expr !$textinsertmode]

    if {$textinsertmode} {
        # cursor is the insert cursor (I shaped)
        # note: peers do not share a common cursor --> no filteroutpeers here!
        if {$Tk85} {
            foreach w $listoftextarea {
                $w configure -blockcursor false
            }
        } else {
            foreach w $listoftextarea {
                $w configure -insertwidth $textinsertcursorwidth \
                             -insertborderwidth $textinsertcursorborderwidth
            }
        }
    } else {
        # cursor is the replace cursor (block shape)
        # note: peers do not share a common cursor --> no filteroutpeers here!
        if {$Tk85} {
            foreach w $listoftextarea {
                $w configure -blockcursor true
            }
        } else {
            foreach w $listoftextarea {
                $w configure -insertwidth $textreplacecursorwidth \
                             -insertborderwidth $textreplacecursorborderwidth
            }
        }
    }
}
