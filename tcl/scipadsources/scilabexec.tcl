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

proc execfile_tocursor {} {
# launch execfile for the current buffer, but only the text before the
# insert cursor is taken into account

    set curta [gettextareacur]

    # copy the relevant text part to a temporary textarea
    # it must be a textarea, not just a text widget because
    # the listoffile array is used by execfile on it later
    set tempta [createnewemptytextarea]
    $tempta insert 1.0 [$curta get 1.0 insert]

    # exec it (the file is never displayed)
    execfile $tempta

    # forget about the temporary thing whatever the result
    # of execfile is (error messages and so on are dealt with
    # directly in proc execfile), don't ask for saving
    closelistofta $tempta {}
}

proc execallfiles {} {
# launch execfile for all opened, colorized, Scilab scheme, buffers
# but ask for confirmation for files having level zero code
    global listoffile listoftextarea pad

    # order of execution is the order in $listoftextarea,
    # i.e. it is always the file opening order, regardless
    # of $windowsmenusorting
 
    # filter out any file not having Scilab scheme or not colorized
    set tatoexec [list ]
    foreach ta [filteroutpeers $listoftextarea] {
        if {$listoffile("$ta",language) eq "scilab" && $listoffile("$ta",colorize)} {
            lappend tatoexec $ta
        }
    }
 
    foreach ta $tatoexec {
        foreach {hasunsupcode unsupstatements} [buffercontainsunsupportedstatements $ta] {}
        if {$hasunsupcode} {
        set answ [tk_messageBox -icon warning -type ok -parent $pad \
            -title [concat [mc "Unsupported code found"] : [file tail $listoffile("$ta",fullname)]] \
            -message [concat \
                      [mc "File contains unsupported instructions"] \
                      ($unsupstatements). \
                      [mc "This cannot be executed from Scipad.\nYou should comment or remove these instructions.\nFor more details please see ticket #12 at Scipad website."] ] ]
        return
        }
    }

    set execthisbuffer [list ] 
    foreach ta $tatoexec {
        if {[bufferhaslevelzerocode $ta]} {
            # Mixed .sce/.sci
            showtext $ta
            set answ [tk_messageBox -icon question -type yesno -parent $pad \
                    -title [concat [mc "Main level code found"] : [file tail $listoffile("$ta",fullname)]] \
                    -message [mc "File contains main level code.\nLoad into Scilab anyway?"] ]
            switch -- $answ {
                yes {lappend execthisbuffer true }
                no  {lappend execthisbuffer false}
            }
        } else {
            # Pure .sci file (or endfunction missing, see proc bufferhaslevelzerocode)
            lappend execthisbuffer true
        }
    }

    foreach ta $tatoexec execthis $execthisbuffer {
        if {!$execthis} {
            continue
        }
        set execresult [execfile $ta false]
        # ignore case of exec'ing an empty file
        if {$execresult == 3} {
            set execresult 0
        }
        # $execresult == 4 can't happen since this case is tested above
        # before starting exec'ing the buffers
        # do not exec remaining files if there was a problem
        if {$execresult != 0} {
            break
        }
    }
}

proc execfile {{buf "current"} {getpath false}} {
# exec a buffer into Scilab
# if the buffer is modified (not saved), then an attempt is made to save it
# in a temporary location. After exec-ing it, the temp file is deleted only
# if getpath is false (otherwise the returned pathname would be immediately
# obsolete)
# the return value usually is:
#     0 = success
#     1 = scilab busy - exec was not performed
#     2 = user selected no when asked for overwriting (if silent save fails,
#         the user is asked about overwriting the original file on disk) - exec
#         was not performed
#     3 = attempt to exec an empty file - exec was not performed
#     4 = attempt to exec a file containing "pause" or "abort"
#    -1 = exec instruction failed in Scilab - exec was not performed
# however, if getpath is true, then the return value in case of success only
# is a list:
#     {0 0 $fullfilepath}  = success, the buffer has NOT been temporarily saved,
#                            and $fullfilepath is $listoffile("$textarea",fullname)
#     {0 1 $fullfilepath}  = success, the buffer has been temporarily saved,
#                            $fullfilepath is the filepath where the buffer has
#                            been temporarily saved
# Warning: the temporary file is left over on disk in the latter case, it should
# be deleted by the caller

    global listoffile pad
    global tmpdir

    if {$buf == "current"} {
        set textarea [gettextareacur]
    } else {
        set textarea $buf
    }

    if {[$textarea index end-1c] == 1.0} {
        showinfo [mc "No point in loading an empty file!"]
        set outval 3
        return $outval
    }

    foreach {hasunsupcode unsupstatements} [buffercontainsunsupportedstatements $textarea] {}

    if {$hasunsupcode} {
        set answ [tk_messageBox -icon warning -type ok -parent $pad \
            -title [concat [mc "Unsupported code found"] : [file tail $listoffile("$textarea",fullname)]] \
            -message [concat \
                      [mc "File contains unsupported instructions"] \
                      ($unsupstatements). \
                      [mc "This cannot be executed from Scipad.\nYou should comment or remove these instructions.\nFor more details please see ticket #12 at Scipad website."] ] ]
        set outval 4
        return $outval
    }

    if {[isscilabbusy 1 $listoffile("$textarea",fullname)]} {return 1}

    set savedintempdir false

    if {[ismodified $textarea]} {
        # try to save the file in a temporary directory
        set nametosave [file join $tmpdir [file tail $listoffile("$textarea",fullname)]]
        if {[catch {writefileondisk $textarea $nametosave 1 1}] != 0} {
            set answer [tk_messageBox -title [mc "Silent file save failed"] \
                    -icon question -type yesno -parent $pad \
                    -message [mc "File could not be saved in a temporary location.\nOverwrite original file?"] ]
            switch -- $answer {
                yes { filetosave $textarea; set f $listoffile("$textarea",fullname); set doexec 1 }
                no  { set outval 2 ; return $outval }
            }
        } else {
            set f $nametosave
            set doexec 1
            set savedintempdir true
        }
    } else {
        # file is not modified wrt to its version on disk - use this version on disk
        set f $listoffile("$textarea",fullname)
        set doexec 1
    }
    set esc_f [escapequotes $f]
    if $doexec {
        if {[catch {ScilabEval_lt "exec(\"$esc_f\");" "sync" "seq"}]} {
            scilaberror $listoffile("$textarea",fullname)
            set outval -1
        } else {
            showinfo [mc "Exec done"]
            set outval 0
        }
    }

    if {$savedintempdir && !$getpath} {
        ScilabEval_lt "mdelete(\"$esc_f\");" "seq"
    }

    # this is in case a script modifies a file opened in Scipad
    checkifanythingchangedondisk $pad

    if {$outval == 0 && $getpath} {
        if {!$savedintempdir} {
            return [list $outval 0 $f]
        } else {
            return [list $outval 1 $f]
        }
    } else {
        return $outval
    }
}

proc execselection {} {
# run the Scipad selection in Scilab
# note: block selection is supported

    global pad listoffile

    # execselection cannot be executed since it needs the colorization results
    if {[colorizationinprogress]} {
        return
    }

    # abort if Scilab is busy
    if {[isscilabbusy 2]} {
        return
    }

    set textareacur [gettextareacur]

    # abort if the language scheme is whatever but "scilab"
    # (justification: comments (as meant by the Scilab syntax) will be trimmed down below)
    if {$listoffile("$textareacur",language) ne "scilab"} {
        return
    }

    set selindices [gettaselind $textareacur any]

    if {$selindices ne ""} {

        # ScilabEval does not digest multilines directly, they have to be
        # concatenated first.
        # Comments could in principle be passed to ScilabEval, but
        # since multilines are joined in a single line we have to strip
        # comments off
        set comm [trimcontandcomments_usetaginfo $textareacur $selindices]

        # echo the command in the Scilab shell
        regsub -all -line {"} $comm     {""} dispcomm
        regsub -all -line {'} $dispcomm {''} dispcomm1
        # The following test is to cope with string length limits in C language using %s
        # The hardwired limit in character length is 509-13 since (quote from the MSDN
        # Library - Oct 2001):
        # ANSI compatibility requires a compiler to accept up to 509 characters in a string
        # literal after concatenation. The maximum length of a string literal allowed in
        # Microsoft C is approximately 2,048 bytes.
        # (end of quote)
        # Because I don't know the limit for other compilers, I keep 509 as the maximum
        # above which the string is not displayed. Anyway, more than this is very hard
        # to read in the Scilab shell.
        if {[string length $dispcomm1] < 496} {
            ScilabEval_lt "mprintf(\"%s\\n\",\"$dispcomm1\")" seq
        }

        ScilabEval_lt $comm seq

        # this is in case the evaluated script modifies a file opened in Scipad
        checkifanythingchangedondisk $pad
    }
}

proc execstring {str} {
# exec $str in Scilab
# return values: same as proc execfile

    global tmpdir defaultencoding

    # create a temporary file, put everything in there, and exec it
    # this part is catched to take into account possible access
    # (permissions) errors
    if {[catch {
        set fname [file join $tmpdir "Scipad_execfile_bp_tempfile.sci"]
        set fid [open $fname w]
        fconfigure $fid -encoding $defaultencoding
        puts $fid $str
        close $fid
        ScilabEval_lt "exec(\"$fname\");" "sync" "seq"
        set execresult 0
    }] != 0} {
        # if the temporary file solution did not work, let's create a
        # temporary regular buffer and exec it!
        set saved_ta [gettextareacur]
        filesetasnew
        [gettextareacur] insert 1.0 $str
        set execresult [execfile "current"]
        closecurta "NoSaveQuestion"
        showtext $saved_ta
    }
    return $execresult
}

proc execallnonlevelzerocode {} {
# exec all non level zero code from all buffers
# special case: if there is no non level zero code, then the exec
# is considered successful (return code is 0)
    set allfuntexts [getallnonlevelzerocode]
    # catch the case of exec'ing an empty file
    if {$allfuntexts != ""} {
        set execresult [execstring $allfuntexts]
    } else {
        set execresult 0
    }
    return $execresult
}

proc importmatlab {} {
    global pad listoffile
    global tileprocalreadyrunning
    global bug2672_shows_up Tk85
    global preselectedfilterinimportmatlabbox

    if {$tileprocalreadyrunning} {return}

    if {[isscilabbusy 3]} {return}

    set matfiles [mc "Matlab files"]
    set allfiles [mc "All files"]
    set types [concat "{\"$matfiles\"" "{*.m}}" \
                      "{\"$allfiles\"" "{* *.*}}" ]
    set dtitle [mc "Matlab file to convert"]
    if {$Tk85} {
        # make use of TIP242 (-typevariable option)
        # note that $bug2672_shows_up is necessarily false (see
        # definition of bug2672_shows_up)
        set sourcefile [tk_getOpenFile -filetypes $types -parent $pad -title "$dtitle" \
                                       -typevariable preselectedfilterinimportmatlabbox]
    } else {
        if {$bug2672_shows_up} {
            set sourcefile [tk_getOpenFile -filetypes $types -title "$dtitle"]
        } else {
            set sourcefile [tk_getOpenFile -filetypes $types -parent $pad -title "$dtitle"]
        }
    }
    if {$sourcefile !=""} {
        set sourcedir [file dirname $sourcefile]
        set destfile [file rootname $sourcefile].sci
        set convcomm "execstr(\"res=mfile2sci(\"\"$sourcefile\"\",\
                      \"\"$sourcedir\"\",%f,%f,1,%t)\",\"errcatch\",\"m\")"
        set impcomm \
            "if $convcomm==0 then \
               TCL_EvalStr(\"delinfo; openfile \"\"$destfile\"\"\",\"scipad\"); \
             else; \
               TCL_EvalStr(\"failmatlabimp\",\"scipad\");\
             end"
        showinfo [mc "Scilab is converting, please hold on..." ]
        ScilabEval_lt $impcomm "sync" "seq"
    }
}

proc failmatlabimp {} {
    global ScilabBugzillaURL pad
    tk_messageBox -title [mc "Matlab file import"]  \
      -message [concat [mc "Conversion of the file failed, see the Scilab window\
                    for details -- Perhaps report the error text and the\
                    offending Matlab file to"] \
                    $ScilabBugzillaURL] \
      -icon error -parent $pad
}

proc createhelpfile {whatkind} {
    # first exec the file in scilab, so that the current function is
    # really defined; then call help_skeleton or help_from_sci (based
    # on $whatkind, and pipe the result to a new (unsaved) buffer.
    # NB: execing the file can have far-reaching consequences
    # if the file does more than just defining functions.
    # Responsibility left to the user.

    global listoffile
    global tileprocalreadyrunning

    if {$tileprocalreadyrunning} {return}

    if {[isscilabbusy 0]} {return}

    set indexin [[gettextareacur] index insert]
    scan $indexin "%d.%d" ypos xpos
    set infun [whichfun $indexin [gettextareacur]]
    set funname [lindex $infun 0]

    set execresult [execfile "current" true]
    if {[lindex $execresult 0] == 0} {
        set pathprompt [mc "Please select destination path for the xml source of the help file" ]
        set dir [tk_chooseDirectory -title $pathprompt]
        if {$dir != ""} {
            set wastemporarysaved [lindex $execresult 1]
            set savedfunname [lindex $execresult 2]
            set xmlfile [file join $dir $funname.xml]
            set warntitle [concat [mc "Older version of"] $xmlfile [mc "found!"] ]
            set warnquest [concat [mc "An old version of"] $xmlfile [mc "already exists: open the old file instead?"] ]
            set warnold [mc "Existing file" ]
            set warnnew [mc "New skeleton"]
            if [file exists $xmlfile] {
                set answer [tk_dialog .existxml $warntitle $warnquest \
                      questhead 0 $warnold $warnnew]
            } else {
                set answer 1
            }
            if $answer {
                if {$whatkind == "skeleton"} {
                    ScilabEval_lt "help_skeleton(\"$funname\",\"$dir\")" "sync"
                } else {
                    # $whatkind == "fromsci"
                    # escape quotes in filename - should be useless
                    # anyway, the help_from_sci feature is used to create help files from
                    # Scilab functions which names cannot contain ' or " (see help names)
                    # this is therefore just to avoid an ugly error in case someone tries
                    set esc_savedfunname [escapequotes $savedfunname]
                    ScilabEval_lt "help_from_sci(\"$esc_savedfunname\",\"$dir\")" "sync"
                    # delete the leftover temporary file created in proc execfile
                    # with getpath being true
                    if {$wastemporarysaved} {
                        catch {file delete -- $savedfunname}
                    }
                }
            }
            openfile $xmlfile
        }
    }
}

proc xmlhelpfile {} {
# save the file and call xmlfiletohtml (in Scilab 4 or Scicoslab),
# or do nothing (in Scilab 5) because of bug 3015 and because
# xmlfiletohtml was removed from Scilab 5 on 29 August 2011
# (this is bug 3431)

    global listoffile
    global Scilab5

    if {[isscilabbusy 4]} {return}

    if {$Scilab5} {
        pleaseuseabetterscilabversion 3015

    } else {
        filetosavecur
        set filetocomp $listoffile("[gettextareacur]",fullname)
        set filename [file tail    $filetocomp]
        set filepath [file dirname $filetocomp]
        set cwd [pwd]
        cd $filepath
        set esc_filename [escapequotes $filename]
        ScilabEval_lt "xmlfiletohtml(\"$esc_filename\")" sync
        cd $cwd
    }
}

proc ScilabEval_lt {comm {opt1 ""} {opt2 ""}} {
# ScilabEval with length test
# This is needed because ScilabEval cannot accept commands longer than bsiz
# (they are truncated by Scilab). Workaround: Long commands shall be saved
# into a file that is exec'ed by ScilabEval.
# This proc checks first the length of the command passed to ScilabEval.
# - If this length is smaller than bsiz-1, pass the command to ScilabEval for
# execution.
# - If this length is greater than bsiz-1 but smaller than lsiz-1, save the
# command in a file and do a ScilabEval exec("the_file"). If this fails
# (wrong permission rights...) then warn the user that something really weird
# might happen since there is no way to pass the command to Scilab.
# - If this length is greater than lsiz-1, warn the user that the command
# cannot be passed to Scilab

    # this global solves bugs 1848 and 1853 even if sciprompt is not used in proc ScilabEval_lt
    global sciprompt

    global tmpdir
    global pad
    global defaultencoding

    set bsiz_1  4095   ;# Must be consistent with bsiz defined in stack.h
    set lsiz_1 65535   ;# Must be consistent with lsiz defined in stack.h
    set commlength [string length $comm]
    if {$commlength <= $bsiz_1} {
        # No problem to process this
        ScilabEval $comm $opt1 $opt2
    } elseif {$commlength <= $lsiz_1} {
        # Command is too long for a direct ScilabEval but can be passed through an exec'ed file
        # Create a file in tmpdir, and save the command in it.
        # Large (>$splitsize) commands are split into smaller parts, and trailing dots
        # are added.
        # This part is catched to take into account possible access (permissions) errors
        if {[catch {
            set fname [file join $tmpdir "ScilabEval_command.sce"]
            set splitsize 4000 ;# arbitrary but works up to approx. 4095
            set nbparts [expr {[string length $comm] / $splitsize + 1}]
            set fid [open $fname w]
            fconfigure $fid -encoding $defaultencoding
            set startpos 0
            for {set i 1} {$i < $nbparts} {incr i} {
                set stoppos  [expr {$i * $splitsize - 1}]
                # Warning: the string must not be split (.. added) just after a dot!
                # Here possible endless loop if $comm contains only dots, but why would this happen?
                while {[string index $comm $stoppos] == "."} {incr stoppos}
                puts $fid "[string range $comm $startpos $stoppos].."
                set startpos [incr stoppos]
            }
            puts $fid [string range $comm $stoppos end]
            close $fid
            ScilabEval "exec(\"$fname\");" $opt1 $opt2
        }] != 0} {
            tk_messageBox  -title [mc "ScilabEval command cannot be passed to Scilab!"] -icon warning -type ok \
                           -message [concat [mc impossibleScilabEval_message] "ScilabEval" $comm $opt1 $opt2] \
                           -parent $pad
        }
    } else {
        # Command is definitely too long to be passed to Scilab, even if exec'ed in a file
        # If the command was nevertheless sent, it would trigger error 108
        # Even tk_messageBox does not accept too large -message content
        set comm [concat "[string range $comm 0 4000]..." [mc "(end of command skipped)"] ]
        tk_messageBox  -title [mc "ScilabEval command cannot be passed to Scilab!"] -icon warning -type ok \
                       -message [concat [mc impossibleScilabEval_message2] "ScilabEval" $comm $opt1 $opt2] \
                       -parent $pad
    }
}

proc cleantmpScilabEvalfile {} {
# Try to remove the possibly existing files in tmpdir
# created by ScilabEval_lt
    global tmpdir
    catch {file delete [file join $tmpdir "ScilabEval_command.sce"]}
}

proc isscilabbusy {{messagenumber "nomessage"} args} {
# check if Scilab is busy or not
# return true if busy, and false if idle
# $messagenumber, if present, gives a message id to display in a message box
# additional arguments may be passed to customize the message
# if $messagenumber is not given, then no message will be displayed and the
# test on Scilab idleness is silent
    global sciprompt
    global pad
    if {[string compare $sciprompt -1] == 0} {
        if {$messagenumber == "nomessage"} {
            return true
        }
        switch -exact -- $messagenumber {
            0 { set mes \
                [mc "Scilab is working, please wait for the prompt to execute this command!"]
              }
            1 { set mes [concat \
                [mc "Scilab is working, wait for the prompt to load file"] \
                 [lindex $args 0] ]
              }
            2 { set mes \
                [mc "Scilab is working, wait for the prompt to execute the selection."]
              }
            3 { set mes \
                [mc "Scilab is working, wait for the prompt to convert a Matlab file."]
              }
            4 { set mes \
                [mc "Scilab is working, wait for the prompt to compile the help file."]
              }
            5 { set mes \
                [mc "Scilab is working, wait for the prompt to issue a debugger command."]
              }
            default { set mes \
                "Unexpected message number in proc isscilabbusy - Please report."
            }
        }
        tk_messageBox -message $mes -title [mc "Scilab working"] -type ok -icon info -parent $pad
        return true
    } else {
        return false
    }
}

proc scilaberror {funnameargs} {
# display the last Scilab error message and associated information
# note on $errline: $errline is physical or logical (as returned by
#                   lasterror()) depending on the underlying Scilab environment
#                   this difference is handled in proc blinkline

    global ScilabErrorMessageBox
    global errnum errline errmsg errfunc
    global Scilab5
    global pad
    if {$ScilabErrorMessageBox} {
        # Communication between Scipad and Scilab through the
        # Tcl global interp is not supported by Scilab 5 (but still in Scilab 4 and Scicoslab)
        # See http://wiki.scilab.org/Tcl_Thread
        if {$Scilab5} {
            # Let Scilab display the message so that there is no more locking process
            # for communication between Tcl and Scilab.
            # Lasterror outputs are already known in scilab, let's use them.
            #
            # We need to escape ' in scilab strings using ''
            # Used after Scipad Localisation => string map {' ''}
            #
            ScilabEval_lt "\[db_str,db_n,db_l,db_func\]=lasterror();" "sync" "seq"
            set shellError [string map {' ''} [concat [mc "The shell reported an error while trying to execute "] $funnameargs [mc ": error "]]]
            set lineError [string map {' ''} [mc "at line "]]
            set funcError [string map {' ''} [mc " of "]]
            set dialogtitle [string map {' ''} [mc "Scilab execution error"]]
            ScilabEval_lt "messagebox(\[\"$shellError\"+msprintf(\" %d\",db_n); \
                                        db_str; \
                                        \"$lineError\"+msprintf(\" %d\",db_l)+\"$funcError\"+db_func\], \"$dialogtitle\", \"error\", \"modal\" )" \
                          "sync" "seq"
            # warning: seq only here, because sync seq would be a deadlock
            ScilabEval_lt  "TCL_EvalStr(\"blinkline \"+msprintf(\"%d\",db_l)+\" \"+strsubst(db_func,\"\"\"\",\"\\\"\"\"),\"scipad\")" "seq"
        } else {
            ScilabEval_lt "\[db_str,db_n,db_l,db_func\]=lasterror();" "sync" "seq"
            ScilabEval_lt  "TCL_SetVar(\"errnum\", msprintf(\" %d\",db_n), \"scipad\");" "sync" "seq"
            ScilabEval_lt  "TCL_SetVar(\"errline\", msprintf(\" %d\",db_l), \"scipad\");" "sync" "seq"
            ScilabEval_lt  "TCL_SetVar(\"errfunc\", strsubst(db_func,\"\"\"\",\"\\\"\"\"), \"scipad\")" "sync" "seq"
            ScilabEval_lt  "TCL_SetVar(\"errmsg\" , strsubst( \
                                             strsubst( \
                                             strsubst( \
                                             strsubst( \
                                             strsubst( \
                                                        strcat(stripblanks(db_str),ascii(13)) \
                                                              ,\"\"\"\",\"\\\"\"\") \
                                                              ,\"''\",\"\\''\") \
                                                              ,\"$\",\"\\$\") \
                                                              ,\"\[\",\"\\\[\") \
                                                              ,\"\]\",\"\\\]\") \
                                           , \"scipad\" )" "sync" "seq"
            tk_messageBox -title [mc "Scilab execution error"] -parent $pad \
                -message [append dummyvar [mc "The shell reported an error while trying to execute "]\
                              $funnameargs [mc ": error "] $errnum "\n" $errmsg "\n" [mc "at line "]\
                              $errline [mc " of "] $errfunc]
            blinkline $errline $errfunc
        }
    }
    showinfo [mc "Execution aborted!"]
    if {[getdbstate] != "NoDebug"} {
        canceldebug_bp
    }
}

proc blinkline {li ma {nb 3}} {
# Blink $nb times line $li in macro function named $ma
# The macro is supposed to be defined in one of the opened buffers (no
# opening of files occur here)
# The line number $li to blink is taken as being logical when running in
# Scilab-4.1.2, or physical in Scicoslab-4.x (x>=4) and in Scilab 5.
# Warning: This proc is also used from outside of Scipad by edit_error
    global SELCOLOR
    global linenumberstype
    set funtogoto [funnametofunnametafunstart $ma]
    if {$funtogoto != ""} {
        set w [lindex $funtogoto 1]
        if {$linenumberstype eq "logical"} {
            set li [condphyslinetologline $ma $li]
        } else {
            # $linenumberstype eq "logical_ignorecontlines", or "physical"
            # normally there should be nothing to do: physical lines in function (i.e.
            # logical lines ignoring continued lines) are shown (and used by proc
            # dogotoline since it receives "logical" as first argument)
            # BUT one has to take the special case of a continued first logical line
            # into account
            set funstartind [lindex $funtogoto 2]
            set offsetline1continued [getnboftaggedcontlinesmakingfunfirstline $w $funstartind]
            set li [expr {$offsetline1continued + $li}]
        }
        dogotoline "logical" $li "function" $funtogoto
        set i1 [$w index "insert linestart"]
        set i2 [$w index "insert lineend + 1c"]
        for {set i 0} {$i < $nb} {incr i} {
            $w tag add blinkedline $i1 $i2
            $w tag configure blinkedline -background $SELCOLOR
            update idletasks
            after 500
            $w tag remove blinkedline $i1 $i2
            update idletasks
            # do not wait when it's the last blink:
            # control is given back to the caller ASAP
            if {$i < $nb} {
                after 500
            }
        }
    } else {
        # function not found among opened buffers, do nothing
    }
}
