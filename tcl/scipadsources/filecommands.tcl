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

#####################################################################
#
# About the variables used:
#
#   $winopened
#       Opened buffer ID.
#       $winopened starts from 1 (1 is the first buffer opened)
#       It is never decreased
#       It is increased each time a new file is opened
#       A file saved as another name keeps its $winopened value
#       The radionbutton entry in the windows menu has a -value
#       option containing the $winopened consistent with the name
#       of the menu entry (see below at the end of this comment)
#
#   $textareaid
#       This is the unique identifier of the text widget displaying
#       the content of a given file. When a new textarea is created,
#       it is given the $winopened value in $textareaid
#
#   $pad.new$textareaid
#       Buffer name. This is the unique pathname of the text widget
#       displaying the content of a file. This is usually referred to
#       as $textarea, or $ta for short
#       This text widget is packed in a frame that is itself added
#       as a pane in possibly nested panedwindows
#
#   $listoftextarea
#       Contains the list of the above opened textarea names.
#       Order of the elements matters (increasing order mandatory,
#       i.e. $pad.newX must be placed before $pad.newY if X < Y)
#       The order of the buffers in $listoftextarea is actually the
#       order of opening of the buffers (note: the order in the
#       Windows menu is only a display order)
#
#
#   A textarea name $ta can be used as a pointer to file or buffer
#   attributes:
#
#     $listoffile("$ta",fullname)
#       Full path+name of the file on disk that is displayed in $ta
#       Exception: new file not yet saved on disk. In this case it is
#       the same as listoffile("$ta",displayedname)
#
#     $listoffile("$ta",displayedname)
#       Displayed name of the file on disk that is displayed in $ta
#       This may be:
#         - the shortest unambiguous reference to that file
#         - the full pathname of that file
#       The displayed name does not contain the underlined number shown
#       in the Windows menu - This number is only found in the -label of
#       this menu
#       However the displayed name includes the appended peer id <id>,
#       if the textarea has peers
#
#     $listoffile("$ta",new)
#       0: file was opened from disk
#       1: file is a new file
#
#     $listoffile("$ta",save)
#       0: file is unmodified
#       1: file has been modified and should be saved before leaving Scipad
#      Note: Starting from Scipad 5.3, this setting is deprecated and replaced
#            by the text widget embedded modified flag associated to the undo
#            stack - it shouldn't be found any longer in the source code
#
#     $listoffile("$ta",readonly)
#       0: file can be written
#       1: file is read only
#
#     $listoffile("$ta",binary)
#       0: file is believed (by Scipad) to be a text file
#       1: file is detected to be a binary file (note this detection may fail)
#
#     $listoffile("$ta",thetime)
#       Time of the last file modification on disk by Scipad
#
#     $listoffile("$ta",disksize)
#       Size of the file on disk when last opened or saved by Scipad
#
#     $listoffile("$ta",language)
#       Language scheme. Currently can be scilab, xml, modelica or none
#
#     $listoffile("$ta",undostackdepth)
#       Depth of the undo stack. Used for enabling/disabling the undo menu entry
#
#     $listoffile("$ta",redostackdepth)
#       Depth of the redo stack. Used for enabling/disabling the redo menu entry
#
#     $listoffile("$ta",undostackmodifiedlinetags)
#       Undo stack containing modified line tags (the colored tags showing what
#       lines were unsaved and modified, or saved and modified)
#
#     $listoffile("$ta",redostackmodifiedlinetags)
#       Redo stack containing modified line tags (the colored tags showing what
#       lines were unsaved and modified, or saved and modified)
#
#     $listoffile("$ta",progressbar_id)
#       If colorization is in progress, this is the progressbar identifier
#       Otherwise it's an empty string
#
#     $listoffile("$ta",colorize)
#       true: file gets colorized
#       false: no colorization for this file
#
#     $listoffile("$ta",encoding)
#       Name of the encoding in which the file is stored,
#       e.g. utf-8 or euc-jp or cp1252 or a lot of other possibilities
#       See SEP#12 for a complete description of the encodings support in Scipad
#
#     $listoffile("$ta",eolchar)
#       Line ending character used by the file on disk at the time of reading
#       the file content from disk
#       This may be "crlf", "cr", or "lf" (the "mixed" case defaults to
#       [platformeolchar], see proc warnifchangedlineendings)
#
#   The windows menu entries are radionbuttons, with the following
#   properties:
#     -value is $winopened  (value of $winopened at the time of the radiobutton
#      creation)
#     -label is $listoffile("$ta",displayedname), $ta being $pad.new$winopened
#      (again, $winopened value at the time of the creation)
#     This label is prepended by an underlined number (for the first 9 entries
#     only)
#     This label is also appended by a peer identifier <X> if relevant
#     All the labels of the menu are different at any time, except
#     during ambiguities removal (In the Options menu, item Filenames does
#     not propose any option that would lead to ambiguous file names)
#     It is very important to maintain this property throughout the code
#     because extractindexfromlabel relies on this and is used everywhere.
#     Actually what must be different is the real displayed filename,
#     i.e. the label without the leading underlined number and without
#     the peer identifier
#
#####################################################################

source [file join $sourcedir filenew.tcl]
source [file join $sourcedir fileclose.tcl]
source [file join $sourcedir exit.tcl]
source [file join $sourcedir fileopen.tcl]
source [file join $sourcedir filesave.tcl]
source [file join $sourcedir filerevert.tcl]
source [file join $sourcedir fileencoding.tcl]
source [file join $sourcedir filelineending.tcl]
source [file join $sourcedir fileancillaries.tcl]
source [file join $sourcedir prunefilename.tcl]
