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

##################################################
# procs for layouts management
##################################################
proc openlayout {} {
# open and restore a layout file from disk (ask the user for its filename first)
    global pad
    global layoutstartdir
    global bug2672_shows_up Tk85

    showinfo [mc "Open file"]

    # remember the latest path used for opening/saving layout files,
    # but the first time use the current path
    if {![info exists layoutstartdir]} {set layoutstartdir [pwd]}

    set preselectedfilter [extenstoknowntypes ".lay"]

    if {$Tk85} {
        # make use of TIP242 (-typevariable option)
        # note that $bug2672_shows_up is necessarily false (see
        # definition of bug2672_shows_up)
        set file [tk_getOpenFile -filetypes [knowntypes_layoutfiles_or_allfiles] -parent $pad \
                                 -initialdir $layoutstartdir -multiple 0 \
                                 -typevariable preselectedfilter]
    } else {
        if {$bug2672_shows_up} {
            set file [tk_getOpenFile -filetypes [knowntypes_layoutfiles_or_allfiles] \
                                     -initialdir $layoutstartdir -multiple 0]
        } else {
            set file [tk_getOpenFile -filetypes [knowntypes_layoutfiles_or_allfiles] -parent $pad \
                                     -initialdir $layoutstartdir -multiple 0]
        }
    }

    if {$file != ""} {
        doopenlayoutfile $file
    }
}

proc doopenlayoutfile {file} {
# open and restore a given layout file $file from disk
    global pad
    global restorelayoutrunning tileprocalreadyrunning

    if {$restorelayoutrunning} {return}
    if {$tileprocalreadyrunning} {return}

    if {[closeallreallyall] eq "aborted"} {
        return
    }

    set layoutstartdir [file dirname $file]

    set layoutstructure [openlayoutfileondisk $file]

    if {$layoutstructure ne "readerror"} {
        # catch needed because we're now trying to parse the .lay file
        # and suppose it contains properly formatted Tcl code (precisely:
        # a list), which could not be the case
        if {[catch {restorelayoutstructure $layoutstructure}] == 0} {
        } else {
            # error was triggered during layout restore
            # Scipad state could be anything, it's not
            # possible to recover from this error
            set mes [mc "Unrecoverable error encountered while parsing the file."]
            append mes "\n"
            append mes [mc "Either the file is corrupted, or this is not a layout file at all."]
            append mes "\n\n"
            append mes [mc "Scipad will now exit."]
            set tit [mc "Unrecoverable error"]
            tk_messageBox -message $mes -icon error -title $tit -parent $pad
            exit
        }
    } else {
        showinfo [mc "Error while reading the layout file"]
    }
}

proc openlayoutfileondisk {fullfilename} {
# read layout file and catch errors
    if {[catch {set layoutstructure [uncatchedopenlayoutfileondisk $fullfilename]}] == 0} {
        return $layoutstructure
    } else {
        return "readerror"
    }
}

proc uncatchedopenlayoutfileondisk {fullfilename} {
# read layout file, errors uncatched (expected to be catched by the caller)
    global defaultencoding
    set filehandle [open $fullfilename r]
    fconfigure $filehandle -encoding $defaultencoding
    set layoutstructure [read -nonewline $filehandle]
    close $filehandle
    return $layoutstructure
}

proc savelayoutas {} {
# save a layout file on disk (ask the user for its filename first)
    global pad
    global restorelayoutrunning
    global layoutstartdir
    global bug2672_shows_up Tkbug3071836_shows_up Tk85

    if {$restorelayoutrunning} {
        return
    }

    showinfo [mc "Save as"]

    # remember the latest path used for opening/saving layout files,
    # but the first time use the current path
    if {![info exists layoutstartdir]} {set layoutstartdir [pwd]}

    set preselectedfilter [extenstoknowntypes ".lay"]

    set proposedname ""
    
    set layoutstructure [getlayoutstructure]

    set writesucceeded 0

    if {$Tk85} {
        # make use of TIP242 (-typevariable option)
        # note that $bug2672_shows_up is necessarily false (see
        # definition of bug2672_shows_up)
        if {!$Tkbug3071836_shows_up} {
            set myfile [tk_getSaveFile -filetypes [knowntypes_layoutfiles_or_allfiles] -parent $pad \
                            -initialfile $proposedname -initialdir $layoutstartdir \
                            -typevariable preselectedfilter]
        } else {
            set myfile [tk_getSaveFile -filetypes [knowntypes_layoutfiles_or_allfiles] -parent $pad \
                                                       -initialdir $layoutstartdir \
                            -typevariable preselectedfilter]
        }
    } else {
        # $Tk85 is false, therefore this is necessarily Tk 8.4.x, which
        # does not suffer from Tk bug 3071836
        if {$bug2672_shows_up} {
            set myfile [tk_getSaveFile -filetypes [knowntypes_layoutfiles_or_allfiles] \
                            -initialfile $proposedname -initialdir $layoutstartdir]
        } else {
            set myfile [tk_getSaveFile -filetypes [knowntypes_layoutfiles_or_allfiles] -parent $pad \
                            -initialfile $proposedname -initialdir $layoutstartdir]
        }
    }

    if {$myfile != ""} {
        set layoutstartdir [file dirname $myfile]
        set preselectedfilter [extenstoknowntypes [file extension $myfile]]
        set writesucceeded [writesavelayout $layoutstructure $myfile]
        while {!$writesucceeded} {
            if {$Tk85} {
                # make use of TIP242 (-typevariable option)
                # note that $bug2672_shows_up is necessarily false (see
                # definition of bug2672_shows_up)
                if {!$Tkbug3071836_shows_up} {
                    set myfile [tk_getSaveFile -filetypes [knowntypes_layoutfiles_or_allfiles] -parent $pad \
                                    -initialfile $proposedname -initialdir $layoutstartdir \
                                    -typevariable preselectedfilter]
                } else {
                    set myfile [tk_getSaveFile -filetypes [knowntypes_layoutfiles_or_allfiles] -parent $pad \
                                                               -initialdir $layoutstartdir \
                                    -typevariable preselectedfilter]
                }
            } else {
                # $Tk85 is false, therefore this is necessarily Tk 8.4.x, which
                # does not suffer from Tk bug 3071836
                if {$bug2672_shows_up} {
                    set myfile [tk_getSaveFile -filetypes [knowntypes_layoutfiles_or_allfiles] \
                                    -initialfile $proposedname -initialdir $layoutstartdir]
                } else {
                    set myfile [tk_getSaveFile -filetypes [knowntypes_layoutfiles_or_allfiles] -parent $pad \
                                    -initialfile $proposedname -initialdir $layoutstartdir]
                }
            }
            if {$myfile != ""} {
                set layoutstartdir [file dirname $myfile]
                set writesucceeded [writesavelayout $layoutstructure $myfile]
            } else {
                break
            }
        }
    }

    if {$writesucceeded} {
        showinfo [mc "Saved successfully!"]
    }
}

proc writesavelayout {layoutstructure fullfilename} {
# save a layout file on disk and catch errors
    if {[catch {uncatchedwritesavelayout $layoutstructure $fullfilename}] == 0} {
        set writeok true
    } else {
        set writeok false
    }
    return $writeok
}

proc uncatchedwritesavelayout {layoutstructure fullfilename} {
# save a layout file on disk, errors uncatched (expected to be catched by the caller)
    global defaultencoding
    set layfile [open $fullfilename w]
    fconfigure $layfile -encoding $defaultencoding
    puts $layfile $layoutstructure
    close $layfile
}

proc savelayoutstructureatendofprevsession {} {
# this proc updates the layout structure currently open in Scipad
# this list is a saved preference that will be later used to restore
# the state of Scipad when the next session will be started
# note that the decision of saving the layout structure does not depend
# on the variable loadpreviouslyopenedfilesonstartup, it is always done

    global layoutstructureatendofprevsession
    set layoutstructureatendofprevsession [getlayoutstructure]
}

proc restorelayoutstructureatendofprevsession {} {
# open the files that were opened when the previous Scipad session was closed
# a warning is triggered in case a file cannot be found

    global loadpreviouslyopenedfilesonstartup
    global layoutstructureatendofprevsession

    if {!$loadpreviouslyopenedfilesonstartup} {
        return
    } else {
        restorelayoutstructure $layoutstructureatendofprevsession
    }
}

