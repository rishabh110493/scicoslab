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
# revert to saved version of current buffer
##################################################

proc revertsaved {textarea {ConfirmFlag "ConfirmNeeded"}} {
# revert the file displayed in $textarea to its latest saved version
    global pad listoffile

    set thefile $listoffile("$textarea",fullname) 

    # check for the perverse case that someone deleted or changed the file
    # to unreadable
    if {![fileexistsondisk $textarea]} {
        return
    }
    if {[fileunreadable $thefile]} {
        return
    }

    if {$ConfirmFlag eq "ConfirmNeeded"} {
        set answer [tk_messageBox \
            -message [concat [mc "Revert"] $thefile [mc "to saved?"] ] \
            -type yesno -icon question -title [mc "Revert confirm?"] \
            -parent $pad]
    } else {
        set answer "yes"
    }

    if {$answer eq "yes"} {

        # save cursor position in the not yet reverted textarea,
        # so that it can be restored at the end (for all peers)
        # the position after reverting is not necessary the same
        # but when it's close this feature is useful
        set cursorpos [list ]
        foreach ta [getfullpeerset $textarea] {
            lappend cursorpos [$ta index insert]
        }

        # properly removing breakpoints in Scipad is mandatory here
        # otherwise the bptsprops entries are not unset - see details
        # in proc deletebreakpoint
        # if in a debug session, this will also remove the breakpoints
        # from Scilab
        removebpt_scipad $textarea

        # temporary set to non binary, otherwise the textarea is not editable
        # this is really needed since proc checkiffilechangedondisk changes this
        # flag before calling proc revertsaved
        set listoffile("$textarea",binary) 0
        TextStyles $textarea

        # only now proceed with reverting the textarea to its saved content
        set oldfile [open $thefile r]
        fconfigure $oldfile -encoding $listoffile("$textarea",encoding)
        $textarea delete 1.0 end 
        while {![eof $oldfile]} {
            $textarea insert end [read -nonewline $oldfile ] 
        }
        close $oldfile

        resetmodified $textarea "clearundoredostacks"

        set unwritflag [fileunwritable $thefile]
        set modtimflag [file mtime $thefile]
        set disksize   [file size $thefile]
        set binaryflag [fileisbinary $thefile]
        set eolchrflag [warnifchangedlineendings $textarea $thefile [getfilelineendingchar $thefile] $binaryflag]
        foreach ta [getfullpeerset $textarea] {
            set listoffile("$ta",readonly) $unwritflag
            # the file on disk may have been changed in the meantime
            # by someone who has perversely turned it into a binary file
            set listoffile("$ta",binary) $binaryflag
            TextStyles $ta
            set listoffile("$ta",eolchar)  $eolchrflag
            set listoffile("$ta",thetime)  $modtimflag
            set listoffile("$ta",disksize) $disksize
            setmodifiedlinetags $ta {}
        }

        showtext $textarea
        foreach ta [getfullpeerset $textarea] thecursorpos $cursorpos {
            $ta mark set insert $thecursorpos
            $ta see $thecursorpos
        }
        backgroundcolorize $textarea
        tagcontlines $textarea
        updatemodifiedlinemargin_allpeers $textarea
    }

}

proc checkiffilechangedondisk {textarea} {
# check if file on disk has changed (i.e. did another application modify
# the file on disk?) since last loading in Scipad
    global listoffile pad
    set filestatusondisk [filehaschangedondisk $textarea]
    switch -- $filestatusondisk {
        0 {
            return
        }
        1 {
            # note: if thetime and the readonly flags would not be updated first,
            # we would enter a recursion:
            # if revertsaved pops up the "unreadable file" warning, there is once
            # more a change of focus, which triggers this proc recursively.
            # An a posteriori rationale: the decision whether to keep the version
            # on disk or the one in memory is itself the most recent editing action.
            foreach ta [getfullpeerset $textarea] {
                set listoffile("$ta",thetime)  [file mtime $listoffile("$textarea",fullname)]
                set listoffile("$ta",disksize) [file size  $listoffile("$textarea",fullname)]
                # check [fileisbinary ] instead of $listoffile("$textarea",binary)
                # to deal with the perverse case the external application
                # changed the type of the file
                set fileisbin [fileisbinary $listoffile("$textarea",fullname)]
                if {$fileisbin} {
                    set listoffile("$ta",readonly) 1
                } else {
                    set listoffile("$ta",readonly) [fileunwritable $listoffile("$textarea",fullname)]
                }
                set listoffile("$ta",binary) $fileisbin
            }
            set msgChanged [concat [mc "The contents and/or properties of "] \
                                   $listoffile("$textarea",fullname) \
                                   [mc "has been modified outside of Scipad. Do you want to reload it?"] ]
            set msgTitle [mc "File has changed!"]
            set answer [tk_messageBox -message $msgChanged \
                            -title $msgTitle -type yesno -icon question -parent $pad]
            switch -- $answer {
                yes {revertsaved $textarea NoConfirm}
                no  {}
            }
        }
        2 {
            # file has disappeared from disk, thus for Scipad it's a new file (and this
            # line also prevents from entering recursion)
            # however, if the file is a binary file, closure is forced here because
            # there is anyway no mean to save binary files from Scipad
            if {$listoffile("$textarea",binary)} {
                set msgVanished [concat [mc "The file"] \
                                        $listoffile("$textarea",fullname) \
                                        [mc "does no longer exist on disk."] \
                                        [mc "It will now be closed since it is a binary file."] ]
                set msgTitle [mc "File has vanished!"]
                tk_messageBox -message $msgVanished -title $msgTitle -type ok -icon warning -parent $pad
                set closethefile true
            } else {
                foreach ta1 [getfullpeerset $textarea] {
                    set listoffile("$ta1",new) 1
                    set listoffile("$ta1",readonly) 0
                }
                set msgVanished [concat [mc "The file"] \
                                        $listoffile("$textarea",fullname) \
                                        [mc "does no longer exist on disk."] \
                                        [mc "Do you want Scipad to close it?"] ]
                set msgTitle [mc "File has vanished!"]
                set answer [tk_messageBox -message $msgVanished \
                                -title $msgTitle -type yesno -icon question -parent $pad]
                switch -- $answer {
                    yes {set closethefile true}
                    no  {set closethefile false}
                }
            }
            if {$closethefile} {
                showtext $textarea ; closecurfile yesnocancel
            } else {
            }
        }
    }
}

proc checkifanythingchangedondisk {w} {
# check if any opened buffer has changed on disk
    global listoftextarea pad checkifanythingchangedondisk_running
    # The test on $w below prevents from asking the confirmation question
    # multiple times since more than one single FocusIn event can be fired
    # e.g when focus is set to Scipad by clicking on a text widget: the binding
    # fires for .scipad but also for .scipad.newX because .scipad is in the
    # bindtags list for .scipad.newX
    if {$w != $pad} {
        return
    }
    # $checkifanythingchangedondisk_running is used to prevent the following situation:
    # With two or more files opened in Scipad, two or more of them get deleted from the
    # disk. This is detected by Scipad on <FocusIn> event, which launches proc
    # checkifanythingchangedondisk. This proc launches checkiffilechangedondisk, which
    # asks the user if the deleted file shall be closed from Scipad. User answers yes.
    # The messageBox open/close triggers a new <FocusIn> event that in proc
    # checkifanythingchangedondisk takes the list of textareas *before* closure of the
    # deleted files, and when running the second time checkifanythingchangedondisk the
    # user gets an error  can't read "listoffile(".scipad.newXX",fullname)": no such
    # element in array  because this textarea has been closed in the meantime
    # The fix is therefore to prevent simultaneous launches of the present proc, and
    # this is done using a guard variable checkifanythingchangedondisk_running
    if {$checkifanythingchangedondisk_running} {
        return
    }
    set checkifanythingchangedondisk_running true
    # Without the update below, a problem may happen in the following situation:
    # An email message is dragged from Thunderbird, and dropped onto Scipad
    # Then the user clicks on the closure cross for this file.
    # The <FocusIn> event would trigger in parallel the file is closing, and
    # at the time the changes of the temporary file that was created during
    # the drag and drop are checked, detection that this file disappeared
    # from the disk would be done in checkiffilechangedondisk, the user would
    # be asked for closing the corresponding textarea, and kaboom this textarea
    # would no longer exist. This update forces closure first, which updates
    # $listoftextarea, leading to checking if file changed on disk only on the
    # remaining textareas, and this case can no longer happen
    update
    # catch needed to deal with the case Scipad is closed by the red cross
    # while it did not have focus. The <FocusIn> event triggers, which launches
    # the present proc but Scipad already has executed closure of its files.
    # At this point, Tcl error would trigger in proc getpeerlist (called by
    # proc filteroutpeers). This problem cannot be seen in Standalone mode, only
    # when the Tcl interp still exists after Scipad closure, i.e. in Scicoslab
    # for instance.
    catch {
        foreach ta [filteroutpeers $listoftextarea] {
            checkiffilechangedondisk $ta
        }
    }
    set checkifanythingchangedondisk_running false
}
