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

##################################################
# procs for opening buffers from disk
##################################################
proc opensourceof {} {
# open a dialog for selection of the function whose source the user
# wants to open
    global pad menuFont textFont
    global opensoflb opensofbOK
    global Tk85
    global restorelayoutrunning

    if {$restorelayoutrunning} {return}
    if {[isscilabbusy 0]} {return}

    set opensof $pad.opensof
    catch {destroy $opensof}
    toplevel $opensof -class Dialog
    wm transient $opensof $pad
    wm withdraw $opensof
    setscipadicon $opensof
    wm title $opensof [mc "Open source of..."]

    frame $opensof.f1
    label $opensof.f1.l1 -text [mc "Open source of:"] -font $menuFont
    entry $opensof.f1.entry \
        -font $textFont -exportselection 0 \
        -validate key -validatecommand "updatecompletions %P %d"
    pack $opensof.f1.l1 $opensof.f1.entry -side left
    pack configure $opensof.f1.entry -expand 1 -fill x -padx 5
    pack $opensof.f1 -fill x

    frame $opensof.f2
    set opensoflb $opensof.f2.lb
    scrollbar $opensof.f2.sb -command "$opensoflb yview"
    listbox $opensoflb -height 4 -width 10 -font $textFont \
        -yscrollcommand "$opensof.f2.sb set" -takefocus 0
    pack $opensoflb $opensof.f2.sb -side left -padx 2
    pack configure $opensoflb -expand 1 -fill both 
    pack configure $opensof.f2.sb -fill y
    pack $opensof.f2 -expand 1 -fill both

    set opensofbOK $opensof.f3.buttonOK
    frame $opensof.f3
    button $opensofbOK -text "OK" \
            -command "OKopensourceof $opensof" \
            -font $menuFont
    button $opensof.f3.buttonCancel -text [mc "Cancel"] \
            -command "destroy $opensof" \
            -font $menuFont
    grid $opensofbOK              -row 0 -column 0 -sticky we -padx 10
    grid $opensof.f3.buttonCancel -row 0 -column 1 -sticky we -padx 10
    grid columnconfigure $opensof.f3 0 -uniform 1
    grid columnconfigure $opensof.f3 1 -uniform 1
    if {$Tk85} {
        grid anchor $opensof.f3 center
    }
    pack $opensof.f3 -pady 4 -after $opensof.f2 -expand 0 -fill x

    # arrange for the buttons to disappear last
    # when the window size is reduced
    pack configure $opensof.f2 -after $opensof.f3
    pack configure $opensof.f2 -side bottom
    pack configure $opensof.f3 -side bottom
    pack configure $opensof.f1 -after $opensof.f3

    update
    setwingeom $opensof
    wm resizable $opensof 1 1 
    wm minsize $opensof [winfo width $opensof] [winfo height $opensof]
    wm deiconify $opensof

    bind $opensof <Return> {OKopensourceof %W}
    # bind to the listbox only, otherwise quick clicks on the scrollbar
    # triggers a validation of the currently selected item, which is
    # not desirable
    bind $opensof.f2.lb <Double-Button-1> {OKopensourceof %W}
    bind $opensof <Escape> "destroy $opensof"
    bind $opensof <Up>   {scrollarrows_bp $opensoflb up}
    bind $opensof <Down> {scrollarrows_bp $opensoflb down}
    bind $opensof <MouseWheel> {if {%D<0} {scrollarrows_bp $opensoflb down}\
                                          {scrollarrows_bp $opensoflb up}   }
    $opensofbOK configure -state disable
    focus $opensof.f1.entry
}

proc updatecompletions {partialfunnametoopen edittype} {
# update the completions list in the listbox of the "open source of" dialog

    global bgcolors fgcolors
    foreach c1 "$bgcolors $fgcolors" {global $c1}
    global opensoflb opensofbOK

    $opensoflb delete 0 end

    set compl [getcompletions $partialfunnametoopen "scilab"]

    # populate the listbox with the possible completions
    foreach posscompl $compl {
        set tag [lindex $posscompl 0]
        set completedword [lindex $posscompl 1]
        # colorization stuff
        switch -- $tag {
            libfun  {set col $LFUNCOLOR}
            scicos  {set col $SCICCOLOR}
            userfun {set col $USERFUNCOLOR}
            default {}
        }
        if {$tag == "libfun" || $tag == "scicos" || $tag == "userfun"} {
            $opensoflb insert end $completedword
            $opensoflb itemconfigure end \
                    -foreground $col -selectforeground $col\
                    -background $BGCOLOR
            $opensoflb itemconfigure end -selectbackground [shade \
                [$opensoflb itemcget end -selectforeground] \
                [$opensoflb itemcget end -background] 0.5]
        }
    }

    set nbcompl [$opensoflb size]
    if {$nbcompl == 0} {
        # ring the bell only when inserting chars
        if {$edittype == 1} {
            bell
        }
        $opensofbOK configure -state disabled
    } else {
        $opensoflb selection set 0
        $opensoflb see 0
        $opensofbOK configure -state normal
    }

    return 1
}

proc OKopensourceof {w} {
# get the function name to open, and open the corresponding file
    global opensoflb opensofbOK
    if {[$opensofbOK cget -state] ne "disabled"} {
        set nametoopen [$opensoflb get [$opensoflb curselection]]
        set keywtype [gettagfromkeyword $nametoopen]
        doopenfunsource $keywtype $nametoopen
        destroy [winfo toplevel $w]
    } else {
        bell
    }
}

proc openlibfunsource {ind} {
    global textareacur
    if {[isscilabbusy 0]} {return}
    # exit if the cursor is not by a libfun or a scicos or a userfun keyword
    set keywtype ""
    if {[lsearch [$textareacur tag names $ind] "scicos"] !=-1} \
       {set keywtype scicos}
    if {[lsearch [$textareacur tag names $ind] "libfun"] !=-1} \
       {set keywtype libfun}
    if {[lsearch [$textareacur tag names $ind] "userfun"] !=-1} \
       {set keywtype userfun}
    if {$keywtype==""} return
    set lrange [$textareacur tag prevrange $keywtype "$ind+1c"]
    if {$lrange==""} {set lrange [$textareacur tag nextrange $keywtype $ind]}
    set curterm [$textareacur get [lindex $lrange 0] [lindex $lrange 1]]
    if {[info exists curterm]} {
        set curterm [string trim $curterm]
        if {$curterm!=""} {
            doopenfunsource $keywtype $curterm
        }
    }
}

proc doopenfunsource {keywtype nametoopen} {
# do the function source file opening
# $nametoopen is the keyword whose source is to be opened
# $keywtype is its associated tag (must be libfun or scicos
# or userfun to be relevant)
    global words scicosdir blocksdir
    switch $keywtype {
        "libfun" {
            # the simplest thing to do here would have been to
            #   ScilabEval_lt "scipad(get_function_path(\"$nametoopen\"))" "seq"
            # but unfortunately this does not work when used from the debugger
            # call stack area (the shell goes deeper one level and execution is
            # delayed), therefore a more complicated solution here
            set fullcomm "TCL_EvalStr(\"openfile \"\"\"+strsubst(get_function_path(\"$nametoopen\"),\"\\\",\"/\")+\"\"\" currenttile iso8859-1\",\"scipad\");"
            ScilabEval_lt $fullcomm "seq"
        }
        "scicos" {
            set globpat_scicosdir [file join "$scicosdir" $nametoopen.sci]
            set globpat_blocksdir [file join "$blocksdir" "*" $nametoopen.sci]
            set filetoopen [glob $globpat_scicosdir $globpat_blocksdir]
            # for the same reason as above, simply issuing
            #   ScilabEval_lt "scipad(\"$filetoopen\")" "seq"
            # does not always work
            # <TODO>: the line below does not need the ScilabEval(TCL_EvalStr...) construct
            #         because there is no Scilab instruction inside
            #         openfile $filetoopen      should be just enough - to be checked
            ScilabEval_lt "TCL_EvalStr(\"openfile \"\"$filetoopen\"\" currenttile iso8859-1\",\"scipad\");" "seq"
        }
        "userfun" {
            set nameinitial [string range $nametoopen 0 0]
            set candidates $words(scilab.$keywtype.$nameinitial)
            for {set i 0} {$i<[llength $candidates]} {incr i} {
                if {[lindex [lindex $candidates $i] 0] == $nametoopen} {
                    dogotoline "physical" 1 "function" [lindex $candidates $i]
                    break
                }
            }
        }
    }
}

proc guarded_openlistoffiles {filelist tiledisplay needpercentsubstitution} {
# wrapper around openlistoffiles that resets the number of files simultaneously
# being opened to zero after the work is done, and tells the user if the limit
# concerning the max number of files that can be opened at the same time was hit

    global pad nbfilessimultaneouslybeingopened

    set nbfilesnotopen [openlistoffiles $filelist $tiledisplay $needpercentsubstitution]

    set nbfilessimultaneouslybeingopened 0

    if {$nbfilesnotopen > 0} {
        set tit [mc "Too many files"]
        set mes [mc "You asked for too many files to open simultaneously."]
        append mes "\n\n"
        append mes [concat $nbfilesnotopen [mc "files were not opened."]]
        tk_messageBox -message $mes -icon warning -title $tit -parent $pad
    }
}

proc openlistoffiles {filelist tiledisplay needpercentsubstitution} {
# open many files at once - for use with file list provided by TkDnD
# the open dialog is not shown
# in case a directory is given, open all the files in that directory
# $needpercentsubstitution instructs this proc to substitute percent
# sequences in filenames (see bug 2998), which should only be done
# when the filename is provided by TkDnD (and only on Linux), and not
# when the file chooser provided it
# on Windows, $needpercentsubstitution is ignored

    global tcl_platform
    global nbfilessimultaneouslybeingopened maxnbfilessimultaneouslybeingopened

    set nbfilesnotopen 0

    foreach f $filelist {

        regsub "^file:" $f "" f
        # in unix, .* files are not matched by *, but .* matches . and ..
        # If we don't exclude them, we have infinite recursion
        if {[file tail $f] == "." || [file tail $f] == ".."} continue
        # on Linux, TkDnD provides filenames that can contain %xy escape sequences
        # that must be substituted - This is bug 2998, fixed for all platforms
        # I know of but Ubuntu 8.04.x because the latter is affected by Ubuntu bug 320959
        # see  https://bugs.launchpad.net/ubuntu/+bug/320959
        if {$needpercentsubstitution eq "substpercentseq" && $tcl_platform(platform) eq "unix"} {
            set f [substitutepercentescapesequences $f]
        }
        if {[file isfile $f] == 1} {
            if {$nbfilessimultaneouslybeingopened < $maxnbfilessimultaneouslybeingopened} {
                incr nbfilessimultaneouslybeingopened
                openfile $f $tiledisplay
            } else {
                incr nbfilesnotopen
            }
        } elseif {[file isdirectory $f] == 1} {
            incr nbfilesnotopen [openlistoffiles [glob -nocomplain -directory $f -types hidden *] $tiledisplay $needpercentsubstitution]
            incr nbfilesnotopen [openlistoffiles [glob -nocomplain -directory $f -types {f d} *]  $tiledisplay $needpercentsubstitution]
        } else {
            # In windows this never happened to us, but linux applications
            # allow sometimes drag of e.g. http:// or ftp://; moreover
            # spaces in namefiles can produce unexpected results
            tk_messageBox -title [mc "Weird drag&drop"] -message [concat \
                       $f [ mc "is neither a valid filename nor a valid directory.\
                       Either you're dragging an object of another type, or\
                       you hit a bug of the dnd mechanism." ] ]
        }
    }

    return $nbfilesnotopen
}

proc showopenwin {tiledisplay} {
# bring up the open dialog for file selection
# if file is not already open, open it
# otherwise just switch buffers to show it
# the new buffer is displayed in the current tile if
# $tiledisplay == "currenttile", otherwise in a new tile
# created by splitting the current one horizontally
# in which case $tiledisplay == "horizontal", or
# vertically in which case $tiledisplay == "vertical"
    global pad listoffile
    global startdir
    global bug2672_shows_up Tk85
    global preselectedfilterinopensaveboxes
    global restorelayoutrunning tileprocalreadyrunning

    if {$restorelayoutrunning} {return}
    if {$tileprocalreadyrunning} {return}

    showinfo [mc "Open file"]

    # if the current textarea does not have an associated pathname, then
    # remember the latest path used for opening/saving files
    # otherwise use this pathname and preselect the extension to
    # match the one of this pathname
    foreach {curtapath curtaext} [getpathandext [gettextareacur]] {}
    if {$curtapath == {}} {
        if {![info exists startdir]} {set startdir [pwd]}
    } else {
        set startdir $curtapath
        set preselectedfilterinopensaveboxes [extenstoknowntypes $curtaext]
    }

    if {$Tk85} {
        # make use of TIP242 (-typevariable option)
        # note that $bug2672_shows_up is necessarily false (see
        # definition of bug2672_shows_up)
        set file [tk_getOpenFile -filetypes [knowntypes] -parent $pad \
                                 -initialdir $startdir -multiple 1 \
                                 -typevariable preselectedfilterinopensaveboxes]
    } else {
        if {$bug2672_shows_up} {
            set file [tk_getOpenFile -filetypes [knowntypes] \
                                     -initialdir $startdir -multiple 1]
        } else {
            set file [tk_getOpenFile -filetypes [knowntypes] -parent $pad \
                                     -initialdir $startdir -multiple 1]
        }
    }
    if {[llength $file] > 0} {
        set startdir [file dirname [lindex $file 0]]
        guarded_openlistoffiles $file $tiledisplay "DONTsubstpercentseq"
    }
}

proc isfilealreadyopen {file} {
# return true if the file with full name $file is already contained
# in at least one textarea
# return false otherwise
    if {[getlistoftacontainingfile $file] eq {}} {
        return false
    } else {
        return true
    }
}

proc openfileifexists {file} {
# wrapper to openfile, but issues a warning if the file does not exist (anymore).
# if the file is already open:
#   - if the current textarea show it, nothing is done
#   - otherwise action is the same as hitting the entry in the windows menu
    global listoffile pad
    global tileprocalreadyrunning
    if {$tileprocalreadyrunning} {return}
    if {[isfilealreadyopen $file]} {
        if {$listoffile("[gettextareacur]",fullname) eq $file} {
            # nothing to do
        } else {
            set ta [lindex [getlistoftacontainingfile $file] 0]
            set i [extractindexfromlabel $pad.filemenu.wind $listoffile("$ta",displayedname)]
            $pad.filemenu.wind invoke $i
        }
        return 1
    } else {
        if {[file exists $file]} {
             return [openfile $file]
        } else {
             set answer \
                [tk_messageBox -type yesno -icon question -parent $pad \
                 -title [mc "File not found"] -message "[mc "The file"]\
                  $file [mc "does not exist anymore. Do you want to create an\
                  empty file with the same name?"]"]
             switch -- $answer {
               yes {return [openfile $file]}
               no  {return 0}
               }
        }
    }
}

proc openfile {file {tiledisplay "currenttile"} {encodingtouse ""}} {
# try to open a file with filename $file (no file selection through a dialog)
# if file is not already open, open it using encoding $encodingtouse
# otherwise just switch buffers to show it
# return value:
#    0 if file could not be open
#    1 if file could be open or displayed (switched buffers)
    global pad winopened listoftextarea listoffile
    global closeinitialbufferallowed startdir
    global currentencoding

    # hack for bringing up the chooser, if $file is a directory
    # on windows this has to precede the check for readable,
    # because a directory is "unreadable"
    if {[file isdirectory $file]} {
        set startdir $file
        showopenwin currenttile; 
        return
    }

    if {[fileunreadable $file]} {return 0}

    # ignore windows shortcut since nothing is implemented to follow them
    # and to open the target they point to
    if {[fileiswindowsshortcut $file]} {return 0}

    if {[string compare $file ""]} {
        # search for an opened existing file
        set res [lookiffileisopen "$file"]
        if {$res == 0} {
            if {[file exists $file]} {
                if {![fileunreadable $file]} {
                    set fileisbin [fileisbinary $file]
                    notopenedfile $file $fileisbin  ; # increments $winopened
                    set ta $pad.new$winopened
                    set listoffile("$ta",thetime)  [file mtime $file]
                    set listoffile("$ta",disksize) [file size  $file]
                    set listoffile("$ta",new) 0
                    # unless otherwise specified, use the encoding selected in the options/encoding menu
                    # check also that $encodingtouse matches a known encoding, if not (partial install
                    # of Tcl or other reason), switch to the current encoding for opening the file
                    if {$encodingtouse eq "" || [lsearch -exact [encoding names] $encodingtouse] == -1} {
                        set encodingtouse $currentencoding
                    }
                    shownewbuffer $file $tiledisplay $encodingtouse
                    # this must be done after shownewbuffer because the textarea must be in
                    # the normal state to receive the data read from the disk
                    set listoffile("$ta",binary) $fileisbin
                    # update the options menu and encoding property in listoffile
                    set currentencoding $encodingtouse
                    setencoding
                    # this needs to be done at the end because proc warnifchangedlineendings
                    # may call proc modifiedtitle, which needs most of the info in $listoffile("$ta",...)
                    set listoffile("$ta",eolchar) [warnifchangedlineendings $ta $file [getfilelineendingchar $file] $fileisbin]
                } else {
                    # nothing to do, return with no new file opened
                    return 0
                }
            } else {
                notopenedfile $file 0  ; # increments $winopened
                set ta $pad.new$winopened
                set listoffile("$ta",thetime)  0
                set listoffile("$ta",disksize) 0
                set listoffile("$ta",new) 1
                set listoffile("$ta",eolchar) [platformeolchar]
                set listoffile("$ta",binary) 0
                lappend listoftextarea $ta
                if {$closeinitialbufferallowed} {
                    set closeinitialbufferallowed false
                    byebyeta $pad.new1 opennewemptyfile
                }
                showtext $ta
                RefreshWindowsMenuLabelsWrtPruning
            }
            $ta mark set insert "1.0"
            keyposn $ta
            newfilebind
        } else {
            fileisopen $file
            $pad.filemenu.wind invoke $res
        }
        return 1
    } else {
        return 0
    }
}

proc lookiffileisopen {file} {
# Return zero if $file is not already open, i.e. if the full path
# of $file is not already in some $listoffile("$textarea",fullname)
# If the file is already open, return the number of the windows menu
# entry to invoke in order to display this buffer
    global pad listoffile listoftextarea
    set ilab 0
    set fpf [file normalize $file]
    foreach textarea [filteroutpeers $listoftextarea] {
        if {$listoffile("$textarea",fullname) eq $fpf} {
            set ilab [extractindexfromlabel $pad.filemenu.wind $listoffile("$textarea",displayedname)]
            break
        }
    }
    return $ilab
}

proc notopenedfile {file fileisbin} {
# $file is not opened - this sets the $listoffile area values for that file
# and adds an entry in the windows menu
# $fileisbin is a flag telling whether $file is (1) a binary file,
# or (0) if it is not. In the former case the readonly flag is forced
    global winopened pad listoffile
    global currentencoding autodetectencodinginxmlfiles

    incr winopened

    set ta $pad.new$winopened

    dupWidgetOption [gettextareacur] $ta

    set listoffile("$ta",fullname) [file normalize $file]
    set listoffile("$ta",displayedname) [file tail $listoffile("$ta",fullname)]
    set listoffile("$ta",language) [extenstolang $file]
    setlistoffile_colorize $ta  $listoffile("$ta",fullname)
    set listoffile("$ta",new) 0

    if {[file exists $file]} {
        if {$fileisbin} {
            set listoffile("$ta",readonly) 1
        } else {
            set listoffile("$ta",readonly) [fileunwritable $file]
        }
    } else {
        set listoffile("$ta",readonly) 0
    }

    # force the binary flag to false and call TextStyles, so that when
    # reading the file right after this there will be no disabled state
    # of the textarea that would prevent from inputting the data into
    # the textarea - the correct value of listoffile("$ta",binary)
    # is set in proc openfile, and proc TextStyles is called again
    # by proc shownewbuffer -> proc showtext
    set listoffile("$ta",binary) 0 ; TextStyles $ta

    set listoffile("$ta",undostackdepth) 0
    set listoffile("$ta",redostackdepth) 0
    set listoffile("$ta",undostackmodifiedlinetags) [list ]
    set listoffile("$ta",redostackmodifiedlinetags) [list ]
    set listoffile("$ta",progressbar_id) ""

    if {$autodetectencodinginxmlfiles} {
        # automatic detection of encoding (for xml files)
        set detenc [detectencoding $file]
        set listoffile("$ta",encoding) $detenc
        set currentencoding $detenc
        # do NOT call proc setencoding here because the current textarea is still
        # unchanged: that would set the detected encoding to the current textarea
        # and not only on the file currently being opened! setenconding will be
        # called by the caller of the present proc notopenedfile
    } else {
        # no auto-detection of encoding, just use the current encoding
        # selected in the options/encoding menu
        set listoffile("$ta",encoding) $currentencoding
    }

    addwindowsmenuentry $winopened $listoffile("$ta",displayedname)
}

proc shownewbuffer {file tiledisplay encodingtouse} {
    global pad winopened closeinitialbufferallowed
    set ta $pad.new$winopened
    openfileondisk $ta $file $tiledisplay $encodingtouse
    resetmodified $ta "clearundoredostacks"
    # colorization must be launched before showing the textarea
    # so that foreground colorization while stepping into
    # libfun ancillaries works (example with calfrq)
    backgroundcolorize $ta
    tagcontlines $ta
    if {$tiledisplay == "currenttile"} {
        showtext $ta
    } else {
        set closeinitialbufferallowed false
        # pack the new buffer in a split window
        splitwindow $tiledisplay $ta
    }
    RefreshWindowsMenuLabelsWrtPruning
    AddRecentFile [file normalize $file]
}

proc newfilebind {} {
    global pad winopened textareaid
    set ta $pad.new$winopened
    bind $ta <KeyRelease> {catch {keyposn %W}}
    TextStyles $ta
    set textareaid $winopened
    tkdndbind $ta
}

proc fileisopen {file} {
# file is already opened
    global pad
    tk_messageBox -type ok -title [concat [mc "Open file"] $file] -message [concat \
      [mc "The file"] $file [mc "is already opened! Save the current opened\
      file to another name and reopen it from disk!"] ] -parent $pad
}

proc openfileondisk {textarea thefile tiledisplay encodingtouse} {
# really open/read a file from disk
# all readability tests have normally been done before
    global listoftextarea pad closeinitialbufferallowed
    set msgWait [mc "Wait seconds while loading and colorizing file"]
    showinfo $msgWait
    lappend listoftextarea $textarea
    if {$closeinitialbufferallowed && $tiledisplay == "currenttile" } {
        set closeinitialbufferallowed false
        byebyeta $pad.new1 opennewemptyfile
    }
    set newnamefile [open $thefile r]
    fconfigure $newnamefile -encoding $encodingtouse
    $textarea insert end [read -nonewline $newnamefile]
    close $newnamefile
}
