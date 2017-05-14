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
# procs exiting Scipad
##################################################
#
# High level architecure of the quitting procs:
#
# quit from Scipad:
#   exitapp_yesnocancel
#       |->    doexitapp
#                   |->      closelistofta
#       |->     killscipad
#
# quit from Scilab (scipad.quit in Scilab5, scilab.quit in Scicoslab):
#   exitapp
#       |->     doexitapp
#                   |->      closelistofta
#       |->     killscipad

proc killscipad {} {
# kill main window and save preferences on exit
    global pad WMGEOMETRY WMSTATE

    #save the geometry for the next time
    set WMSTATE [wm state $pad]
    if {$WMSTATE == "zoomed"} {
        # restore normal (i.e. non-maximized) state before saving
        # the output of wm geometry, otherwise dimensions are large
        # when relaunching Scipad
        wm state $pad "normal"
    }
    set WMGEOMETRY [wm geometry $pad]

    savepreferences

    destroy $pad

    # The following line is needed in case Scipad is launched directly
    # in wish (debug purposes)
    # The two instructions *must* be in this order, and in a single catch
    # structure:
    # Scipad in Scilab: console hide throws an error (catched), destroy . is
    # not executed (it must not be executed because otherwise Scipad cannot
    # be launched again after first close)
    # Scipad in wish: both instructions are executed and are needed, especially
    # the destroy . because this kills the wish process that would still be
    # alive in the computer otherwise
    catch {console hide ; destroy .}
    unset pad
}

proc exitapp_yesnocancel {} {
# exit Scipad
# this proc is called when quitting Scipad from Scipad (file menu, or
# upper-right cross of the window)
# this proc allows to cancel the action and in this case to not leave
# this is the proc normally used for exiting from Scipad
# when exiting from Scilab, cancel is not possible and proc exitapp
# shall be used instead
# note about the catch below: see proc exitapp
    global restorelayoutrunning
    if {$restorelayoutrunning} {return}
    if {[catch {doexitapp yesnocancel}]} {killscipad}
}

proc exitapp {} {
# exit Scipad
# this proc is called when quitting Scipad from Scilab
# in this case cancelling the action is not possible
# for Scilab 4, Scicoslab and Scilab 5 compatibility reasons the name of this
# proc should not be changed:
#   Scilab 4 and Scicoslab call it from scilab.quit (most general exit script
#     evaluated when quitting Scilab)
#   Scilab 5 call it from scipad.quit (which is part of the Scipad module,
#     thus more under my control)
# note about the catch below:
#   exitapp will fail for instance when the user tries to close Scipad
#   using [x] or File/Exit when Scipad is opening files at the same time
#   (dnd of a directory with many files)
    if {[catch {doexitapp yesno}]} {killscipad}
}

proc doexitapp {quittype} {
# exit Scipad
# this proc is called by proc idleexitapp only
    global listoftextarea
    global globalsearchID

    # stop searching in files
    if {[info exists globalsearchID]} {
        cancelsearchinfiles $globalsearchID
    } else {
        # no search in files has been done in that Scipad session
        # no specific action is then required to cancel them
    }

    # stop debugger and clean Scilab state
    if {[getdbstate] == "DebugInProgress"} {
        # note that the abort below is useless: it executes in a ScilabEval sync,
        # i.e. in a dedicated parser, and just aborts in that parser without
        # interfering with what's happening in the main parser
        # <TODO>: find a way to abort in the main parser when this parser is busy
        #         hint: this is just impossible with the current amount of control
        #               we have on Scilab from Tcl!
        ScilabEval_lt "\"delbpt();abort\"" "sync" "seq"
        cleantmpScilabEvalfile
    }

    set listoftatosave [getuseranswerstoasksaveconfirm $listoftextarea $quittype]

    if {$listoftatosave eq "UserHitCancel"} {
        # the user clicked cancel during the questions asking
        # about saving the modified files
        # --> don't save or close anything
        return

    } else {

        # save the list of opened files, for restoring them later
        # on the next Scipad session opening
        savelayoutstructureatendofprevsession

        # close all files, save those asked by the user
        # and don't open a new textarea when the last gets closed
        closelistofta $listoftextarea $listoftatosave nonewemptyfile
    }
}

proc asksaveconfirm {ta quittype} {
# query the modified flag of textarea $ta, and if it is set
# ask the user for confirmation (with a view to save the buffer)
# possible values for $quittype are "yesno" or "yesnocancel", which are directly
# fed into the -type option of the message box for buttons selection
# return value may be:
# the return value may be "yes" or "no"           if  $quittype was "yesno"
#                      or "yes", "no" or "cancel" if  $quittype was "yesnocancel"

    global listoffile pad

    if  {[ismodified $ta]} {

        # display the textarea to help the user make his opinion about whether
        # this file shall be saved or not
        showtext $ta

        # ask the user if buffer should be saved
        set answer [tk_messageBox -message [ concat [mc "The contents of"] \
           $listoffile("$ta",fullname) \
           [mc "may have changed, do you wish to save your changes?"] ] \
           -title [mc "Save Confirm?"] -type $quittype -icon question -parent $pad]

    } else {
        # buffer was not modified
        set answer "no"
    }

    return $answer
}

proc getuseranswerstoasksaveconfirm {listoftatocheck quittype} {
# ask for saving or not all buffers which are both:
#    - modified
#    - in $listoftatocheck   (pass $listoftextarea here to include all buffers)
# possible values for $quittype are "yesno" or "yesnocancel", which are directly
# fed into the -type option of the message box for buttons selection
# the return value is:
#    - the list of textareas for which the user wants saving, if the user didn't
#      click on cancel
#    - the special keyword "UserHitCancel" if the user has hit cancel (the questions
#      asked stop as soon as cancel has been hit once)
# the question is being asked only once for a given file, even if the textarea
# displaying this file has peers

    set curta [gettextareacur]
    set listoftatosave [list ]

    foreach ta [shiftlistofta [filteroutpeers $listoftatocheck] [gettextareacur]] {
        set answ [asksaveconfirm $ta $quittype]
        switch -- $answ {
            cancel {
                    set listoftatosave "UserHitCancel"
                    break
                   }
            yes    {
                    lappend listoftatosave $ta
                   }
            no     {
                   }
        }
    }

    showtext $curta
    return $listoftatosave
}
