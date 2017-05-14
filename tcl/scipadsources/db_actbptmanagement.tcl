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

proc updateactivebreakpoint { {itemno 3} } {
    set comm1 "\[db_l,db_m\]=where();"
    set comm2 "if size(db_l,1)>=$itemno then"
    # the curly braces around string(db_m($itemno)) below are required
    # to avoid TCL_EvalStr to try to evaluate string(db_m($itemno))
    # this is useful for instance when the function name where the
    # breakpoint stop occurs starts with a dollar sign $
    set comm3 "TCL_EvalStr(\"updateactbreakpointtag \"+msprintf(\"%d\",db_l($itemno))+\" {\"+string(db_m($itemno))+\"} \",\"scipad\");"
    set comm4 "else"
    set comm5 "TCL_EvalStr(\"updateactbreakpointtag 0 \"\"\"\" \",\"scipad\");"
    set comm6 "end;"
    set fullcomm [concat $comm1 $comm2 $comm3 $comm4 $comm5 $comm6]
    ScilabEval_lt "$fullcomm" "seq"
}

proc updateactbreakpointtag {{activeline -1} {activemacro -1}} {
# Show the active breakpoint
# This is done by using proc dogotoline

    # uabpt_opened is used to prevent more than one recursive call
    global backgroundtasksallowed
    global uabpt_opened_a_file       ; # used only in this proc, to differentiate between the possible two successive executions
    global afilewasopenedbyuabpt     ; # used indirectly in proc checkendofdebug_bp
    global Scilab5 Scicoslab
    global curbptta curbptpos
    global linenumberstype

    removeallactive_bp

    if {$activemacro == ""} {return}

    # during the debug, funnametofunnametafunstart cannot return
    # the wrong function, there can be no duplicates
    set funtogoto [funnametofunnametafunstart $activemacro]

    if {$funtogoto == ""} {
        # check if $activemacro is the first $maxcharinascilabname characters
        # of a function defined in one of the opened buffers and if so, highlight
        # the breakpoint in that function and don't try to open the macro from a
        # libfun in this case
        set funnamefromtruncatedmaxcharinascilabname [getfulllengthnamefromfunnamemaxcharinascilabname $activemacro]
        if {[lindex $funnamefromtruncatedmaxcharinascilabname 0]} {
            updateactbreakpointtag $activeline [lindex $funnamefromtruncatedmaxcharinascilabname 1]
        } else {
            if {!$uabpt_opened_a_file} {
                # in principle the breakpoint to highlight is in a libfun
                # ancillary (can happen while stepping into)
                # open the adequate file first (no background colorization,
                # so that colorization is finished when calling dogotoline
                # in the next call to updateactbreakpointtag)
                # and try again to update the activebreakpoint tag
                # note: this must be done the way below because it makes use
                # of the queueing ScilabEval "seq" instructions
                set afilewasopenedbyuabpt true
                set uabpt_opened_a_file true
                set backgroundtasksallowed false
                doopenfunsource "libfun" $activemacro
                set comm1 "TCL_EvalStr(\"updateactbreakpointtag $activeline $activemacro;\",\"scipad\");"
                set comm2 "TCL_EvalStr(\"set backgroundtasksallowed true\",\"scipad\");"
                set fullcomm [concat $comm1 $comm2]
                ScilabEval_lt "$fullcomm" "seq"
            } else {
                # the function where the breakpoint has to be highlighted
                # could still not be found after trying to open it (it is
                # perhaps not a libfun after all) - should never happen,
                # but in any case do nothing
                tk_messageBox -message "The active breakpoint to highlight ($activemacro,$activeline) could not be found. \
                                        This should never happen, please report!"
            }
        }
    } else {
        # the function where the breakpoint has to be highlighted has
        # been found among the opened buffers, either because it was
        # already open or because the previous call to this proc
        # performed the opening
        set uabpt_opened_a_file false

        set ta [lindex $funtogoto 1]
        set funstartind [lindex $funtogoto 2]
        set offsetline1continued [getnboftaggedcontlinesmakingfunfirstline $ta $funstartind]
        if {$Scilab5 || $Scicoslab} {
            # the index where skipline must check is the position of the physical
            # line (in function) where the debug has stopped (whereas the active
            # breakpoint and the insert cursor will be positioned on the first
            # physical line starting the logical line containing the physical
            # line in the function) - see also proc isnocodeorcondcontline
            # also, don't forget the special case of the function first line,
            # which may be a continued line
            set linewhereskiplinechecks [expr {$offsetline1continued + $activeline}]
            set typeoflineforcheck "physical"
        } else {
            # the index where skipline must check is the position of the logical
            # line where the debug has stopped (same as the active breakpoint and
            # the insert cursor position) - proc isnocodeorcondcontline is anyway
            # the same as proc isnocodeline in this Scilab environment
            set linewhereskiplinechecks $activeline
            set typeoflineforcheck "logical"
        }

        # go to the logical line in the function, and tag it as the active breakpoint
        if {$linenumberstype eq "logical"} {
            set activeline [condphyslinetologline $activemacro $activeline]
        } else {
            # $linenumberstype eq "logical_ignorecontlines", or "physical"
            # normally there should be nothing to do: physical lines in function (i.e.
            # logical lines ignoring continued lines) are shown (and used by proc
            # dogotoline since it receives "logical" as first argument)
            # BUT one has to take the special case of a continued first logical line
            # into account
            set activeline [expr {$offsetline1continued + $activeline}]
        }
        dogotoline "logical" $activeline "function" $funtogoto
        set actpos [$ta index insert]
        $ta tag add activebreakpoint "$actpos linestart" "$actpos lineend"

        # place the insert cursor on the physical line in the function
        # warning: guru stuff here!
        # this is compulsory for skipping lines correctly because in proc
        # checkendofdebug_bp the proc isnocodeorcondcontline is called with
        # (escaped) $curbptta and $curbptpos as position to check, which
        # works only because these (when escaped) denote the correct position
        # *at the time isnocodeorcondcontline is called*.
        # This is not so obvious as it seems. It works only because the
        # interlacing of ScilabEval/TCL_EvalStr in proc checkendofdebug_bp
        # make it work. In contrast, calling [isnocodeorcondcontline $curbptta $curbptpos]
        # now (to have a true/false flag instead of having two values) does
        # not work because the flag would be evaluated too early.
        # This can be best understood by reading the output in debug(-1) mode
        dogotoline $typeoflineforcheck $linewhereskiplinechecks "function" $funtogoto
        set curbptta [gettextareacur]
        set curbptpos [$curbptta index insert]
    }
}

proc closecurifopenedbyuabpt {} {
# as it says, this proc closes the current buffer if proc updateactbreakpointtag
# did just open a libfun - this is used in proc checkendofdebug_bp
    global afilewasopenedbyuabpt
    if {$afilewasopenedbyuabpt} {
        closecur
    }
}

proc removeallactive_bp {} {
    global listoftextarea
    foreach textarea [filteroutpeers $listoftextarea] {
        $textarea tag remove activebreakpoint 1.0 end
    }
}
