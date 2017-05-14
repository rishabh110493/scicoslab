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

proc whichfun {indexin textarea} {
# This proc checks whether the text position $indexin provided in buffer $textarea
# is in a function or not.
# If no  : return an empty list
# If yes : return a list with the following data:
#       $funname   : function name
#       $lineinfun : logical line number of $indexin in function $funname
#                    (this is always the logical line number taking the continued
#                    lines into account)
#       $funline   : definition line of the function, e.g. [a,b]=foo(c,d)
#       $precfun   : index where $funname definition starts (position of the f
#                    of the word "function")
#       $contlines : number of continued lines between $precfun and $indexin
#       $funnestlevel : nesting level of $funname (always >= 1 - in level zero
#                       code, whichfun returns the empty list)
    global listoffile
    global funlineREpat1 funlineREpat2 scilabnameREpat

    # return {} if the language is anything but scilab
    if {$listoffile("$textarea",language) ne "scilab"} {return {}}

    # return {} if the colorization of buffer is off
    if {!$listoffile("$textarea",colorize)} {return {}}

    set indexin [$textarea index $indexin]
    scan $indexin "%d.%d" ypos xpos

    set lfunpos [list]
    set curpos 1.0
    set amatch "firstloop"
    while {$amatch != ""} {
        # search for the next "function" or "endfunction" which is not in a
        # comment nor in a string
        set amatch [$textarea search -exact -regexp "\\m(end)?function\\M" $curpos $indexin]
        if {$amatch!=""} {
            while {[lsearch [$textarea tag names $amatch] "textquoted"] !=-1 || \
                   [lsearch [$textarea tag names $amatch] "rem2"      ] !=-1} {
                set amatch [$textarea search -exact -regexp "\\m(end)?function\\M" "$amatch+8c" $indexin]
                if {$amatch==""} break
            }
        }
        if {$amatch!=""} {
            if {[$textarea get $amatch] == "e"} {
                # "endfunction" found
                if {![$textarea compare "$indexin-11c" < $amatch]} {
                    # the 'if' above is to include the "endfunction" word
                    # into the core of the function
                    set lfunpos [lreplace $lfunpos end end]
                }
            } else {
                # "function" found
                lappend lfunpos $amatch
            }
            set curpos "$amatch+1c"
        }
    }

    set insidefun 1
    if {$lfunpos == [list]} {
        # endfunction was found above, therefore we're not in a function
        set insidefun 0
    } else {
        # function was found above, therefore we are in a function
        # (well, at least a priori - see below)
        set precfun [lindex $lfunpos end]
        # get the full function definition line, including possible
        # continued lines and comments
        set pat "$funlineREpat1$scilabnameREpat$funlineREpat2"
        if {![regexp -- $pat [$textarea get $precfun end] funline]} {
            # special case: the regexp didn't match, which means that the
            # function definition line contains only the word "function",
            # with no function name (unterminated edit for example)
            set insidefun 0
        } else {
            # remove the leading keyword function (8 characters)
            set funline [string range $funline 8 end]
            # remove continued lines tags and comments
            set funline [trimcontandcomments $funline]
            # find function name
            set funname [extractfunnamefromfunline $funline]
            # funname=="" might happen if regexp $pat does not match while function
            # detection above did find the word "function" - really? such a case
            # should have been trapped above by testing [info exists funline], no?
            # anyway, this doesn't harm, so:
            if {$funname==""} {set insidefun 0}
        }
    }

    if {$insidefun == 0} {
        return {}
    } else {
        # check how many continued (.. or unmatched bracket or brace in a single
        # physical line) lines between $indexin and $precfun, and derive the
        # current logical line within the function definition
        set contlines [countcontlines $textarea $precfun $indexin]
        scan $precfun "%d." beginfunline 
        set lineinfun [expr {$ypos - $beginfunline - $contlines + 1}]

        # get the nesting level of current function
        set funnestlevel [llength $lfunpos]

#        tk_messageBox -message [concat \
#                               [mc "Being at line"] $ypos \
#                               [mc ", function"] $funname \
#                               [mc "begins at"] $precfun \
#                               [mc ", and there are"] $contlines \
#                               [mc "continued lines, i.e. we are at line"] $lineinfun \
#                               [mc "of"] $funname "\n$funline"]

        return [list $funname $lineinfun $funline $precfun $contlines $funnestlevel] 
    }
}

proc getendfunctionpos {ta precfun {exittypes "only_endfunction"}} {
# look for endfunction corresponding to position $precfun in $ta (beginning
# of function definition)
# if $exittypes == "only_endfunction":
#    only the position of the endfunction keyword is returned
#    the position returned is the index in $ta of the first n of the word
#    endfunction corresponding to the function definition starting at $precfun
#    if no endfunction corresponding to $precfun is found, then -1 is returned
# otherwise:
#    the proc returns a list of indices, each of them corresponding to an
#    exit point (a return point) of the function starting at $precfun
#    keywords considered as exit points are "return", "resume" and
#    "endfunction". The position returned is the position of the second
#    character of each of these keywords
#    if no endfunction corresponding to $precfun is found, then -1 is returned
#    even if there were return or resume before in the text
    if {$exittypes == "only_endfunction"} {
        set searchpat {\m(end)?function\M}
    } else {
        set searchpat {\m(((end)?function)|(return)|(resume))\M}
    }
    set lfunpos [list $precfun]
    set repos [list ]
    set amatch [$ta search -exact -regexp "\\mfunction\\M" $precfun end]
    set curpos [$ta index "$amatch + 1c"]
    set amatch "firstloop"
    while {[llength $lfunpos] != 0} {
        # search for the next "function" or "endfunction" which is not in a
        # comment nor in a string
        set amatch [$ta search -exact -regexp $searchpat $curpos end]
        if {$amatch != ""} {
            while {[lsearch [$ta tag names $amatch] "textquoted"] !=-1 || \
                   [lsearch [$ta tag names $amatch] "rem2"      ] !=-1} {
                set amatch [$ta search -exact -regexp $searchpat "$amatch+6c" end]
                if {$amatch==""} break
            }
        }
        if {$amatch != ""} {
            if {[$ta get $amatch] == "e"} {
                # "endfunction" found
                if {![$ta compare "end-11c" < $amatch]} {
                    # the 'if' above is to include the "endfunction" word
                    # into the core of the function
                    set lfunpos [lreplace $lfunpos end end]
                }
            } elseif {[$ta get $amatch] == "f"} {
                # "function" found
                lappend lfunpos $amatch
            } else {
                # "return" or "resume" found
                # be clever, and don't include what is in a nested function
                # of the function starting at $precfun (those positions are
                # not return points of function starting at $precfun)
                if {[llength $lfunpos] == 1} {
                    lappend repos [$ta index "$amatch + 1c"]
                }
            }
            set curpos [$ta index "$amatch + 1c"]
        } else {
            set curpos -1
            break
        }
    }
    if {$exittypes == "only_endfunction"} {
        return $curpos
    } else {
        if {$curpos != "-1"} {
            lappend repos $curpos
            return $repos
        } else {
            return $curpos
        }
    }
}

proc getallfunctionsareasintextarea {ta} {
# get all functions defined in the given textarea (only if scheme is scilab)
# and return a flat list with the following elements for each function found:
#    $funname   : function name
#    $precfun   : physical line number where $funname is defined in $ta
#    $endfunc   : physical line number where $funname end in $ta (line number
#                 of the endfunction)
# If the buffer does not contain any functions, [list "" 0 0] is returned
# Warning: $endfunc actually contains the index in $ta where the first n from
#          "endfunction" is found - this is different from $precfun, that always
#          is xxxx.0, i.e. the first position in line xxxx
# Note that the order of the functions returned is the order of their
# definition in the buffer, i.e. the order of the function definition lines
# when reading the buffer from its start to its end (nested functions are not
# special in any respect).

    # check about the language scheme is made in proc getallfunsintextarea
    set allfuns [lindex [getallfunsintextarea $ta] 1]

    if {[lindex $allfuns 0] eq "0NoFunInBuf"} {
        return [list "" 0 0]
    }

    set allfunctionsareas [list ]

    foreach {funname funline precfun} $allfuns {
        set endfunc [getendfunctionpos $ta $precfun "only_endfunction"]
        if {$endfunc != -1} {
            lappend allfunctionsareas $funname $precfun $endfunc
        } else {
            # unterminated function: ignore it
        }
    }

    return $allfunctionsareas
}

proc getfunandlogicallineandnestlevelatpos {ta allfunctionsareas pos} {
# return the function name, logical line number in $funname and nesting level
# at position $pos:  { $funname $lineinfun $nestinglevel }
#   $funname  : name of the function
#   $lineinfun: line number in that function - this is the logical line number
#               if $linenumberstype eq "logical", or the logical line number
#               while ignoring continued lines (i.e. continued lines count
#               as normal lines) if if $linenumberstype eq "logical_ignorecontlines"
#   $nestinglevel:
#     if $pos is a level zero position, i.e. if it is out of any function, then return zero
#     if $pos is in a first level function, return 1
#     if $pos is a first level nested function in a first level function, return 2
#     and so on...

    global linenumberstype

    set pos [$ta index $pos]

    set funname ""
    set lineinfun 0
    set nestinglevel 0

    # this proc may be called when no function is in the buffer, i.e.
    # $allfunctionsareas is empty (actually [list {} 0 0]), in this case
    # the comparisons such as [$ta compare $pos >= $precfun] will not work
    # and this case needs to be trapped
    if {[lindex $allfunctionsareas 0] eq ""} {
        return [list $funname $lineinfun $nestinglevel]
    }

    # this algorithm works for nested functions because $allfunctionsareas is
    # ordered: the order is the order of the functions definition in the buffer,
    # including nested functions. The last time both inner ifs below are true is
    # the most nested function position at $pos, which is precisely what is wanted
    foreach {fun precfun endfunc} $allfunctionsareas {
        if {[$ta compare $pos >= $precfun]} {
            if {[$ta compare $pos <= $endfunc]} {
                set funname $fun
                if {$linenumberstype eq "logical"} {
                    set contlines [countcontlines $ta $precfun $pos]
                } else {
                    # $linenumberstype eq "logical_ignorecontlines"
                    set contlines 0
                }
                scan $precfun "%d." beginfunline 
                scan $pos "%d." ypos
                set lineinfun [expr {$ypos - $beginfunline - $contlines + 1}]
                incr nestinglevel
            }
        }
    }

    return [list $funname $lineinfun $nestinglevel]
}

proc tagcontlinesinallbuffers {} {
    global listoftextarea
    foreach w [filteroutpeers $listoftextarea] {
        tagcontlines $w
    }
}

proc tagcontlines {w} {
# detect and tag continued lines in the entire textarea $w
# the whole line must be tagged, from the first character until and including
# the \n at the end so that proc getstartofcontline and getendofcontline work
# as expected
# this proc also takes care of the visual appearance of continued lines
#
# notes about performance:
#   see comments in proc tagModelicaannotations

    global showContinuedLines listoffile
    global bgcolors
    foreach c1 $bgcolors {global $c1}
    global dotcontlineRE bracketscontlineRE bracescontlineRE

    # don't tag anything if the language is not scilab
    if {$listoffile("$w",language) ne "scilab"} {
        $w tag remove contline 1.0 end
        return
    }

    set contlineRE "$bracketscontlineRE|$bracescontlineRE|$dotcontlineRE"

    $w tag remove contline 1.0 end
    set ind "1.0"
    set previ 0
    set cont [regexp -all -inline -line -indices -- $contlineRE [$w get "1.0" end]]
    foreach fullmatch $cont {
        foreach {i j} $fullmatch {}
        # what really cuts down performance is to do [$w index "1.0 + $i c"]
        # many times with $i being large (>100000, which is fairly common
        # for say 15000 lines buffers), thus avoid to do it at all and use
        # position differences [expr {$j - $i}] instead
        # of course, bracing expr provides a good amount of performance too
        # For a 15000 lines test buffer performance gain factor is better
        # than 20:1, depending on the buffer content
        set mi [$w index "$ind + [expr {$i - $previ}] c"]
        set mj [$w index "$mi + [expr {$j - $i}] c"]
        $w tag add contline "$mi linestart" "$mj lineend + 1 c"
        set ind $mi
        set previ $i
    }
    if {$showContinuedLines} {
        $w tag configure contline -background $CONTLINECOLOR
    } else {
        $w tag configure contline -background {}
    }
    $w tag lower contline
}

proc createnestregexp {nestlevel opdel cldel} {
# Create a regular expression able to match $nestlevel levels of nested
# items enclosed in balanced $opdel (open delimiter) and $cldel (close
# delimiter)
# Any level of nesting is achievable through $nestlevel (but not an
# arbitrary level), but performance has to be considered
# Note: the regexp returned uses only non reporting parenthesis, which is
# required to properly match continued lines (proc tagcontlines), but also
# to avoid a huge performance impact if sub-matches would be reported
# This proc allows to match for instance (brackets are the delimiters, $nestlevel is > 2):
# [ you [simply [ can't] match [arbitrarily nested] constructs [with regular expressions]]]

    set qtext {(?:(?:["'][^"']*["'])*)}
    set op "\\$opdel"
    set nodel "(?:\[^\\$opdel\\$cldel\"'\]*|$qtext)"
    set cl "\\$cldel"

    set RE {}
    append RE $op $nodel

    for {set i 2} {$i <= $nestlevel} {incr i} {
        append RE {(?:} {(?:} $op $nodel
    }

    for {set i 2} {$i <= $nestlevel} {incr i} {
        append RE $cl {)*} $nodel {)+}
    }

    append RE $cl

    return $RE
}

proc countcontlines {w {indstart "1.0"} {indstop "insert"}} {
# Count the continued lines in textarea $w
# Counting is done between the line containing $indstart (included) down to
# $indstop (included)
# continued lines are supposed to have been tagged previously
# warning: the result of countcontlines must not be used for converting
#          between logical and physical line numbers in functions because
#          this proc just counts tags and does not take care of nested
#          function definitions
    set taggedcl [$w tag ranges contline]
    set contlines 0
    set indstart [$w index "$indstart linestart"]
    set indstop  [$w index "$indstop  lineend  "]
    foreach {i1 i2} $taggedcl {
        if {[$w compare $i1 > $indstop]} {
            break
        }
        if {[$w compare $i1 >= $indstart]} {
            # include the last line (untagged) of the continued line
            set i2 [$w index "$i2 lineend"]
            if {[$w compare $i2 > $indstop]} {
                set i2 $indstop
            }
            incr contlines [regexp -all -- {\n} [$w get $i1 $i2]]
        } else {
            # counting countined lines in an area starting after the start
            # of the continued line
            if {[$w compare $i2 > $indstop]} {
                # the end of the tagged continued line is after the position
                # where counting must stop
                incr contlines [regexp -all -- {\n} [$w get $indstart $indstop]]
            } else {
                # the end of the tagged continued line is before the position
                # where counting must stop
                set i2 [$w index "$i2 lineend"]
                if {[$w compare $i2 > $indstop]} {
                    set i2 $indstop
                }
                incr contlines [regexp -all -- {\n} [$w get $indstart $i2]]
            }
        }
    }
    return $contlines
}

proc iscontinuedline {textarea ind} {
# return true if line containing index $ind is a continued line
# return false otherwise
# note that this proc checks whether the line is tagged as a continued
# line or not, i.e. the last physical line defining a continued line
# has [iscontinuedline] to false - this is what is wanted!
    if {[lsearch [$textarea tag names $ind] contline] != -1} {
        return true
    } else {
        return false
    }
}

proc getstartofcontline {textarea ind} {
# if line at $ind is a continued line
#    return index linestart of the continued line containing $ind
# otherwise
#    return "$ind linestart"
    if {[iscontinuedline $textarea $ind]} {
        # + 1 c below to deal with the case where $ind is at the beginning
        # of a line ($textarea tag prevrange contline $ind would return the
        # previous range, not the one starting at $ind) - since the trailing
        # \n is also tagged as contline, it works for any $ind position in
        # the line
        return [lindex [$textarea tag prevrange contline "$ind + 1 c"] 0]
    } else {
        return [$textarea index "$ind linestart"]
    }
}

proc getendofcontline {textarea ind} {
# if line at $ind is a continued line
#    return index lineend of the continued line containing $ind
#    the real end of the continued line is returned, i.e. it includes
#    the last line of the continued line (this physical line is not
#    tagged as a continued line)
# otherwise
#    return "$ind lineend"
# contrary to proc getrealendofcontline, this proc does not always return
# the real end of the continued line, instead it returns "$ind lineend"
# if line at $ind is not tagged as a continued line 
    if {[iscontinuedline $textarea $ind]} {
        # + 1 c below to deal with the case where $ind is at the beginning
        # of a line ($textarea tag prevrange contline $ind would return the
        # previous range, not the one starting at $ind) - since the trailing
        # \n is also tagged as contline, it works for any $ind position in
        # the line
        return [$textarea index \
                "[lindex [$textarea tag prevrange contline "$ind + 1 c"] 1] \
                 lineend"]
    } else {
        return [$textarea index "$ind lineend"]
    }
}

proc getrealstartofcontline {w ind} {
# return start bound of a line
# and take care of nearby continued lines
# this proc is the same as getstartofcolorization
    return [getstartofcolorization $w $ind]
}

proc getrealendofcontline {w ind} {
# return end bound of a line
# and take care of nearby continued lines
# this proc is different from getendofcolorization and also from
# getendofcontline (see comments in the latter)
    return [getendofcolorization $w [$w index "$ind - 1 l"]]
}

proc showwhichfun {} {
    global pad
    set textarea [gettextareacur]
    set infun [whichfun [$textarea index insert] $textarea]
    if {$infun !={} } {
        set funname [lindex $infun 0]
        set lineinfun [lindex $infun 1]
        tk_messageBox -message [concat [mc "Function"] $funname [mc "line"] $lineinfun] \
                      -title [mc "Which function?"] -parent $pad
    } else {
        tk_messageBox -message [mc "The cursor is not currently inside a function body."] \
                      -title [mc "Which function?"] -parent $pad
    }
}

proc getfulllengthnamefromfunnamemaxcharinascilabname {fnam} {
# Return a list of two items:
# [list $isafunnamemaxcharinascilabnamefoundinanyta $correspondingfunname]
# $isafunnamemaxcharinascilabnamefoundinanyta is true if and only if:
#    $fnam has exactly $maxcharinascilabname characters (current Scilab
#    limit for function names - no need to check for longer than this)
#  and
#    the $maxcharinascilabname characters of $fnam match the first
#    $maxcharinascilabname characters of at least one function name among
#    those found in the opened buffers
#    Function names that have less than $maxcharinascilabname characters
#    are not considered in the matching process
# otherwise $isafunnamemaxcharinascilabnamefoundinanyta is false
# $correspondingfunname is the full length function name corresponding
# to $fnam, or "" if there is none
# if there are duplicate matches, then return the last found one (anyway,
# duplicate function names are not supported and detected at configure
# step)
    global maxcharinascilabname
    set maxcharinascilabnameminus1 [expr {$maxcharinascilabname - 1}]
    set itis false
    set flenname ""
    if {[string length $fnam] == $maxcharinascilabname} {
        foreach afunname [getallfunnamesfromalltextareas] {
            if {[string length $afunname] < $maxcharinascilabname} {
                continue
            } else {
                if {[string range $afunname 0 maxcharinascilabnameminus1] eq $fnam} {
                    set itis true
                    set flenname $afunname
                } else {
                    # check next candidate
                }
            }
        }
    }
    return [list $itis $flenname]
}

proc getallfunnamesfromalltextareas {} {
# Return a flat list of all function names found in all textareas
    set allfunnames [list ]
    foreach {ta allfunsinthatta} [getallfunsinalltextareas] {
        foreach {funname funline precfun} $allfunsinthatta {
            if {$funname ne "0NoFunInBuf"} {
                lappend allfunnames $funname
            }
        }
    }
    return $allfunnames
}

proc getallfunsinalltextareas {} {
# Get all the functions defined in all the opened textareas
# (those that have scilab as scheme)
# Result is a string with getallfunsintextarea results:
# "textarea1 { $funname11 $funline11 $precfun11  $funname12 $funline12 $precfun12  ... }
#  textarea2 { $funname21 $funline21 $precfun21  ... }
#  ...
# "
# The order of the buffers in the output is the order in $listoftextarea,
# which is always the order of opening of the buffers (the order in the
# Windows menu is only a display order)
    global listoftextarea
    set hitslist ""
    foreach textarea [filteroutpeers $listoftextarea] {
        set hitslistinbuf [getallfunsintextarea $textarea]
        set hitslist "$hitslist $hitslistinbuf"
    }
    return $hitslist
}

proc getallfunsintextarea {{buf "current"}} {
# Get all the functions defined in the given textarea (only if scheme is scilab
# and if the file is colorized - otherwise return as if there is no function)
# Return a list {$buf $some_results_of_whichfun}
# Continued lines and comments are trimmed so that the function definition line
# returned constitutes a single line
# If there is no function in $buf, then $result_of_whichfun is the following list:
#   $textarea { "0NoFunInBuf" 0 0 }
# Note that the leading zero in "0NoFunInBuf" is here so that the latter cannot
# be a valid function name in Scilab (they can't start with a number)
# If there is at least one function definition in $buf, then $result_of_whichfun
# is a flat list of proc whichfun results preceded by the textarea name:
#   $textarea { $funname1 $funline1 $precfun1  $funname2 $funline2 $precfun2  ... }
#       $funname   : function name
#       $funline   : definition line of the function, e.g. [a,b]=foo(c,d)
#       $precfun   : physical line number where $funname is defined in $buf
# Note further that the order of the functions returned is the order of their
# definition in the buffer, i.e. the order of the function definition lines
# when reading the buffer from its start to its end (nested functions are not
# special in any respect). This order is important because it is used in
# proc execfile_bp to eliminate nested functions from the list

    global listoffile
    global funlineREpat1 funlineREpat2 scilabnameREpat

    if {$buf == "current"} {
        set textarea [gettextareacur]
    } else {
        set textarea $buf
    }

    # return if the language is anything but scilab
    if {$listoffile("$textarea",language) ne "scilab"} {
        return {$textarea { "0NoFunInBuf" 0 0 }}
    }

    # return if colorization of the buffer is switched off
    # (colorization info is needed because it is tested that
    # what is found by the regexp is not a commented or
    # textquoted function, but a regular one)
    if {!$listoffile("$textarea",colorize)} {
        return {$textarea { "0NoFunInBuf" 0 0 }}
    }

    set pat "$funlineREpat1$scilabnameREpat$funlineREpat2"

    set hitslist ""

    set allfun [regexp -all -inline -indices -- $pat [$textarea get 1.0 end]]

    set ind "1.0"
    set previ 0
    foreach {fullmatch funname} $allfun {
        foreach {i j} $fullmatch {}
        set star [$textarea index "$ind + [expr {$i - $previ}] c"]
        set stop [$textarea index "$star + [expr {$j - $i}] c"]
        if {[lsearch [$textarea tag names $star] "rem2"] == -1} {
            if {[lsearch [$textarea tag names $star] "textquoted"] == -1} {
                # skip the keyword "function" (8 characters)
                set funline [$textarea get "$star + 8 c" $stop]
                # remove continued lines tags and comments
                set funline [trimcontandcomments $funline]
                # get function name
                set funname [extractfunnamefromfunline $funline]
                # get physical line number of function definition
                set funstart [$textarea index "$star linestart"]
                # braces around $funline mandatory because $funline can
                # contain spaces
                set hitslist "$hitslist $funname {$funline} $funstart"
            }
        }
        set ind $star
        set previ $i
    }

    if {$hitslist == ""} {
        return [list $textarea [list "0NoFunInBuf" 0 0]]
    } else {
        return [list $textarea $hitslist]
    }
}

proc getlistofallfunidsinalltextareas {} {
# obtain all the functions defined in all the opened buffers, and create a flat list
# containing function name, textarea where this function is defined and physical
# line number where the function definition starts. Format is:
# { funcname1 textarea1 funstartline1 funcname2 textarea2 funstartline2 ...}
    set funidslist {}
    set fundefs [getallfunsinalltextareas]
    foreach {ta fundefsinta} $fundefs {
        foreach {funcname funcline funstartline} $fundefsinta {
            if {$funcname != "0NoFunInBuf"} {
                lappend funidslist $funcname $ta $funstartline
            }
        }
    }
    return $funidslist
}

proc getlistoffunidsincurrenttextarea {} {
# obtain all the functions defined in the current textarea, and create a flat list
# containing function name, textarea where this function is defined and physical
# line number where the function definition starts. Format is:
# { funcname1 textarea funstartline1 funcname2 textarea funstartline2 ...}
    set ta [gettextareacur]
    set funidslist {}
    set fundefs [getallfunsintextarea "current"]
    foreach {ta fundefsinta} $fundefs {
        foreach {funcname funcline funstartline} $fundefsinta {
            if {$funcname != "0NoFunInBuf"} {
                lappend funidslist $funcname $ta $funstartline
            }
        }
    }
    return $funidslist
}

proc stringifyfunid {afunidlist {allfunnames ""}} {
# from a list formatted as $afunidlist, i.e. {funname ta funstartline},
# create a nicely formatted string for display to the user:
#    {funname ta funstartline} (i.e. a funid value)  ==>  formatted string
# this proc tries to be a bit clever:
#  - if there is no duplicate function name, then the result is just this
#    function name and nothing more:
#        funname
#  - if there is one or more duplicate function names, then:
#    . if filenames are non ambiguous, the result is:
#        funname ([file tail $listoffile("$ta",fullname)]:funstartline)
#    . otherwise, the result is:
#        funname ($listoffile("$ta",fullname):funstartline)
# the optional parameter allfunnames must either be the empty string,
# or it must be [getallfunnamesfromalltextareas]
# in the former case, getallfunnamesfromalltextareas is called in this proc,
# which has a performance impact (500 ms for ~100 random sci/sce files)
# in the latter case, getallfunnamesfromalltextareas does not need to be
# called since $allfunnames already contains its result
# this is useful to save performance when calling proc stringifyfunid in
# a loop such as:
#    set mylist [list ]
#    set allfunnames [getallfunnamesfromalltextareas]
#    foreach {funname ta funstartline} $funtogotolist {
#        lappend mylist [stringifyfunid [list $funname $ta $funstartline] $allfunnames]
#    }
# because then getallfunnamesfromalltextareas is called only once for all
# iterations of the loop
# this proc is the reciprocal of proc parsefunidstring

    global listoffile unklabel

    foreach {funname ta funstartline} $afunidlist {}

    if {$funname eq $unklabel} {

        set res $unklabel

    } else {

        if {$allfunnames eq ""} {
            set allfunnames [getallfunnamesfromalltextareas]
        }
        set dupsoffunname [lsearch -exact -all $allfunnames $funname]
 
        if {[llength $dupsoffunname] == 1} {
            # no duplicate function names exist, no confusion between functions
            # can arise, just use the function name alone
            set res $funname
 
        } else {
            # there is at least one duplicate function name
            set tasambiguouswiththisone [IsPrunedNameAmbiguous $ta]
            if {$tasambiguouswiththisone eq ""} {
                # the filename is not ambiguous, no confusion between filenames
                # can arise, just use file tail of the filename
                set shownfilename [file tail $listoffile("$ta",fullname)]
            } else {
                # the filename is also ambiguous, then display it in full
                set shownfilename $listoffile("$ta",fullname)
            }
            # note that when there is duplicate function names, then the line
            # number must always be shown because duplicates may be in the same
            # file and the line number is the only way to make the difference
            set res "$funname ($shownfilename:[expr {round($funstartline)}])"
        }
    }

    return $res
}

proc parsefunidstring {stringifiedfunid} {
# parse a string $stringifiedfunid representing a funid,
# and extract/create the corresponding (unique) funid list, i.e.:
#    {funname ta funstartline}
# this proc is the reciprocal of proc stringifyfunid

    global unklabel

    if {$stringifiedfunid eq $unklabel || $stringifiedfunid eq ""} {

        set funidlist [list $unklabel 0 0]

    } else {

        # parse the string received in argument in order to detect whether
        # it denotes a single function name or a function name with
        # filename and linenumber in parenthesis
        if {[string index $stringifiedfunid end] ne ")"} {

            # just a function name alone, which as a consequence is non ambiguous
            set funidlist [funnametofunnametafunstart $stringifiedfunid]
            if {$funidlist eq ""} {
                # function name not found among opened buffers
                tk_messageBox -message "Panic #1 in parsefunidstring! This should never happen, please report!"
            }

        } else {

            # a function name, with filename and line number to disambiguate it
            set endoffunname [expr {[string first "(" $stringifiedfunid] - 2}]
            set funname [string range $stringifiedfunid 0 $endoffunname]
            set beforecolopos [expr {[string last ":" $stringifiedfunid] - 1}]
            set filenameinfo [string range $stringifiedfunid [expr {$endoffunname + 3}] $beforecolopos]
            set funstartline [string range $stringifiedfunid [expr {$beforecolopos + 2}] end-1]
            # $funstartline is an index in the textarea, it has to receive the trailing zero
            set funstartline "$funstartline.0"

            # now $filenameinfo is either a file tail or a full filepath
            # one can make the difference by passing $filenameinfo to getlistoftacontainingfile
            # and checking whether the result is empty or nor, because this proc checks
            # $filenameinfo against all $listoffile("$ta",fullname)
            set tashavingfilenameinfo [getlistoftacontainingfile $filenameinfo]
            if {$tashavingfilenameinfo eq ""} {
                # $filenameinfo is a file tail
                set tas [getlistoftacontainingfiletail $filenameinfo]
                if {$tas eq ""} {
                    # no textarea have [file tail $listoffile(...,fullname)]
                    # equal to $filenameinfo
                    tk_messageBox -message "Panic #2 in parsefunidstring! This should never happen, please report!"
                }
                # arbitrarily pick the first peer of the list 
                set ta [lindex $tas 0]
            } else {
                # $filenameinfo is a full filepath
                # arbitrarily pick the first peer of the list
                set ta [lindex $tashavingfilenameinfo 0]
            }
            set funidlist [list $funname $ta $funstartline]
        }
    }

    return $funidlist
}

proc funnametofunnametafunstart {functionname} {
# given a function name, this proc looks in all the opened buffers and
# tries to find a function with this name
# if it succeeds, then the proc returns a list with one getallfunsintextarea
# result, more precisely, this is a list {$funcname $ta $funstartline}
# if it does not succeed, then the return value is ""
# <TODO> This search might fail if the same function name can be found in more
#        than one single buffer - in this case, the first match is returned
#        this proc should be improved to prompt the user whenever there is
#        more than one match
#        Hmm, maybe the ultimate fix would rather be to maintain a list of
#        functions defined in the buffers i.e. listoftextarea("$ta",definedfuns)
#        this should be dynamical - this would be good for performance since
#        getallfunsinalltextareas, which is usually the slowest proc, would
#        have to be called much less often
#        Handling this is needed because this proc is not only used in the
#        debugger but also elsewhere (proc blinkline, that is even called from
#        outside of Scipad by edit_error - asking the user where it should
#        blink is probably not the best thing to do!!)
#        In the debugger there can no longer be duplicate functions, this case
#        is trapped and the debug won't run
    set fundefs [getallfunsinalltextareas]
    set funstruct ""
    foreach {ta fundefsinta} $fundefs {
        foreach {funcname funcline funstartline} $fundefsinta {
            if {$funcname == $functionname} {
                set funstruct [list $funcname $ta $funstartline]
                break
            }
        }
    }
    return $funstruct
}

proc trimcontandcomments {str} {
# remove comments and continued lines from $str and return the resulting
# string
# warning: this does not use the textquoted tag information, it only
#          uses the regular expressions for matching comments and continued lines
#          therefore it shall be used only when there is no risk of having
#          strings like  a =" dxkierf //ez ef"  in $str
#          such an example is the function definition line of a Scilab script
    global scommRE scontRE2
    regsub -all -- $scontRE2 $str  "" str2
    regsub -all -- $scommRE  $str2 "" str2
    set str2 [string trim $str2]
    return $str2
}

proc trimcontandcomments_usetaginfo {ta indices} {
# remove comments from the text in textarea $ta, remove continued line marks,
# concatenate multilines with a semicolon, and return the resulting string
# the portion of text to consider is delimited by the indices in $indices, which
# can contain several start/stop indices (i.e. $indices is a list of an even
# number of indices denoting increasing positions in $ta)
# this proc does use the textquoted tag information, so that strings
# like  a =" dxkierf //ez ef"  will not get their comment-like part removed

    global scommRE scontRE1

    set fullstr ""
    foreach {sta sto} $indices {

        # 1. Remove comments
        set str ""
        set substr [$ta get $sta $sto]
        set substrsta $sta
        # get all comment candidate strings
        set allmatch [regexp -all -inline -indices -- $scommRE $substr]
        foreach amatch $allmatch {
            foreach {i j} $amatch {}
            set nocomment false
            # index in $ta of the first slash starting the comment candidate
            set postotest [$ta index "$sta + $i c"]
            while {[lsearch [$ta tag names $postotest] "textquoted"] != -1} {
                # this match is not a comment, it's quoted text also matching
                # the comment regular expression (which is basic: // followed
                # by anything until eol)
                # in this case, repeat the search until no match or real comment
                # (i.e. not textquoted) be found - this is needed for:
                #   s = "abc // def"  // here my comment
                #   a = 1
                # which would otherwise result in the concatenated:
                # s = "abc // def"  // here my comment ; a = 1
                # and Scilab would ignore s2 = ... when interpreting this
                set subsubstr [$ta get "$postotest + 1 c" $sto]
                set newmatch [regexp -inline -indices -- $scommRE $subsubstr]
                if {$newmatch eq {}} {
                    set nocomment true
                    break
                }
                foreach {ii jj} [lindex $newmatch 0] {}
                set postotest [$ta index "$postotest + 1 c + $ii c"]
            }
            if {!$nocomment} {
                # a real comment has been found - don't include it
                # in the constructed string
                append str [$ta get $substrsta $postotest]
                set substrsta [$ta index "$sta + $j c + 1 c"]
            }
        }
        # don't forget to add the last part of the substring
        append str [$ta get $substrsta $sto]

        # 2. remove leading white space in each line (keep just one space,
        #    or if there was no space then add a leading one)
        regsub -all -line -- {^\s*} $str " " str2

        # 3. join continued lines
        regsub -all -line -- $scontRE1 $str2 "" str3

        # 4. join multilines with ";"
        regsub -all -line -- {\n} $str3 ";" str4

        # 5. concatenate to fullstr (case of a block selection)
        append fullstr $str4 ";"
    }

    return $fullstr
}

proc extractfunnamefromfunline {str} {
# find the function name in a function definition line
    global snRE
    set funname ""
    if {[set i [string first "=" $str]] != {}} {
        regexp -start [expr {$i + 1}] -- $snRE $str funname  
    } else {
        regexp -- $snRE $str funname  
    }
    return $funname
}

proc isnocodeline {w ind} {
# return true if the line containing index $ind in textarea $w
# is a no code line, i.e. if this line either:
#     - is empty
# or  - contains only blanks (spaces or tabs)
# or  - contains only a comment with possible leading blanks
# otherwise, return false
    global sblRE scommRE
    if {[regexp -- "^$sblRE$scommRE?\$" \
                   [$w get "$ind linestart" "$ind lineend"]]} {
        return true
    }
    return false
}

proc isnocodeorcondcontline {w ind} {
# return true if the line containing index $ind in textarea $w
# is a no code line (see proc isnocodeline)
# or (conditionally in Scilab 5 or Scicoslab 4.x (x>3) only) if
# the previous line is a continued line (i.e. $ind does not
# denote the first line starting a logical line)
# otherwise, return false
    global Scilab5 Scicoslab
    if {[isnocodeline $w $ind]} {
        return true
    }
    if {$Scilab5 || $Scicoslab} {
        if {[iscontinuedline $w [$w index "$ind - 1l"]]} {
            return true
        }
    }
    return false
}

proc islevelzeroindex {w ind} {
# return true if the index $ind in textarea $w denotes a level zero
# position, i.e. if it is not inside a function
# return false otherwise
    if {[whichfun $ind $w] eq ""} {
        return true
    } else {
        return false
    }
}

proc bufferhaslevelzerocode {w} {
# return true if textarea $w has at least one character of "level zero" code,
# i.e. at least one character outside of a function and that is part of an
# executable statement (i.e. an uncommented non blank character)
# this file is therefore either a pure .sce file or a mixed .sce/.sci

    set out false

    # these characters can be present between functions even if uncommented,
    # they don't denote main level code
    set nocodechars {" " "\t" "\n"}

    set funsinthatbuf [lindex [getallfunsintextarea $w] 1]

    if {[lindex $funsinthatbuf 0] == "0NoFunInBuf"} {
        set out true
    } else {

        # is there main level code before the first function definition,
        # or between function definitions?
        set ind "1.0"
        foreach {fname fline precf} $funsinthatbuf {
            # if this function is nested in a higher level function,
            # skip it since only the intervals between highest level
            # functions must be scanned
            if {[whichfun $precf $w] != {}} {
                # there is no $ind adjustment to do because if this function
                # is nested, it is inside a function starting before it,
                # which means that $ind has already been adjusted to the
                # correct endfunction keyword at the end of the previous
                # iteration
                continue
            }
            while {[$w compare $ind < $precf]} {
                set ch [$w get $ind]
                # $ch is a character from a code statement if it is a non
                # commented char different from space, newline, or tab
                if {[lsearch [$w tag names $ind] "rem2"] == -1} {
                    if {[lsearch $nocodechars $ch] == -1} {
                        set out true
                        break
                    }
                }
                set ind [$w index "$ind + 1 c"]
            }
            if {$out} {break}
            set endpos [getendfunctionpos $w $precf]
            if {$endpos != -1} {
                set ind [$w index "$endpos + 10 c"]
            } else {
                # function not terminated by an endfunction keyword
                # then we have reached the end of the buffer
                # and there is no need to break
                # there is neither no need to return a special error
                # code since proc checkforduplicateorunterminatedfuns
                # has been called long before and the code we're now
                # in won't be run when an unterminated function exists
                set ind "end"
            }
        }

        # is there main level code after the last function definition?
        while {[$w compare $ind < end]} {
            set ch [$w get $ind]
            # $ch is a character from a code statement if it is a non
            # commented char different from space, newline, or tab
            if {[lsearch [$w tag names $ind] "rem2"] == -1} {
                if {[lsearch $nocodechars $ch] == -1} {
                    set out true
                    break
                }
            }
            set ind [$w index "$ind + 1 c"]
        }
    }

    return $out
}

proc getlistofancillaries {ta fun tag {lifun -1}} {
# scan function $fun from textarea $ta for words tagged as $tag
# and return these words in a list
#   - duplicate names are removed from the list
#   - tagged text inside functions nested in $fun is ignored
#   - if the line argument $lifun is given, then this proc
#     only returns the ancillaries from this logical line in
#     function $fun (note that $lifun is always logical, never
#     physical, whatever the underlying Scilab environment is)
#   - if the line argument $libfun is not given, then all the
#     ancillaries of $fun are returned
    set listofancill [list ]
    set allfunshere [lindex [getallfunsintextarea $ta] 1]
    foreach {funname funline precfun} $allfunshere {
        if {$funname != $fun} {
            continue
        }
        # function of interest is located, create list of
        # all calls to ancillaries tagged as $tag
        set endpos [getendfunctionpos $ta $precfun]
        if {$endpos == -1} {
            # should never happen since handled much ealier by checkforduplicateorunterminatedfuns, but...
            tk_messageBox -message "Unexpected missing endfunction in proc getlistofancillaries: please report"
        }
        foreach {i j} [$ta tag ranges $tag] {
            if {[$ta compare $precfun <= $i]} {
                if {[$ta compare $j <= $endpos]} {
                    # check that the tagged text actually belongs
                    # to $fun and not to an ancillary of $fun
                    foreach {fn lif fl pf cl fnl} [whichfun $i $ta] {}
                    if {$fn == $fun} {
                        # the tagged text is in the right function
                        # (not in a nested fun of the right one)
                        # now check that the line where the tagged
                        # text appears is the given logical line $lifun
                        # or skip this test if $libfun was not given
                        if {$lifun == -1 || $lifun == $lif} {
                            lappend listofancill [$ta get $i $j]
                        }
                    }
                }
            }
        }
        # remove duplicates
        for {set i 0} {$i < [llength $listofancill]} {incr i} {
            for {set j [expr {$i + 1}]} {$j < [llength $listofancill]} {incr j} {
                if {[lindex $listofancill $j] == [lindex $listofancill $i]} {
                    set listofancill [lreplace $listofancill $j $j]
                    incr j -1
                }
            }
        }
    }
    return $listofancill
}

proc getallnonlevelzerocode {} {
# copy any non level zero code from all scilab scheme buffers
# into a string
# <TODO>: getallfunsinalltextareas only returns functions from
#         buffers 1) tagged as scilab buffers and 2) colorized
#         Maybe a warning to the user about the non exec-ing of
#         scilab not colorized buffers would be a good idea...
# <TODO>: instead of execing all non level zero code from all scilab
#         scheme buffers, Scipad should actually exec only the
#         configured function plus all its ancillaries if those
#         ancillaries have ever been open in Scipad (let's simplify
#         and limit ourself to those that are currently open in
#         Scipad). The proposed solution is to scan the function being
#         debugged for ancillary functions, check recursively if any
#         of them is defined in a Scipad buffer, and dump all their
#         definitions only to a temporary file and execute that file.
#         I.e. refine the current scheme below.

    set allfuntexts ""
    set allfuns [getallfunsinalltextareas]
    foreach {textarea funsinthatta} $allfuns {
        set funsto 1.0
        foreach {funnam funlin funsta} $funsinthatta {
            if {$funnam == "0NoFunInBuf"} {
                break
            }
            if {[$textarea compare $funsta >= $funsto]} {
                set funsto [getendfunctionpos $textarea $funsta]
                if {$funsto == -1} {
                    # unterminated function (i.e. function keyword with
                    # no balanced endfunction keyword) -> ignore it
                    # this can't happen in principle since proc execfile_bp
                    # is called after checkforduplicateorunterminatedfuns
                    continue
                }
                set funsto [$textarea index "$funsto wordend"]
                set funtext [$textarea get $funsta $funsto]
                append allfuntexts $funtext "\n"
            } else {
                # this {funnam funlin funsta} item denotes a function
                # nested in another one already copied -> ignore it
            }
        }
    }
    return $allfuntexts
}

proc buffercontainsunsupportedstatements {ta} {
# check if the code in buffer $ta contains unsupported statements, i.e.
# code that will make the underlying Scilab or Scicoslab interpreter unstable
# if it gets executed from Scipad
# In Scilab 5, forbidden statements are pause and abort (in any function or
# in non level zero code)
# In !$Scilab5, forbidden statements are abort in any function (but abort is
# allowed in level zero code)
# if unsupported code is found, return {true $str}
#                     otherwise return {false $str}
# where $str is a string formatted for display in an error message

    global listoffile
    global Scilab5

    # return if the language is anything but scilab
    if {$listoffile("$ta",language) ne "scilab"} {
        return false
    }

    # return if colorization of the buffer is switched off
    if {!$listoffile("$ta",colorize)} {
        return false
    }

    if {$Scilab5} {
        set forbiddenstatementsstring "pause, abort"
    } else {
        set forbiddenstatementsstring "abort"
    }

    set forbiddenstatements_RE [string map {", " ")|("} $forbiddenstatementsstring]
    set forbiddenstatements_RE "\\m($forbiddenstatements_RE)\\M"

    set foundone false
    set sta 1.0
    set sto end

    # check if there is any forbidden statement in the buffer,
    # while avoiding any quoted or commented text
    set amatch [$ta search -exact -regexp $forbiddenstatements_RE $sta $sto]
    if {$amatch ne ""} {
        while {[lsearch [$ta tag names $amatch] "textquoted"] !=-1 || \
               [lsearch [$ta tag names $amatch] "rem2"      ] !=-1 || \
               ( !$Scilab5 && [islevelzeroindex $ta $amatch] )} {
            # <TODO> next line works because both pause and abort have exactly 5 characters
            set amatch [$ta search -exact -regexp $forbiddenstatements_RE "$amatch+5c" $sto]
            if {$amatch eq ""} {
                break
            }
        }
    }
    if {$amatch ne ""} {
        set foundone true
    }

    return [list $foundone $forbiddenstatementsstring]
}

proc condloglinetophyslineinfun {funname linenumber} {
# conditional compatibility wrapper for physical/logical line numbers
# from the different target environments in which Scipad is intended
# to run
# if running aside of Scilab 5 or Scicoslab 4.x (x>3), logical line
# numbers exchanged with setbpt()/delbpt() must be converted to physical
# line numbers (as measured in functions) while this is not the case
# for older environments

    global Scilab5 Scicoslab
    if {$Scilab5 || $Scicoslab} {
        return [loglinetophyslineinfun_dicho $funname $linenumber]
    } else {
        return $linenumber
    }
}

proc loglinetophyslineinfun_dicho {funname logline} {
# given a function name funname and a logical line number in this function,
# return the physical line number in that function of the line that *ends*
# the definition of this logical line
# algorithm uses dichotomy
# warning: function $funname is supposed to exist among the opened buffers,
#          and this function is supposed to have a logical line numbered
#          $logline (otherwise panic)

    set funinfo [funnametofunnametafunstart $funname]

    if {$funinfo != ""} {
        set ta [lindex $funinfo 1]
        set funstartind [lindex $funinfo 2]

        # logical line 1 of functions is special: it is concatenated internally
        # into a single physical line (so far same as other lines), but it is on
        # physical line 1 (no empty lines before the line where the line elements
        # are concatenated)
        # functions having their first line continued must be considered as if
        # they were starting on the last line of their function definition line
        set offsetline1continued [getnboftaggedcontlinesmakingfunfirstline $ta $funstartind]

        set endfunc [getendfunctionpos $ta $funstartind "only_endfunction"]
        if {$endfunc != -1} {

            set cursta [$ta index $funstartind]
            set cursto [$ta index $endfunc]
            set curmid [intmiddleind $ta $cursta $cursto]
            if {[$ta compare $curmid == $cursta]} {
                # happens for functions composed of only two lines (the function
                # declaration line and the endfunction line), with $logline
                # being 1 or 2
                # the logical line received is also the physical line to return
                return $logline
            }

            set found false
            while {!$found} {

                set infun [whichfun $curmid $ta]
                if {$infun == ""} {

                    # should never happen
                    tk_messageBox -message "Loop in proc loglinetophyslineinfun_dicho has run out of $funname into level zero code. \
                                            This should never happen, please report!"
                    return -1

                } elseif {[lindex $infun 0] != $funname} {

                    # peeked in a function nested in $funname
                    # this case is undecidable (no way to know on what side
                    # the search range should be refined)
                    # therefore give up dichotomy, KISS and fall back to
                    # linear search algorithm
                    return [loglinetophyslineinfun_linear $funname $logline]

                } else {

                    # OK, we're still in the same function
                    set curmidlogline [lindex $infun 1]
                    if {$curmidlogline < $logline} {
                        # refine search range toward the end of the function
                        set cursta $curmid
                        set curmid [intmiddleind $ta $cursta $cursto]
                        if {[$ta compare $curmid == $cursta]} {
                            # $cursta and $cursto denote two neighbour lines
                            # since intmiddleind uses int() it rounds toward the
                            # highest integer less than the middle index, which
                            # is again $cursta
                            # one must break this potential endless loop here,
                            # which is easy since $curmidlogline < $logline
                            # and $ta compare $curmid == $cursta necessarily
                            # mean that the result index is $cursto
                            set curmid $cursto
                            set found true
                        }
                    } elseif {$curmidlogline > $logline} {
                        # refine search range toward the beginning of the function
                        set cursto $curmid
                        set curmid [intmiddleind $ta $cursta $cursto]
                        if {[$ta compare $curmid == $cursta]} {
                            # same as right above, but now the result index is $cursta
                            set curmid $cursta
                            set found true
                        }
                    } else {
                        # $curmidlogline == $logline, $curmid is the result index
                        set found true
                    }
                }
            }

            set curmid [getendofcontline $ta $curmid]
            scan $curmid "%d." searchedphyslineinbuf
            scan $funstartind "%d." funstartphyslineinbuf
            set physlineinfun [expr {$searchedphyslineinbuf - $funstartphyslineinbuf + 1}]
            set physlineinfun [expr {$physlineinfun - $offsetline1continued}]
            return $physlineinfun

        } else {
            # unterminated function - should never happen
            tk_messageBox -message "Function $funname has no endfunction (proc loglinetophyslineinfun_dicho). \
                                    This should never happen, please report!"
            return -1
        }

    } else {
        # function $funname was not found among the opened buffers - should never happen
        tk_messageBox -message "Function $funname passed to proc loglinetophyslineinfun_dicho could not be found in any buffer. \
                                This should never happen, please report!"
        return -1
    }

}

proc loglinetophyslineinfun_linear {funname logline} {
# given a function name funname and a logical line number in this function,
# return the physical line number in that function of the line that *ends*
# the definition of this logical line
# algorithm searches linearly from start to end of the function
# warning: function $funname is supposed to exist among the opened buffers,
#          and this function is supposed to have a logical line numbered
#          $logline (otherwise panic)

    set funinfo [funnametofunnametafunstart $funname]

    if {$funinfo != ""} {
        set ta [lindex $funinfo 1]
        set funstartind [lindex $funinfo 2]

        # logical line 1 of functions is special: it is concatenated internally
        # into a single physical line (so far same as other lines), but it is on
        # physical line 1 (no empty lines before the line where the line elements
        # are concatenated)
        # functions having their first line continued must be considered as if
        # they were starting on the last line of their function definition line
        set offsetline1continued [getnboftaggedcontlinesmakingfunfirstline $ta $funstartind]

        set curind [$ta index "$funstartind + 1 c"]
        set curlogline 1
        while {$curlogline < $logline} {
            set curind [$ta index "$curind + 1 l"]
            set infun [whichfun $curind $ta]
            if {$infun == ""} {
                # should never happen
                tk_messageBox -message "Loop in proc loglinetophyslineinfun_linear has run out of $funname into level zero code. \
                                        This should never happen, please report!"
                return -1
            } elseif {[lindex $infun 0] != $funname} {
                # entered a function nested in $funname, go on looping
                # until back to $funname, but keep curlogline untouched
                continue
            } else {
                # OK, we're still in the same function
                set curlogline [lindex $infun 1]
            }
        }

        set curind [getendofcontline $ta $curind]
        scan $curind "%d." searchedphyslineinbuf
        scan $funstartind "%d." funstartphyslineinbuf
        set physlineinfun [expr {$searchedphyslineinbuf - $funstartphyslineinbuf + 1}]
        set physlineinfun [expr {$physlineinfun - $offsetline1continued}]
        return $physlineinfun

    } else {
        # function $funname was not found among the opened buffers - should never happen
        tk_messageBox -message "Function $funname passed to proc loglinetophyslineinfun_linear could not be found in any buffer. \
                                This should never happen, please report!"
        return -1
    }

}

proc condphyslinetologline {funname linenumber} {
# conditional compatibility wrapper for physical/logical line numbers
# from the different target environments in which Scipad is intended
# to run
# if running aside of Scilab 5 or Scicoslab 4.x (x>3), physical line
# numbers in functions received from where() must be converted to
# logical line numbers while this is not the case for older
# environments

    global Scilab5 Scicoslab
    if {$Scilab5 || $Scicoslab} {
        return [physlineinfuntologline $funname $linenumber]
    } else {
        return $linenumber
    }
}

proc physlineinfuntologline {funname physlineinfun} {
# given a function name funname and a physical line number in this function,
# return the logical line number in that function
# warning: function $funname is supposed to exist among the opened buffers,
#          and this function is supposed to have a physical line numbered
#          $physlineinfun (otherwise panic)
#          if $funname does not exist among the opened buffers, then return
#          -$physlineinfun

    set funinfo [funnametofunnametafunstart $funname]

    if {$funinfo != ""} {

        if {$physlineinfun == 1} {

            # the code for $physlineinfun != 1 will not work if $physlineinfun == 1
            # because $indofstartoflogline will be before the word "function", i.e.
            # in fact just out of the function definition, thus $infun would receive ""
            # therefore a special case for $physlineinfun == 1, fortunately the
            # answer to return is easy: the logical line number corresponding to
            # the first physical line number is 1
            set logline 1

        } else {

            set ta [lindex $funinfo 1]
            set funstartind [lindex $funinfo 2]

            # logical line 1 of functions is special: it is concatenated internally
            # into a single physical line (so far same as other lines), but it is on
            # physical line 1 (no empty lines before the line where the line elements
            # are concatenated)
            # functions having their first line continued must be considered as if
            # they were starting on the last line of their function definition line
            set offsetline1continued [getnboftaggedcontlinesmakingfunfirstline $ta $funstartind]

            scan $funstartind "%d." funstartind_line
            set indcorrespondingtophyslineinfun [string trim "[expr {$physlineinfun + $funstartind_line + $offsetline1continued - 1}].0"]
            set indofstartoflogline [getrealstartofcontline $ta $indcorrespondingtophyslineinfun]
            set infun [whichfun $indofstartoflogline $ta]
            if {$infun == ""} {
                # this should never happen in principle
                #tk_messageBox -message "proc physlineinfuntologline has run out of $funname into level zero code. \
                #                        This should never happen, please report!"
                #set logline -1
                # however it happens when executing Load into Scilab on a malformed file (missing an end
                # statement for instance). In this case the line number reported by Scilab is the line
                # number of the last line plus one
                # We will return here the line number of the last line of the function
                set infun [whichfun [$ta index "$indofstartoflogline - 1 l"] $ta]
                set logline [lindex $infun 1]
            } elseif {[lindex $infun 0] != $funname} {
                # $physlineinfun in $funname denotes a line contained in a function nested in $funname
                # this should never happen
                tk_messageBox -message "proc physlineinfuntologline has received line number $physlineinfun in $funname, which \
                                        denotes a line pertaining to function [lindex $infun 0] nested in $funname. \
                                        This should never happen, please report!"
                set logline -1
            } else {
                # OK, this is still the same function
                set logline [lindex $infun 1]
            }
        }

    } else {
        # function $funname was not found among the opened buffers
        # this can happen during the debug when stopping in a function called by
        # another function whose buffer has been closed
        set logline -$physlineinfun
    }

    return $logline

}

proc getnboftaggedcontlinesmakingfunfirstline {ta funstartind} {
# get the number of continued lines (tagged as such, i.e. the number of
# lines having yellow background, not including the last line which is
# not tagged as continued) making a function first logical line
# $funstartind is the index of the function start in textarea $ta
    scan $funstartind "%d." funstartind_line
    set indofendoffirstline [getendofcontline $ta $funstartind]
    scan $indofendoffirstline "%d." lastlineinbufoffirstlinecont
    set offsetline1continued [expr {$lastlineinbufoffirstlinecont - $funstartind_line}]
    return $offsetline1continued
}

proc getlistofuniquevarnames {ta} {
# parse textarea $ta for Scilab variable names and return these names
# variable names detection is based on grabbing a Scilab legal name
# (or list of names) found before an = sign
# (see regexp below for more details)
# duplicate variable names are removed
# performance of this proc is quite good: ~150 ms on a typical 15000 lines file
# <TODO> add parsing of variables declaration such as  myvar(2)=xx  perhaps,
#        although this is probably not so useful for careful programmers because
#        array variables should be initialized (myvar=zeros(...) for instance),
#        which is already covered in this proc

    global snRE_rep snRE sbklnRE_rep spalnRE_rep sblRE

    set fulltext " [$ta get 1.0 end]"

    # match Scilab names followed by the equal sign:  var =
    set pat1 $snRE_rep
    append pat1 $sblRE {=}
    set allmatch1 [regexp -all -inline -indices -- $pat1 $fulltext]
    set allmatch1strings [list ]
    foreach {amatchwithequal amatch} $allmatch1 {
        foreach {i j} $amatch {}
        lappend allmatch1strings [string range $fulltext $i $j]
    }

    # match lists of Scilab names separated by commas
    # and enclosed in brackets and followed by the equal sign:
    #   [var1,var2,...] =
    set pat2 $sbklnRE_rep
    append pat2 $sblRE {=}
    set allmatch2 [regexp -all -inline -indices -- $pat2 $fulltext]
    set allmatch2strings [list ]
    foreach {amatchwithequal amatch} $allmatch2 {
        # split list of names into names
        # regexp matching again (the split command would not work due to
        # possible continued lines)
        foreach {i j} $amatch {}
        set listofnames [list ]
        set subtext [string range $fulltext $i $j]
        set allmatch21 [regexp -all -inline -indices -- $snRE $subtext]
        foreach asubmatch $allmatch21 {
            foreach {sta sto} $asubmatch {}
            lappend listofnames [string range $subtext $sta $sto]
        }
        set allmatch2strings [concat $allmatch2strings $listofnames]
    }

    # match lists of Scilab names separated by commas
    # and enclosed in parenthesis and preceded by a scilab name
    # preceded by the equal sign, or the name "function":
    #    = sciname(var1,var2...)    or   function sciname(var1,var2...)
    # (this is to detect variables in function definition lines)
    set pat3 {(?:=|function)}
    append pat3 $sblRE $snRE $sblRE $spalnRE_rep
    set allmatch3 [regexp -all -inline -indices -- $pat3 $fulltext]
    set allmatch3strings [list ]
    foreach {amatchwithequal amatch} $allmatch3 {
        # split list of names into names
        # regexp matching again (the split command would not work due to
        # possible continued lines)
        foreach {i j} $amatch {}
        set listofnames [list ]
        set subtext [string range $fulltext $i $j]
        set allmatch31 [regexp -all -inline -indices -- $snRE $subtext]
        foreach asubmatch $allmatch31 {
            foreach {sta sto} $asubmatch {}
            lappend listofnames [string range $subtext $sta $sto]
        }
        set allmatch3strings [concat $allmatch3strings $listofnames]
    }

    set allmatch [concat $allmatch1strings $allmatch2strings $allmatch3strings]

    # sort and remove duplicates
    set uniquenames [lsort -unique -increasing -dictionary $allmatch]

    return $uniquenames
}
