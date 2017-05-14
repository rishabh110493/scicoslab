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
# file encoding procs
##################################################

proc changeencondingtosystem {} {
# switch the current encoding to the system encoding
# (the default encoding always is the system encoding)
    global currentencoding defaultencoding
    set currentencoding $defaultencoding
    changeencoding
}

proc changeencoding {} {
# if the current textarea shows a file that was never saved before,
#   set the encoding property of the current buffer to be the encoding
#   currently selected in the encoding options menu
# otherwise
#   do the same but also reload the file from disk after having asked
#   the user for confirmation (existing changes, if any, are lost)
    global pad currentencoding listoffile

    setencoding

    set textarea [gettextareacur]

    if {$listoffile("$textarea",new) == 0} {
        # the current textarea shows a file that exists on disk

        set tit [mc "Reload confirm?"]
        set mes [mc "The encoding that will be used when saving file"]
        append mes " " $listoffile("$textarea",fullname) " "
        append mes [mc "has just been modified to"]
        append mes " " $currentencoding ".\n\n"
        append mes [mc "Shall Scipad now additionally reload this file from disk using this new encoding?"]
        if {[ismodified $textarea]} {
            append mes "\n" ">>>>  " [mc "Warning: your existing changes will be lost!"] "  <<<<"
        }

        set answ [tk_messageBox -message $mes -type yesno -icon question -title $tit -parent $pad]

        if {$answ eq yes} {
            revertsaved $textarea NoConfirm
        }

    }

}

proc setencoding {} {
# set the encoding property of the current buffer to be the encoding
# currently selected in the encoding options menu,
# and add this encoding to the list of recent encodings
    global currentencoding listoffile

    set textarea [gettextareacur]
    foreach ta [getfullpeerset $textarea] {
        set listoffile("$ta",encoding) $currentencoding
        modifiedtitle $ta
    }

    # encoding system MUST NOT be modified because the system encoding
    # for the platform on which Scipad is running does not change
    # Saying encoding system $currentencoding here would result in a
    # number of issues such as encoding eating $env:
    # can't read "env(SCIHOME)": no such variable
    # This would happen in a number of situations and can be trimmed down to:
    #    % encoding system
    #    cp1252
    #    % puts $env(TEMP)
    #    C:\DOCUME~1\FRANOI~1\LOCALS~1\Temp
    #    % encoding system gb2312-raw
    #    % puts $env(TEMP)
    #    can't read "env(TEMP)": no such variable
    #    % parray env
    #    missing close-brace 
    # see also: http://groups.google.fr/group/comp.lang.tcl/browse_thread/thread/fef4676cee655d97

    # add in the MRU list of encodings
    AddRecentEncoding $currentencoding
}

proc detectencoding {filename} {
# detect encoding of $filename if it is an xml file
# this is done by looking for the encoding name in the prolog
# of the file
# if detection fails for any reason, the current encoding name is returned
# if detection succeeds, then the returned string is an encoding name
# among the list of known encodings

    global xml_prologstart_RE_rep currentencoding

    # check that the filename extension is xml
    if {[extenstolang $filename] ne "xml"} {
        return $currentencoding
    }
    # extension is xml, read the file using the current encoding
    # if anything fails then return $currentencoding
    if {[catch { \
                set fileid [open $filename r]; \
                fconfigure $fileid -encoding $currentencoding; \
                set allthetext [read -nonewline $fileid]; \
                close $fileid \
               } \
         ]} {
        return $currentencoding
    }

    # regexp match the encoding name in the prolog
    set encodingwasfound [regexp -nocase $xml_prologstart_RE_rep $allthetext -> detectedencoding]
    if {$encodingwasfound} {
        # encoding name found, now contained in $detectedencoding
        # the list of encoding is apparently returned in lower case by [encoding names]
        # therefore the detected encoding name really is the lowercase conversion
        # of what was found in the xml prolog
        set detectedencoding [string tolower $detectedencoding]
        if {[lsearch -exact [encoding names] $detectedencoding] != -1} {
            # detected encoding name is known by Scipad
            return $detectedencoding
        } else {
            # Scipad (in fact Tcl) is not aware of the detected encoding
            # try to remove the dash after iso and check again since
            # iso8859-1 is part of [encoding system] while iso-8859-1 is mentioned
            # in Scilab xml help files
            set detectedencoding2 [string map {iso- iso} $detectedencoding]
            if {[lsearch -exact [encoding names] $detectedencoding2] != -1} {
                # detected encoding name is now known by Scipad
                return $detectedencoding2
            } else {
                # try to add a dash after utf and check again since
                # utf-8 is part of [encoding system] while utf8 might be used
                # in some xml help files although this is incorrect
                set detectedencoding2 [string map {utf utf-} $detectedencoding]
                if {[lsearch -exact [encoding names] $detectedencoding2] != -1} {
                    # detected encoding name is now known by Scipad
                    return $detectedencoding2
                } else {
                    return $currentencoding
                }
            }
        }
    } else {
        # no match in the xml prolog
        return $currentencoding
    }
}
