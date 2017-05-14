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

proc createmenues {} {
# about performance of this proc, see comments in proc msgcat::mcunknown
    global pad tcl_platform bgcolors fgcolors
    global sourcedir moduledir msgsdir
    global listoffile listoftextarea bindset
    global FirstBufferNameInWindowsMenu
    global FirstMRUFileNameInFileMenu
    global FirstMRUEncodingInOptEncMenu
    global FirstColorEntryInOptionsColorsMenu
    global Shift_Tab
    foreach c1 "$bgcolors $fgcolors" {global $c1}
    global Tk85 standaloneScipad
    global currentencoding defaultencoding nbrecentencodings
    global autodetectencodinginxmlfiles
    global currenteolchar
    global Tkbug3021557_shows_up
    global ScipadprojectatSourceForgeURL ticketentrypointatScipadprojectatSourceForgeURL

    #destroy old menues (used when changing language)
    foreach w [winfo children $pad.filemenu] {
        catch {destroy $w}
    }
    $pad.filemenu delete 0 end

    #file menu
    menu $pad.filemenu.files -tearoff 1
    eval "$pad.filemenu add cascade [me "&File"] -menu $pad.filemenu.files "
    eval "$pad.filemenu.files add command [me "&New"] [ca {filesetasnew}]"
    eval "$pad.filemenu.files add command [me "&Open..."] \
                   [ca {showopenwin currenttile}]"
    menu $pad.filemenu.files.openintile -tearoff 0
    eval "$pad.filemenu.files add cascade [me "Open &in new"]\
      -menu $pad.filemenu.files.openintile"
        eval "$pad.filemenu.files.openintile add command \
                   [me "&horizontal tile"] [ca {showopenwin horizontal}]"
        eval "$pad.filemenu.files.openintile add command \
                   [me "&vertical tile"]   [ca {showopenwin vertical}]"
    eval "$pad.filemenu.files add command [me "Op&en source of..."] \
                   [ca {opensourceof}] "
    eval "$pad.filemenu.files add command [me "&Save"] [ca {filetosavecur}]"
    eval "$pad.filemenu.files add command [me "Save &as..."]\
                   [ca {filesaveascur}]"
    eval "$pad.filemenu.files add command [me "Save a&ll"] -command \"filetosaveall\" "
    eval "$pad.filemenu.files add command [me "&Revert..."] -state disabled\
                    [ca {revertsaved [gettextareacur]}]"
    $pad.filemenu.files add separator
    eval "$pad.filemenu.files add command [me "Import &Matlab file..."] \
                   [ca {importmatlab}]"
    $pad.filemenu.files add separator
    eval "$pad.filemenu.files add command [me "Create help s&keleton..."] \
                   -command \"createhelpfile skeleton\" -state disabled "
    eval "$pad.filemenu.files add command [me "Create help from hea&d comments..."] \
                   -command \"createhelpfile fromsci\" -state disabled "
    eval "$pad.filemenu.files add command [me "Compile as &help page"] \
                   -command \"xmlhelpfile\" -state disabled "
    $pad.filemenu.files add separator
    eval "$pad.filemenu.files add command [me "Open &function source"] \
              [ca {openlibfunsource [[gettextareacur] index insert]}]\
                   -state disabled"
    $pad.filemenu.files add separator
    eval "$pad.filemenu.files add command [me "Print Se&tup"]\
            [ca {printsetup}]"
    eval "$pad.filemenu.files add command [me "&Print"] \
            [ca {selectprint [gettextareacur]}]"
    $pad.filemenu.files add separator
    set FirstMRUFileNameInFileMenu [expr {[$pad.filemenu.files index last] + 1}]
    BuildInitialRecentFilesList
    eval "$pad.filemenu.files add command [me "&Close file"]\
                   [ca {closecurfile yesnocancel}]"
    menu $pad.filemenu.files.closeall -tearoff 0
    eval "$pad.filemenu.files add cascade [me "Close all"]\
      -menu $pad.filemenu.files.closeall"
        eval "$pad.filemenu.files.closeall add command \
                   [me "files &overall"] [ca {closeallreallyall}]"
        eval "$pad.filemenu.files.closeall add command \
                   [me "&files but current one (keep all its views)"] [ca {closeallbutcurrentfilekeeppeers}]"
        eval "$pad.filemenu.files.closeall add command \
                   [me "files but current one (keep &current view only)"] [ca {closeallbutcurrentfileclosepeers}]"
        eval "$pad.filemenu.files.closeall add command \
                   [me "&views of current file (keep current view)"] [ca {closeallviewsofcurrenttabutcurrentview}]"
        eval "$pad.filemenu.files.closeall add command \
                   [me "&hidden views"] [ca {closeallhiddenta}]"
    $pad.filemenu.files add separator
    eval "$pad.filemenu.files add command [me "E&xit"] [ca exitapp_yesnocancel]"
    bind $pad.filemenu.files <<MenuSelect>> {+showinfo_menu_file %W}

    #edit menu
    menu $pad.filemenu.edit -tearoff 1
    eval "$pad.filemenu add cascade [me "&Edit"] -menu $pad.filemenu.edit "
    eval "$pad.filemenu.edit add command [me "&Undo"] \
               [ca {undo [gettextareacur]}]"
    eval "$pad.filemenu.edit add command [me "&Redo"] \
               [ca {redo [gettextareacur]}]"
    $pad.filemenu.edit add separator
    eval "$pad.filemenu.edit add command [me "Cu&t"] [ca {cuttext normal}]"
    eval "$pad.filemenu.edit add command [me "B&lock cut"] [ca {cuttext block}]"
    eval "$pad.filemenu.edit add command [me "&Copy"] [ca copytext]"
    eval "$pad.filemenu.edit add command [me "&Paste"] [ca {pastetext normal}]"
    eval "$pad.filemenu.edit add command [me "&Block paste"] [ca {pastetext block}]"
    eval "$pad.filemenu.edit add command [me "&Delete"] [ca deletetext]"
    $pad.filemenu.edit add separator
    eval "$pad.filemenu.edit add command [me "Select &All"] [ca selectall]"
    # warning when uncommenting this: the underlines of all the Edit menu should
    # be reviewed, currently there is a duplicate on letter t
    #    eval "$pad.filemenu.edit add command [me "Insert &Time/Date"] \
    #               -command \"printtime\" "
    $pad.filemenu.edit add separator
    eval "$pad.filemenu.edit add command [me "Co&mment selection"] \
               [ca CommentSel]"
    eval "$pad.filemenu.edit add command [me "U&ncomment selection"] \
               [ca UnCommentSel]"
    eval "$pad.filemenu.edit add command [me "To&ggle comments in selection"] \
               [ca togglecomments]"
    $pad.filemenu.edit add separator
    eval "$pad.filemenu.edit add command [me "&Indent selection"] \
               [ca IndentSel]"
    eval "$pad.filemenu.edit add command [me "Unin&dent selection"] \
               [ca UnIndentSel]"
    $pad.filemenu.edit add separator
    eval "$pad.filemenu.edit add command [me "Convert &each selected tab into spaces"] \
               [ca converttabstospacesinsel]"
    eval "$pad.filemenu.edit add command [me "Convert each selected group of spaces into &one tab"] \
               [ca convertspacestotabsinsel]"
    eval "$pad.filemenu.edit add command [me "Remove trailing blan&ks in selection"] \
               [ca removetrailingblanksinsel]"
    eval "$pad.filemenu.edit add command [me "Transpose two c&haracters"] \
               [ca transposechars]"
    $pad.filemenu.edit add separator
    eval "$pad.filemenu.edit add command [me "ROT&13 selection"] \
               [ca rot13substitute]"
    $pad.filemenu.edit add separator
    eval "$pad.filemenu.edit add command [me "Turn &single to double quoted string in selection"] \
               [ca convertsinglequotestodoublequotes]"
    $pad.filemenu.edit add separator
    eval "$pad.filemenu.edit add command [me "Selection to lower case"] \
               [ca tolowercase]"
    eval "$pad.filemenu.edit add command [me "Selection to upper case"] \
               [ca touppercase]"
    eval "$pad.filemenu.edit add command [me "Switch case of first letter of words"] \
               [ca switchcase]"
    eval "$pad.filemenu.edit add command [me "Capitalize words"] \
               [ca capitalize]"
    $pad.filemenu.edit add separator
    menu $pad.filemenu.edit.sort -tearoff 0
    eval "$pad.filemenu.edit add cascade [me "Sort"]\
                  -menu $pad.filemenu.edit.sort "
        menu $pad.filemenu.edit.sort.strings -tearoff 0
        eval "$pad.filemenu.edit.sort add cascade [me "As strings"] \
                 -menu $pad.filemenu.edit.sort.strings "
            eval "$pad.filemenu.edit.sort.strings add command [me "Ascending"] \
                     -command \"sortselection -dictionary -increasing\" "
            eval "$pad.filemenu.edit.sort.strings add command [me "Descending"] \
                     -command \"sortselection -dictionary -decreasing\" "
        menu $pad.filemenu.edit.sort.reals -tearoff 0
        eval "$pad.filemenu.edit.sort add cascade [me "As real numbers"] \
                 -menu $pad.filemenu.edit.sort.reals "
            eval "$pad.filemenu.edit.sort.reals add command [me "Ascending"] \
                     -command \"sortselection -real -increasing\" "
            eval "$pad.filemenu.edit.sort.reals add command [me "Descending"] \
                     -command \"sortselection -real -decreasing\" "
    $pad.filemenu.edit add separator
    eval "$pad.filemenu.edit add command [me "Join selected lines"] \
               [ca joinlinesnotspacetrim]"
    eval "$pad.filemenu.edit add command [me "Join selected lines (trim spaces)"] \
               [ca joinlineswithspacetrim]"
    eval "$pad.filemenu.edit add command [me "Reformat selected lines..."] \
               [ca reformatlinesdialog]"

    #search menu
    menu $pad.filemenu.search -tearoff 1
    eval "$pad.filemenu add cascade [me "&Search"] \
               -menu $pad.filemenu.search  "
    eval "$pad.filemenu.search add command [me "&Incremental search..."] \
               [ca {incsearchnext}]"
    $pad.filemenu.search add separator
    eval "$pad.filemenu.search add command [me "&Find..."] \
               [ca {findtextdialog find}]"
    eval "$pad.filemenu.search add command [me "Find &Next"] [ca findnext]"
    eval "$pad.filemenu.search add command [me "Find &Previous"] [ca reversefindnext]"
    $pad.filemenu.search add separator
    eval "$pad.filemenu.search add command [me "&Replace..."] \
               [ca {findtextdialog replace}]"
    $pad.filemenu.search add separator
    eval "$pad.filemenu.search add command [me "&Goto Line..."] [ca gotoline]"

    # exec menu
    menu $pad.filemenu.exec -tearoff 1
    eval "$pad.filemenu add cascade [me "E&xecute"] -menu $pad.filemenu.exec "
    eval "$pad.filemenu.exec add command [me "&Load into Scilab"] \
              [ca execfile]"
    eval "$pad.filemenu.exec add command [me "Load into Scilab (to &cursor)"] \
              [ca execfile_tocursor]"
    eval "$pad.filemenu.exec add command [me "Load &all into Scilab"] \
              [ca execallfiles]"
    eval "$pad.filemenu.exec add command [me "&Evaluate selection"] \
              [ca execselection]"

    #debug menu
# debug menu entries have for now hardwired accelerators, because they are
# handled elsewhere according to the debug state machine
# Their bindings are not changed when switching style
    menu $pad.filemenu.debug -tearoff 1
    eval "$pad.filemenu add cascade [me "&Debug"] -menu $pad.filemenu.debug "
    eval "$pad.filemenu.debug add command [me "&Insert/Remove breakpoint"] \
               -command \"insertremove_bp\" -accelerator F9\
               -image menubutsetbptimage -compound left "
    eval "$pad.filemenu.debug add command [me "&Edit breakpoints"] \
               -command \"showbptgui_bp\" -accelerator Ctrl+F9\
               -image menubuteditbptimage -compound left "
    eval "$pad.filemenu.debug add command [me "Remove &all breakpoints"] \
               -command \"removeallbpt_scipad_bp\" -accelerator Shift+F9\
               -image menubutremoveallimage -compound left "
    $pad.filemenu.debug add separator
    eval "$pad.filemenu.debug add command [me "&Configure execution..."] \
               -command \"configurefoo_bp\" -accelerator F10\
               -image menubutconfigureimage -compound left "
    $pad.filemenu.debug add separator
    eval "$pad.filemenu.debug add command [me "Go to next b&reakpoint"] \
               -command \"tonextbreakpoint_bp\" -accelerator F11\
               -image menubutnextimage -compound left "

    menu $pad.filemenu.debug.step -tearoff 1
    eval "$pad.filemenu.debug add cascade [me "&Step by step"]\
                  -menu $pad.filemenu.debug.step \
                  -image menubutstepimage -compound left "
        eval "$pad.filemenu.debug.step add command [me "Step &into"] \
                 -command \"stepbystepinto_bp\" -accelerator Shift+F8\
                 -image menubutstepenterimage -compound left "
        eval "$pad.filemenu.debug.step add command [me "Step o&ver"] \
                 -command \"stepbystepover_bp\" -accelerator F8\
                 -image menubutstepoverimage -compound left "
        eval "$pad.filemenu.debug.step add command [me "Step &out"] \
                 -command \"stepbystepout_bp\" -accelerator Ctrl+F8\
                 -image menubutstepexitimage -compound left "

    eval "$pad.filemenu.debug add command [me "Run to re&turn point"] \
               -command \"runtoreturnpoint_bp\" -accelerator Shift+F11\
               -image menubutruntoreturnimage -compound left "
    eval "$pad.filemenu.debug add command [me "Run to c&ursor"] \
               -command \"runtocursor_bp\" -accelerator Ctrl+F11\
               -image menubutruntocursorimage -compound left "
    eval "$pad.filemenu.debug add command \
               [me "G&o on ignoring any breakpoint"] \
               -command \"goonwo_bp\" -accelerator Shift+F12\
               -image menubutgoonignorimage -compound left "
    $pad.filemenu.debug add separator
    eval "$pad.filemenu.debug add command [me "Show &watch"] \
               -command \"showwatch_bp\" -accelerator Ctrl+F12\
               -image menubutwatchimage -compound left "
    $pad.filemenu.debug add separator
    eval "$pad.filemenu.debug add command [me "&Break"] \
               -command \"break_bp\" -accelerator F12\
               -image menubutbreakimage -compound left "
    eval "$pad.filemenu.debug add command [me "Cance&l debug"] \
               -command \"canceldebug_bp\" \
               -image menubutcancelimage -compound left "

    # scheme menu
    menu $pad.filemenu.scheme -tearoff 1
    eval "$pad.filemenu add cascade [me "S&cheme"] \
               -menu $pad.filemenu.scheme "
    eval "$pad.filemenu.scheme add radiobutton [me "&Scilab"] \
               -command {changelanguage \"scilab\"} -variable Scheme \
               -value \"scilab\" "
    eval "$pad.filemenu.scheme add radiobutton [me "&XML"] \
               -command {changelanguage \"xml\"} -variable Scheme \
               -value \"xml\" "
    eval "$pad.filemenu.scheme add radiobutton [me "&Modelica"] \
               -command {changelanguage \"modelica\"} -variable Scheme \
               -value \"modelica\" "
    eval "$pad.filemenu.scheme add radiobutton [me "&none"] \
               -command {changelanguage \"none\"} -variable Scheme \
               -value \"none\" "
    $pad.filemenu.scheme add separator
    eval "$pad.filemenu.scheme add checkbutton [me "&Colorize"] \
      -command {switchcolorizefile}\
      -offvalue false -onvalue true -variable ColorizeIt"

    # options menu
    menu $pad.filemenu.options -tearoff 1
    eval "$pad.filemenu add cascade [me "&Options"] \
               -menu $pad.filemenu.options "
    eval "$pad.filemenu.options add command [me "&Fonts..."] \
              [ca choosefonts]"
    eval "$pad.filemenu.options add cascade [me "&Colors"] \
               -menu $pad.filemenu.options.colors"
        menu $pad.filemenu.options.colors -tearoff 1
        eval "$pad.filemenu.options.colors add command [me "&Revert all colors to default"] \
                  [ca updateallcolorstodefault]"
        $pad.filemenu.options.colors add separator
        set FirstColorEntryInOptionsColorsMenu [expr {[$pad.filemenu.options.colors index last] + 1}]
        foreach c $bgcolors {
            eval "$pad.filemenu.options.colors add command [me "$c"] \
                -command {changecolor $c} -background \[set $c\]\
                -foreground $FGCOLOR -activeforeground $FGCOLOR"
        }
        foreach c $fgcolors {
            eval "$pad.filemenu.options.colors add command [me "$c"] \
                -command {changecolor $c} -foreground \[set $c\] \
                -activeforeground \[set $c\] -background $BGCOLOR"
        }
        updateactiveforegroundcolormenu

    menu $pad.filemenu.options.colorizeoptions -tearoff 0
    eval "$pad.filemenu.options add cascade [me "Colori&zation"] \
      -menu $pad.filemenu.options.colorizeoptions"
        menu $pad.filemenu.options.colorizeoptions.colorizeonopen -tearoff 0
        eval "$pad.filemenu.options.colorizeoptions add cascade [me "Colorize on file o&pen"] \
          -menu $pad.filemenu.options.colorizeoptions.colorizeonopen"
            eval "$pad.filemenu.options.colorizeoptions.colorizeonopen add radiobutton [me "&Always"] \
                  -value always -variable colorizeenable "
            eval "$pad.filemenu.options.colorizeoptions.colorizeonopen add radiobutton [me "Ask for &big files"]\
                  -value ask -variable colorizeenable "
            eval "$pad.filemenu.options.colorizeoptions.colorizeonopen add radiobutton [me "&Never"] \
                  -value never -variable colorizeenable "
        $pad.filemenu.options.colorizeoptions add separator
        eval "$pad.filemenu.options.colorizeoptions add checkbutton [me "Colorize \'&strings\'"] \
              -command {refreshQuotedStrings}\
              -offvalue no -onvalue yes -variable scilabSingleQuotedStrings"
        eval "$pad.filemenu.options.colorizeoptions add checkbutton [me "Show c&ontinued lines"] \
              -command {tagcontlinesinallbuffers}\
              -offvalue no -onvalue yes -variable showContinuedLines"
        $pad.filemenu.options.colorizeoptions add separator
        eval "$pad.filemenu.options.colorizeoptions add checkbutton [me "Colorize user &functions"] \
              -command {set previoustimecolorizeuserfun_us 0 ; docolorizeuserfun}\
              -offvalue no -onvalue yes -variable colorizeuserfuns"
        eval "$pad.filemenu.options.colorizeoptions add checkbutton [me "Colorize user &variables"] \
              -command {set previoustimecolorizeuservar_us 0 ; docolorizeuservar ; togglegreyuservartooltipsoptions}\
              -offvalue no -onvalue yes -variable colorizeuservars"
        eval "$pad.filemenu.options.colorizeoptions add checkbutton [me "&Auto release (favor performance)"] \
              -offvalue no -onvalue yes -variable autoreleasecolorization"
        $pad.filemenu.options.colorizeoptions add separator
        eval "$pad.filemenu.options.colorizeoptions add checkbutton [me "&Highlight Modelica annotations"] \
                   -command \"tagModelicaannotationsinallbuffers\" \
                   -offvalue false -onvalue true -variable highlightModelicaannot"
        if {!$Tkbug3021557_shows_up} {
            eval "$pad.filemenu.options.colorizeoptions add checkbutton [me "Hide Modelica &annotations"] \
                       -command \"tagModelicaannotationsinallbuffers\" \
                       -offvalue false -onvalue true -variable hideModelicaannot"
        } else {
            eval "$pad.filemenu.options.colorizeoptions add checkbutton [me "Hide Modelica &annotations"] \
                       -command \"tagModelicaannotationsinallbuffers\" \
                       -offvalue false -onvalue true -variable hideModelicaannot \
                       -state disabled"
        }

    menu $pad.filemenu.options.margins -tearoff 0
    eval "$pad.filemenu.options add cascade [me "&Margins"] \
      -menu $pad.filemenu.options.margins"
      menu $pad.filemenu.options.margins.linenumbers -tearoff 0
      eval "$pad.filemenu.options.margins add cascade [me "&Line numbers"] \
        -menu $pad.filemenu.options.margins.linenumbers"
          eval "$pad.filemenu.options.margins.linenumbers add radiobutton [me "&Hide"] \
            -command {togglelinenumbersmargin}\
            -value hide -variable linenumbersmarginmenusetting"
          eval "$pad.filemenu.options.margins.linenumbers add radiobutton [me "&Left aligned"] \
            -command {togglelinenumbersmargin}\
            -value left -variable linenumbersmarginmenusetting"
          eval "$pad.filemenu.options.margins.linenumbers add radiobutton [me "&Right aligned"] \
            -command {togglelinenumbersmargin}\
            -value right -variable linenumbersmarginmenusetting"
      menu $pad.filemenu.options.margins.modifiedlines -tearoff 0
      eval "$pad.filemenu.options.margins add cascade [me "&Modified lines"] \
        -menu $pad.filemenu.options.margins.modifiedlines"
          eval "$pad.filemenu.options.margins.modifiedlines add checkbutton [me "&Hide"] \
            -command {togglemodifiedlinemargin}\
            -offvalue show -onvalue hide -variable modifiedlinemarginmenusetting"

    menu $pad.filemenu.options.toolbar -tearoff 0
    eval "$pad.filemenu.options add cascade [me "Tool&bar"] \
      -menu $pad.filemenu.options.toolbar"
        eval "$pad.filemenu.options.toolbar add checkbutton [me "&Visible"] \
          -command {toggletoolbarvisible}\
          -offvalue false -onvalue true -variable maintoolbarvisibleflag"
        eval "$pad.filemenu.options.toolbar add checkbutton [me "&Small icons"] \
          -command {redrawmaintoolbar}\
          -offvalue false -onvalue true -variable maintoolbarsmalliconsflag"
    eval "$pad.filemenu.options add checkbutton [me "Word &wrap"] \
      -command {togglewordwrap}\
      -offvalue none -onvalue word -variable wordWrap"
    menu $pad.filemenu.options.uservartooltips -tearoff 0
    eval "$pad.filemenu.options add cascade [me "User &variables tooltips"] \
           -menu $pad.filemenu.options.uservartooltips "
        eval "$pad.filemenu.options.uservartooltips add radiobutton \
          [me "&Always"] \
          -value always -variable showuservartooltips"
        eval "$pad.filemenu.options.uservartooltips add radiobutton \
          [me "Only when &debugging"] \
          -value debug -variable showuservartooltips"
        eval "$pad.filemenu.options.uservartooltips add radiobutton \
          [me "&Never"] \
          -value never -variable showuservartooltips"
    menu $pad.filemenu.options.highlightpbb -tearoff 0
    eval "$pad.filemenu.options add cascade [me "&Highlight matching \( \) \\\[ \\\] \{ \}"] \
           -menu $pad.filemenu.options.highlightpbb "
        eval "$pad.filemenu.options.highlightpbb add radiobutton \
          [me "When &hovering with the mouse"] \
          -value hover -variable highlightmatchingchars"
         eval "$pad.filemenu.options.highlightpbb add radiobutton \
          [me "When the &cursor is nearby"] \
          -value cursor -variable highlightmatchingchars"
         eval "$pad.filemenu.options.highlightpbb add radiobutton \
          [me "In &both cases"] \
          -value both -variable highlightmatchingchars"
       eval "$pad.filemenu.options.highlightpbb add radiobutton \
          [me "&Never"] \
          -value never -variable highlightmatchingchars"
    menu $pad.filemenu.options.doubleclick -tearoff 0
    eval "$pad.filemenu.options add cascade [me "&Double-click behavior"]\
      -menu $pad.filemenu.options.doubleclick"
        eval "$pad.filemenu.options.doubleclick add radiobutton [me "&Linux"] \
              -value Linux -variable doubleclickscheme \
              -command \"updatedoubleclickscheme\" "
        # the underline below cannot be on the first W otherwise it collides
        # with the main menu bar item with same name
        eval "$pad.filemenu.options.doubleclick add radiobutton [me "Windo&ws"] \
              -value Windows -variable doubleclickscheme \
              -command \"updatedoubleclickscheme\" "
        eval "$pad.filemenu.options.doubleclick add radiobutton [me "&Scilab"] \
              -value Scilab -variable doubleclickscheme \
              -command \"updatedoubleclickscheme\" "
    menu $pad.filemenu.options.linenumberstype -tearoff 0
    eval "$pad.filemenu.options add cascade [me "Line numbe&rs type"]\
      -menu $pad.filemenu.options.linenumberstype"
        eval "$pad.filemenu.options.linenumberstype add radiobutton [me "&Physical"] \
          -command {togglelinenumberstype}\
          -value physical -variable linenumberstype"
        eval "$pad.filemenu.options.linenumberstype add radiobutton [me "L&ogical (with continued lines sharing the same line number)"] \
          -command {togglelinenumberstype}\
          -value logical -variable linenumberstype"
        eval "$pad.filemenu.options.linenumberstype add radiobutton [me "Logical (&same as error messages/whereami)"] \
          -command {togglelinenumberstype}\
          -value logical_ignorecontlines -variable linenumberstype"
    eval "$pad.filemenu.options add cascade [me "&Tabs and indentation"] \
               -menu $pad.filemenu.options.tabs"
        menu $pad.filemenu.options.tabs -tearoff 0
        eval "$pad.filemenu.options.tabs add checkbutton [me "Tab inserts &spaces"] \
                    -offvalue tabs -onvalue spaces -variable tabinserts"
        eval "$pad.filemenu.options.tabs add cascade  \
                [me "&Indentation spaces"]\
                -menu [tk_optionMenu $pad.filemenu.options.tabs.indentspaces \
                        indentspaces 1 2 3 4 5 6 7 8 9 10]"
        set tabsizemenu [tk_optionMenu $pad.filemenu.options.tabs.tabsize \
                        tabsizeinchars 1 2 3 4 5 6 7 8]
        eval "$pad.filemenu.options.tabs add cascade  \
                [me "&Tab size (characters)"] -menu $tabsizemenu"
        for {set i 0} {$i<=[$tabsizemenu index last]} {incr i} {
            $tabsizemenu entryconfigure $i -command {settabsize}
        }
        eval "$pad.filemenu.options.tabs add checkbutton [me "Use &keyword indentation"] \
                    -offvalue 0 -onvalue 1 -variable usekeywordindent"
    eval "$pad.filemenu.options add cascade [me "Com&pletion"] \
               -menu $pad.filemenu.options.completion"
        menu $pad.filemenu.options.completion -tearoff 0
        eval "$pad.filemenu.options.completion add radiobutton \
                    [me "&Tab"] -command {SetCompletionBinding}\
                    -value \"Tab\" -variable completionbinding"
        eval "$pad.filemenu.options.completion add radiobutton \
                    [me "&Control-Tab"] -command {SetCompletionBinding}\
                    -value \"Control-Tab\" -variable completionbinding"
        eval "$pad.filemenu.options.completion add radiobutton \
                    [me "&Alt-Tab"] -command {SetCompletionBinding}\
                    -value \"Alt-Tab\" -variable completionbinding"
        eval "$pad.filemenu.options.completion add radiobutton \
                    [me "&Shift-Tab"] -command {SetCompletionBinding}\
                    -value \[list $Shift_Tab\] -variable completionbinding"
        eval "$pad.filemenu.options.completion add radiobutton \
                    [me "C&ontrol-Alt-Tab"] -command {SetCompletionBinding}\
                    -value \"Control-Alt-Tab\" -variable completionbinding"
        eval "$pad.filemenu.options.completion add radiobutton \
                    [me "S&hift-Control-Tab"] -command {SetCompletionBinding}\
                    -value \"Shift-Control-Tab\" -variable completionbinding"
        eval "$pad.filemenu.options.completion add radiobutton \
                    [me "Sh&ift-Alt-Tab"] -command {SetCompletionBinding}\
                    -value \"Shift-Alt-Tab\" -variable completionbinding"
        eval "$pad.filemenu.options.completion add radiobutton \
                    [me "Shi&ft-Control-Alt-Tab"] -command {SetCompletionBinding}\
                    -value \"Shift-Control-Alt-Tab\" -variable completionbinding"
    menu $pad.filemenu.options.filenames -tearoff 0
    eval "$pad.filemenu.options add cascade [me "File&names"] \
           -menu $pad.filemenu.options.filenames "
        eval "$pad.filemenu.options.filenames add radiobutton \
                 [me "&Full path"] \
                 -command {RefreshWindowsMenuLabelsWrtPruning}\
                 -value full -variable filenamesdisplaytype"
        eval "$pad.filemenu.options.filenames add radiobutton \
                 [me "Full path if &ambiguous"] \
                 -command {RefreshWindowsMenuLabelsWrtPruning}\
                 -value fullifambig -variable filenamesdisplaytype"
        eval "$pad.filemenu.options.filenames add radiobutton \
                 [me "&Unambiguous pruned path"]\
                 -command {RefreshWindowsMenuLabelsWrtPruning}\
                 -value pruned -variable filenamesdisplaytype"
        eval "$pad.filemenu.options.filenames add radiobutton \
                 [me "Pruned &directory path"]\
                 -command {RefreshWindowsMenuLabelsWrtPruning}\
                 -value pruneddir -variable filenamesdisplaytype"
    menu $pad.filemenu.options.windmenusort -tearoff 0
    eval "$pad.filemenu.options add cascade [me "Windows menu &sorting"] \
           -menu $pad.filemenu.options.windmenusort "
        eval "$pad.filemenu.options.windmenusort add radiobutton \
                 [me "&File opening order"] -command {sortwindowsmenuentries}\
                 -value openorder -variable windowsmenusorting"
        eval "$pad.filemenu.options.windmenusort add radiobutton \
                 [me "&Alphabetically"] -command {sortwindowsmenuentries}\
                 -value alphabeticorder -variable windowsmenusorting"
        eval "$pad.filemenu.options.windmenusort add radiobutton \
                 [me "&Most recently used"] -command {sortwindowsmenuentries}\
                 -value MRUorder -variable windowsmenusorting"
    menu $pad.filemenu.options.locale -tearoff 0
    eval "$pad.filemenu.options add cascade [me "&Locale"] \
           -menu $pad.filemenu.options.locale "
    foreach l [getavailablelocales] {
        eval "$pad.filemenu.options.locale add radiobutton \
            [me [concat $l locale]] \
            -variable lang -value $l -command relocalize"
    }
# feature enabled yet not 100% ok (see bindings/issues.txt) - teasing!
    menu $pad.filemenu.options.bindings -tearoff 0
    eval "$pad.filemenu.options add cascade [me "B&indings style"] \
           -menu $pad.filemenu.options.bindings "
    foreach bindstyleentry [getswitchablebindnames] {
# REMOVE -state disabled below to make this option menu work
        eval "$pad.filemenu.options.bindings add radiobutton \
            [me $bindstyleentry] -state disabled \
            -variable bindstyle -value $bindstyleentry -command \"rebind\"" 
    }
    menu $pad.filemenu.options.opencloseexit -tearoff 0
    eval "$pad.filemenu.options add cascade [me "Open/Close files, E&xit"] \
           -menu $pad.filemenu.options.opencloseexit "
        eval "$pad.filemenu.options.opencloseexit add cascade [me "Enc&oding"] \
                   -menu $pad.filemenu.options.opencloseexit.encodings"
            menu $pad.filemenu.options.opencloseexit.encodings -tearoff 1
            eval "$pad.filemenu.options.opencloseexit.encodings add command [me "&System encoding"] \
              [ca changeencondingtosystem]"
            $pad.filemenu.options.opencloseexit.encodings entryconfigure end -label \
                    [concat [$pad.filemenu.options.opencloseexit.encodings entrycget end -label] "([encoding system])"]
            $pad.filemenu.options.opencloseexit.encodings add separator
            set FirstMRUEncodingInOptEncMenu [expr {[$pad.filemenu.options.opencloseexit.encodings index last] + 1}]
            BuildInitialRecentEncodingsList
            # if the MRU list of encodings is empty, then add platform system encoding, iso8859-1 and utf-8
            # these encodings are supposed to exist (distributed with Tcl)
            if {$nbrecentencodings == 0} {
                AddRecentEncoding "utf-8"
                AddRecentEncoding "iso8859-1"
                AddRecentEncoding $defaultencoding
            }
            eval "$pad.filemenu.options.opencloseexit.encodings add cascade [me "More enc&odings"] \
                       -menu $pad.filemenu.options.opencloseexit.encodings.more"
                menu $pad.filemenu.options.opencloseexit.encodings.more -tearoff 1
                foreach en [lsort -dictionary [encoding names]] {
                    $pad.filemenu.options.opencloseexit.encodings.more add radiobutton -label $en \
                        -command {changeencoding} -value $en -variable currentencoding
                }
            set recentencodingsnumbmenu [tk_optionMenu $pad.filemenu.options.opencloseexit.encodings.recente \
                            maxrecentencodings 0 1 2 3 4 5 6 7 8 9 10]
            eval "$pad.filemenu.options.opencloseexit.encodings add cascade  [me "&Recent encodings"]\
                       -menu $recentencodingsnumbmenu"
            for {set i 0} {$i<=[$recentencodingsnumbmenu index last]} {incr i} {
                $recentencodingsnumbmenu entryconfigure $i -command {UpdateRecentEncodingsList}
            }
            eval "$pad.filemenu.options.opencloseexit.encodings add checkbutton [me "&Auto-detect encoding when loading XML files"] \
              -offvalue false -onvalue true -variable autodetectencodinginxmlfiles"

        $pad.filemenu.options.opencloseexit add separator
        set recentfilesnumbmenu [tk_optionMenu $pad.filemenu.options.opencloseexit.recentf \
                        maxrecentfiles 0 1 2 3 4 5 6 7 8 9 10 15 20 25 30 35 40 50]
        eval "$pad.filemenu.options.opencloseexit add cascade  [me "&Recent files"]\
                   -menu $recentfilesnumbmenu"
        for {set i 0} {$i<=[$recentfilesnumbmenu index last]} {incr i} {
            $recentfilesnumbmenu entryconfigure $i -command {UpdateRecentFilesList}
        }
        eval "$pad.filemenu.options.opencloseexit add checkbutton [me "Re&member opened files across sessions"] \
          -offvalue false -onvalue true -variable loadpreviouslyopenedfilesonstartup"
        eval "$pad.filemenu.options.opencloseexit add checkbutton [me "Try to detect &binary files"] \
          -offvalue false -onvalue true -variable detectbinaryfiles"
        $pad.filemenu.options.opencloseexit add separator
        menu $pad.filemenu.options.opencloseexit.eolchar -tearoff 0
        eval "$pad.filemenu.options.opencloseexit add cascade [me "Line endin&g character for saving"] \
               -menu $pad.filemenu.options.opencloseexit.eolchar "
            eval "$pad.filemenu.options.opencloseexit.eolchar add radiobutton \
                [me "&Detect when reading files on disk (use platform default if inconsistent)"] \
                 -value detect -variable currenteolchar"
            eval "$pad.filemenu.options.opencloseexit.eolchar add radiobutton \
                [me "CR+LF (&Windows)"] \
                 -value crlf -variable currenteolchar"
            eval "$pad.filemenu.options.opencloseexit.eolchar add radiobutton \
                [me "CR (&Macintosh)"] \
                 -value cr -variable currenteolchar"
            eval "$pad.filemenu.options.opencloseexit.eolchar add radiobutton \
                [me "LF (&Linux/Unix)"] \
                 -value lf -variable currenteolchar"
        eval "$pad.filemenu.options.opencloseexit add cascade  [me "&Backup files depth"]\
                   -menu [tk_optionMenu $pad.filemenu.options.opencloseexit.backup \
                        filebackupdepth 0 1 2 3 4 5 6 7 8 9 10]"
        $pad.filemenu.options.opencloseexit add separator
        eval "$pad.filemenu.options.opencloseexit add checkbutton [me "Show closure &X"] \
          -command {toggleclosureXcross}\
          -offvalue false -onvalue true -variable showclosureXcross"
        eval "$pad.filemenu.options.opencloseexit add checkbutton [me "Exit on &last file close"] \
          -offvalue false -onvalue true -variable exitwhenlastclosed"
    menu $pad.filemenu.options.messageboxes -tearoff 0
    eval "$pad.filemenu.options add cascade [me "Execution &errors"] \
           -menu $pad.filemenu.options.messageboxes "
        eval "$pad.filemenu.options.messageboxes add radiobutton \
            [me "In Scilab &shell only"] \
             -value false -variable ScilabErrorMessageBox"
        eval "$pad.filemenu.options.messageboxes add radiobutton \
            [me "Copied in a &message box"] \
             -value true -variable ScilabErrorMessageBox"
    menu $pad.filemenu.options.scipadupdates -tearoff 0
    eval "$pad.filemenu.options add cascade [me "Scipad &updates"] \
           -menu $pad.filemenu.options.scipadupdates "
        eval "$pad.filemenu.options.scipadupdates add cascade [me "&Check for Scipad updates"] \
                   -menu $pad.filemenu.options.scipadupdates.checkforupdates"
            menu $pad.filemenu.options.scipadupdates.checkforupdates -tearoff 0
# debug entry
#            eval "$pad.filemenu.options.scipadupdates.checkforupdates add radiobutton \
#                [me "Every minute"] \
#                 -value oneminute -variable scipadupdatecheckinterval"
            eval "$pad.filemenu.options.scipadupdates.checkforupdates add radiobutton \
                [me "Every &day"] \
                 -value oneday -variable scipadupdatecheckinterval"
            eval "$pad.filemenu.options.scipadupdates.checkforupdates add radiobutton \
                [me "Every &week"] \
                 -value oneweek -variable scipadupdatecheckinterval"
            eval "$pad.filemenu.options.scipadupdates.checkforupdates add radiobutton \
                [me "Every &month"] \
                 -value onemonth -variable scipadupdatecheckinterval"
            eval "$pad.filemenu.options.scipadupdates.checkforupdates add radiobutton \
                [me "&Never"] \
                 -value never -variable scipadupdatecheckinterval"
        eval "$pad.filemenu.options.scipadupdates add cascade [me "&Internet connection"] \
                   -menu $pad.filemenu.options.scipadupdates.connect"
            menu $pad.filemenu.options.scipadupdates.connect -tearoff 0
            eval "$pad.filemenu.options.scipadupdates.connect add checkbutton \
                [me "Auto&detect proxy configuration (presence, host name and port)"] \
                 -offvalue false -onvalue true -variable autodetectproxy \
                 -command cb_menu_autodetectproxy "
            eval "$pad.filemenu.options.scipadupdates.connect add command \
                [me "&Set proxy name/IP and port"] [ca inputproxyhostandport]"
            $pad.filemenu.options.scipadupdates.connect add separator
            eval "$pad.filemenu.options.scipadupdates.connect add checkbutton \
                [me "Use proxy &authentication"] \
                 -offvalue false -onvalue true -variable proxyauthentication \
                 -command cb_menu_useproxyauth "
            eval "$pad.filemenu.options.scipadupdates.connect add command \
                [me "Set &login and password"] [ca inputproxyauthenticationdata]"
            eval "$pad.filemenu.options.scipadupdates.connect add checkbutton \
                [me "&Remember authentication across sessions"] \
                 -offvalue false -onvalue true -variable rememberauthentication "

    # windows menu
    menu $pad.filemenu.wind -tearoff 1 -title [mc "Opened Files"]
    eval "$pad.filemenu add cascade [me "&Windows"] -menu $pad.filemenu.wind "
    eval "$pad.filemenu.wind add command [me "&Maximize"] \
            [ca {maximizebuffer}] "
    eval "$pad.filemenu.wind add command [me "&Split"] \
            [ca {splitwindow vertical "" tile}] "
    eval "$pad.filemenu.wind add command [me "S&plit (side by side)"] \
            [ca {splitwindow horizontal "" tile}] "
    if {$Tk85} {
        eval "$pad.filemenu.wind add command [me "Sp&lit file"] \
                   [ca {splitwindow vertical "" file}] "
        eval "$pad.filemenu.wind add command [me "Spl&it file (side by side)"] \
                   [ca {splitwindow horizontal "" file}] "
    }
    eval "$pad.filemenu.wind add command [me "Tile all &vertically"] \
               -command \"tileallbuffers vertical\" "
    eval "$pad.filemenu.wind add command [me "Tile all &horizontally"] \
               -command \"tileallbuffers horizontal\" "
    eval "$pad.filemenu.wind add command [me "Space sashes &evenly"] \
               -command \"spaceallsashesevenly\" "
    $pad.filemenu.wind add separator
    eval "$pad.filemenu.wind add command [me "Show previous buffer"] \
               [ca {prevbuffer all}] "
    eval "$pad.filemenu.wind add command [me "Show next buffer"] \
               [ca {nextbuffer all}] "
    eval "$pad.filemenu.wind add command [me "Switch focus to previous already visible buffer"] \
               [ca {prevbuffer visible}] "
    eval "$pad.filemenu.wind add command [me "Switch focus to next already visible buffer"] \
               [ca {nextbuffer visible}] "
    eval "$pad.filemenu.wind add command [me "Show previous hidden buffer in the current tile"] \
               [ca {switchbuffersinpane "current" "backward"}] "
    eval "$pad.filemenu.wind add command [me "Show next hidden buffer in the current tile"] \
               [ca {switchbuffersinpane "current" "forward"}] "
    $pad.filemenu.wind add separator
    # layouts sub-menu
    menu $pad.filemenu.wind.layouts -tearoff 0
    eval "$pad.filemenu.wind add cascade [me "La&youts"] -menu $pad.filemenu.wind.layouts "
        eval "$pad.filemenu.wind.layouts add command [me "&Load layout..."] \
            [ca {openlayout}] "
        eval "$pad.filemenu.wind.layouts add command [me "&Save layout as..."] \
            [ca {savelayoutas}] "
    $pad.filemenu.wind add separator
    set FirstBufferNameInWindowsMenu [expr {[$pad.filemenu.wind index last] + 1}]
    foreach ta $listoftextarea {
        set taid [gettaidfromwidgetname $ta]
        addwindowsmenuentry $taid $listoffile("$ta",displayedname)
    }
    bind $pad.filemenu.wind <<MenuSelect>> {+showinfo_menu_wind %W}

    # help menu
    menu $pad.filemenu.help -tearoff 1
    eval "$pad.filemenu add cascade [me "&Help"] \
               -menu $pad.filemenu.help "
    eval "$pad.filemenu.help add command [me "&Help..."] [ca helpme]"
    eval "$pad.filemenu.help add command [me "&What's?..."] [ca helpword]"
    $pad.filemenu.help add separator
    eval "$pad.filemenu.help add command [me "Change&log"] \
           -command {textbox [file join {$moduledir} changelog.txt] \
           \"[mc "Changes in the Scipad codebase"]\"}"
    eval "$pad.filemenu.help add command [me "&Bugs \& wishlist"] \
            -command {textbox [file join {$moduledir} BUGS] \
             \"[mc "Scipad known bugs"]\"}"
    eval "$pad.filemenu.help add command [me "&Report a Scipad bug"] \
             -command {invokebrowser $ticketentrypointatScipadprojectatSourceForgeURL}"
    eval "$pad.filemenu.help add command [me "Adding &translations"] \
             -command {textbox [file join $msgsdir AddingTranslations.txt] \
              \"[mc "Adding Scipad Translations"]\"}"
    $pad.filemenu.help add separator
    eval "$pad.filemenu.help add command [me "&Scipad website"] \
             -command {invokebrowser $ScipadprojectatSourceForgeURL}"
    eval "$pad.filemenu.help add command [me "Check for newer Scipad &versions"] \
             -command {userrequestcheckfornewerscipadversion}"
    $pad.filemenu.help add separator
    eval "$pad.filemenu.help add command [me "&About"] \
             -command aboutme -accelerator Shift+F1"
## additional hacker entries, some disabled for the moment
# in case they become enabled, entries must be added in the msg files
#    eval "$pad.filemenu.help add command \
#            [me "&edit msg file"] \
#            -command {openfile [file join $msgsdir \$lang.msg]}"

    # add entries in the system menu
    if {$tcl_platform(platform) eq "windows"&& $standaloneScipad} {
        menu $pad.filemenu.system -tearoff 0
        eval "$pad.filemenu add cascade [me "System"] \
                -menu $pad.filemenu.system "
        ::consoleAux::setup
        eval "$pad.filemenu.system add checkbutton [me "Show console"] \
                -variable ::consoleAux::mapped -command ::consoleAux::toggle"
    }

    # now make the menu bar visible
    $pad configure -menu $pad.filemenu

    # create array of menu entries identifiers
    # this array allows to avoid to refer to menu entries by their hardcoded id
    createarrayofmenuentriesid $pad.filemenu

    # set the correct font for menues, including tk_optionMenues, that do not
    # have a -font option - also set the tab size since updatefont all will
    # call settabsize
    updatefont all

    # make the normal/disable state of uservar tooltips entry of the options menu
    # consistent with colorization enabling of user variables
    togglegreyuservartooltipsoptions

    # enable/disable the proxy options menu entries
    togglegreyproxyoptions
}

proc disablemenuesbinds {} {
# Disable certain menu entries and bindings
# This is used to avoid event overlapping that would trigger repeated calls
# to certain procs that do not support multiple instances running at the same
# time. proc tileallbuffer (because of the textarea destroy) is such an example.
# Scipad exit (File/Exit or clicking on [x]) does not make use of this
# facility to avoid hangs - the user can always escape out
    global pad nbrecentfiles FirstBufferNameInWindowsMenu listoftextarea
    global tileprocalreadyrunning
    global Tk85
    set tileprocalreadyrunning true
    # File/Close
    set iClose [expr {[GetFirstRecentFileInd] + $nbrecentfiles + 1}]
    $pad.filemenu.files entryconfigure $iClose -state disabled
    binddisable $pad {closecurfile yesnocancel}
    # Windows menu entries
    set lasttoset [expr {$FirstBufferNameInWindowsMenu - 2}]
    for {set i 1} {$i<=$lasttoset} {incr i} {
        if {[$pad.filemenu.wind type $i] ne "separator"} {
            $pad.filemenu.wind entryconfigure $i -state disabled
        }
    }
    bind $pad <Control-Key-1> ""
    bind $pad <Control-Key-2> ""
    bind $pad <Control-Key-3> ""
    if {$Tk85} {
        bind $pad <Control-Alt-Key-2> ""
        bind $pad <Control-Alt-Key-3> ""
    }
    # Close and hide buttons in the tile titles
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {
            [getpaneframename $ta].topbar.f.clbutton configure -state disabled
            [getpaneframename $ta].topbar.f.hibutton configure -state disabled
        }
    }
}

proc restoremenuesbinds {} {
# Restore menu entries and bindings disabled previously by proc disablemenuesbinds
    global pad nbrecentfiles FirstBufferNameInWindowsMenu listoftextarea
    global tileprocalreadyrunning
    global Tk85
    # File/Close
    set iClose [expr {[GetFirstRecentFileInd] + $nbrecentfiles + 1}]
    $pad.filemenu.files entryconfigure $iClose -state normal
    bindenable $pad {closecurfile yesnocancel}
    # Windows menu entries
    set lasttoset [expr {$FirstBufferNameInWindowsMenu - 2}]
    for {set i 1} {$i<=$lasttoset} {incr i} {
        if {[$pad.filemenu.wind type $i] ne "separator"} {
            $pad.filemenu.wind entryconfigure $i -state normal
        }
    }
    bind $pad <Control-Key-1> "$pad.filemenu.wind invoke 1"
    bind $pad <Control-Key-2> "$pad.filemenu.wind invoke 2"
    bind $pad <Control-Key-3> "$pad.filemenu.wind invoke 3"
    if {$Tk85} {
        bind $pad <Control-Alt-Key-2> "$pad.filemenu.wind invoke 4"
        bind $pad <Control-Alt-Key-3> "$pad.filemenu.wind invoke 5"
    }
    # Close and hide buttons in the tile titles
    foreach ta $listoftextarea {
        if {[isdisplayed $ta]} {
            [getpaneframename $ta].topbar.f.clbutton configure -state normal
            [getpaneframename $ta].topbar.f.hibutton configure -state normal
        }
    }
    set tileprocalreadyrunning false
}

proc getlastvisibletextareamenuind {} {
# get the index in the windows menu of the last entry of this menu
# that is visible (i.e. packed in a pane)
# note that there is always such an entry
    global pad FirstBufferNameInWindowsMenu
    set found 0
    set i [$pad.filemenu.wind index end]
    while {$i >= $FirstBufferNameInWindowsMenu} {
        if {[isdisplayed $pad.new[$pad.filemenu.wind entrycget $i -value]]} {
            set found 1
            break
        }
        incr i -1
    }
    if {$found == 1} {
        return $i
    } else {
        # shouldn't happen
        tk_messageBox -message "Impossible case in proc getlastvisibletextareamenuind: please report"
        return ""
    }
}

proc getlasthiddentextareamenuind {} {
# get the index in the windows menu of the last entry of this menu
# that is not visible (i.e. packed in a pane), or "" if all buffers
# are visible
    global pad FirstBufferNameInWindowsMenu
    set found 0
    set i [$pad.filemenu.wind index end]
    while {$i >= $FirstBufferNameInWindowsMenu} {
        if {![isdisplayed $pad.new[$pad.filemenu.wind entrycget $i -value]]} {
            set found 1
            break
        }
        incr i -1
    }
    if {$found == 1} {
        return $i
    } else {
        return ""
    }
}

proc getlasthiddentextareaid {} {
# get the -value option ($textareaid) of the last entry of the windows menu
# that is not visible (i.e. packed in a pane), or "" if all buffers
# are visible
    global pad
    set i [getlasthiddentextareamenuind]
    if {$i != ""} {
        return [$pad.filemenu.wind entrycget $i -value]
    } else {
        return ""
    }
}

proc extractindexfromlabel {dm labsearched} {
# extractindexfromlabel is here to cure bugs with special filenames, and
# to deal with labels with an underlined number prepended
# This proc should be used as a replacement for [$menuwidget index $label]
# It returns the index of entry $label in $menuwidget, even if $label is a
# number or an index reserved name (see the Tcl/Tk help for menu indexes)
# The leading underlined number is not considered to be part of the label
# and is ignored
# If $label is not found in $menuwidget, it returns -1
    global pad FirstBufferNameInWindowsMenu
    global FirstMRUFileNameInFileMenu nbrecentfiles

    if {$dm == "$pad.filemenu.wind"} {
        set startpoint $FirstBufferNameInWindowsMenu
        set stoppoint  [$dm index last]
    } elseif {$dm == "$pad.filemenu.files"} {
        set startpoint $FirstMRUFileNameInFileMenu
        set stoppoint  [expr {$FirstMRUFileNameInFileMenu + $nbrecentfiles}]
    } else {
        tk_messageBox -message "Unexpected menu widget in proc extractindexfromlabel ($dm): please report"
    }

    for {set i $startpoint} {$i<=$stoppoint} {incr i} {
        if {[$dm type $i] != "separator" && [$dm type $i] != "tearoff"} {
            set lab [$dm entrycget $i -label]
            # the first labels have an underlined number prepended
            # that must be removed before comparison to the searched label
            # if there are at least 9 entries in the windows menu, then almost always
            # there are 9 labels having such an underlined leading number
            # there is an exception where there are only 8 such labels, which is
            # during closure of a textarea (proc byebyeta)
            # this exception must be checked by ensuring that we do not remove
            # the prepended number for labels not having an underline, otherwise
            # this proc fails when a file such as "2 tests.sci" is placed in position 9
            # during the closure of a textarea located before position 9 in the windows
            # menu
            # ...and then there is no need to check if {$i < [expr {$startpoint + 9}]}
            # anymore, just check whether the label has an underline!
            if {[$dm entrycget $i -underline] == 0} {
                regexp {^[1-9] (.*)} $lab -> lab
            }
            if {$lab eq $labsearched} {
                return $i
            }
        }
    }
    return -1
}

proc setwindowsmenuentrylabel {entry lab {sortmenu "sortmenu"}} {
# set the label of entry $entry of the windows menu
# $entry is relative to the start of the menu, i.e. to entry #0,
# and not to $FirstBufferNameInWindowsMenu
# $lab is the label without any leading underlined number
# the optional argument sortmenu is a flag allowing to sort the
# Windows menu, it should always be "sortmenu" (or not given)
# the only exception being precisely when sorting the menu, i.e.
# when called from proc sortwindowsmenuentries (this would otherwise
# create an infinite recursion)
# this proc takes care of updating the entry label with or without
# an underlined number prepended, depending on the position of the
# entry in the menu (only the first 9 entries have such an
# underlined number)
    global pad FirstBufferNameInWindowsMenu

    if {$entry < $FirstBufferNameInWindowsMenu} {
        tk_messageBox -message "setwindowsmenuentrylabel: entry parameter is $entry,\
                                which is less than $FirstBufferNameInWindowsMenu.\
                                This should never happen, please report!"
    }

    set underlinednumber [expr {$entry - $FirstBufferNameInWindowsMenu + 1}]

    if {$underlinednumber < 10} {
        # here I first used
        #   set underlinedlabel [concat $underlinednumber $lab]
        # but concat trims spaces at the beginning of $lab, which will later
        # fool the regexp matching
        #   regexp {^[1-9] (.*)} $lab -> lab
        # in proc extractindexfromlabel
        set underlinedlabel "$underlinednumber $lab"
        $pad.filemenu.wind entryconfigure $entry \
           -label $underlinedlabel -underline 0
    } else {
        $pad.filemenu.wind entryconfigure $entry \
           -label $lab
    }

    if {$sortmenu eq "sortmenu"} {
        sortwindowsmenuentries
    }

}

proc addwindowsmenuentry {val lab} {
# add an entry at the end of the windows menu, and prepend an underlined
# number if possible
# inputs: $val : -value of the variable attached to the radiobutton
#         $lab : -label of the menu entry, without any leading number
    global pad
    $pad.filemenu.wind add radiobutton \
        -value $val -variable textareaid \
        -command "showtext $pad.new$val"
    setwindowsmenuentrylabel [$pad.filemenu.wind index end] $lab
}

proc sortwindowsmenuentries {} {
    global pad listoftextarea
    global FirstBufferNameInWindowsMenu

    set li [getwindowsmenusortedlistofta $listoftextarea]

    set i $FirstBufferNameInWindowsMenu
    foreach item $li {
        foreach {ta lab mtim} $item {}
        set taid [gettaidfromwidgetname $ta]
        $pad.filemenu.wind entryconfigure $i \
            -value $taid \
            -command "showtext $ta"
        setwindowsmenuentrylabel $i $lab "dontsort"
        salmonizewindowsmenuentry $i $ta
        incr i
    }
}

proc salmonizewindowsmenuentry {ent ta} {
    global pad
    if {[ismodified $ta]} {
        $pad.filemenu.wind entryconfigure $ent -background Salmon \
            -activebackground LightSalmon
    } else {  
        $pad.filemenu.wind entryconfigure $ent -background "" \
            -activebackground ""
    }
}

proc createarrayofmenuentriesid {root} {
# create a global array containing the menu entries index
# $MenuEntryId($menu_pathname.$entry_label) == menu entry id in $menu_pathname
# note: $entry_label is localized (it is the label that appears in the menu)
# For instance, in french locale, we have:
#         $MenuEntryId($pad.filemenu.files.Nouveau) == 0
    global MenuEntryId
    foreach w [winfo children $root] {
        if {[catch {set temp [$w index last]}] != 0} {
            # this is to handle the case of the tk_optionMenu menues
            set w $w.menu
        }
        for {set id 0} {$id<=[$w index last]} {incr id} {
            if {[$w type $id] == "command" || \
                [$w type $id] == "radiobutton" || \
                [$w type $id] == "checkbutton" || \
                [$w type $id] == "cascade"} {
                set MenuEntryId($w.[$w entrycget $id -label]) $id
            }
            if {[$w type $id] == "cascade"} {
                createarrayofmenuentriesid $w
            }
        }
    }
}

proc showinfo_menu_file {w} {
# display full pathname of a recent file entry of the file menu
# as a showinfo
    global pad nbrecentfiles listofrecentfiles
    if {$nbrecentfiles > 0} {
        set rec1ind [GetFirstRecentFileInd]
        set recnind [expr {$rec1ind + $nbrecentfiles - 1}]
        set mouseentry [$w index active]
        if {$rec1ind<=$mouseentry && $mouseentry<=$recnind} {
            showinfo [lindex $listofrecentfiles [expr {$mouseentry - $rec1ind}]]
        }
    }
}

proc showinfo_menu_wind {w} {
# display full pathname of a file entry of the windows menu
# as a showinfo
    global pad FirstBufferNameInWindowsMenu listoffile listoftextarea
    set mouseentry [$w index active]
    if {$mouseentry=="none"} {
        # can happen when hovering over a separator
        # we must return otherwise the last menu entry is used for
        # the showinfo
        return
    }
    if {$FirstBufferNameInWindowsMenu<=$mouseentry} {
        foreach ta $listoftextarea {
            set ind [extractindexfromlabel $pad.filemenu.wind $listoffile("$ta",displayedname)]
            if {$ind==$mouseentry} {
                break
            }
        }
        showinfo $listoffile("$ta",fullname)
    }
}

proc ca {menucommand} {
# look up the bindings array to see if there is a binding defined
# for the given command, and in case generate a -command -accelerator pair
    set event [findbinding $menucommand]
    if {$event == ""} {
        return "-command {$menucommand}"
    } else {
        regsub -all {Control} $event {Ctrl} kevent
        regsub -all {underscore} $kevent {_} kevent
        regsub -all {backslash} $kevent {\\\\} kevent
        regsub -all {slash} $kevent {/} kevent
        regsub -all {percent} $kevent {%} kevent
        regsub -all {exclam} $kevent {!} kevent
        regsub -all {Key-} $kevent {} kevent
        regsub -all {\-} $kevent {+} kevent
        regsub -all {><} $kevent { } kevent
        regsub {>\Z} $kevent {} kevent
        regsub {\A<} $kevent {} kevent
        return "-command {$menucommand} -accelerator \"$kevent\""
    }
}

proc filteroutmenuclones {listofwidgets} {
# take a list of widget names and return this list without the names
# denoting menues of type menubar or tearoff, which are menu clones
# Reference:
# http://groups.google.com/group/comp.lang.tcl/browse_frm/thread/87adc111127063bc/05efee764b23540d
    set nomenubar [list ]
    foreach item $listofwidgets {
        if {[winfo class $item] != "Menu"} {
            lappend nomenubar $item
        } else {
            if {[$item cget -type] != "menubar" && [$item cget -type] != "tearoff"} {
                lappend nomenubar $item
            } else {
                # drop it
            }
        }
    }
    return $nomenubar
}

proc concatmenues {listofmenues} {
# make a menu from the menues listed in $listofmenues
# the returned menu contains all items from all menues modulo the following:
#   1. the tearoff entry, if present, is removed
#   2. the entries from menu_i are separated from the entries from menu_i+1
#      by a separator
#   3. cascade entries are not supported (thus ignored)
#   4. underlines are removed
#   5. shortcuts (accelerators) are removed (to avoid duplicates)
    global pad
    catch {destroy $pad.retmenu}
    menu $pad.retmenu
    foreach amenu $listofmenues {
        for {set i 0} {$i<=[$amenu index last]} {incr i} {
            if {[$amenu type $i] eq "command" || \
                [$amenu type $i] eq "radiobutton" || \
                [$amenu type $i] eq "checkbutton"} {
                $pad.retmenu add [$amenu type $i]
                foreach optioninfo [$amenu entryconfigure $i] {
                    foreach {optname synoptname classname defval curval} $optioninfo {
                        $pad.retmenu entryconfigure [$pad.retmenu index last] $optname $curval
                    }
                }
                $pad.retmenu entryconfigure [$pad.retmenu index last] -accelerator "" -underline -1
            } elseif {[$amenu type $i] eq "separator"} {
                $pad.retmenu add separator
            } elseif {[$amenu type $i] eq "tearoff"} {
                # cascade items not supported
                # tearoff item ignored
            }
        }
        $pad.retmenu add separator
    }
    # remove the spurious separator at the bottom of the result menu
    $pad.retmenu delete end
    # explicitely remove the tearoff entry
    $pad.retmenu configure -tearoff 0
    return $pad.retmenu
}

proc togglegreyuservartooltipsoptions {} {
# tooltips showing user variables content need colorization since they
# are triggered by a binding to the uservar tag
# this proc enables or disables the options related to the uservar
# tooltips in the options menu, depending on the value of $colorizeuservars
    global colorizeuservars pad MenuEntryId
    if {$colorizeuservars} {
        $pad.filemenu.options entryconfigure \
                $MenuEntryId($pad.filemenu.options.[mcra "User &variables tooltips"]) \
                -state normal
    } else {
        $pad.filemenu.options entryconfigure \
                $MenuEntryId($pad.filemenu.options.[mcra "User &variables tooltips"]) \
                -state disabled
    }
}

proc togglegreyproxyoptions {} {
# grey out as required the Internet connection sub-menu entries in the options menu

    global pad MenuEntryId internetpackagesloaded
    global useaproxy autodetectproxy proxyauthentication rememberauthentication

    if {!$internetpackagesloaded} {
        $pad.filemenu.options entryconfigure \
                $MenuEntryId($pad.filemenu.options.[mcra "Scipad &updates"]) \
                -state disabled
        # "Check for newer Scipad versions" is not greyed out, since a message
        # box will tell the user that required packages could not be found
        return
    }

    if {$useaproxy} {

        # a proxy was either autodetected or manually set

        # if autodetect is geared in, one should not be able to set host name
        # and port manually (clearer for the user about what info is really used
        # for the connection)
        if {$autodetectproxy} {
            $pad.filemenu.options.scipadupdates.connect entryconfigure \
                    $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "&Set proxy name/IP and port"]) \
                    -state disabled
        } else {
            $pad.filemenu.options.scipadupdates.connect entryconfigure \
                    $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "&Set proxy name/IP and port"]) \
                    -state normal
        }

        # use of authentication is possible for any proxy, be it autodetected or not
        $pad.filemenu.options.scipadupdates.connect entryconfigure \
                $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "Use proxy &authentication"]) \
                -state normal

        # if proxy authentication is requested, then ungrey the two related items
        if {$proxyauthentication} {
            $pad.filemenu.options.scipadupdates.connect entryconfigure \
                    $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "Set &login and password"]) \
                    -state normal
            $pad.filemenu.options.scipadupdates.connect entryconfigure \
                    $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "&Remember authentication across sessions"]) \
                    -state normal
        } else {
            $pad.filemenu.options.scipadupdates.connect entryconfigure \
                    $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "Set &login and password"]) \
                    -state disabled
            set rememberauthentication false
            $pad.filemenu.options.scipadupdates.connect entryconfigure \
                    $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "&Remember authentication across sessions"]) \
                    -state disabled
        }

    } else {

        # $useaproxy is false, i.e. autodetection did not find any proxy
        # therefore Scipad supposes the Internet connection is direct
        # and all options are greyed but "Autodetect proxy"
        # "Use authentication" and "Rmemeber authentication" are unset so
        # that it's clearer in the menu that no proxy will be used, and so
        # that Scipad will not save login/password in the preferences file
        $pad.filemenu.options.scipadupdates.connect entryconfigure \
                $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "&Set proxy name/IP and port"]) \
                -state disabled
        set proxyauthentication false
        $pad.filemenu.options.scipadupdates.connect entryconfigure \
                $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "Use proxy &authentication"]) \
                -state disabled
        $pad.filemenu.options.scipadupdates.connect entryconfigure \
                $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "Set &login and password"]) \
                -state disabled
        set rememberauthentication false
        $pad.filemenu.options.scipadupdates.connect entryconfigure \
                $MenuEntryId($pad.filemenu.options.scipadupdates.connect.[mcra "&Remember authentication across sessions"]) \
                -state disabled
    }
}
