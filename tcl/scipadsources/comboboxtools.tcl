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

#######################################################################
## Generic procs for dealing with comboboxes
## These procs are gathered in the present file in order to
## keep combobox.tcl (which is a courtesy package) untouched
## as much as possible
#######################################################################

proc sortcombolistboxMRUfirst {comboname selectedvalue} {
# this proc is meant to be called by the -command option of
# comboboxes that populate their listbox through the user input
# in their entry
# it reorders the listbox associated to $comboname such that
# the selected item $selectedvalue climbs to the topmost
# position in it, thus showing the most recently used items first

    # the initial empty string entry (when the dropdown listbox is empty)
    # is of no interest, and shall not be added to the listbox
    # the combobox package removes it as soon as there is a regular entry
    # in the listbox, unless we specifically add the empty string as an
    # entry, which is what we are avoiding right now
    if {$selectedvalue eq ""} {
        return
    }

    set ind [getindexofstringincombo $comboname $selectedvalue]

    if {$ind != -1} {
        $comboname list delete $ind
        $comboname list insert 0 $selectedvalue
    } else {
        # should never happen (since $selectedvalue is a value from
        # the listbox) if this proc is called the way it is supposed
        # to be, i.e. through the -command option of comboboxes
        # in any event, do nothing
    }
}

proc insertentrycontentincombolistbox {comboname {nosizelimit false}} {
# insert the entry box content of a combobox in the topmost place
# of its listbox, if it's not already in the listbox
# an empty entry content is ignored
# if the optional nosizelimit parameter is NOT given (or false),
# then the number of entries in the listbox is at maximum equal to the
# global  $maxnbentriesindropdownlistboxes  (i.e. inserting a new item
# in the listbox will delete the last entry if needed)
# if the optional nosizelimit parameter IS given, then the number of
# entries in the listbox is not limited

    global maxnbentriesindropdownlistboxes

    # get the entry content
    set entrycontent [$comboname get]

    # don't insert empty entries in the listbox
    if {$entrycontent eq ""} {
        return
    }

    set ind [getindexofstringincombo $comboname $entrycontent]

    if {$ind == -1} {
        $comboname list insert 0 $entrycontent
        if {!$nosizelimit} {
            set nbofelts [$comboname list size]
            if {$nbofelts > $maxnbentriesindropdownlistboxes} {
                $comboname list delete end
            } else {
                # nothing to do: number of entries is lower than the requested maximum
            }
        } else {
            # no request for keeping the number of entries in the listbox
            # below a threshold, therefore do nothing
        }
    } else {
        # the entry content is already somewhere in the listbox,
        # then do nothing
    }
}

proc getindexofstringincombo {comboname str} {
# search for $str in the listbox associated to the combobox $comboname
# if found, return the index in this listbox of $str
# if not found, return -1

    # get the content of the listvar
    set listvarcontent [getcombolistvarcontent $comboname]

    if {$listvarcontent ne {}} {
        set ind 0
        foreach elt $listvarcontent {
            if {$elt eq $str} {
                break
            } else {
                incr ind
            }
        }
        if {$ind >= [llength $listvarcontent]} {
            return -1
        } else {
            return $ind
        }
    } else {
        # empty listbox
        return -1
    }
}

proc getcombolistvarcontent {comboname} {
# introspect $comboname to find the content of its listvar variable
    set listvarname [$comboname cget -listvar]
    global $listvarname
    set listvarcontent [eval [list set $listvarname]]
    return $listvarcontent
}

proc setcombolistboxwidthtolargestcontent {comboname} {
# browse the content of the listbox associated to the combobox $comboname
# and set the width of the listbox to the width of the largest element,
# but not less than the width of the combobox

    # get the content of the listvar
    set listvarcontent [getcombolistvarcontent $comboname]

    # do nothing if the listbox is empty, thus keeping the default
    # width of the listbox as set in the combobox package
    # this is better than setting the width to 0, which would be happening
    # if we would not test for empty $listvarcontent
    if {$listvarcontent eq {}} {
        return
    }

    set widest 0
    foreach elt $listvarcontent {
        set eltlen [string length $elt]
        if {$eltlen > $widest} {
            set widest $eltlen
        }
    }
    set combowidth [$comboname cget -width]
    if {$widest < $combowidth} {
        # do nothing: the width will be exactly the width of the full combobox
    } else {
        # add some margin because -dropdownwidth takes a number of *average-sized*
        # characters to display, and this is sometimes a tiny bit not enough to
        # display the full string
        incr widest 2
        $comboname configure -dropdownwidth $widest
    }
}

proc isanycomboboxopened {w} {
# return true if the dropdown listbox of any combobox among the children of $w is displayed
    set res false
    foreach ch [allchildren $w] {
        if {[winfo class $ch] ne "Combobox"} {
            continue
        }
        if {[iscomboboxopened $ch]} {
            set res true
            break
        }
    }
    return $res
}

proc iscomboboxopened {comboname} {
# return true if the dropdown listbox of the combobox $comboname is displayed
    if {[winfo ismapped [$comboname subwidget dropdown]]} {
        return true
    } else {
        return false
    }
}
