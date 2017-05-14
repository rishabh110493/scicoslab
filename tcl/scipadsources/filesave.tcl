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
# procs for saving buffers to disk
##################################################
proc filetosavecur {} {
# save current buffer to disk
    filetosave [gettextareacur]
}

proc filetosaveall {} {
# save all modified buffers to disk
    global listoftextarea
    foreach ta [filteroutpeers $listoftextarea] {
        # no need to explicitely forbid saving of binary files here
        # since they can't be modified anyway
        if {[ismodified $ta]} {
            filetosave $ta
        }
    }
}

proc filesaveascur {} {
# save current buffer to disk as...
    filesaveas [gettextareacur]
}

proc filetosave {textarea} {
# check if file on disk has changed (i.e. did another application modify
# the file on disk?) since last loading in Scipad
# and ask the user if he still wants to save in that case
# if yes or if there was no change on disk, perform the save on disk
# note: the modification check is almost pointless now since
# Scipad performs this check each time it gets focus - it is kept
# to deal with the perverse case where some external process modifies
# the file while Scipad keeps focus, and for the case the user answers
# he doesn't want to reload a file modified on disk
    global listoffile pad

    if {$listoffile("$textarea",binary)} {
        set msgWait [concat $listoffile("$textarea",fullname) [mc "cannot be written because it is a binary file!"]]
        tk_messageBox -message $msgWait -icon error -type ok -title [mc "Can't save binary files"] -parent $pad
        return
    }

    if {[fileexistsondisk $textarea]} {

        if {[filetimeondiskisdifferent $textarea]} {

            # file was modified by another application since Scipad last saved it
            set msgChanged [concat [mc "The contents of "] \
                                   $listoffile("$textarea",fullname) \
                                   [mc "has changed on disk, save it anyway?"] ]
            set msgTitle [mc "File has changed!"]
            set answer [tk_messageBox -message $msgChanged -title $msgTitle \
                            -type yesnocancel -icon question -parent $pad]
 
            switch -- $answer {
                yes    {
                         if {![writesave $textarea $listoffile("$textarea",fullname)]} {
                             filesaveas $textarea
                         }
                       }
                no     {}
                cancel {}
            }
 
        } else {

            # file was not modified by another application since Scipad last saved it
            if {![writesave $textarea $listoffile("$textarea",fullname)]} {
                filesaveas $textarea
            }
        }

    } else {

        # file does not yet exist on disk
        filesaveas $textarea
    }
}

proc filesaveas {textarea} {
# bring up the Save As... dialog so that the user can pick up a file name
# and do the save under that filename
    global listoffile pad
    global startdir
    global bug2672_shows_up Tkbug3071836_shows_up
    global Tk85 preselectedfilterinopensaveboxes

    # filesaveas cannot be executed since it uses getallfunsintextarea
    # which needs the colorization results
    if {[colorizationinprogress]} {return}

    showinfo [mc "Save as"]

    # binary files cannot be saved
    if {$listoffile("$textarea",binary)} {
        set msgWait [concat $listoffile("$textarea",fullname) [mc "cannot be written because it is a binary file!"]]
        tk_messageBox -message $msgWait -icon error -type ok -title [mc "Can't save binary files"] -parent $pad
        return
    }

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

    # proposedname is the first function name found in the buffer
    set proposedname ""
    set firstfuninfo [lindex [getallfunsintextarea $textarea] 1]
    if {[lindex $firstfuninfo 0] != "0NoFunInBuf"} {
        set proposedname [lindex $firstfuninfo 0]
    }
    if {$listoffile("$textarea",new)==0 || $proposedname==""} {
        foreach {proposedname peerid} [removepeerid $listoffile("$textarea",displayedname)] {}
    } else {
        set proposedname $proposedname.sci
    }

    set writesucceeded 0

    if {$Tk85} {
        # make use of TIP242 (-typevariable option)
        # note that $bug2672_shows_up is necessarily false (see
        # definition of bug2672_shows_up)
        if {!$Tkbug3071836_shows_up} {
            set myfile [tk_getSaveFile -filetypes [knowntypes] -parent $pad \
                            -initialfile $proposedname -initialdir $startdir \
                            -typevariable preselectedfilterinopensaveboxes]
        } else {
            set myfile [tk_getSaveFile -filetypes [knowntypes] -parent $pad \
                                                       -initialdir $startdir \
                            -typevariable preselectedfilterinopensaveboxes]
        }
    } else {
        # $Tk85 is false, therefore this is necessarily Tk 8.4.x, which
        # does not suffer from Tk bug 3071836
        if {$bug2672_shows_up} {
            set myfile [tk_getSaveFile -filetypes [knowntypes] \
                            -initialfile $proposedname -initialdir $startdir]
        } else {
            set myfile [tk_getSaveFile -filetypes [knowntypes] -parent $pad \
                            -initialfile $proposedname -initialdir $startdir]
        }
    }

    if {$myfile != ""} {
        set startdir [file dirname $myfile]
        set preselectedfilterinopensaveboxes [extenstoknowntypes [file extension $myfile]]
        set writesucceeded [writesave $textarea $myfile]
        while {!$writesucceeded} {
            if {$Tk85} {
                # make use of TIP242 (-typevariable option)
                # note that $bug2672_shows_up is necessarily false (see
                # definition of bug2672_shows_up)
                if {!$Tkbug3071836_shows_up} {
                    set myfile [tk_getSaveFile -filetypes [knowntypes] -parent $pad \
                                    -initialfile $proposedname -initialdir $startdir \
                                    -typevariable preselectedfilterinopensaveboxes]
                } else {
                    set myfile [tk_getSaveFile -filetypes [knowntypes] -parent $pad \
                                                               -initialdir $startdir \
                                    -typevariable preselectedfilterinopensaveboxes]
                }
            } else {
                # $Tk85 is false, therefore this is necessarily Tk 8.4.x, which
                # does not suffer from Tk bug 3071836
                if {$bug2672_shows_up} {
                    set myfile [tk_getSaveFile -filetypes [knowntypes] \
                                    -initialfile $proposedname -initialdir $startdir]
                } else {
                    set myfile [tk_getSaveFile -filetypes [knowntypes] -parent $pad \
                                    -initialfile $proposedname -initialdir $startdir]
                }
            }
            if {$myfile != ""} {
                set startdir [file dirname $myfile]
                set writesucceeded [writesave $textarea $myfile]
            } else {
                break
            }
        }
    }

    if {$writesucceeded} {
        foreach ta [getfullpeerset $textarea] {
            set listoffile("$ta",fullname) [file normalize $myfile]
            set listoffile("$ta",new) 0
        }
        set ilab [extractindexfromlabel $pad.filemenu.wind \
                  $listoffile("$textarea",displayedname)]
        foreach {dname peerid} [removepeerid $listoffile("$textarea",displayedname)] {}
        set listoffile("$textarea",displayedname) \
                [file tail $listoffile("$textarea",fullname)]
        set dname [appendpeerid $listoffile("$textarea",displayedname) $peerid]
        set listoffile("$textarea",displayedname) $dname
        setwindowsmenuentrylabel $ilab $listoffile("$textarea",displayedname)

        # refresh peer identifiers in the windows menu and title bars
        foreach peerta [getpeerlist $textarea] {
            set ilab [extractindexfromlabel $pad.filemenu.wind \
                     $listoffile("$peerta",displayedname)]
            foreach {dname peerid} [removepeerid $listoffile("$peerta",displayedname)] {}
            set dname [appendpeerid $listoffile("$textarea",displayedname) $peerid]
            set listoffile("$peerta",displayedname) $dname
            setwindowsmenuentrylabel $ilab $dname
        }
        # refresh panes titles (actually only needed for peers)
        updatepanestitles

        RefreshWindowsMenuLabelsWrtPruning
        AddRecentFile $listoffile("$textarea",fullname)
    }
}

proc writesave {textarea nametosave} {
# generic save function - write a file onto disk if it is writable
# return value:
#    1  file was successfully written
#    0  otherwise
    global listoffile pad

    # if the file exists, check if the file is writable 
    # if it doesn't, check if the directory is writable
    # (case of Save as...) (non existent files return 0 to writable)
    if {[file exists $nametosave]} {
        set readonlyflag [fileunwritable $nametosave]
    } else {
        set readonlyflag [fileunwritable [file dirname $nametosave]]
    }

    if {!$readonlyflag} {
        # writefileondisk catched to deal with unexpected errors (should
        # be none!)
        if {[catch {writefileondisk $textarea $nametosave}] == 0} {
            resetmodified $textarea
            setsavedmodifiedline $textarea
            foreach ta [getfullpeerset $textarea] {
                set listoffile("$ta",thetime)  [file mtime $nametosave]
                set listoffile("$ta",disksize) [file size  $nametosave]
                if {!$listoffile("$ta",binary)} {
                    set listoffile("$ta",readonly) $readonlyflag
                } else {
                    # don't change $listoffile("$ta",readonly),
                    # which is already set to 1 for binary files
                }
            }
            set msgWait [concat [mc "File"] $nametosave [mc "saved"]]
            showinfo $msgWait
            # windows menu entries must be sorted so that order is
            # correct when sorting by MRU (the file that was just saved
            # has become the most recently used)
            sortwindowsmenuentries
            return 1
        } else {
            set msgWait [concat $nametosave [mc "cannot be written!"]]
            tk_messageBox -message $msgWait -icon error -type ok -title [mc "Save As"] -parent $pad
            return 0
        }
    } else {
        set msgWait [concat $nametosave [mc "cannot be written!"]]
        tk_messageBox -message $msgWait -icon error -type ok -title [mc "Save As"] -parent $pad
        return 0
    }
}

proc writefileondisk {textarea nametosave {backupskip 0} {forceplatformeol 0}} {
# really write the file onto the disk
# all writability tests have normally been done before
    global filebackupdepth tcl_platform
    global pad listoffile

    if {!$backupskip} {
        backupfile $nametosave $filebackupdepth
    }

    # open in mode "w" means "WRONLY CREAT TRUNC", and this should work OK
    # for all files, hidden or not, IMHO
    # but experience shows that "w" fails with existing hidden files on
    # Windows. See Tcl bug 1622579:
    # http://sourceforge.net/tracker/index.php?func=detail&aid=1622579&group_id=10894&atid=110894
    # However, the TRUNC flag is really needed (i.e. there should be the
    # full "w" mode) to overwrite files, otherwise writing overwrites
    # without truncating to zero length when opening, which results in
    # a wrong file when the new version is smaller than the previous
    # version on disk
    # Therefore, hidden files are treated specially on windows: first
    # the hidden flag is removed, the file is saved on disk and finally
    # the hidden flag is set back
    set specialtreatment 0
    if {$tcl_platform(platform) == "windows" && [file exists $nametosave]} {
        if {[file attributes $nametosave -hidden]} {
            set specialtreatment 1
        }
    }

    if {$specialtreatment} {
        file attributes $nametosave -hidden 0
    }

    # since save is allowed during debug (thus providing a mean to
    # save modifications performed before the debug was launched)
    # there is a need to filter out lines of the .sce debug wrapper
    # so that they are not included in the saved file
    # the solution used dumps the content of the buffer to save into
    # a temporary text widget and removes everything tagged as db_wrapper
    # before writing the file on disk
    # this needs more memory than the natural approach of saving line by
    # line, but it avoids a lot of headaches in determining which is the
    # last line not tagged (this line must be saved with the -nonewline
    # option of puts)
    set dbwrapranges [$textarea tag ranges db_wrapper]
    text $pad.temptextwidget
    $pad.temptextwidget insert 1.0 [$textarea get 1.0 "end-1c"]
    if {$dbwrapranges != {}} {
        eval "$pad.temptextwidget delete $dbwrapranges"
    }
    set texttosave [$pad.temptextwidget get 1.0 end]
    # destroy NOW otherwise it's a leftover when the file is not writable
    # for instance, creating problems for the next execution such as
    # "window name "temptextwidget" already exists in parent"
    destroy $pad.temptextwidget

    set eoltrans [getlineendingchar $textarea $forceplatformeol]
    set listoffile("$textarea",eolchar) $eoltrans

    set FileNameToSave [open $nametosave w]
    fconfigure $FileNameToSave -encoding    $listoffile("$textarea",encoding) \
                               -translation $listoffile("$textarea",eolchar)
    puts -nonewline $FileNameToSave $texttosave
    close $FileNameToSave

    if {$specialtreatment} {
        file attributes $nametosave -hidden 1
    }
}

proc savepreferences {} {

  global env listofpref listofpref_list listofcondpref
  global defaultencoding

  set preffilename [file join $env(SCIHOME) .SciPadPreferences.tcl]

  set preffile [open $preffilename w]
  # the preferences file is always saved with the default platform system encoding
  # this avoids to source it later in an encoding different than the platform
  # native encoding, which is a feature available only from Tcl 8.5 onwards
  fconfigure $preffile -encoding $defaultencoding

  foreach opt $listofpref {
      global $opt
      if {![info exists $opt]} {
              continue
      }
      puts $preffile [concat "set $opt" \{[set $opt]\}]
  }

  foreach opt $listofpref_list {
      global $opt
      if {![info exists $opt]} {
              continue
      }
      set value ""
      foreach item $opt {
          set value [concat $value [set $item]]
      }
      puts $preffile "set $opt \[list $value\]"
  }

  foreach elt $listofcondpref {
      foreach {opt cond} $elt {
          global $opt $cond
          if {![info exists $opt]} {
                  continue
          }
          if {[set $cond]} {
              puts $preffile [concat "set $opt" \{[set $opt]\}]
          }
      }
  }

  close $preffile

}

proc backupfile { fname { levels 10 } } {
# before writing to a file $fname, call: backupfile $fname
# and the file will not get overwritten.
#
# renames like so: .bak, .ba2, .ba3, .ba4, etc.
#
# this proc was taken from http://wiki.tcl.tk/1641 and slightly adapted

    if {$levels==0} {return}

    if { [ catch {
        if { [ file exists $fname ] } {
            set dir [ file dirname $fname ]
            set files [ glob -nocomplain -path ${fname} .ba* ]
            set i $levels
            while { [ incr i -1 ] } {
                if { [ lsearch -exact $files ${fname}.ba$i ] > -1 } {
                    file rename -force ${fname}.ba$i ${fname}.ba[ incr i ]
                    incr i -1
                }
            }
            if {$levels >= 2} {
                if { [ file exists ${fname}.bak ] } {
                    file rename -force ${fname}.bak ${fname}.ba2
                }
            }
            file rename -force $fname ${fname}.bak
        }
    } err ] } {
        return -code error "backupfile($fname $levels): $err"
    }
}
