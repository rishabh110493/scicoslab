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


# This code was borrowed from   http://wiki.tcl.tk/1006
# and was written by Kevin B. Kenny


# The ''consoleAux'' namespace holds variables and procedures
# that help manage the system console on Windows

namespace eval consoleAux {
    namespace export setup;         # Initialization
    namespace export toggle;        # Command to map/unmap the
                                    # console on demand
    variable mapped;                # Flag == 1 iff the console
                                    # is currently mapped
}

#------------------------------------------------------------------
#
# consoleAux::setup --
#
#       Set up the system console control on Windows.
# 
# Parameters:
#       None.
#
# Results:
#       None.
#
# Side effects:
#       Bindings are established so that the variable,
#       '::consoleAux::mapped' is set to reflect the state
#       of the console.
#
# Notes:
#       Depends on undocumented internal API's of Tk and
#       therefore may not work on future releases.
#
#------------------------------------------------------------------

proc consoleAux::setup {} {

    # Make the console have a sensible title
    console title "Scipad debug"
    console eval {

        # Determine whether the console has started in the
        # mapped state.

        if { [winfo ismapped .console] } {
            consoleinterp eval {
                set ::consoleAux::mapped 1
            }
        } else {
            consoleinterp eval {
                set ::consoleAux::mapped 0
            }
        }
        # Establish bindings to reflect the state of the
        # console in the 'mapped' variable.

        bind .console <Map> {
            consoleinterp eval {
                set ::consoleAux::mapped 1
            }
        }
        bind .console <Unmap> {
            consoleinterp eval {
                set ::consoleAux::mapped 0
            }
        }
    }
    return
}

#------------------------------------------------------------------
#
# consoleAux::toggle --
#
#       Change the 'mapped' state of the console in response
#       to a checkbutton.
#
# Parameters:
#       None.
#
# Results:
#       None.
#
# Side effects:
#       If the console is marked 'mapped', shows and raises it.
#       Otherwise, hides it.
#
#------------------------------------------------------------------

proc consoleAux::toggle {} {
    variable mapped
    if {$mapped} {
        console show
        console eval { raise . }
    } else {
        console hide
    }
    return
}

