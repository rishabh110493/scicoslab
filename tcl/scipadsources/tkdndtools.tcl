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

proc tkdndbind {w} {
# Drag and drop feature using TkDnD
# $w must be textarea

    global TkDnDloaded pad dndinitiated sourcetextarea
    global savedsel savedseli dnddroppos
    global debuglog logbindings logchildrenbindings

    # Abort if TkDnD package is not available
    if {!$TkDnDloaded} {
        bind $w <ButtonRelease-1>  { \
            endblockselection %W ; \
            if {[info exists listoffile("%W",fullname)]} { \
                if {[isdisplayed %W]} { \
                    focustextarea %W ; \
                } \
            } \
        }
        bind $w <Control-Button-1> { \
            %W tag remove sel 1.0 end ; \
            followlink %W %x %y ; \
        }
        # bindings for block selection
        bind $w <Shift-Control-Button-1> { \
            startblockselection %W %x %y ; \
            break ; \
        }
        bind $w <Shift-Control-Button1-Motion> { \
            selectblock %W %x %y ; \
            break ; \
        }
        bind $w <Shift-Control-ButtonRelease-1> { \
            endblockselection %W ; \
            break ; \
        }
        showmessagemissingtkdndpackage
        return
    }

    # To ensure that the widgets have been created before binding to them
    update idletasks

    # Drag and drop files or directories to Scipad - Just a few lines!
    dnd bindtarget $pad text/uri-list <Drop> "droplistoffilesontextarea %D"
    dnd bindtarget $pad text/uri-list <Drag> "return %A"
    dnd bindtarget $w   text/uri-list <Drop> "droplistoffilesontextarea %D"
    dnd bindtarget $w   text/uri-list <Drag> "focustextarea %W ; return %A"

    # Drag and drop text within Scipad, or coming from the outside - More complicated!
    dnd bindtarget $w text/plain <Drop> {
        if {[info exists sourcetextarea]} {
            # drag from Scipad, drop in Scipad

            if {$sourcetextarea == "%W" && [gettaselind %W any] != ""} {
                # drag and drop in the same Scipad buffer
                #
                # if the mouse went out of the buffer during drag, and
                # finally drops in the same buffer as the drag buffer
                # the selection has been lost in the process because of
                # focustextarea below in the <DragEnter> event, thus the
                # drop process is the same as if two different buffers
                # were involved (-> else clause of this if above)
                #
                # here we didn't fly out of the buffer, sel tag still here
                if {![isposinsel %W %x %y]} {
                    # the mouse, in fact the destination mark cursor, is not
                    # inside the selection, or if it is, it is at the very
                    # first position of the selection
                    if {"%A" == "copy"} {
                        %W tag remove sel 1.0 end
                        dnd_putorpastetext %W %D
                    } else {
                        # "%A" == "move"
                        set sepflag [startatomicedit %W]
                        dnd_deleteorblockcuttext $savedseli
                        dnd_putorpastetext %W %D
                        endatomicedit %W $sepflag
                    }
                } else {
                    # drop occurs at the same place as drag, do nothing
                    # except prevent the cursor from being inside the selection
                    # which should never be the case
                    foreach {sta sto} [gettaselind %W single] {}
                    %W mark set insert $sto
                    %W see insert
                }

            } else {
                # drag from a Scipad buffer, drop in another Scipad buffer
                if {"%A" == "move"} {
                    focustextarea $sourcetextarea
                    $sourcetextarea tag remove sel 1.0 end
                    eval "$sourcetextarea tag add sel $savedseli"
                    dnd_deleteorblockcuttext $savedseli
                }
                %W tag remove sel 1.0 end
                focustextarea %W ; # needed if next command is actually paste (which performs in current textarea)
                dnd_putorpastetext %W %D
            }
            unset sourcetextarea

        } else {
            # drag from outside of Scipad, drop in Scipad
            %W tag remove sel 1.0 end
            puttext %W %D "replaceallowed"
        }

        restorecursorblink ; # needed for drags from the outside
        set dndinitiated false
        if {[info exists dnddroppos]} {
            unset dnddroppos
        }
    }

    dnd bindsource $w text/plain {
        set sourcetextarea %W
        return $savedsel
    }

    dnd bindtarget $w text/plain <Drag> {
        set dndreallystarted true
        set dnddroppos [%W index @%x,%y]
        %W mark set insert $dnddroppos
        %W see insert
        if {%x <= 10} { %W xview scroll -1 units }
        if {%x >= [expr {[winfo width  %W] - 10}]} { %W xview scroll 1 units }
        if {%y <= 10} { %W yview scroll -1 units }
        if {%y >= [expr {[winfo height %W] - 10}]} { %W yview scroll 1 units }
        update idletasks
        if {[lsearch "%m" "Control"] != -1} {
            return copy
        } else {
            return move
        }
    }

    dnd bindtarget $w text/plain <DragEnter> {
        # select the target textarea - update makes the cursor visible
        # focus -force makes cursor visible even for drags from outside of Scipad
        focus -force %W
        focustextarea %W
        update
        stopcursorblink ; # needed for drags from the outside
        # Bug fixed: We must put %a into a variable before returning it, and cannot
        #            directly use    return %a
        #            Using directly "return %a" causes a crash (on Win7 64 bits at
        #            least) when dragging an email from Outlook and hovering over
        #            Scipad afterwards (without even releasing the mouse button1 to
        #            drop the email). Strange thing.
        #            Note that the type of the dragged object is text/plain and that
        #            this dragged text contains no information about where on the
        #            disk this email can be found, i.e. the email cannot be opened
        #            by this drag operation
        set listofactions %a
        return $listofactions
    }

    # break prevents class binding from triggering
    bind $w <Button-1>         { if {[Button1BindTextArea %W %x %y]} {break} }
    bind $w <Control-Button-1> { if {[Button1BindTextArea %W %x %y]} { \
                                     break ; \
                                 } else { \
                                     %W tag remove sel 1.0 end ; \
                                     followlink %W %x %y ; \
                                 } \
                               }
    # if {[info exists listoffile("%W",fullname)]} in the else clause below
    # is required to solve a bug reported in the newsgroup at
    # http://groups.google.com/group/comp.soft-sys.math.scilab/browse_thread/thread/21cee717df71ab0/d5957386272e17b3
    # http://groups.google.com/group/comp.soft-sys.math.scilab/browse_thread/thread/875daad29986228e/ae651d1a948ba67c
    # The double click in the file/open box fires two <ButtonRelease-1>
    # events to the first buffer ($pad.new1), and when these events come
    # to Scipad this buffer has already been closed thanks to the automagical
    # close of the initial buffer
    bind $w <ButtonRelease-1>  { if {$dndinitiated} { \
                                     set dndinitiated false ; \
                                 } else { \
                                     endblockselection %W ; \
                                     if {[info exists listoffile("%W",fullname)]} { \
                                         if {[isdisplayed %W]} { \
                                             focustextarea %W ; \
                                         } \
                                     } \
                                 } \
                               }
    bind $w <Button1-Leave>    { if {$dndinitiated} {break} }
    bind $w <Double-Button-1>  { if {$dndinitiated} {break} }
    bind $w <Triple-Button-1>  { if {$dndinitiated} {break} }
    bind $w <Button1-Motion>   { if {$dndinitiated} {break} }

    # bindings for block selection
    bind $w <Shift-Control-Button-1> { if {![Button1BindTextArea %W %x %y]} { \
                                           startblockselection %W %x %y ; \
                                           break ; \
                                       } \
                                     }
    bind $w <Shift-Control-Button1-Motion> { if {!$dndinitiated} { \
                                                 selectblock %W %x %y ; \
                                                 break ; \
                                             } \
                                           }
    bind $w <Shift-Control-ButtonRelease-1> { if {!$dndinitiated} { \
                                                 endblockselection %W ; \
                                                 break ; \
                                              } \
                                            }
    # prevent from extending the block selection by dragging outside
    # of the visible part of the textarea, since this is not compatible
    # with the pixel-like block selection process
    bind $w <Shift-Control-Button1-Leave> { break }

    # nice cursor change when mouse is over the selection
    $w tag bind sel <Enter> {%W configure -cursor hand2 ; set mouseoversel true}
    $w tag bind sel <Leave> {%W configure -cursor xterm ; set mouseoversel false}

    # debug log settings: log bindings for the new textarea
    if {$debuglog && $logbindings && $logchildrenbindings} {
        foreach sequ [bind $w] {
            set script [bind $w $sequ]
            bind $w $sequ "log \"\n----------------------\" ; \
                           log \"Bind $w $sequ triggered!\"; \
                           $script; \
                           log \"End of bind $w $sequ\"; \
                           log \"\n----------------------\n\" "
        }
    }

}

proc droplistoffilesontextarea {w} {
    global pad
    global restorelayoutrunning tileprocalreadyrunning

    if {$restorelayoutrunning} {return}
    if {$tileprocalreadyrunning} {return}

    # if a single .lay file is dropped, then consider this is a layout file
    # instead of opening it as a text file, unless the user disagrees
    if {[llength $w] == 1} {
        set w0 [lindex $w 0]
        if {[file isfile $w0] && [file extension $w0] eq ".lay"} {
            set mes [mc "The dropped file seems to be a Scipad layout file."]
            append mes " "
            append mes [mc "Scipad will open it as such."]
            append mes "\n"
            append mes [mc "Click Cancel to open as a text file instead."]
            set tit [mc "Layout file detected"]
            set answ [tk_messageBox -message $mes -type okcancel -icon info -title $tit -parent $pad]
            if {$answ eq "ok"} {
                doopenlayoutfile $w0
                return
            }
        }
    }

    guarded_openlistoffiles $w currenttile substpercentseq
}

proc Button1BindTextArea { w x y } {
    global dndinitiated savedsel savedseli dndreallystarted
    global mouseoversel dnd_issourceblocksel

    # note: when dndreallystarted is false, the Text class binding fires
    # after this proc (no "break" in the binding that launched this proc),
    # and in that Text class binding the insert point is normally set to
    # [::tk::TextClosestGap $w $x $y] which is slightly different from
    # @$x,$y  -- see redefinition of proc ::tk::TextClosestGap in
    # textarea.tcl
    $w mark set insert @$x,$y
    $w see insert

    set dndreallystarted false
    set savedseli [gettaselind $w any]
    if {$savedseli != ""} {
        if {$mouseoversel} {
            set dndinitiated true
            set savedsel [gettatextstring $w $savedseli]
            set dnd_issourceblocksel [expr {[llength $savedseli] != 2}]
            stopcursorblink
            dnd drag $w -actions {copy move}
            # (Windows) dnd drag returns only after the drop action (in case
            # mouse has moved) or after button release (if no mouse move)
            # if drop has been called by dnd drag, cursor blinking is already
            # restored but if the mouse did not move then drop has not been
            # called and cursor blinking must be restored here
            restorecursorblink
        }
    }

    # ensure that the insertion point remains visible, even if it jumped
    # to the next line (see comment above about TextClosestGap)
    after idle "$w see insert"

    return $dndreallystarted
}

proc dnd_putorpastetext {w toput} {
# puttext if the source selection was a single sel,
# or pastetext as block otherwise
    global dnd_issourceblocksel
    if {!$dnd_issourceblocksel} {
        # single selection
        puttext $w $toput "replaceallowed"
    } else {
        # multirange selection, i.e. block selection
        pastetext block $toput
    }
}

proc dnd_deleteorblockcuttext {selindices} {
# deletetext if the source selection was a single sel,
# or blockcuttext otherwise
    global dnd_issourceblocksel
    if {!$dnd_issourceblocksel} {
        # single selection
        deletetext
    } else {
        # multirange selection, i.e. block selection
        cuttext block $selindices
    }
}

############################
# Temporary cursor blinking start/stop
#
# 1. proc dostopcursorblink implements a hack to ensure that the cursor is
#    on during a drag, so that it is visible
#    This is a workaround to avoid Tk bug 1169429
#    See http://sourceforge.net/tracker/?func=detail&atid=112997&aid=1169429&group_id=12997
#    The proper fix is included in any Tk version strictly greater than 8.5.0 beta 3
#
# 2. Launching the procs in the background prevents from having the dnd locks
#    issues that were previously reported in the newsgroup:
#    http://groups.google.fr/group/comp.soft-sys.math.scilab/browse_thread/thread/b07a13adc073623d/b4e07072205c0435
#
# Warning: if !$backgroundtasksallowed (this should only be a debug setting),
# the dnd locks issues are not fixed

proc stopcursorblink {} {
    global cursorblink backgroundtasksallowed
    if {$cursorblink} {
        if {$backgroundtasksallowed} {
            after cancel {dorestorecursorblink}
            after idle {dostopcursorblink}
        } else {
            dostopcursorblink
        }
    }
}

proc restorecursorblink {} {
    global cursorblink backgroundtasksallowed
    if {$cursorblink} {
        if {$backgroundtasksallowed} {
            after cancel {dostopcursorblink}
            after idle {dorestorecursorblink}
        } else {
            dorestorecursorblink
        }
    }
}

proc dostopcursorblink {} {
    global listoftextarea
    global Tk85

    if {$Tk85} {
        # Tk bug 1169429 is fixed
        foreach ta $listoftextarea {
            $ta configure -insertofftime 0
        }

    } else {
        # Tk bug 1169429 is not fixed, work around it
        foreach ta $listoftextarea {
            $ta configure -insertofftime 2
        }
        update
        after 5
        foreach ta $listoftextarea {
            $ta configure -insertofftime 0
        }
        update
    }
}

proc dorestorecursorblink {} {
    global listoftextarea
    foreach ta $listoftextarea {
        $ta configure -insertofftime 500
    }
}

# End of temporary cursor blinking start/stop
############################

proc dndbinddirentrybox {w} {
# set an entry box to be a drop target for text/plain content
# $w must be an entry widget
    global TkDnDloaded

    # Abort if TkDnD package is not available
    if {!$TkDnDloaded} {
        showmessagemissingtkdndpackage
        return
    }

    # To ensure that the widgets have been created before binding to them
    update idletasks

    # select the current content when the mouse enters the entry box
    dnd bindtarget $w text/plain <DragEnter> {
        focus -force %W
        %W selection range 0 end
    }

    # deselect the current content when the mouse leaves the entry box
    dnd bindtarget $w text/plain <DragLeave> {
        %W selection clear
    }

    # insert the dragged text in the drop target
    dnd bindtarget $w text/plain <Drop> {
        %W delete 0 end
        %W insert end %D
    }
}

proc showmessagemissingtkdndpackage {} {

    global pad show_message_missing_tkdnd
    global wasalreadyinshowmessagemissingtkdndpackage
    global tcl_platform

    if {($tcl_platform(platform) ne "macintosh") && \
        $show_message_missing_tkdnd && \
        ![info exists wasalreadyinshowmessagemissingtkdndpackage]} {
        set wasalreadyinshowmessagemissingtkdndpackage 1
        set tit [mc "Missing package"]
        set mes [concat [mc "Warning: Package TkDnD could not be found. Installation instructions: type help scipad in Scilab."] \
                        [mc "Shall Scipad continue to show this message at each startup?"] ]
        set answ [tk_messageBox -message $mes -type yesno -icon warning -title $tit -parent $pad]
        if {$answ == yes} {
            set show_message_missing_tkdnd true
        } else {
            set show_message_missing_tkdnd false
        }
    }
}
