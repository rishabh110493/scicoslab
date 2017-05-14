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

#####################################################################
#
# There are two relevant arrays used for colorization and keyword
# matching: chset and words.
#
# words contains elements addressed as words($MODE.$TAG.$INITIAL). 
# $MODE by now is always scilab,
# $TAG is one of {comm intfun predef libfun scicos userfun uservar}
# $INITIAL is a single character, a valid scilab name initial.
# Each element is a Tcl list containing all the words of the given $TAG
# beginning with $INITIAL (not all possible INITIALs need to be present,
# if thereare no keywords beginning with that letter).
# The script dynamickeywords.sce and proc getlistofuniquevarnames actually
# order them alphabetically.
# This is not exploited by the colorize procs, nor for autocompletion.
#
# Special case for the words array: $TAG == userfun - this entry is not
# sorted, and does not only contain the functions names but for each
# function a list of the following form: {$fname $buf $precf}, where:
#    . $fname : function name
#    . $buf   : name of the textarea containing that function
#    . $precf : physical line number in $buf identifying the beginning
#               of $fname
# This is required for the goto function feature, in order not to
# confuse functions with the same name defined more than once (in a
# single buffer or among opened buffers)
#
# Note for the words array with $TAG == uservar : this entry is sorted,
# it is not a special case
#
# chset contains elements addressed as chset($MODE.$TAG). Each element
# is a string of all the represented initials of the keywords in class
# $MODE.$TAG. Also this is presently alphabetically sorted, though the fact
# is not exploited.
# Special case: $TAG == userfun - this entry is not sorted
#
# Thus a word encountered in the text is matched with the database of
# keywords in the following way:
#
#    take the first character of the word
#    if initial is in the relevant chset($MODE.$TAG)
#        check for a match in {words($MODE.$TAG.$INITIAL)}
#
#####################################################################


proc load_words {} {

    global words chset intmacdir sourcedir


    # Scilab words

    # empty initialization of the keyword arrays, for the
    #  detached invocation of scipad (and for early-bird colorization requests)
    set chset(scilab.command) {}
    set chset(scilab.intfun) {}
    set chset(scilab.predef) {}
    set chset(scilab.libfun) {}
    set chset(scilab.scicos) {}
    # ask to scilab about keywords:
    # Warning: "seq" option only is mandatory so that colorization
    #          works with scipad somefile.sci (i.e. the ScilabEval
    #          below must be queued before colorization starts in
    #          the file that will be loaded through the famous
    #          TCL_EvalStr("ScilabEval "TCL_EvalStr(""openfile ...
    #          (see scipad.sci)
    # Note: "sync" "seq" would have been the right thing to do, but for
    #       some unclear reason words and chset are unknown in that case
    #       when the exec returns (running in sync mode is the same as
    #       running in a function: local vars are unknown upon function
    #       return). What is however strange is that this applies to slave
    #       Tcl interpreters too...
    ScilabEval_lt "exec \"$intmacdir/dynamickeywords.sce\";" "seq"

    set chset(scilab.userfun) {}

    set chset(scilab.uservar) {}


    # Modelica words

    # for the time being, Modelica keywords are not loaded dynamically
    # <TODO> load Modelica keywords dynamically
    # a words file with keywords is read and used to populate the
    # chset and words arrays
    set type {}
    set col {}
    set f [open $sourcedir/words r]
    while {[gets $f line] >= 0} {
        if {[string trim $line] eq ""} {
            # allow for minimal formatting (blank lines)
            continue
        } elseif {[lindex $line 0] eq {//}} {
            # allow for minimal formatting (comments starting by // followed by a blank))
            continue
        } elseif {[lindex $line 0] eq {#MODE}} {
            set type [lindex $line 1]
        } elseif {[lindex $line 0] eq {#TAG}} {
            set col [lindex $line 1]
            set chset($type.$col) {}
        } else {
            set ch [string range $line 0 0]
            append chset($type.$col) $ch
            set words($type.$col.$ch) $line
        }
    }
    close $f


    # presently empty lists for other schemes - not used, thus commented
#    set chset(none) {}
#    set chset(xml) {}
}

proc colorize {w ista iend ista_cl iend_cl} {
# colorize in textarea $w from start position $ista to end position $iend,
# multiline tags (usually strings, depending on the language scheme) are
# colorized from $ista_cl to $iend_cl
# colorization is done depending on the language scheme attached to $w
    global listoffile

    set ista    [$w index $ista   ]
    set iend    [$w index $iend   ]
    set ista_cl [$w index $ista_cl]
    set iend_cl [$w index $iend_cl]

    # if colorize is set to false, the only thing to do is to remove
    # colorization tags (in the large range)
    if {!$listoffile("$w",colorize)} {
        remalltags $w $ista_cl $iend_cl
        return
    } else {
        # tags need to be removed only on the small range (i.e. from $ista
        # to $iend) since the tags which will be searched for in the large range
        # (i.e. from $ista_cl to $iend_cl), will anyway remove any other tag later
        remalltags $w $ista $iend
    }

    switch -- $listoffile("$w",language) {
        "scilab"   { colorize_scilab   $w $ista $iend $ista_cl $iend_cl }
        "modelica" { colorize_modelica $w $ista $iend $ista_cl $iend_cl }
        "xml"      { colorize_xml      $w $ista $iend $ista_cl $iend_cl }
        "none"     { colorize_none     $w $ista $iend $ista_cl $iend_cl }
    }
}

proc remalltags {w begin ende} {
# remove all tags identifying remarkable strings, including those which are
# compatible with strings and comments, i.e. those which can be used inside
# Scilab strings and comments

    remalltags_strcomincompat $w $begin $ende

    $w tag remove url $begin $ende
}

proc remalltags_strcomincompat {w begin ende} {
# remove all tags identifying remarkable strings but don't touch those which
# are compatible with strings and comments

    $w tag remove parenthesis $begin $ende
    $w tag remove bracket     $begin $ende
    $w tag remove brace       $begin $ende
    $w tag remove punct       $begin $ende
    $w tag remove operator    $begin $ende
    $w tag remove number      $begin $ende
    $w tag remove intfun      $begin $ende
    $w tag remove command     $begin $ende
    $w tag remove predef      $begin $ende
    $w tag remove libfun      $begin $ende
    $w tag remove scicos      $begin $ende
    $w tag remove rem2        $begin $ende
    $w tag remove xmltag      $begin $ende
    $w tag remove textquoted  $begin $ende
    # tag userfun is deleted in proc docolorizeuserfun
    # tag uservar is deleted in proc docolorizeuservar

    $w tag remove Modelica_punct       $begin $ende
    $w tag remove Modelica_parenthesis $begin $ende
    $w tag remove Modelica_bracket     $begin $ende
    $w tag remove Modelica_brace       $begin $ende
    $w tag remove Modelica_operator    $begin $ende
    $w tag remove Modelica_number      $begin $ende
    $w tag remove Modelica_keyword     $begin $ende
    $w tag remove Modelica_introp      $begin $ende
    $w tag remove Modelica_string      $begin $ende
    $w tag remove Modelica_comment     $begin $ende
}

proc colorize_scilab {w ista iend ista_cl iend_cl} {
# Colorize in textarea $w :
#   - strings and comments (which are possibly on continued lines): from start
#       position $ista_cl to end position $iend_cl
#   - any other tag: from $ista position to $iend position
# Warning: if $ista denotes a position located *after* $iend, nothing is done
# Colorization is done as a Scilab scheme without checking this assumption
# here:   $listoffile("$w",language)   must be   "scilab"

    global words chset
    global Scilab_operatorREpat
    global floatingpointnumberREpat
    global snRE
    global urlREpat

    set searchedstr [$w get $ista $iend]

    # get the list of all scilab mode tags and remove the userfun and
    # uservar tags since they are treated specially by proc backgroundcolorizetasks
    regsub -all "scilab." [array names chset -glob scilab\.*] "" scitags
    set userfunpos [lsearch $scitags "userfun"]
    set scitags [lreplace $scitags $userfunpos $userfunpos]
    set uservarpos [lsearch $scitags "uservar"]
    set scitags [lreplace $scitags $uservarpos $uservarpos]

    # TAGS:
    # order matters here - for instance textquoted has to be after operator,
    # so operators are not colorized within strings

    # punctuation
    colorizetag $w {[;,]} punct $searchedstr $ista

    # parentheses
    colorizetag $w {[()]} parenthesis $searchedstr $ista

    # brackets
    colorizetag $w {[\[\]]} bracket $searchedstr $ista

    # braces
    #ES: why at all call ":" a "brace"?
    colorizetag $w {[\{\}:]} brace $searchedstr $ista

    # operators
    colorizetag $w $Scilab_operatorREpat operator $searchedstr $ista

    # numbers can contain +-. therefore follows operator colorization
    colorizetag_submatchvar $w $floatingpointnumberREpat number $searchedstr $ista

    # Scilab keywords - they are Scilab "names" (see help names)
    set allmatch [regexp -all -inline -indices -- $snRE $searchedstr]
    set ind $ista
    set previ 0
    foreach amatch $allmatch {
        foreach {i j} $amatch {}
        set star [$w index "$ind + [expr {$i - $previ}] c"]
        set stop [$w index "$star + [expr {$j - $i + 1}] c"]
        set kword [$w get $star $stop]
        set initial [string range $kword 0 0]
        foreach itag $scitags {
            if {[string first $initial $chset(scilab.$itag)]>=0} {
                #####
                # debug code to understand bug 4053
                if {[catch {lsearch -exact $words(scilab.$itag.$initial) $kword}]} {
                    # bug 4053 triggers
                    # race condition? save vars NOW by passing them by value as args
                    # instead of using a global in proc dealwithbug4053
                    global dynamickeywords_running dynamickeywords_ran_once
                    dealwithbug4053 $w $itag $initial $scitags $star $stop $kword $amatch $allmatch \
                                    $dynamickeywords_running $dynamickeywords_ran_once \
                                    [array get chset] [array get words]
                }
                # end of debug code to understand bug 4053
                # <TODO> remove this section and similar ones throughout the Scipad code once bug 4053 is fixed
                #####
                if {[lsearch -exact $words(scilab.$itag.$initial) \
                        $kword] != -1} {
                    $w tag add $itag $star $stop
                }
            }
        }
        set ind $star
        set previ $i
    }

    # urls
    colorizetag $w $urlREpat url $searchedstr $ista

    # process colorization for remarkable items possibly spanning multiple lines

    # Text quoted with single/double quotes as textquoted, and Scilab remarks
    colorizestringsandcomments_sd_scilab $w $ista_cl $iend_cl
}

proc colorize_modelica {w ista iend ista_cl iend_cl} {
# Colorize in textarea $w :
#   - strings and comments (which are possibly on continued lines): from start
#       position $ista_cl to end position $iend_cl
#   - any other tag: from $ista position to $iend position
# Warning: if $ista denotes a position located *after* $iend, nothing is done
# Colorization is done as a Modelica scheme without checking this assumption
# here:   $listoffile("$w",language)   must be   "modelica"

    global words chset
    global Modelica_operatorREpat
    global Modelica_floatingpointnumberREpat
    global Modelica_keywordlike_RE
    global urlREpat

    set searchedstr [$w get $ista $iend]

   # get the list of all modelica mode tags
    regsub -all "modelica." [array names chset -glob modelica\.*] "" modtags

    # TAGS: order matters here

    # see comments about the order of tags colorization
    # in other similar colorization procs

    # punctuation
    colorizetag $w {[;,:]} Modelica_punct $searchedstr $ista

    # parentheses
    colorizetag $w {[()]} Modelica_parenthesis $searchedstr $ista

    # brackets
    colorizetag $w {[\[\]]} Modelica_bracket $searchedstr $ista

    # braces
    colorizetag $w {[\{\}]} Modelica_brace $searchedstr $ista

    # operators
    colorizetag $w $Modelica_operatorREpat Modelica_operator $searchedstr $ista

    # numbers
    colorizetag_submatchvar $w $Modelica_floatingpointnumberREpat Modelica_number $searchedstr $ista

    # Modelica words
    # first prefilter what could be a Modelica word (use a regexp)
    # then, from the matching ranges, tag only the actual Modelica words by
    # comparing the matches to the Modelica keywords (do it quickly, use the initial
    # of the keyword)
    set allmatch [regexp -all -inline -indices -- $Modelica_keywordlike_RE $searchedstr]
    set ind $ista
    set previ 0
    foreach amatch $allmatch {
        foreach {i j} $amatch {}
        set star [$w index "$ind + [expr {$i - $previ}] c"]
        set stop [$w index "$star + [expr {$j - $i + 1}] c"]
        set kword [$w get $star $stop]
        set initial [string range $kword 0 0]
        foreach itag $modtags {
            if {[string first $initial $chset(modelica.$itag)]>=0} {
                if {[lsearch -exact $words(modelica.$itag.$initial) $kword] != -1} {
                    # Modelica intrinsic operators need further check to ensure that
                    # the match really has function syntax, i.e. the next non-blank
                    # character is an opening parenthesis - however only the name of
                    # the intrinsic operator must be tagged, not the parenthesis
                    if {$itag eq "Modelica_introp"} {
                        set justafterthename [$w index $stop]
                        set didmatch [regexp -indices -- {[[:blank:]]*\(} [$w get $justafterthename end] posofmatch]
                        if {$didmatch} {
                            if {[lindex $posofmatch 0] != 0} {
                                # the match is not an intrinsic operator since it is
                                # not followed by an opening parenthesis
                                continue
                            } else {
                                # the match really is an intrinsic operator
                            }
                        } else {
                            # no opening parenthesis after the name
                            # I choose arbitrarily to not colorize the match
                            continue
                        }
                    }
                    $w tag add $itag $star $stop
                }
            }
        }
        set ind $star
        set previ $i
    }
    # give priority to intrinsic operators over keywords
    # the example case is   initial   (keyword)   and   initial()   (intrinsic operator)
    $w tag lower Modelica_keyword Modelica_introp

    # urls
    colorizetag $w $urlREpat url $searchedstr $ista

    # process colorization for remarkable items possibly spanning multiple lines

    # Modelica strings and comments
    # they are done in the background because one needs to consider the
    # full content of the textarea, not just chunks
}

proc colorize_xml {w ista iend ista_cl iend_cl} {
# Colorize in textarea $w :
#   - strings: from start position $ista_cl to end position $iend_cl
#   - any other tag: from $ista position to $iend position
# Warning: if $ista denotes a position located *after* $iend, nothing is done
# Colorization is done as an XML scheme without checking this assumption
# here:   $listoffile("$w",language)   must be   "xml"

    global words chset
    global floatingpointnumberREpat urlREpat

    set searchedstr [$w get $ista $iend]

   # TAGS: order matters here

    # parentheses
    colorizetag $w {[()]} parenthesis $searchedstr $ista

    # brackets
    colorizetag $w {[\[\]]} bracket $searchedstr $ista

    # braces
    colorizetag $w {[\{\}:]} brace $searchedstr $ista

    # numbers can contain +-. therefore follows operator colorization
    colorizetag_submatchvar $w $floatingpointnumberREpat number $searchedstr $ista

    # XML tag (#ES this is a problem as <> are also operators)
    # the regexp pattern is a bit oversimplified
    # it does not check properly nested <> constructs, it just
    # looks for the first closing delimiter
    # therefore <hello<<world> is recognized as a single XML tag
    # do we really want it? - In general, nested <> are not
    # properly dealt with here (<TODO>)
    colorizetag $w {<[^>]*>} xmltag $searchedstr $ista

    # urls
    colorizetag $w $urlREpat url $searchedstr $ista

    # process colorization for remarkable items possibly spanning multiple lines

    # Text quoted with single/double quotes as textquoted
    colorizestringsandcomments_sd_xml_or_none $w $ista_cl $iend_cl
}

proc colorize_none {w ista iend ista_cl iend_cl} {
# Colorize in textarea $w :
#   - strings: from start position $ista_cl to end position $iend_cl
#   - any other tag: from $ista position to $iend position
# Warning: if $ista denotes a position located *after* $iend, nothing is done
# Colorization is done as an "none" scheme without checking this assumption
# here:   $listoffile("$w",language)   must be   "none"

    global words chset
    global floatingpointnumberREpat urlREpat

    set searchedstr [$w get $ista $iend]

    # TAGS: order matters here

    # parentheses
    colorizetag $w {[()]} parenthesis $searchedstr $ista

    # brackets
    colorizetag $w {[\[\]]} bracket $searchedstr $ista

    # braces
    colorizetag $w {[\{\}:]} brace $searchedstr $ista

    # numbers can contain +-. therefore follows operator colorization
    colorizetag_submatchvar $w $floatingpointnumberREpat number $searchedstr $ista

    # urls
    colorizetag $w $urlREpat url $searchedstr $ista

    # process colorization for remarkable items possibly spanning multiple lines

    # Text quoted with single/double quotes as textquoted, and Scilab remarks
    colorizestringsandcomments_sd_xml_or_none $w $ista_cl $iend_cl
}

proc colorizetag {w pat tagname str start} {
# ancillary for proc colorize_xxxx, written for speed
    set allmatch [regexp -all -inline -indices -- $pat $str]
    set ind $start
    set previ 0
    foreach amatch $allmatch {
        foreach {i j} $amatch {}
        set star [$w index "$ind  + [expr {$i - $previ}] c"]
        set stop [$w index "$star + [expr {$j - $i + 1}] c"]
        $w tag add $tagname $star $stop
        set ind $star
        set previ $i
    }
}

proc colorizetag_submatchvar {w pat tagname str start} {
# same as proc colorizetag, but the real match is in the first subMatchVar,
# not in matchVar
# this is due to the fact the lookbehind is missing in Tcl and must be
# replaced by a regular match, which must then be ignored
    set allmatch [regexp -all -inline -indices -- $pat $str]
    set allrealmatch {}
    foreach {u v} $allmatch {
        lappend allrealmatch $v
    }
    set ind $start
    set previ 0
    foreach amatch $allrealmatch {
        foreach {i j} $amatch {}
        set star [$w index "$ind  + [expr {$i - $previ}] c"]
        set stop [$w index "$star + [expr {$j - $i + 1}] c"]
        $w tag add $tagname $star $stop
        set ind $star
        set previ $i
    }
}

proc colorizestringsandcomments_sd_scilab {w thebegin theend} {
# colorize strings and comments between indices $thebegin and $theend in
# textarea $w
# consider single quotes (') and double quotes ("), or double quotes only
# based on the Options menu setting
# colorization is done as a Scilab scheme without checking this assumption
# here:   $listoffile("$w",language)   must be   "scilab"
# comments and continued strings are dealt with only in scilab
# language scheme

    global scilabSingleQuotedStrings

    if {$scilabSingleQuotedStrings == "yes"} {
        # single quotes or double quotes
        set quotespattern {["']}

        # since in Scilab it is legal to declare a="string', no effort is
        # made here to detect unbalanced quotes by their type

        # regular expression matching a simple string on a (non-continued) line
        # actually the character just before the string is part of the match
        # this allows for removing incorrect colorization of multiple matrix
        # transpose on a single line
        set simpstrRE {((?:[^\w_#!?$\]\}\)"'\.]|\A(?:))["'][^"'\.\n]*(?:\.?[^"'\.\n]*)+["'])}

        # regular expression matching a continued string possibly ending with a
        # comment, if this string was not already matched by $simpstrRE
        # actually the character just before the string is part of the match
        # this allows for removing incorrect colorization of multiple matrix
        # transpose on a single line
        set contstrRE {((?:[^\w_#!?$\]\}\)"']|\A(?:))["'](?:(?:[^"'\.\n]*(?:\.[^"'\.\n]+)*\.{2,} *)+(?://[^\n]*)?\n)+[^"'\n]*["'])}

    } else {
        # double quotes only
        set quotespattern {"}

        set simpstrRE {((?:[^\w_#!?$\]\}\)"]|\A(?:))"[^"\.\n]*(?:\.?[^"\.\n]*)+")}
        set contstrRE {((?:[^\w_#!?$\]\}\)"]|\A(?:))"(?:(?:[^"\.\n]*(?:\.[^"\.\n]+)*\.{2,} *)+(?://[^\n]*)?\n)+[^"\n]*")}
    }

    # regular expression matching a comment outside of a continued string
    # if this comment was not already matched by $simpstrRE or $contstrRE
    set outstrcommRE {(//[^\n]*)}

    # regular expression matching in two separate parts the continued string
    # part and the comment part of a continued line containing a comment
    set separationRE {([^\.\n]*(?:\.[^\.\n]+)*\.{2,} *)((//[^\n]*)?)}

    set textcommfullRE "$simpstrRE|$contstrRE|$outstrcommRE"

    colorizestringsandcomments_scilab $w $thebegin $theend \
            $textcommfullRE $separationRE $quotespattern
}

proc colorizestringsandcomments_sd_xml_or_none {w thebegin theend} {
# colorize strings and comments between indices $thebegin and $theend in
# textarea $w
# consider single quotes (') and double quotes ("), or double quotes only
# based on the Options menu setting
# colorization is done as an XML  or "none" scheme without checking this assumption
# here:   $listoffile("$w",language)   must be   "xml"  or  "none"
# comments and continued strings are ignored

    global scilabSingleQuotedStrings

    if {$scilabSingleQuotedStrings == "yes"} {
        # single quotes or double quotes
        set quotespattern {["']}
        set simpstrRE {(?:(?:.|\A(?:))["'][^"'\n]*["'])}
    } else {
        # double quotes only
        set quotespattern {"}
        set simpstrRE {(?:(?:.|\A(?:))"[^"'\n]*")}
    }

    set separationRE {}
    set textcommfullRE "$simpstrRE"

    colorizestringsandcomments_xml_or_none $w $thebegin $theend \
            $textcommfullRE $separationRE $quotespattern
}

proc colorizestringsandcomments_scilab {w thebegin theend textcommfullRE separationRE quotespattern} {
# colorize properly comments and text quoted with single or double quotes,
# depending on the regexps received, while taking care of continued lines
# possibly containing interlaced comments (this is legal in Scilab)
# this proc is for "scilab" language scheme

    global listoffile

    set resi {}
    set simpstr {}
    set contstr {}
    set outstrcomm {}

    set allmatch [regexp -all -inline -indices -- $textcommfullRE [$w get $thebegin $theend]]

    set star $thebegin
    set previ 0

    foreach {resi simpstr contstr outstrcomm} $allmatch {
        foreach {i j} $resi {}
        set star [$w index "$star  + [expr {$i - $previ}] c"]
        set ind $star
        # $ind contains now the start index for a not yet colorized match
        # with either:
        #   1 - a simple string without continuation dots, e.g.:
        #         "there is no co.mm.ent//in this str.ing"
        #   2 - a string formed by continued lines, possibly with embedded
        #       comments, e.g.:
        #         "a continued ..  // this part is a comment
        #          line with 1 comment"
        #   3 - a regular comment outside of a string declaration, e.g.:
        #         // there is no string in this "tricky" comment
        # the matching order is mandatorily the order above as coded
        # in the regular expression - this order *must* be followed below
        # cases 1 and 2: the match starts at the character before the
        # opening quote, or at an empty string before the quote
        # case 3: the match starts at the first slash indicating a comment

        # length of the match
        set num [expr {$j - $i + 1}]

        set done false
        # try first case: string on a single line
        if {[lindex $simpstr 0] != -1} {
            foreach {i1 j1} $simpstr {}
            if {$i == $i1 && $j == $j1} {
                # we're really in the first case
                $w mark set stop "$ind +$num c"
                if {![string match $quotespattern [$w get $ind]]} {
                    # in this case we did not match at the beginning of the
                    # string but one character before the opening quote
                    set ind "$ind + 1 c"
                } else {
                    # we matched at the opening quote - no adjustment to $ind
                }
                # textquoted deletes any other tag
                remalltags_strcomincompat $w $ind stop
                $w tag add textquoted $ind stop
                set done true
            } else {
                # some part located after $ind matches $simpstrRE
                # ignore this for now and try cases 2 and 3 first
            }
        }

        # try second case: string on continued lines, possibly with comments
        if {!$done && [lindex $contstr 0] != -1} {
            foreach {i1 j1} $contstr {}
            if {$i == $i1 && $j == $j1} {
                # we're really in the second case
                $w mark set stop "$ind +$num c"
                # the comment part must be separated from the string part, and
                # this has to be done for each continued line but the last one
                if {![string match $quotespattern [$w get $ind]]} {
                    # in this case we did not match at the beginning of the
                    # string but one character before the opening quote
                    set ind "$ind + 1 c"
                } else {
                    # we matched at the opening quote - no adjustment to $ind
                }
                set subtext [$w get $ind stop]
                set strpart {}
                set commpart {}
                set colstart [$w index $ind]
                while {[regexp -indices -- $separationRE $subtext \
                        res1 strpart commpart]} {
                    # colorize string part of the line
                    set scolstart [$w index "$colstart + [lindex $strpart 0] c"]
                    set scolstop  [$w index "$colstart + [lindex $strpart 1] c + 1 c"]
                    remalltags_strcomincompat $w $scolstart $scolstop
                    $w tag add textquoted $scolstart $scolstop
                    # colorize comment part of the line
                    if {$commpart != {}} {
                        set ccolstart [$w index "$colstart + [lindex $commpart 0] c"]
                        set ccolstop  [$w index "$colstart + [lindex $commpart 1] c + 1 c"]
                        remalltags_strcomincompat $w $ccolstart $ccolstop
                        $w tag add rem2 $ccolstart $ccolstop
                    }
                    set colstart [$w index "$colstart + [lindex $res1 1] c + 1 c"]
                    set subtext [string replace $subtext 0 [lindex $res1 1]]
                    set strpart {}
                    set commpart {}
                }
                # treat the special case of the last line, which is not a
                # continued line (doesn't match $separationRE)
                remalltags_strcomincompat $w $colstart stop
                $w tag add textquoted $colstart stop
                set done true
            } else {
                # some part located after $ind matches $contstrRE
                # ignore this for now and try case 3 first
            }
        }

        # try third case: regular comment outside of a string
        if {!$done && [lindex $outstrcomm 0] != -1} {
            foreach {i1 j1} $outstrcomm {}
            if {$i == $i1 && $j == $j1} {
                # we're really in the third case
                $w mark set stop "$ind +$num c"
                # rem2 deletes any other tag
                remalltags_strcomincompat $w $ind stop
                $w tag add rem2 $ind stop
                set done true
            } else {
                # some part located after $ind matches $outstrcommRE
                # but this should have been dealt with in the previous cases...
            }
        }

        if {!$done} {
            # should never happen
            tk_messageBox -message "Colorization algorithm fooled!\n\
                Position is $ind and regexp match length is $num.\n\
                Text at this place is:\n[$w get $ind "$ind + $num c"]\n\
                Please report this problem (include your current file)." \
                -icon warning -title "Colorization error"
            # this is to avoid to repeat the message
            break
        }

        set resi {}
        set simpstr {}
        set contstr {}
        set outstrcomm {}
        set previ $i
    }
}

proc colorizestringsandcomments_xml_or_none {w thebegin theend textcommfullRE separationRE quotespattern} {
# colorize properly comments and text quoted with single or double quotes,
# depending on the regexps received
# this proc is for "xml" or "none" language schemes

    global listoffile

    set allmatch [regexp -all -inline -indices -- $textcommfullRE [$w get $thebegin $theend]]

    set star $thebegin
    set previ 0

    foreach resi $allmatch {
        foreach {i j} $resi {}
        set star [$w index "$star  + [expr {$i - $previ}] c"]
        set ind $star
        # length of the match
        set num [expr {$j - $i + 1}]
        $w mark set stop "$ind +$num c"
        if {![string match $quotespattern [$w get $ind]]} {
            # in this case we did not match at the beginning of the
            # string but one character before the opening quote
            set ind "$ind + 1 c"
        } else {
            # we matched at the opening quote - no adjustment to $ind
        }
        # textquoted deletes any other tag
        remalltags_strcomincompat $w $ind stop
        $w tag add textquoted $ind stop
        set previ $i
    }
}

proc dobackgroundcolorize {w thebegin progressbar} {
# do colorization in background
# actually this uses a trick to keep Scipad responsive while colorization
# is in progress - useful for large files
# colorization is performed by small line increments that are colorized
# one after the other when Scipad is idle
# adjustment of increment ($incre) is important:
#   . if decreased, the complete colorization process will last longer
#     due to time overhead from this proc
#   . if increased, Scipad will be less responsive
# the progressbar is also updated accordingly

    global pad nbfilescurrentlycolorized listoffile

    # avoid Tcl error when Scipad is closed during colorization
    if {![info exist pad]} {
        return
    }

    scan $progressbar $pad.cp%d progressbarId

    # if the file has been closed during colorization, destroy the
    # progressbar and abort colorization
    if {![info exist listoffile("$w",fullname)]} {
        destroy $progressbar
        incr nbfilescurrentlycolorized -1
        return
    }

    # if the file has been asked for recolorization, abort it and reuse
    # the same progressbar to relaunch colorization
    if {$listoffile("$w",progressbar_id) == ""} {
        # relaunch colorization from the beginning, using the already
        # packed progressbar
        SetProgress $progressbar 0
        set listoffile("$w",progressbar_id) $progressbarId
        dobackgroundcolorize $w 1.0 $progressbar
        return
    }

    # colorization not aborted - normal process

    # number of lines constituting a colorization chunk
    set incre 20

    set curend "$thebegin + $incre l"
    set curend [getendofcolorization $w $curend]

    set thebegin [getstartofcolorization $w $thebegin]

    # if the file just needs removal of the colorization tags, do it at once
    if {!$listoffile("$w",colorize)} {
        set curend [$w index end]
    }

    scan [$w index $curend] "%d.%d" ycur xcur
    scan [$w index end]     "%d.%d" yend xend
    SetProgress $progressbar $ycur $yend $listoffile("$w",displayedname)

    if {[$w compare $curend < end]} {
        set theend [$w index $curend]
        colorize $w $thebegin $theend $thebegin $theend
        set newbegin $theend
        after idle [list after 1 dobackgroundcolorize $w $newbegin $progressbar]
    } else {
        # last colorization step
        colorize $w $thebegin end $thebegin end
        set listoffile("$w",progressbar_id) ""
        incr nbfilescurrentlycolorized -1
        destroy $progressbar
        # update status info - might be needed since logical line info makes
        # use of proc getallfunctionsareasintextarea, which in turn uses colorization info
        # BUT don't write  keyposn $w  because when launching several simultaneous colorizations
        # the ongest one will win the latest update of keyposn stuff whereas it should be
        # the current textarea
        keyposn [gettextareacur]
        backgroundcolorizetasks
    }
}

proc backgroundcolorize {w} {
# if allowed, launch background colorization of a buffer from its start,
# initialize the colorization progressbar,
# and keep track of the buffers currently being colorized

    global backgroundtasksallowed nbfilescurrentlycolorized
    global pad progressbarId listoffile

    if {!$backgroundtasksallowed} {
        # colorize actually in foreground

        set progressbar [Progress $pad.cp0]
        pack $progressbar -fill both -expand 0 -before $pad.pw0 -side bottom

        set thebegin "1.0"
        set curend $thebegin
        while {[$w compare $thebegin < end]} {
            set thebegin $curend
            # if the file just needs removal of the colorization tags, do it at once
            if {!$listoffile("$w",colorize)} {
                set curend [$w index end]
            } else {
                set curend [getendofcolorization $w "$curend + 10 l"]
            }
            colorize $w $thebegin $curend $thebegin $curend
            scan [$w index $thebegin] "%d.%d" ycur xcur
            scan [$w index end]       "%d.%d" yend xend
            SetProgress $progressbar $ycur $yend $listoffile("$w",displayedname)
            update idletasks
        }

        set lastbegin [getstartofcolorization $w "$curend - 10 l"]
        colorize $w $lastbegin end $lastbegin end

        docolorizeuserfunwhenidle
        docolorizeuservarwhenidle

        destroy $progressbar

    } else {

        # check if the file is already being colorized (can be the case when
        # switching scheme for instance)
        # reset colorization of the file already being colorized - this
        # is achieved by emtying the progressbar id, which is detected
        # in the background colorization proc that is already running
        if {$listoffile("$w",progressbar_id) != ""} {
            set listoffile("$w",progressbar_id) ""
        } else {
            # start colorization of a file currently not being colorized
            incr progressbarId
            incr nbfilescurrentlycolorized
            set listoffile("$w",progressbar_id) $progressbarId
            set progressbar [Progress $pad.cp$progressbarId]
            pack $progressbar -fill both -expand 0 -before $pad.pw0 -side bottom
            dobackgroundcolorize $w 1.0 $progressbar
        }

    }
}

proc colorizationinprogress {{withmessage "message"}} {
# return true if colorization of a buffer is in progress
# certain actions (those that make use of the colorization result such as the
# rem2 or textquoted tag) cannot be executed during colorization

    global nbfilescurrentlycolorized pad

    if {$nbfilescurrentlycolorized > 0} {
        if {$withmessage eq "message"} {
            set mes [mc "You can't do that while colorization is in progress.\
                     Please try again when finished."]
            set tit [mc "Command forbidden during colorization"]
            tk_messageBox -message $mes -icon warning -title $tit -parent $pad
        }
        return true
    } else {
        return false
    }

}

proc iscurrentbufnotcolorized {} {
# return true if current buffer is not colorized
# certain debugger commands cannot be executed if colorization is disabled
    global ColorizeIt pad
    if {!$ColorizeIt} {
        set mes [mc "You must enable colorization to be able to launch the debugger!"]
        set tit [mc "The debugger needs colorization"]
        tk_messageBox -message $mes -icon error -title $tit -parent $pad
        return true
    } else {
        return false
    }
}

proc backgroundcolorizetasks {} {
# launch colorization tasks that need to consider the full content
# of the textarea (the ones that do not need this are executed by
# proc backgroundcolorize)

    if {[colorizationinprogress nomessage]} {
        return
    }

    # Scilab language scheme
    backgroundcolorizeuserfun
    backgroundcolorizeuservar

    # Modelica language scheme
    # note that the order matters : comments must be before strings
    # since comments do not contain Modelica strings
    # and   strings do not contain Modelica comments
    # and colorization of strings will detect whether the regexp matches
    # in a comment or not
    backgroundcolorizeModelicacomments
    backgroundcolorizeModelicastrings
}

proc backgroundcolorizeuserfun {} {
# launch a docolorizeuserfunwhenidle command in background for all the visible buffers
# docolorizeuserfunwhenidle can be a bit long to execute for large buffers despite
# the efforts put in speed improvement
# if many docolorizeuserfunwhenidle are waiting for execution, e.g. when the user types
# quicker than the position can be updated by Scipad, there can be many
# docolorizeuserfunwhenidle commands pending -> first delete them since they are now
# pointless and launch only the latest command
# docolorizeuserfunwhenidle is catched to deal more easily with buffers that were
# closed before the command could be processed
    global backgroundtasksallowed
    if {$backgroundtasksallowed} {
        after cancel [list after 1 "catch \"docolorizeuserfunwhenidle\""]
        after idle   [list after 1 "catch \"docolorizeuserfunwhenidle\""]
    } else {
        docolorizeuserfunwhenidle
    }
}

proc backgroundcolorizeuservar {} {
# launch a docolorizeuservarwhenidle command in background for all the visible buffers
# see proc backgroundcolorizeuserfunwhenidle for more details
    global backgroundtasksallowed
    if {$backgroundtasksallowed} {
        after cancel [list after 1 "catch \"docolorizeuservarwhenidle\""]
        after idle   [list after 1 "catch \"docolorizeuservarwhenidle\""]
    } else {
        docolorizeuservarwhenidle
    }
}

proc backgroundcolorizeModelicacomments {} {
# launch a docolorizeModelicacommentswhenidle command in background for all the visible buffers
# see proc backgroundcolorizeuserfunwhenidle for more details
    global backgroundtasksallowed
    if {$backgroundtasksallowed} {
        after cancel [list after 1 "catch \"docolorizeModelicacommentswhenidle\""]
        after idle   [list after 1 "catch \"docolorizeModelicacommentswhenidle\""]
    } else {
        docolorizeModelicacommentswhenidle
    }
}

proc backgroundcolorizeModelicastrings {} {
# launch a docolorizeModelicastringswhenidle command in background for all the visible buffers
# see proc backgroundcolorizeuserfunwhenidle for more details
    global backgroundtasksallowed
    if {$backgroundtasksallowed} {
        after cancel [list after 1 "catch \"docolorizeModelicastringswhenidle\""]
        after idle   [list after 1 "catch \"docolorizeModelicastringswhenidle\""]
    } else {
        docolorizeModelicastringswhenidle
    }
}

proc docolorizeuserfunwhenidle {} {
    global minuseridletime
    dowhenidle $minuseridletime {catch docolorizeuserfun}
}

proc docolorizeuservarwhenidle {} {
    global minuseridletime
    dowhenidle $minuseridletime {catch docolorizeuservar}
}

proc docolorizeModelicastringswhenidle {} {
    global minuseridletime
    dowhenidle $minuseridletime {catch docolorizeModelicastrings}
}

proc docolorizeModelicacommentswhenidle {} {
    global minuseridletime
    dowhenidle $minuseridletime {catch docolorizeModelicacomments}
}

proc dowhenidle {delay cmd} {
# with Tk 8.5:
#    execute command $cmd when the user has been idle for $delay (in milliseconds)
# with Tk before 8.5:
#    tk inactive (TIP 245) is not available in Tk 8.4, thus $delay is ignored and
#    this proc executes   after idle $cmd
# this proc is largely inspired from  http://wiki.tcl.tk/21079  (WhenIdle.tcl, Keith Vetter)
# the main additional refinement is that this proc cancels pending (rescheduled)
# commands identical to the latest command received - useful in this precise use case
# in Scipad: we are otherwise queueing colorization commands which become obsolete as
# soon as a new such command is triggered during editing (this is true because the
# userfun and uservar colorization commands consider the entire text, not only the
# area around the latest edit action)

    global Tk85

    if {$Tk85} {
        set t [tk inactive]
        if {$t == -1} {
            # querying the user inactive time is not supported by the operating system
            after idle $cmd
        } else {
            set diff [expr {$delay - $t}]
            if {$diff <= 0} {
                # catched to deal with Scipad closure easily
                catch {eval $cmd}
            } else {
                after cancel [list dowhenidle $delay $cmd]
                after $diff  [list dowhenidle $delay $cmd]
            }
            
        }

    } else {
        # Tk 8.4
        after idle $cmd
    }
}

proc docolorizeuserfun {} {
# wrapper to docolorizeusernames for user functions
# that also allows releasing the feature depending on measured performance

    global colorizeuserfuns autoreleasecolorization
    global previoustimecolorizeuserfun_us thresholdcolorizeuserfuntime_us

    if {$autoreleasecolorization} {

        if {$previoustimecolorizeuserfun_us < $thresholdcolorizeuserfuntime_us} {
            # processing time was acceptable during the previous run
            # therefore colorize again
            set timeuserfun [time {docolorizeusernames userfun $colorizeuserfuns}]
            scan $timeuserfun %d previoustimecolorizeuserfun_us

        } else {
            # previous processing time exceeded the defined threshold
            # therefore switch colorization off
            set colorizeuserfuns "no"
            docolorizeusernames userfun $colorizeuserfuns ; # to remove colorization tags
            togglegreyuservartooltipsoptions
        }

    } else {
        # no auto release: colorization forced
        docolorizeusernames userfun $colorizeuserfuns
    }
}

proc docolorizeuservar {} {
# wrapper to docolorizeusernames for user variables
# that also allows releasing the feature depending on measured performance

    global colorizeuservars autoreleasecolorization
    global previoustimecolorizeuservar_us thresholdcolorizeuservartime_us

    if {$autoreleasecolorization} {

        if {$previoustimecolorizeuservar_us < $thresholdcolorizeuservartime_us} {
            # processing time was acceptable during the previous run
            # therefore colorize again
            set timeuservar [time {docolorizeusernames uservar $colorizeuservars}]
            scan $timeuservar %d previoustimecolorizeuservar_us

        } else {
            # previous processing time exceeded the defined threshold
            # therefore switch colorization off
            set colorizeuservars "no"
            docolorizeusernames uservar $colorizeuservars ; # to remove colorization tags
        }

    } else {
        # no auto release: colorization forced
        docolorizeusernames uservar $colorizeuservars
    }
}

proc docolorizeusernames {tag colorizeusername} {
# detect and colorize user names (functions or variables, depending
# on the content of $tag)
# recreate the list of all user defined names in all the textareas
# and tag (colorize) them in all the visible buffers
# $tag can be either "userfun" or "uservar"
# note that neither chset nor words are sorted for userfun tag
#  but that both chset and words are sorted for uservar tag
#  (this fact is however not used)
    global listoffile listoftextarea
    global words chset
    global notsnccRE notsncclookaheadRE
    global maxcharinascilabname

    set mode scilab

    # note wrt to peers:
    #    - tags are shared among peers
    #    - $listoffile("$ta",colorize) is the same for all peers of $ta
    # there is therefore no need to perform the tasks in this proc for all
    # textareas, it is only required for any one of the peers (and of course
    # for textareas that have no peers)
    set nopeerslistoftextarea [filteroutpeers $listoftextarea]

    foreach ta $nopeerslistoftextarea {
        if {![isfilehidden $ta]} {
            $ta tag remove $tag 1.0 end
        }
    }

    # if user functions must not be colorized, that's all!
    if {!$colorizeusername} {
        return
    }

    # remove userfun or uservar entries from the words array and reset chset
    foreach initialtag [array names words $mode.$tag.*] {
        unset words($initialtag)
    }
    set chset($mode.$tag) ""

    # populate arrays chset and words
    if {$tag == "userfun"} {
        # note: no check for duplicates is made, but this cannot happen since
        # the arrays have just been cleaned - apparent duplicates can however
        # appear if a function is defined more than once in a buffer or across
        # opened buffers (the entries in words will at least differ by the
        # line number)
        foreach ta $nopeerslistoftextarea {
            if {$listoffile("$ta",colorize)} {
                set funsinthatbuf [lindex [getallfunsintextarea $ta] 1]
                if {[lindex $funsinthatbuf 0] == "0NoFunInBuf"} {
                    continue
                }
                foreach {fname fline precf} $funsinthatbuf {
                    set ch [string range $fname 0 0]
                    if {[string first $ch $chset($mode.$tag)] == -1} {
                        append chset($mode.$tag) $ch
                    }
                    lappend words($mode.$tag.$ch) [list $fname $ta $precf]
                }
            }
        }
    } else {
        # $tag == "uservar"
        # note: duplicate removal is made in getlistofuniquevarnames
        foreach ta $nopeerslistoftextarea {
            set varnames [getlistofuniquevarnames $ta]
            foreach varn $varnames {
                set ch [string range $varn 0 0]
                if {[string first $ch $chset($mode.$tag)] == -1} {
                    append chset($mode.$tag) $ch
                }
                lappend words($mode.$tag.$ch) $varn
            }
        }
    }

    # to improve drastically performance, better use a regexp once with
    # many alternatives (foo1|foo2|foo3|... or var1|var2|var3|...) rather
    # than running a simpler regexp (just fooi or just vari) n times (n
    # being the number of defined functions, resp. variables)
    # speed gain is approximately 20%
    # <TODO> try to see whether performance could be improved by
    #        constructing a shorter regexp pattern based on common letters
    #        in the names, i.e.  foo(?:1|2|3)|bar(?:1|4)|...
    #        note: according to RE experts, there is no point in going
    #              down that path, see:
    #              https://groups.google.com/forum/?hl=fr&fromgroups#!topic/comp.lang.tcl/FRzBlXvDyiE
    #              Opinion is that since "the pattern changes at *runtime*,
    #              the regexp recompilation is costly. At some point it'll
    #              be worth even ditching REs altogether and using hashing
    #              over fixed-sized sliding substrings, or similar hacks."
    #        but: an interesting approach was suggested in the above thread,
    #             consisting in constructing a regexp pattern with only the
    #             candidates that have string length equal to the length of
    #             the string to match. However this is not adapted to the
    #             present case where we're regexp matching the full text of
    #             the textarea against the pattern, in order to collect just
    #             the list of matching indices (we're not interested in which
    #             part of the textarea matched which part of the pattern)
    # <TODO> try to resurrect the old approach for scilab keywords, now
    #        used to colorize Modelica keywords - this is based on regexp
    #        matching (with a simple regexp, thus quick), followed by a
    #        secondary matching based on the initial of the keyword
    # construct the composite regexp pattern
    set atleastone false
    set pat $notsnccRE
    append pat {(}
    foreach mode_tag_initial [array names words -glob $mode.$tag.*] {
        foreach elt $words($mode_tag_initial) {
            set aname [lindex $elt 0]
            # A question mark or dollar sign in the name must
            # be escaped otherwise the regexp compilation fails
            # (Scilab names can contain in particular ? or $)
            set escaname [escapespecialchars $aname]
            append pat $escaname {|}
            set atleastone true
        }
    }
    set pat [string range $pat 0 "end-1"]
    append pat {)} $notsncclookaheadRE

    if {!$atleastone} {
        # there is no function or variable name in any buffer
        # speed up things!
        # the upcoming regexp matching cannot succeed
        return
    }

    # colorize found names if not in a comment nor in a string
    # for functions this includes both the function definition line and
    # calls to the defined functions, if not in a comment nor in a string
    # tagging is done only in visible buffers
    foreach ta $nopeerslistoftextarea {
        if {![isfilehidden $ta] && $listoffile("$ta",colorize)} {

            # don't colorize user names in buffers other than scilab
            if {$listoffile("$ta",language) != "scilab"} {
                continue
            }

            # the leading space is added so that the regexp can match at
            # the very beginning of the text
            # regexping for $notsnccRE|(?:) is not correct because it would
            # match function/variable names inside longer Scilab names
            set fulltext " [$ta get 1.0 end]"

            set allmatch [regexp -all -inline -indices -- $pat $fulltext]

            # parse regexp results and tag with $tag (i.e. "userfun" or "uservar") accordingly
            set ind "1.0"
            set previ 1 ;# and not 0 because of the added leading space in $fulltext
            foreach {fullmatch funnamematch} $allmatch {
                foreach {i j} $funnamematch {}
                set star [$ta index "$ind + [expr {$i - $previ}] c"]
                if {[lsearch [$ta tag names $star] "rem2"] == -1} {
                    if {[lsearch [$ta tag names $star] "textquoted"] == -1} {
                        set malength [expr {$j - $i + 1}]
                        set stop [$ta index "$star + $malength c"]
                        if {$malength > $maxcharinascilabname} {
                            # clip tagging length to $maxcharinascilabname characters,
                            # since this is the Scilab limitation - this is to remind
                            # the user of this limit
                            # Scipad is not limited in the length of names, but Scilab is
                            set stop [$ta index "$stop - [expr {$malength - $maxcharinascilabname}] c"]
                        }
                        $ta tag add $tag $star $stop
                    }
                }
                set ind $star
                set previ $i
            }

            # $tag ("userfun" or "uservar") is of higher priority than
            # operator - must do this because of the $ case, which is
            # an operator, and can also be in a Scilab name
            $ta tag raise $tag operator

            # $tag ("userfun" or "uservar") is of higher priority than
            # number because numbers can be part of Scilab names
            $ta tag raise $tag operator
        }
    }

}

proc docolorizeModelicacomments {} {
# detect and colorize Modelica comments
# in all the visible buffers
# Modelica comments overcome Modelica strings, i.e.:
#    // this is a "Modelica" comment     is a comment with no string
    global listoffile listoftextarea
    global Modelica_singlelinecomment_RE Modelica_multilinecomment_RE

    # note wrt to peers:
    #    - tags are shared among peers
    #    - $listoffile("$ta",colorize) is the same for all peers of $ta
    # there is therefore no need to perform the tasks in this proc for all
    # textareas, it is only required for any one of the peers (and of course
    # for textareas that have no peers)
    set nopeerslistoftextarea [filteroutpeers $listoftextarea]

    foreach ta $nopeerslistoftextarea {
        if {$listoffile("$ta",language) eq "modelica"} {
            if {![isfilehidden $ta]} {
                set fulltext [$ta get 1.0 end]
                $ta tag remove Modelica_comment 1.0 end
                # 1. (potentially) multiline comments   (/*   ... */)
                colorizetag $ta $Modelica_multilinecomment_RE Modelica_comment $fulltext 1.0
                # 2. single line comments               (//   ...   )
                colorizetag $ta $Modelica_singlelinecomment_RE Modelica_comment $fulltext 1.0
            }
        }
    }
}

proc docolorizeModelicastrings {} {
# detect and colorize Modelica strings
# in all the visible buffers
    global listoffile listoftextarea
    global Modelica_string_RE

    # note wrt to peers:
    #    - tags are shared among peers
    #    - $listoffile("$ta",colorize) is the same for all peers of $ta
    # there is therefore no need to perform the tasks in this proc for all
    # textareas, it is only required for any one of the peers (and of course
    # for textareas that have no peers)
    set nopeerslistoftextarea [filteroutpeers $listoftextarea]

    foreach ta $nopeerslistoftextarea {
        if {$listoffile("$ta",language) eq "modelica"} {
            if {![isfilehidden $ta]} {
                $ta tag remove Modelica_string 1.0 end
                set allmatch [regexp -all -inline -indices -- $Modelica_string_RE [$ta get 1.0 end]]
                set ind 1.0
                set previ 0
                foreach amatch $allmatch {
                    foreach {i j} $amatch {}
                    set star [$ta index "$ind  + [expr {$i - $previ}] c"]
                    set stop [$ta index "$star + [expr {$j - $i + 1}] c"]
                    if {[lsearch [$ta tag names $star] "Modelica_comment"] == -1} {
                        $ta tag add Modelica_string $star $stop
                    }
                    set ind $star
                    set previ $i
                }
                # now remove the Modelica_comment tag in strings that may contain it
                # anyway, Modelica_string deletes any other tag
                foreach {star stop} [$ta tag ranges Modelica_string] {
                    remalltags_strcomincompat $ta $star $stop
                    $ta tag add Modelica_string $star $stop
                }
            }
        }
        # Warning! this MUST be here, i.e. outside of the  if {$listoffile("$ta",language) eq "modelica"}
        # because when scitching the language scheme it must be launched to remove the existing
        # tags on Modelica annotations
        # Since tagModelicaannotations uses string colorization results it must be placed here
        tagModelicaannotations $ta
    }
}

proc changelanguage {newlanguage} {
    global listoffile pad

    set textarea [gettextareacur]
    set oldlanguage $listoffile("$textarea",language)

    if {$oldlanguage ne $newlanguage} {
        foreach ta [getfullpeerset $textarea] {
            set listoffile("$ta",language) $newlanguage
        }
        showinfo [mc "Wait seconds while recolorizing file"]
        schememenus $textarea
        backgroundcolorize $textarea
        tagcontlines $textarea

        # if this is a new file not opened from disk,
        # then the filename extension must be changed
        if {$listoffile("$textarea",new) == 1} {
            switch -- $newlanguage {
                "scilab"   { set ext "sce" }
                "xml"      { set ext "xml" }
                "modelica" { set ext "mo"  }
                default    { set ext "sce" }
            }

            # replace extension of file name by the new extension
            foreach ta [getfullpeerset $textarea] {
                set ilab [extractindexfromlabel $pad.filemenu.wind \
                          $listoffile("$ta",displayedname)]
                foreach {dispname peerid} [removepeerid $listoffile("$ta",displayedname)] {}
                set dispname [string replace $dispname "end-2" end $ext]
                set dispname [appendpeerid $dispname $peerid]
                set listoffile("$ta",displayedname) $dispname
                set listoffile("$ta",fullname) \
                        [string replace $listoffile("$ta",fullname) "end-2" end $ext]
                # update the windows menu label
                setwindowsmenuentrylabel $ilab $listoffile("$textarea",displayedname)
                RefreshWindowsMenuLabelsWrtPruning
            }
        }
    }
}

proc switchcolorizefile {} {
# switch colorization of the current buffer on or off
    global listoffile ColorizeIt
    global funnameargs funnames
    set w [gettextareacur]
    foreach ta [getfullpeerset $w] {
        set listoffile("$ta",colorize) $ColorizeIt
    }
    if {$ColorizeIt} {
        showinfo [mc "Wait seconds while recolorizing file"]
    }
    if {!$ColorizeIt} {
        # prevent the configure box to open from a scilab buffer that can
        # no more contain functions since colorization is off
        set funnameargs ""
        set funnames ""
    }
    backgroundcolorize $w
}

proc schememenus {textarea} {
    global pad listoffile
    global Shift_F8 Shift_F9 Shift_F11 Shift_F12
    global watch watchwinicons watchwinstepicons
    global MenuEntryId
    set dm $pad.filemenu.debug
    set dms $pad.filemenu.debug.step
    if {$listoffile("$textarea",language) eq "scilab"} {
        # Scilab language scheme
        # enable "Load into scilab" entries
        $pad.filemenu.exec entryconfigure $MenuEntryId($pad.filemenu.exec.[mcra "&Load into Scilab"]) -state normal
        $pad.filemenu.exec entryconfigure $MenuEntryId($pad.filemenu.exec.[mcra "Load into Scilab (to &cursor)"]) -state normal
        $pad.filemenu.exec entryconfigure $MenuEntryId($pad.filemenu.exec.[mcra "Load &all into Scilab"]) -state normal
        # restore bindings
        bindenable $pad execfile
        bind $pad <F5> {filetosave %W; execfile}
        # enable the debug entries and watch window icons
        # this is set selectively in function of the debugger state
        setdbmenuentriesstates_bp
        # enable "create help skeleton" - done in proc keyposn
        # enable "Show continued lines"
        $pad.filemenu.options.colorizeoptions entryconfigure $MenuEntryId($pad.filemenu.options.colorizeoptions.[mcra "Show c&ontinued lines"]) -state normal
    } else {
        # language scheme is xml or modelica or none
        # disable "Load into scilab" entries
        $pad.filemenu.exec entryconfigure $MenuEntryId($pad.filemenu.exec.[mcra "&Load into Scilab"]) -state disabled
        $pad.filemenu.exec entryconfigure $MenuEntryId($pad.filemenu.exec.[mcra "Load into Scilab (to &cursor)"]) -state disabled
        $pad.filemenu.exec entryconfigure $MenuEntryId($pad.filemenu.exec.[mcra "Load &all into Scilab"]) -state disabled
        # remove bindings
        binddisable $pad execfile
        bind $pad <F5> {}
        # disable all the Debug menues entries
        for {set i 1} {$i<=[$dm index last]} {incr i} {
            if {[$dm type $i] == "command" || [$dm type $i] == "cascade"} {
                $dm entryconfigure $i -state disabled
            }
        }
        for {set i 1} {$i<=[$dms index last]} {incr i} {
            if {[$dms type $i] == "command" || [$dms type $i] == "cascade"} {
                $dms entryconfigure $i -state disabled
            }
        }
        # remove debugger bindings
        pbind all $Shift_F9 {}
        bind all <F9> {}
        bind all <Control-F9> {}
        bind all <F10> {}
        bind all <Control-F11> {}
        bind all <F11> {}
        pbind all $Shift_F11 {}
        pbind all $Shift_F8 {}
        bind all <F8> {}
        bind all <Control-F8> {}
        pbind all $Shift_F12 {}
        bind all <F12> {}
        bind all <Control-F12> {}
        # disable watch window icons
        if {[istoplevelopen watch]} {
            set wi $watchwinicons
            set wis $watchwinstepicons
            [lindex $wi $MenuEntryId($dm.[mcra "&Edit breakpoints"])] configure -state disabled
            [lindex $wi $MenuEntryId($dm.[mcra "&Configure execution..."])] configure -state disabled
            [lindex $wi $MenuEntryId($dm.[mcra "Go to next b&reakpoint"])] configure -state disabled
            [lindex $wis $MenuEntryId($dms.[mcra "Step &into"])] configure -state disabled
            [lindex $wis $MenuEntryId($dms.[mcra "Step o&ver"])] configure -state disabled
            [lindex $wis $MenuEntryId($dms.[mcra "Step &out"])] configure -state disabled
            [lindex $wi $MenuEntryId($dm.[mcra "Run to re&turn point"])] configure -state disabled
            [lindex $wi $MenuEntryId($dm.[mcra "Run to c&ursor"])] configure -state disabled
            [lindex $wi $MenuEntryId($dm.[mcra "G&o on ignoring any breakpoint"])] configure -state disabled
            [lindex $wi $MenuEntryId($dm.[mcra "&Break"])] configure -state disabled
            [lindex $wi $MenuEntryId($dm.[mcra "Cance&l debug"])] configure -state disabled
        }
        # disable "create help skeleton" and "help from sci"
        $pad.filemenu.files entryconfigure $MenuEntryId($pad.filemenu.files.[mcra "Create help s&keleton..."]) -state disabled
        $pad.filemenu.files entryconfigure $MenuEntryId($pad.filemenu.files.[mcra "Create help from hea&d comments..."]) -state disabled
        # disable "Show continued lines"
        $pad.filemenu.options.colorizeoptions entryconfigure $MenuEntryId($pad.filemenu.options.colorizeoptions.[mcra "Show c&ontinued lines"]) -state disabled
    }
    if {$listoffile("$textarea",language) eq "xml"} {
        $pad.filemenu.files entryconfigure $MenuEntryId($pad.filemenu.files.[mcra "Compile as &help page"]) -state normal
    } else {
        $pad.filemenu.files entryconfigure $MenuEntryId($pad.filemenu.files.[mcra "Compile as &help page"]) -state disabled
    }
    # nothing special to set if {$listoffile("$textarea",language) eq "modelica"}
}

proc refreshQuotedStrings {} {
    global listoftextarea
    showinfo [mc "Wait seconds while recolorizing file"]
    foreach w [filteroutpeers $listoftextarea] {
        $w tag remove rem2 1.0 end
        $w tag remove textquoted 1.0 end
        backgroundcolorize $w
    }
}

proc getstartofcolorization {w ind} {
# return start bound required for proper recolorization
    global listoffile

    switch -- $listoffile("$w",language) {

        scilab {
            if {[iscontinuedline $w "$ind - 1 l"]} {
                set uplimit [getstartofcontline $w "$ind - 1 l"]
            } else {
                set uplimit [$w index "$ind linestart"]
            }
        }

        xml {
            set prevdelimiterpos [$w search -backwards -- {<} $ind 1.0]
            if {$prevdelimiterpos != ""} {
                set uplimit [$w index $prevdelimiterpos]
            } else {
                set uplimit [$w index "$ind linestart"]
            }
        }

        modelica {
            # colorization of Modelica strings can only be done
            # when considering the entire buffer because they
            # can be multiline
            # proc docolorizeModelicastrings does it in the background
            # therefore here one needs to consider no more than the current line
            set uplimit [$w index "$ind linestart"]
        }

        default {
            set uplimit [$w index "$ind linestart"]
        }

    }

    return $uplimit
}

proc getendofcolorization {w ind} {
# return end bound required for proper recolorization
    global listoffile

    switch -- $listoffile("$w",language) {

        scilab {
            if {[iscontinuedline $w "$ind + 1 l"]} {
                set dnlimit [getendofcontline $w "$ind + 1 l"]
            } else {
                set dnlimit [$w index "$ind + 1 l lineend"]
            }
        }

        xml {
            set nextdelimiterpos [$w search -- {>} "$ind - 1 c" end]
            if {$nextdelimiterpos != ""} {
                set dnlimit [$w index "$nextdelimiterpos + 1 c"]
            } else {
                set dnlimit [$w index "$ind lineend"]
            }
        }

        modelica {
            # colorization of Modelica strings can only be done
            # when considering the entire buffer because they
            # can be multiline
            # proc docolorizeModelicastrings does it in the background
            # therefore here one needs to consider no more than the current line
            set dnlimit [$w index "$ind lineend"]
        }

        default {
            set dnlimit [$w index "$ind + 1 l lineend"]
        }

    }

    return $dnlimit
}

proc tagModelicaannotationsinallbuffers {} {
    global listoftextarea
    global modifiedlinemargin linenumbersmargin
    foreach w [filteroutpeers $listoftextarea] {
        tagModelicaannotations $w
        # updatelinenumbersmargin needed to refresh the line numbers
        # in the margin when the text is shorter than the
        # space in the Scipad window (when it's longer a scroll is
        # triggered which in turn launches updatelinenumbersmargin
        if {[isdisplayed $w]} {
            if {$linenumbersmargin ne "hide"} {
                updatelinenumbersmargin $w
            }
            if {$modifiedlinemargin ne "hide"} {
                updatemodifiedlinemargin $w
            }
        }
    }
}

proc tagModelicaannotations {w} {
# detect and tag Modelica annotations in the entire textarea $w
# the content of the parenthesis is tagged, including the parenthesis themselves
# however only what is inside the parenthesis, and not the parenthesis themselves,
# is tagged for possible elision
# this proc also takes care of the visual appearance of Modelica annotations
#
# notes about performance:
#   This proc uses getindofsymbol2, while tagcontlines, which is performing a
#   similar task, uses a regexp constructed so that a certain level of nested
#   constructs can be matched. It is not possible to regexp match arbitrarily
#   nested constructs, and this is the reason why proc getindofsymbol2 is
#   preferred for matching the closing parenthesis of Modelica annotations.
#   Indeed potentially large number of nested parenthesis can be found in
#   Modelica annotations, and it is not believed a complicated regexp built
#   using proc createnestregexp would be efficient
#   <TODO> Check (by time-ing both possibilities) whether the approach here
#          in proc tagModelicaannotations should be applied to tagcontlines
#          or if the existing (regexp-based) proc tagcontlines is more
#          efficient

    global listoffile
    global bgcolors
    foreach c1 $bgcolors {global $c1}
    global hideModelicaannot highlightModelicaannot

    # these two lines must be here because:
    #   - they have to be executed before the return that
    #     triggers when the language scheme is not "modelica"
    #   - they are mandatory to take care (erase) of past
    #     annotations that are no longer annotations due to
    #     the editing action that was just performed (e.g.
    #     insert a space insidde the word "annotation")
    $w tag remove Modelica_annotation              1.0 end
    $w tag remove Modelica_annotation_hideshowpart 1.0 end

    # don't tag anything if the language is not modelica
    if {$listoffile("$w",language) ne "modelica"} {
        return
    }

    # return early if annotations do not need to be detected
    # this saves a lot of performance when dealing with huge files
    if {!$hideModelicaannot && !$highlightModelicaannot} {
        $w tag configure Modelica_annotation_hideshowpart -elide false
        $w tag configure Modelica_annotation -background {}
        return
    }

    # look for the string "annotation" followed by optional blanks followed by an opening parenthesis
    $w tag remove Modelica_annotation 1.0 end
    set ind "1.0"
    set previ 0
    set annot [regexp -all -inline -line -indices -- {annotation[[:blank:]]*\(} [$w get "1.0" end]]
    foreach fullmatch $annot {
        foreach {i j} $fullmatch {}
        set mi [$w index "$ind + [expr {$i - $previ}] c"]
        set tagshere [$w tag names $mi]
        # the match must not be in a string nor in a comment
        if {[lsearch $tagshere Modelica_string] != -1} {
            continue
        }
        if {[lsearch $tagshere Modelica_comment] != -1} {
            continue
        }
        set mj [$w index "$mi + [expr {$j - $i}] c"]
        # $mj now has the index of the opening parenthesis after the "annotation" keyword
        set sta $mj
        # warning: getindofsymbol2 ... true  needs colorization results !
        set sto [getindofsymbol2 $w $mj "-forwards" {[()]} "\)" true]
        if {$sto ne ""} {
            # the annotation is complete (there is a closing parenthesis)
            $w tag add Modelica_annotation               $sta        "$sto + 1 c"
            $w tag add Modelica_annotation_hideshowpart "$sta + 1 c"  $sto
        }
        set ind $mi
        set previ $i
    }

    if {$hideModelicaannot} {
        $w tag configure Modelica_annotation_hideshowpart -elide true
    } else {
        $w tag configure Modelica_annotation_hideshowpart -elide false
    }
    if {$highlightModelicaannot} {
        $w tag configure Modelica_annotation -background $MODELICAANNOTATIONCOLOR
    } else {
        $w tag configure Modelica_annotation -background {}
    }
    $w tag lower Modelica_annotation
    $w tag lower Modelica_annotation_hideshowpart
}
