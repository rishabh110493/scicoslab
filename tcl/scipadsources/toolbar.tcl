#########################################################################################
#
# Code largely edited by F. Vogel, 2011
#
# A lot of changes were made so that this package better fits my needs for Scipad.
# Namely, in no particular order, and this is probably not an exhaustive list:
#
# - Moved  package require msgcat  at the top of the file
#
# - Added a lot of empty lines and spaces to lighten the code and make it more
#   readable for me
#
# - Documented arrays  DefaultOption  and  ToolbarSpecifications
#
# - Removed unused variables here and there
#
# - Reworked the bindings and options in proc addwidget such that the relief and
#   background are no longer changed when hovering over non-button widgets in a
#   toolbar, which should not happen IMHO
#
# - CreateToolbarWindow:
#     . Prevented floating toolbars to be resized
#     . Commented a binding
#         The following binding in  toolbar.tcl  would unexpectedly redock floating
#         toolbars:
#            bind [winfo toplevel $toolbar] <Destroy> \
#             "+catch \"destroy $win\""
#         Whenever  destroy $textarea  is issued, <Destroy> triggers on $pad as well
#         This is because the <Destroy> event is applied in turn to each element
#         of  [bindtags $textarea]  , which is  {$textarea Text $pad all}
#         Because of the binding above, this would launch  destroy $toolbar.fltWin
#         and then trigger <Destroy> on the floating toolbar $toolbar.fltWin which docks
#         (mounts) the floating toolbar.
#         Fix: The binding above can just be commented, because the floating toolbars
#              will automatically be destroyed when closing Scipad since children of
#              $pad will be destroyed by  destroy $pad  in proc killscipad
#     . Localized the name of the floating toolbar
#
# - Added -showifh and -showifv options for handles, buttons and widgets, and the
#   corresponding entries in the ToolbarSpecifications array:
#     ToolbarSpecifications(ListOfChilds:$toolbar),
#     ToolbarSpecifications(PackedIfHorizontal:$widget:$toolbar) and
#     ToolbarSpecifications(PackedIfVertical:$widget:$toolbar)
#
#########################################################################################


#########################################################################################
#
# Documentation about the variables
#      DefaultOption
# and
#      ToolbarSpecifications
#
#####################################
#
#    DefaultOption  array
#
#####################################
#
# DefaultOption(ToolbarBackground)
#    Default background color of the toolbar frame, of the frame $toolbar.widgets
#    containing the buttons and other toolbar widgets, and of the buttons themselves
#    (but not of the toolbar widgets)
#
# DefaultOption(ToolbarHandleBackground)
#    Default background color of the toolbar handle
#
# DefaultOption(SelectBackground)
#    Default background color of the toolbar when it is highlighted during a mount
#    (dock) operation
#
# DefaultOption(ToolbarImageHandle)
#    If true, then toolbar handles are show using bitmap images named IToolbar
#    (for a horizontal toolbar) and IToolbarVertical (vertical toolbar). The
#    caller of the package must define these images before calling the Init
#    procedure
#    If false, then toolbar handles are made of two tiny frames configured to
#    look like vertical or horizontal bars
#
# DefaultOption(ToolbarFrameRelief)
#    Default -relief option of the toolbar frame
#
# DefaultOption(ToolbarRelief)
#    Default -relief option of the toolbar
#
# DefaultOption(ToolbarHandleRelief)
#    Default -relief option of the toolbar handle
#
# DefaultOption(ToolbarFrameReliefBorderWidth)
#    Default -borderwidth option of the toolbar frame
#
# DefaultOption(ToolbarReliefBorderWidth)
#    Default -borderwidth option of the toolbar
#
# DefaultOption(ToolbarHandleReliefBorderWidth)
#    Default -borderwidth option of the toolbar handle
#
# DefaultOption(ToolbarDecorate)
#    If true, the toolbar frame gets decorations, i.e. a top frame and a bottom
#    frame making the toolbar frame look a bit better
#    If false, the toolbar frame does not get decorations
#
# DefaultOption(TooltipDelay)
#    Delay after which the tooltip will show up when the mouse is over a toolbar item
#
# DefaultOption(TooltipAfterId)
#    ID of the after command that launched the tooltip display (used for cancelling it)
#
# DefaultOption(TooltipDestroyAfterId)
#    ID of the after command that launched the tooltip removal (used for cancelling it)
#
# DefaultOption(TooltipBackground)
#    Default background color of tooltips
#
# DefaultOption(TooltipForeground)
#    Default foreground color of tooltips
#
#####################################
#
#    ToolbarSpecifications  array
#
#####################################
#
# ToolbarSpecifications(Orientation:$toolbar_frame)
#    Property of a toolbar frame: orientation
#    It must be "H" (horizontal) or "V" (vertical)
#
# ToolbarSpecifications(BorderWidth:$toolbar_frame)
#    Property of a toolbar frame: -borderwidth option
#
# ToolbarSpecifications(Side:$toolbar_frame)
#    Property of a toolbar frame: The side where the toolbar frame is packed,
#    with respect to the main application window
#    Values can be "left", "right", "top" or "bottom"
#
# ToolbarSpecifications(HideToolbar:$toolbar)
#    Property of a toolbar: hiddability
#    If true, then the toolbar can be hidden either by clicking on the "Hide" entry
#    of its contextual menu, or by double-clicking with button-2 on it's handle
#    If false, then the toolbar cannot be hidden (no "Hide" entry in the menu,
#    nor binding to hide the toolbar)
#    By default toolbars can be hidden, but this setting may be overwritten by the
#    -hide option of ::toolbar::create 
#
# ToolbarSpecifications(FloatToolbar:$toolbar)
#    Property of a toolbar: floatability
#    If true, then the toolbar can be detached either by clicking on the "Float" entry
#    of its contextual menu, or by double-clicking with button-1 on it's handle
#    If false, then the toolbar cannot be set to float (no "Float" entry in the menu,
#    nor binding to detach it the toolbar)
#    By default toolbars can be detached, but this setting may be overwritten by the
#    -float option of ::toolbar::create 
#
# ToolbarSpecifications(ListOfChilds:$toolbar)
#    Property of a toolbar: list of handles, buttons and widgets names being part of
#    the toolbar
#
# ToolbarSpecifications(TooltipVar:$widget:$toolbar)
#    Property of a button or widget from a toolbar: name of the variable containing the
#    text to show in a tooltip
#
# ToolbarSpecifications(Tooltip:$widget:$toolbar)
#    Property of a button or widget from a toolbar: text to show in a tooltip
#    If both  ToolbarSpecifications(TooltipVar:$name:$toolbar)  and
#    ToolbarSpecifications(Tooltip:$widget:$toolbar)  are given then the former takes
#    precedence and the latter is ignored
#
# ToolbarSpecifications(StatusWidget:$widget:$toolbar)
#    Property of a button or widget from a toolbar: name of the widget in which to show
#    the tooltip text "a la status bar"
#
# ToolbarSpecifications(StatusVar:$widget:$toolbar)
#    Property of a button or widget from a toolbar: name of the variable in which to set
#    the tooltip text when it would be displayed in a status bar
#    If both  ToolbarSpecifications(StatusWidget:$widget:$toolbar)  and
#    ToolbarSpecifications(StatusVar:$name:$toolbar)  are given then the former takes
#    precedence and the latter is ignored
#
# ToolbarSpecifications(StatusPrev:$widget:$toolbar)
#    Property of a button or widget from a toolbar: saved content of the status widget or
#    variable
#    This is used to restore the content of the status bar after display of the tooltip
#    in it, or to restore the content of the status variable after temporarily setting
#    it to the tooltip text
#
# ToolbarSpecifications(PackedIfHorizontal:$widget:$toolbar)
#    Property of a button or widget from a toolbar: packing request when the toolbar is
#    horizontal
#    If true, then the button/widget will be packed in the toolbar when the toolbar frame
#    has horizontal orientation
#    If false, it will not be packed in the toolbar when it has horizontal orientation
#
# ToolbarSpecifications(PackedIfVertical:$widget:$toolbar)
#    Property of a button or widget from a toolbar: packing request when the toolbar is
#    vertical
#    If true, then the button/widget will be packed in the toolbar when the toolbar frame
#    has vertical orientation
#    If false, it will not be packed in the toolbar when it has vertical orientation
#
# ToolbarSpecifications(ExWidgetCmd:$widget)
#    Property of a widget (not a button) from a toolbar: full Tcl command that created this
#    widget, with all options
#    This is used when detaching a toolbar (making it float), in order to properly duplicate
#    the widget
#
# ToolbarSpecifications($widget:<Enter>)
#    Property of a button or widget from a toolbar: script bound to the <Enter> event triggered
#    for that button/widget
#    This is used to save this script when deactivating a toolbar, so that it can be restored
#    on reactivation of the toolbar
#
# ToolbarSpecifications($widget:<Leave>)
#    See above, for <Enter>
#
# ToolbarSpecifications($widget:<Motion>)
#    See above, for <Enter>
#
# ToolbarSpecifications(AfterID)
#    Global property: ID of the after command that launched the destruction of the floating
#    toolbar when mounting it again (this value is used for cancelling this event in case
#    several toolbars are mounted quickly in turn - unlikely...)
#
# ToolbarSpecifications(X1:$frame), ToolbarSpecifications(Y1:$frame)
# ToolbarSpecifications(X2:$frame), ToolbarSpecifications(Y2:$frame)
#    Property of a toolbar frame: coordinates of two opposite corners delimitating the
#    inside of the window in which the toolbar frame is packed
#    This is used when moving a toolbar from one side to another of the main application
#    window
#
#########################################################################################


##
## toolbar.tcl --
##
##   A toolbar widget implementation.
##
## Copyright (c) 1999-2002 by:
##   George Petasis,
##   Institute of Informatics and Telecommunications,
##   National Centre for Scientific Research "Demokritos",
##   Aghia Paraskevi, Athens, Greece.
##
## Author contact information:
##   e-mail: petasis@iit.demokritos.gr
##   URL:    http://www.iit.demokritos.gr/~petasis
##
##
## The following terms apply to all files associated
## with the software unless explicitly disclaimed in individual files.
##
## The authors hereby grant permission to use, copy, modify, distribute,
## and license this software and its documentation for any purpose, provided
## that existing copyright notices are retained in all copies and that this
## notice is included verbatim in any distributions. No written agreement,
## license, or royalty fee is required for any of the authorized uses.
## Modifications to this software may be copyrighted by their authors
## and need not follow the licensing terms described here, provided that
## the new terms are clearly indicated on the first page of each file where
## they apply.
##
## IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
## FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
## ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
## DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.
##
## THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
## INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
## IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
## NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
## MODIFICATIONS.
##

package require Tk
package require msgcat
package provide toolbar 1.0

namespace eval ::toolbar {
  namespace export ToolbarFrame create addbutton addwidget addseparator \
                   activate deactivate
  variable DefaultOption
  variable ToolbarSpecifications
}


# ::toolbar::ToolbarFrame --
#
#        Creates a ToolbarFrame widget. This widget is a container that will
#        contain one or more toolbar widgets.
#
# Arguments:
#        toolbar_frame The name of the widget to be created
#        args          Various configuration options
#
# Results:
#        Creates a new widget and returns its name.

proc ::toolbar::ToolbarFrame {toolbar_frame args} {

  variable ToolbarSpecifications
  variable DefaultOption

  # preset some defaults
  set frame_options [list -bg          $DefaultOption(ToolbarBackground) \
                          -relief      $DefaultOption(ToolbarFrameRelief) \
                          -borderwidth $DefaultOption(ToolbarFrameReliefBorderWidth)]

  foreach {decorate orientation} [list $DefaultOption(ToolbarDecorate) H] {}

  # get options given by the caller
  foreach {option value} $args {
    switch -glob -- $option {
      -decor* { if {[string is true $value]} {
                    set decorate 1
                }
              }
      -orien* { if {[string match v* [string tolower $value]]} {
                    set orientation V
                }
              }
      default {lappend frame_options $option $value}
    }
  }

  # create the frame widget and give it ToolbarFrame as class
  eval frame $toolbar_frame -class ToolbarFrame $frame_options

  ## Make our toolbar frame draggable...
  bind $toolbar_frame <<TMB_1>>     "::toolbar::Click $toolbar_frame"
  bind $toolbar_frame <<TMotion_1>> "::toolbar::Motion $toolbar_frame %X %Y"

  set ToolbarSpecifications(Orientation:$toolbar_frame) $orientation
  set ToolbarSpecifications(BorderWidth:$toolbar_frame) [$toolbar_frame cget -borderwidth]
  set ToolbarSpecifications(Side:$toolbar_frame) top

  bind $toolbar_frame <Destroy> {array unset ::toolbar::ToolbarSpecifications *:%W}

  ## Toolbar Decoration...
  if {$decorate} {

    if {$orientation eq "H"} {

      bind $toolbar_frame <Configure> \
       {if {[expr %h-2*${::toolbar::ToolbarSpecifications(BorderWidth:%W)}]<8} {
          %W.toolbar_top_decoration configure    -bd 0 -height 1
          %W.toolbar_bottom_decoration configure -bd 0 -height 1
          %W configure -bd 0 -height 1
        } else {
          %W.toolbar_top_decoration configure    -bd 1 -height 2
          %W.toolbar_bottom_decoration configure -bd 1 -height 2
          %W configure -borderwidth ${::toolbar::ToolbarSpecifications(BorderWidth:%W)}
        }
       }
       frame $toolbar_frame.toolbar_top_decoration    -relief sunken -bd 1 -height 2
       frame $toolbar_frame.toolbar_bottom_decoration -relief sunken -bd 1 -height 2
       pack  $toolbar_frame.toolbar_top_decoration    -side top    -fill x -expand 1 -pady 0 -ipady 0
       pack  $toolbar_frame.toolbar_bottom_decoration -side bottom -fill x -expand 1 -pady 0 -ipady 0

     } else { ;# orientation is not "H"

       bind $toolbar_frame <Configure> \
       {if {[expr %w-2*${::toolbar::ToolbarSpecifications(BorderWidth:%W)}]<8} {
          %W.toolbar_top_decoration configure    -bd 0 -width 1
          %W.toolbar_bottom_decoration configure -bd 0 -width 1
          %W configure -bd 0 -width 1
        } else {
          %W.toolbar_top_decoration configure    -bd 1 -width 2
          %W.toolbar_bottom_decoration configure -bd 1 -width 2
          %W configure -borderwidth ${::toolbar::ToolbarSpecifications(BorderWidth:%W)}
        }
       }
       frame $toolbar_frame.toolbar_top_decoration    -relief sunken -bd 1 -width 2
       frame $toolbar_frame.toolbar_bottom_decoration -relief sunken -bd 1 -width 2
       pack  $toolbar_frame.toolbar_top_decoration    -side left  -fill y -expand 1 -pady 0 -ipady 0
       pack  $toolbar_frame.toolbar_bottom_decoration -side right -fill y -expand 1 -pady 0 -ipady 0
     }

  } else { ;# $decorate is false

    bind $toolbar_frame <Configure> \
         {if {[expr {%h-2*${::toolbar::ToolbarSpecifications(BorderWidth:%W)}}]<4} {
            %W configure -bd 0 -height 1
          } else {
            %W configure -borderwidth ${::toolbar::ToolbarSpecifications(BorderWidth:%W)}
          }
         }
  }

  return $toolbar_frame
};# ::toolbar::ToolbarFrame


# ::toolbar::create --
#
#        Creates a toolbar widget. This widget is a container of class Toolbar
#        that will contain one or more button and widgets....
#
# Arguments:
#        toolbar       The name of the toolbar in which the widget
#                      is to be created. This widget should
#                      be a child of a ToolbarFrame widget...
#        args          Various configuration options
#
# Results:
#        Creates a new widget and returns its name.

proc ::toolbar::create {toolbar args} {

  variable ToolbarSpecifications
  variable DefaultOption

  # preset some defaults
  set frame_options [list -bd          0 \
                          -relief      $DefaultOption(ToolbarRelief) \
                          -borderwidth $DefaultOption(ToolbarReliefBorderWidth)]

  set ToolbarSpecifications(HideToolbar:$toolbar)  1
  set ToolbarSpecifications(FloatToolbar:$toolbar) 1

  # get options given by the caller
  foreach {arg val} $args {
    switch -glob -- $arg {
      -hide   {set ToolbarSpecifications(HideToolbar:$toolbar)  $val}
      -float  {set ToolbarSpecifications(FloatToolbar:$toolbar) $val}
      default {lappend frame_options $arg $val}
    }
  }

  # create a frame widget and give it Toolbar as class
  eval frame $toolbar -class Toolbar $frame_options

  set toolbar_frame [winfo parent $toolbar]

  bind $toolbar <<TMB_1>>     "::toolbar::Click $toolbar_frame"
  bind $toolbar <<TMotion_1>> "::toolbar::Motion $toolbar_frame %X %Y"

  set orientation $ToolbarSpecifications(Orientation:$toolbar_frame)

  set bg $DefaultOption(ToolbarBackground)

  set ToolbarSpecifications(BorderWidth:$toolbar) [$toolbar cget -borderwidth]

  set ToolbarSpecifications(ListOfChilds:$toolbar) [list ]

  if {$DefaultOption(ToolbarImageHandle)} {

    if {$orientation eq "H"} {
      set Image IToolbar
    } else {
      set Image IToolbarVertical
    }

    button $toolbar.handle -background $DefaultOption(ToolbarHandleBackground) \
       -activebackground $DefaultOption(ToolbarHandleBackground) \
       -relief $DefaultOption(ToolbarHandleRelief) -anchor nw \
       -borderwidth $DefaultOption(ToolbarHandleReliefBorderWidth) \
       -image $Image -highlightcolor $DefaultOption(ToolbarHandleBackground) \
       -highlightthickness 0 -command "::toolbar::HandleCallback $toolbar 1"

    if {$ToolbarSpecifications(HideToolbar:$toolbar)} {
      bind $toolbar.handle <Double-Button-2> "::toolbar::HandleCallback $toolbar 2"
      bind $toolbar.handle <Double-Button-3> "::toolbar::HandleCallback $toolbar 2"
    }
    bind $toolbar.handle <<TMB_1>>     "::toolbar::Click $toolbar_frame"
    bind $toolbar.handle <<TMotion_1>> "::toolbar::Motion $toolbar_frame %X %Y"
    bind $toolbar.handle <<TMB_2>>     "::toolbar::ContextSensitiveMenu $toolbar"

  } else {

    if {$::tcl_platform(platform) eq "windows"} {
      set HandleRelief ridge
    } else {
      set HandleRelief raised
    }

    frame $toolbar.handle -relief flat -bd 1 -background $DefaultOption(ToolbarBackground)

    if {$orientation eq "H"} {
      frame $toolbar.handle.l1 -relief $HandleRelief -bd 1 -width 2 -background $DefaultOption(ToolbarHandleBackground)
      frame $toolbar.handle.l2 -relief $HandleRelief -bd 1 -width 2 -background $DefaultOption(ToolbarHandleBackground)
      pack $toolbar.handle.l1 -fill y -side left -padx 1 -pady 2
      pack $toolbar.handle.l2 -fill y -side left -pady 2
    } else {
      frame $toolbar.handle.l1 -relief $HandleRelief -bd 1 -height 2 -background $DefaultOption(ToolbarHandleBackground)
      frame $toolbar.handle.l2 -relief $HandleRelief -bd 1 -height 2 -background $DefaultOption(ToolbarHandleBackground)
      pack $toolbar.handle.l1 -fill x -side top -pady 1 -padx 2
      pack $toolbar.handle.l2 -fill x -side top -padx 2
    }

    foreach _han [list $toolbar.handle $toolbar.handle.l1 $toolbar.handle.l2] {
      bind ${_han} <Double-Button-1>  "::toolbar::HandleCallback $toolbar 1"
      if {$ToolbarSpecifications(HideToolbar:$toolbar)} {
        bind ${_han} <Double-Button-2> "::toolbar::HandleCallback $toolbar 2"
        bind ${_han} <Double-Button-3> "::toolbar::HandleCallback $toolbar 2"
      }
      bind ${_han} <<TMB_1>>     "::toolbar::Click $toolbar_frame"
      bind ${_han} <<TMotion_1>> "::toolbar::Motion $toolbar_frame %X %Y"
      bind ${_han} <<TMB_2>>     "::toolbar::ContextSensitiveMenu $toolbar"
    }
    bind $toolbar.handle <Enter> "%W configure -relief $HandleRelief"
    bind $toolbar.handle <Leave> "%W configure -relief flat"
  }

  frame $toolbar.widgets -relief flat -bd 0 -bg $bg

  bind $toolbar <Destroy> {catch {array unset ::toolbar::ToolbarSpecifications *:%W}}

  deiconify $toolbar

  return $toolbar
};# ::toolbar::create


# ::toolbar::addbutton --
#
#        Create and pack a button in a toolbar widget....
#
# Arguments:
#        toolbar       The name of the toolbar in which the widget
#                      is to be created. This widget should
#                      be a child of a ToolbarFrame widget...
#        args          Various configuration options
#
# Results:
#        Creates a new button in a toolbar and returns its name.

proc ::toolbar::addbutton {toolbar args} {

  variable ToolbarSpecifications
  variable DefaultOption

  # pick a new unused name for the button
  set win_nu 0
  while {1} {
    set name $toolbar.widgets.$win_nu
    if {![winfo exists $name]} {break}
    incr win_nu
  }

  # preset default values for some options that must be defined
  # because they are used below in the current proc
  foreach      {cmd image bitmap bw relief overrelief text    hfg bg} \
          [list {}  {}    {}     1  flat   raised     $win_nu {}  $DefaultOption(ToolbarBackground)] {}
  foreach {tooltip tooltipvar packwhenh packwhenv} \
          {{}      {}         1         1        } {}

  # get options given by the caller
  set num [llength $args]
  for {set i 0} {$i<$num} {incr i} {
    set arg [lindex $args $i]
    set val [lindex $args [incr i]]
    switch -glob -- $arg {
     -c*          {append cmd $val       ;# -command}
     -i*          {set image $val        ;# -image}
     -bi*         {set bitmap $val       ;# -bitmap}
     -bo*         {set bw $val           ;# -borderwidth}
     -a*          {set hfg $val          ;# -activebackground}
     -r*          {set relief $val       ;# -relief}
     -n*          {set name $val         ;# -name}
     -overr*      {set overrelief $val   ;# -overrelief}
     -statusw*    {set statuswidget $val ;# -statuswidget}
     -statusv*    {set statusvar $val    ;# -statusvar}
     -text        {set text $val         ;# -text}
     -textvar*    {set textvariable $val ;# -textvariable}
     -tooltip     {set tooltip $val      ;# -tooltip}
     -tooltipvar* {set tooltipvar $val   ;# -tooltipvariable}
     -showifh     {set packwhenh $val    ;# -showifh}
     -showifv     {set packwhenv $val    ;# -showifv}
     default { return -code error "unknown option \"$arg\"" }
    }
  }
  set cmd \
    "$name configure -cursor watch; $cmd;\
     catch \"$name configure -cursor {}; $name configure -relief flat\""

  # create the toolbar button...
  button $name -command "$cmd" -relief $relief -background $bg -borderwidth $bw

  if {[string length $image]} {
    $name configure -image $image -highlightbackground $bg -activebackground $bg
  } elseif {[string length $bitmap]} {
    $name configure -bitmap $bitmap -highlightbackground $bg -activebackground $bg
  } else {
    $name configure -text $text
  }

  if {[string length $hfg]} {
    $name configure -activebackground $hfg
  }

  if {[info exists textvariable]} {
    $name configure -textvariable $textvariable
  }

  bind $name <Enter> \
    "%W configure -relief $overrelief;::toolbar::Tooltip show %W $toolbar"

  bind $name <Leave> \
    "%W configure -relief $relief;::toolbar::Tooltip cancel %W $toolbar"

  if {[string length $tooltipvar]} {
    set ToolbarSpecifications(TooltipVar:$name:$toolbar) $tooltipvar
  } elseif {[string length $tooltip]} {
    set ToolbarSpecifications(Tooltip:$name:$toolbar) $tooltip
  }

  if {[info exists statuswidget]} {
    set ToolbarSpecifications(StatusWidget:$name:$toolbar) $statuswidget
  } elseif {[info exists statusvar]} {
    set ToolbarSpecifications(StatusVar:$name:$toolbar) $statusvar
  }

  lappend ToolbarSpecifications(ListOfChilds:$toolbar) $name
  set ToolbarSpecifications(PackedIfHorizontal:$name:$toolbar) $packwhenh
  set ToolbarSpecifications(PackedIfVertical:$name:$toolbar)   $packwhenv

  if {$ToolbarSpecifications(Orientation:[winfo parent $toolbar]) eq "H"} {
    if {$ToolbarSpecifications(PackedIfHorizontal:$name:$toolbar)} {
      pack $name -side left -ipadx 2 -ipady 2 -pady 1 -fill y
    }
  } else {
    if {$ToolbarSpecifications(PackedIfVertical:$name:$toolbar)} {
      pack $name -side top  -ipadx 2 -ipady 2 -padx 1 -fill x
    }
  }

  return $name
};# ::toolbar::addbutton


# ::toolbar::addwidget --
#
#        Create and pack a widget inside a toolbar widget....
#
#        toolbar       The name of the toolbar in which the widget
#                      is to be created. This widget should
#                      be a child of a ToolbarFrame widget...
#        widget        The type of the widget to be created (like label, etc)
#        args          Various configuration options
#
# Results:
#        Creates a new widget inside a toolbar and returns its name.

proc ::toolbar::addwidget {toolbar widget args} {

  variable ToolbarSpecifications
  variable DefaultOption

  # pick a new unused name for the widget
  set win_nu 0
  while {1} {
    set name $toolbar.widgets.$win_nu
    if {![winfo exists $name]} {break}
    incr win_nu
  }

  # preset default values for some options that must be defined
  # because they are used below in the current proc
  foreach {bw entercmd leavecmd tooltip tooltipvar pady packwhenh packwhenv} \
          {1  {}       {}       {}      {}         1    1         1        } {}

  # get options given by the caller
  set widget_args {}
  set num [llength $args]
  for {set i 0} {$i<$num} {incr i} {
    set arg [lindex $args $i]
    set val [lindex $args [incr i]]
    switch -glob -- $arg {
     -bd          -
     -borderw*    {set bw $val           ;# -borderwidth}
     -enterc*     {set entercmd $val     ;# -entercommand}
     -name        {set name $val         ;# -name}
     -leavec*     {set leavecmd $val     ;# -leavecommand}
     -rel*        {set relief $val       ;# -relief}
     -statusw*    {set statuswidget $val ;# -statuswidget}
     -statusv*    {set statusvar $val    ;# -statusvar}
     -tooltip     {set tooltip $val      ;# -tooltip}
     -tooltipvar* {set tooltipvar $val   ;# -tooltipvariable}
     -pady        {set pady $val         ;# -pady}
     -showifh     {set packwhenh $val    ;# -showifh}
     -showifv     {set packwhenv $val    ;# -showifv}
     default      {lappend widget_args $arg $val }
    }
  }

  # create the widget...
  # note: order matters! the default options must be set first,
  #       so that they will be overridden by $widget_args if the
  #       caller gives them explicitely
  eval [list $widget] [list $name] -borderwidth $bw $widget_args

  set ToolbarSpecifications(ExWidgetCmd:$name) [concat $widget $name -borderwidth $bw $widget_args]

  bind $name <Destroy> {catch {unset ::toolbar::ToolbarSpecifications(ExWidgetCmd:%W)}}

  if {![string length $entercmd]} {
    bind $name <Enter> "::toolbar::Tooltip show %W $toolbar"
  } else {
    bind $name <Enter> "::toolbar::Tooltip show %W $toolbar;$entercmd"
  }

  if {![string length $leavecmd]} {
    bind $name <Leave> "::toolbar::Tooltip cancel %W $toolbar"
  } else {
    bind $name <Leave> "::toolbar::Tooltip cancel %W $toolbar;$leavecmd"
  }

  if {[string length $tooltipvar]} {
    set ToolbarSpecifications(TooltipVar:$name:$toolbar) $tooltipvar
  } elseif {[string length $tooltip]} {
    set ToolbarSpecifications(Tooltip:$name:$toolbar) $tooltip
  }

  if {[info exists statuswidget]} {
    set ToolbarSpecifications(StatusWidget:$name:$toolbar) $statuswidget
  } elseif {[info exists statusvar]} {
    set ToolbarSpecifications(StatusVar:$name:$toolbar) $statusvar
  }

  lappend ToolbarSpecifications(ListOfChilds:$toolbar) $name
  set ToolbarSpecifications(PackedIfHorizontal:$name:$toolbar) $packwhenh
  set ToolbarSpecifications(PackedIfVertical:$name:$toolbar)   $packwhenv

  if {$ToolbarSpecifications(Orientation:[winfo parent $toolbar]) eq "H"} {
    if {$ToolbarSpecifications(PackedIfHorizontal:$name:$toolbar)} {
      pack $name -side left -ipadx 2 -ipady 2 -pady $pady -fill y
    }
  } else {
    if {$ToolbarSpecifications(PackedIfVertical:$name:$toolbar)} {
      pack $name -side top  -ipadx 2 -ipady 2 -padx $pady -fill x
    }
  }

  return $name
};# ::toolbar::addwidget


# ::toolbar::addseparator --
#
#        Create and pack a separator inside a toolbar widget....
#
# Arguments:
#        toolbar       The name of the toolbar in which the widget
#                      is to be created. This widget should
#                      be a child of a ToolbarFrame widget...
#        args          Various configuration options
#
# Results:
#        Creates a new separator in a toolbar and returns its name.

proc ::toolbar::addseparator {toolbar args} {

  variable ToolbarSpecifications
  variable DefaultOption

  # pick a new unused name for the widget
  set win_nu 0
  while {1} {
    set name $toolbar.widgets.$win_nu
    if {![winfo exists $name]} {break}
    incr win_nu
  }

  # preset default values for some options that must have a value
  # because they are used below in the current proc
  foreach {orientation attachto packwhenh packwhenv} \
          {vertical    {}       1         1        } {}

  # Get options given by the caller
  foreach {opt val} $args {
    switch -glob -- $opt {
      -orien*  {set orientation $val}
      -name    {set name $val}
      -atta*   {set attachto $val     ;# -attach: a list of widgets that control show/hide of the separator}
      -showifh {set packwhenh $val    ;# -showifh}
      -showifv {set packwhenv $val    ;# -showifv}
      default  {error "addseparator: unknown option $opt..."}
    }
  }

  lappend ToolbarSpecifications(ListOfChilds:$toolbar) $name
  set ToolbarSpecifications(PackedIfHorizontal:$name:$toolbar) $packwhenh
  set ToolbarSpecifications(PackedIfVertical:$name:$toolbar)   $packwhenv

  # create the separator
  switch -glob -- $orientation {

    ver*  { frame $name -relief sunken -bd 1 -background $DefaultOption(ToolbarHandleBackground)
            set tborient $ToolbarSpecifications(Orientation:[winfo parent $toolbar])
            if {$tborient eq "H"} {
              if {$ToolbarSpecifications(PackedIfHorizontal:$name:$toolbar)} {
                pack $name -pady 4 -padx 4
                $name configure -width 2
                pack configure $name -side left -fill y
              }
            } else {
              if {$ToolbarSpecifications(PackedIfVertical:$name:$toolbar)} {
                pack $name -pady 4 -padx 4
                $name configure -height 2
              }
            }
          }

    hor*  { frame $name -relief sunken -bd 1 -height 2 -background $DefaultOption(ToolbarHandleBackground)
            if {$ToolbarSpecifications(PackedIfHorizontal:$name:$toolbar)} {
              pack $name -side top -anchor w -padx 0 -fill x -expand 1
            }
            set parent [winfo parent $name]
            bind $parent <Configure> "+::toolbar::ManageHorizontalSeparator $parent $name"
            lappend attachto $toolbar
            foreach toolbar $attachto {
              bind $toolbar <<ToolBarHide>> "$name configure -bd 0 -height 1"
              bind $toolbar <<ToolBarShow>> "$name configure -bd 1 -height 2"
            }
          }

    default {error "addseparator: unknown value $orientation for parameter orientation"}
  }

  return $name
};# ::toolbar::addseparator

#  This proc is called only when a horizontal separator exists. It catches
#    configure event of the separator parent, and hides the separator if it is
#    the last element of the parent (all toolbars below have been hiden...)
#
proc ::toolbar::ManageHorizontalSeparator {parent window} {
  set ParentHeight [winfo height $parent]
  if {$ParentHeight < 2} {
    return
  }
  set y [winfo y $window]
  if {$y > $ParentHeight} {
    $window configure -bd 0 -height 1
  }
};# ::toolbar::ManageHorizontalSeparator


# ::toolbar::activate --
#
#        Makes a toolbar widget active.
#
# Arguments:
#        toolbar       The name of the widget to be activated. This widget should
#                      be a child of a ToolbarFrame widget...
#
# Results:
#        Makes a toolbar active to user input.

proc ::toolbar::activate {toolbar} {

  variable ToolbarSpecifications

  foreach child [winfo children $toolbar.widgets] {
    catch {$child configure -state normal}
    catch { bind $child <Enter>  $ToolbarSpecifications($child:<Enter>)
            bind $child <Leave>  $ToolbarSpecifications($child:<Leave>)
            bind $child <Motion> $ToolbarSpecifications($child:<Motion>)
          }
  }

  ## Activate floating window, if any...
  set win $toolbar.fltWin
  if [winfo exists $win] {
    foreach child    [winfo children $win] \
            or_child [winfo children $toolbar.widgets] {
      catch {$child configure -state normal}
      catch { bind $child <Enter>  $ToolbarSpecifications($or_child:<Enter>)
              bind $child <Leave>  $ToolbarSpecifications($or_child:<Leave>)
              bind $child <Motion> $ToolbarSpecifications($or_child:<Motion>)
            }
    }
  }

  foreach child [winfo children $toolbar.widgets] {
    catch { unset ToolbarSpecifications($child:<Enter>)
                  ToolbarSpecifications($child:<Leave>)
                  ToolbarSpecifications($child:<Motion>)
          }
  }
};# ::toolbar::activate


# ::toolbar::deactivate --
#
#        Makes a toolbar widget inactive.
#
# Arguments:
#        toolbar       The name of the widget to be deactivated. This widget should
#                      be a child of a ToolbarFrame widget...
#
# Results:
#        Makes a toolbar inactive to user input.

proc ::toolbar::deactivate {toolbar} {

  variable ToolbarSpecifications

  foreach child [winfo children $toolbar.widgets] {
    catch {$child configure -state disabled}
    catch {set ToolbarSpecifications($child:<Enter>)  [bind $child <Enter>]
           set ToolbarSpecifications($child:<Leave>)  [bind $child <Leave>]
           set ToolbarSpecifications($child:<Motion>) [bind $child <Motion>]
          }
    catch {bind $child <Enter>  {}}
    catch {bind $child <Leave>  {}}
    catch {bind $child <Motion> {}}
  }

  ## Deactivate floating window, if any...
  set win $toolbar.fltWin
  if {[winfo exists $win]} {
    foreach child [winfo children $win] {
      catch {$child configure -state disabled}
      catch {bind $child <Enter>  {}}
      catch {bind $child <Leave>  {}}
      catch {bind $child <Motion> {}}
    }
  }
};# ::toolbar::deactivate


# ::toolbar::deiconify --
#
#        Makes a toolbar widget visible. This is an internal function and
#        should not be call by users...
#   (<TODO> once the toolbar has been made hidden (e.g. through the context menu),
#           what other command should be invoked to make it visible again??)
#
# Arguments:
#        args          The name(s) of the toolbar widgets to make visible
#
# Results:
#        Makes a toolbar widget visible by packing its components.

proc ::toolbar::deiconify {args} {

  variable ToolbarSpecifications

  foreach toolbar $args {

    if {[winfo exists $toolbar]} {

      ## Is the toolbar visible in a floating window?
      if {[winfo exists $toolbar.fltWin]} {
        continue
      }

      if {$ToolbarSpecifications(Orientation:[winfo parent $toolbar]) eq "H"} {
        pack $toolbar.handle -side left -fill y
        pack $toolbar.widgets -side left -fill y
      } else {
        pack $toolbar.handle -side top -fill x
        pack $toolbar.widgets -side top -fill x
      }

      $toolbar configure -bd $ToolbarSpecifications(BorderWidth:$toolbar)
      event generate $toolbar <<ToolBarShow>>

    } else {
      # do nothing: no error if ![winfo exists $toolbar]
    }

  }
};# ::toolbar::deiconify


# ::toolbar::SetOrientation --
#
#       Try to change the orientation of a toolbar frame (and thus all the
#       toolbars contained in it) to the given one...
#
# Arguments:
#        toolbar_frame The name of the toolbar frame
#        orientation   The desired orientation (H|V, defaults to H)
#
# Results:
#        Change the orientation of a toolbar frame and all the toolbars
#        contained inside the toolbar frame.

proc ::toolbar::SetOrientation {toolbar_frame {orientation H}} {

  variable ToolbarSpecifications
  variable DefaultOption

  set ToolbarSpecifications(Orientation:$toolbar_frame) $orientation
  set child_toolbars [winfo children $toolbar_frame]

  switch $orientation {

    H {

      eval pack forget $child_toolbars

      ## Has the frame any decorations?
      if {[winfo exists $toolbar_frame.toolbar_top_decoration]} {
        $toolbar_frame.toolbar_top_decoration    conf -height 2 -width 0
        $toolbar_frame.toolbar_bottom_decoration conf -height 2 -width 0
        pack $toolbar_frame.toolbar_top_decoration    -side top    -fill x -expand 1 -pady 0 -ipady 0
        pack $toolbar_frame.toolbar_bottom_decoration -side bottom -fill x -expand 1 -pady 0 -ipady 0
      }

      foreach child_toolbar $child_toolbars {

        ## Is this toolbar in a floating window?
        if {[winfo exists $child_toolbar.fltWin]} {
            continue
        }

        ## Is this a real toolbar, or a separator?
        if {![llength [winfo children $child_toolbar]]} {
          ## A frame with no children? A separator...
          #pack $child_toolbar -side top -pady 4 -padx 4 -fill x
          continue
        }

        ## remove all widgets from the toolbar
        set slaves [pack slaves $child_toolbar.widgets]
        pack forget $child_toolbar.handle $child_toolbar.widgets
        eval pack forget $slaves

        # configure the handler of the toolbar in the H orientation
        if {$DefaultOption(ToolbarImageHandle)} {
          $child_toolbar.handle configure -image IToolbar
        } else {
          pack forget $child_toolbar.handle.l1 $child_toolbar.handle.l2
          $child_toolbar.handle.l1 configure -width 2 -height 0
          $child_toolbar.handle.l2 configure -width 2 -height 0
          pack $child_toolbar.handle.l1 -fill y -side left -padx 1 -pady 2
          pack $child_toolbar.handle.l2 -fill y -side left -pady 2
        }

        ## Now, re-pack all the widgets with H orientation
        pack $child_toolbar.handle $child_toolbar.widgets -side left -fill y -pady 0 -padx 0
        set slaves $ToolbarSpecifications(ListOfChilds:$child_toolbar)
        foreach widget $slaves {
          if {$ToolbarSpecifications(PackedIfHorizontal:$widget:$child_toolbar)} {
            if {[string equal -nocase [winfo class $widget] frame] && ![llength [winfo children $widget]]} {
              ## This is a separator...
              $widget configure -relief sunken -bd 1 -width 2 -height 0
              pack $widget -side left -pady 4 -padx 4 -fill y
            } else {
              pack $widget -side left -ipadx 2 -ipady 2 -pady 1 -fill y
            }
          }
        }

      }

      ## Now its time to pack the toolbars themselves in the hosting toolbar_frame
      set height [winfo width $toolbar_frame]
      incr height -20
      foreach child $child_toolbars {
        ## Is this toolbar in a floating window?
        ##if {[winfo exists $child.fltWin]} {continue}
        ## Is this a real toolbar, or a separator?
        if {![llength [winfo children $child]]} {
          ## A frame with no children? A separator...
          pack $child -side top -anchor sw -padx 0 -fill x -expand 1
        } else {
          pack $child -side left
          if {[winfo x $child] > $height} {
            pack forget $child
            pack $child -side bottom
          }
        }
      }

    }

    V {
      
      eval pack forget $child_toolbars

      ## Has the frame any decorations?
      if {[winfo exists toolbar_frame.toolbar_top_decoration]} {
        $toolbar_frame.toolbar_top_decoration    conf -height 0 -width 2
        $toolbar_frame.toolbar_bottom_decoration conf -height 0 -width 2
        pack $toolbar_frame.toolbar_top_decoration    -side left  -fill y -expand 1 -pady 0 -ipady 0
        pack $toolbar_frame.toolbar_bottom_decoration -side right -fill y -expand 1 -pady 0 -ipady 0
      }

      foreach child_toolbar $child_toolbars {

        ## Is this toolbar in a floating window?
        if {[winfo exists $child_toolbar.fltWin]} {
            continue
        }

        ## Is this a real toolbar, or a separator?
        if {![llength [winfo children $child_toolbar]]} {
          ## A frame with no children? A separator...
          #pack $child_toolbar -side left -pady 4 -padx 4 -fill y
          continue
        }

        ## remove all widgets from the toolbar
        set slaves [pack slaves $child_toolbar.widgets]
        pack forget $child_toolbar.handle $child_toolbar.widgets
        eval pack forget $slaves

        # configure the handler of the toolbar in the V orientation
        if {$DefaultOption(ToolbarImageHandle)} {
          $child_toolbar.handle configure -image IToolbarVertical
        } else {
          pack forget $child_toolbar.handle.l1 $child_toolbar.handle.l2
          $child_toolbar.handle.l1 configure -width 0 -height 2 -bd 1
          $child_toolbar.handle.l2 configure -width 0 -height 2 -bd 1
          pack $child_toolbar.handle.l1 -fill x -side top -pady 1 -padx 2
          pack $child_toolbar.handle.l2 -fill x -side top -padx 2
        }

        ## Now, re-pack all the widgets with V orientation
        pack $child_toolbar.handle $child_toolbar.widgets -side top -fill x -pady 0 -padx 0
        set slaves $ToolbarSpecifications(ListOfChilds:$child_toolbar)
        foreach widget $slaves {
          if {$ToolbarSpecifications(PackedIfVertical:$widget:$child_toolbar)} {
            if {[string equal -nocase [winfo class $widget] frame] && ![llength [winfo children $widget]]} {
              ## This is a separator...
              $widget configure -relief sunken -bd 1 -width 0 -height 2
              pack $widget -side top -pady 4 -padx 4 -fill x
            } else {
              pack $widget -side top -ipadx 2 -ipady 2 -padx 1 -fill x
            }
          }
        }

      }

      ## Now its time to pack the toolbars themselves in the hosting toolbar_frame
      set height [winfo height $toolbar_frame]
      incr height -20
      foreach child $child_toolbars {
        ## Is this toolbar in a floating window?
        #if {[winfo exists $child.fltWin]} {continue}
        if {![llength [winfo children $child]]} {
          ## A frame with no children? A separator...
          pack $child -side left -fill y
        } else {
          pack $child -side top
          if {[winfo y $child] > $height} {
            pack forget $child
            pack $child -side left
          }
        }
      }

    }

    default {error "unknown orientation $orientation"}

  }

  event generate $toolbar_frame <<ToolBarShow>>

};# ::toolbar::SetOrientation


# ::toolbar::CreateToolbarWindow --
#
#        Convert a toolbar widget into a floating window. This function
#        actually hides the toolbar and creates a toplevel window that is an
#        exact replica of the toolbar widget. This is an internal function and
#        should never be called by the user...
#
# Arguments:
#        toolbar       The name of the toolbar widget.
#
# Results:
#        Turn a toolbar into a floating window.

proc ::toolbar::CreateToolbarWindow {toolbar} {

  variable ToolbarSpecifications
  variable DefaultOption

  set win $toolbar.fltWin
  if [winfo exists $win] {
    return
  }

  toplevel $win -bg $DefaultOption(ToolbarBackground)
  wm withdraw $win
  wm transient $win [winfo toplevel $toolbar]
  wm title $win [::msgcat::mc Toolbar]
  wm resizable $win false false

  # mount back the toolbar in case the user closes the floating window
  # (click on the closure red cross)
  bind $win <Destroy> \
     "::toolbar::deiconify $toolbar
      [winfo parent $toolbar] configure -height [winfo height [winfo parent $toolbar]]
      array unset ::toolbar::ToolbarSpecifications X1:*"
  after 600 "bind $win <Configure> \"::toolbar::MountFloat [winfo parent $toolbar] $toolbar %W %x %y\""
#  bind [winfo toplevel $toolbar] <Destroy> "+catch \"destroy $win\""

  ## Create the new widgets...
  foreach child [winfo children $toolbar.widgets] {

    set widget [DuplicateWidget $win $child]
    if {![string length $widget]} {
      continue
    }

    ## Has the old widget a tooltip associated with it?
    if {[info exists ToolbarSpecifications(TooltipVar:$child:$toolbar)]} {
      set ToolbarSpecifications(TooltipVar:$widget:$toolbar) $ToolbarSpecifications(TooltipVar:$child:$toolbar)
      bind $widget <Destroy> "catch \"unset ::toolbar::ToolbarSpecifications(TooltipVar:$widget:$toolbar)\""
    }
    if {[info exists ToolbarSpecifications(Tooltip:$child:$toolbar)]} {
      set ToolbarSpecifications(Tooltip:$widget:$toolbar) $ToolbarSpecifications(Tooltip:$child:$toolbar)
      bind $widget <Destroy> "+catch \"unset ::toolbar::ToolbarSpecifications(Tooltip:$widget:$toolbar)\""
    }

    ## Is the old widget associated with a status bar?
    if {[info exists ToolbarSpecifications(StatusWidget:$child:$toolbar)]} {
      set ToolbarSpecifications(StatusWidget:$widget:$toolbar) $ToolbarSpecifications(StatusWidget:$child:$toolbar)
      bind $widget <Destroy> "+catch \"unset ::toolbar::ToolbarSpecifications(StatusWidget:$widget:$toolbar)\""
    }
    if {[info exists ToolbarSpecifications(StatusVar:$child:$toolbar)]} {
      set ToolbarSpecifications(StatusVar:$widget:$toolbar) $ToolbarSpecifications(StatusVar:$child:$toolbar)
      bind $widget <Destroy> "+catch \"unset ::toolbar::ToolbarSpecifications(StatusVar:$widget:$toolbar)\""
    }
    if {[info exists ToolbarSpecifications(StatusPrev:$child:$toolbar)]} {
      set ToolbarSpecifications(StatusPrev:$widget:$toolbar) $ToolbarSpecifications(StatusPrev:$child:$toolbar)
      bind $widget <Destroy> "+catch \"unset ::toolbar::ToolbarSpecifications(StatusPrev:$widget:$toolbar)\""
    }

    # copy packing requests to the new widget
    set ToolbarSpecifications(PackedIfHorizontal:$widget:$toolbar) $ToolbarSpecifications(PackedIfHorizontal:$child:$toolbar)
    set ToolbarSpecifications(PackedIfVertical:$widget:$toolbar)   $ToolbarSpecifications(PackedIfVertical:$child:$toolbar)

    if {$ToolbarSpecifications(PackedIfHorizontal:$widget:$toolbar)} {
      if {[string equal -nocase [winfo class $widget] frame]} {
        pack $widget -side left -pady 4 -padx 4 -fill y
      } else {
        pack $widget -side left -ipadx 2 -ipady 2 -pady 1 -fill y
      }
    }

  }

  update

  wm geometry $win +[expr [winfo pointerx $win]-([winfo reqwidth $win]/2)]+[expr [winfo pointery $win]-15]
  wm deiconify $win

};# ::toolbar::CreateToolbarWindow

#
# Create a "mirror" widget
#

proc ::toolbar::DuplicateWidget {parent w2 {pack 0}} {

  variable ToolbarSpecifications
  variable DefaultOption

  # pick a new unused name for the widget to create
  set win_nu 0
  while {1} {
    set w1 $parent.$win_nu
    if {![winfo exists $w1]} {break}
    incr win_nu
  }

  switch -exact -- [winfo class $w2] {

      Button      {button $w1}

      Frame       {
                   if {[info exists ToolbarSpecifications(ExWidgetCmd:$w2)]} {
                     if {[llength $ToolbarSpecifications(ExWidgetCmd:$w2)]} {
                       ## Its an external widget...
                       set cmd [lreplace $ToolbarSpecifications(ExWidgetCmd:$w2) 1 1 $w1]
                       #puts $cmd
                       eval $cmd
                     } else {
                       #puts HELP!!!!!!!!!!!!!!!!!!!
                     }
                   } else {
                     if {[llength [winfo children $w2]]} {
                       #puts "Help! !!!!"
                     } else {
                       ## its a separator...
                       frame $w1 -relief sunken -bd 1 -width 2
                       if {$pack} {pack $w1}
                       return $w1
                     }
                   }
                  }

      Label       {label $w1}

      ArrowButton {ArrowButton $w1}

      default     {
                   if {[catch {[string tolower [winfo class $w2]] $w1}]} {
                     return
                   }
                  }

  }

  ## Configure the new widget
  foreach option [$w2 configure] {
    set spec [lindex $option 0]
    catch {$w1 configure $spec [$w2 cget $spec]}
  }

  ## Add Bindings
  foreach Tag [bind $w2] {
     bind $w1 $Tag [bind $w2 $Tag]
  }

  ## Menubuttons are a special case...
  if {[string equal [winfo class $w2] Menubutton]} {
    set menu [$w2 cget -menu]
    $menu clone $w1.menu
    $w1 configure -menu $w1.menu
  }

  if {$pack} {
    pack $w1
  }

  return $w1

};# ::toolbar::DuplicateWidget


#
# Mount Float Window into toplevel window
#
# ::toolbar::MountFloat --
#
#       Convert a toolbar from a floating window into a widget. This function
#       actually shows a hidden toolbar widget and destroys a toplevel window
#       that is an exact replica of the toolbar widget.
#       This is an internal function and should never be called by the user...
#
# Arguments:
#        toolbar       The name of the toolbar widget.
#
# Results:
#        Turn a toolbar into a floating window.

proc ::toolbar::MountFloat {parent toolbar win x y} {

  variable ToolbarSpecifications
  variable DefaultOption

  if {![winfo exists $win]} {
    return
  }

  $parent configure -height [winfo height $parent] \
                    -width  [winfo width  $parent]
  set starty [winfo rooty $parent]

  catch {after cancel $ToolbarSpecifications(AfterID)}

  if {$y > $starty - 20 && $y < $starty + [winfo height $parent]} {
    set startx [winfo rootx $parent]
    if {$x > $startx - 20 && $x < $startx + [winfo width $parent]} {
      set ToolbarSpecifications(AfterID) [ \
          after 400 "catch \"$parent configure -relief $::toolbar::DefaultOption(ToolbarFrameRelief);destroy $win\"" \
      ]
      $parent configure -relief sunken
      $win configure -background $DefaultOption(SelectBackground)
      foreach obj [winfo children $win] {
        if {[winfo class $obj] eq "Button"} {
          catch {$obj configure -background          $DefaultOption(SelectBackground) \
                                -highlightbackground $DefaultOption(SelectBackground)
                }
        }
      }
      bind $win <FocusIn> "$parent configure -relief $::toolbar::DefaultOption(ToolbarFrameRelief);destroy %W"
      return
    }
  }

  bind $win <FocusIn> {}

  $parent configure -relief $DefaultOption(ToolbarFrameRelief)

  $win configure -background $DefaultOption(ToolbarBackground)

  foreach obj [winfo children $win] {
    if {[winfo class $obj] eq "Button"} {
      catch {$obj configure -background          $DefaultOption(ToolbarBackground) \
                            -highlightbackground $DefaultOption(ToolbarBackground)
            }
    }
  }

};# ::toolbar::MountFloat


#
# Toolbar Handle Callback
#
# Event codes:
#    2 : User clicked (with double-button-2 or -3) on the toolbar handle
#          --> hide the toolbar (if it is hiddable)
#    1 : User clicked (with double-button-1) on the toolbar handle
#          --> make the toolbar float (if it is floatable)
#   -1 : User cliked on the "Floating" item of the toolbar contextual menu
#   -2 : User cliked on the "Hide"     item of the toolbar contextual menu

proc ::toolbar::HandleCallback {toolbar {event 1}} {

  variable ToolbarSpecifications

  # don't make the toolbar float if it was declared as non-floatable
  # no need to check for $event == -1 because in this case the context menu
  # item does anyway not display, thus no way to trigger this event
  if {$event == 1 && !$ToolbarSpecifications(FloatToolbar:$toolbar)} {
    return
  }

  if {$event > 0} {
    # the user must have clicked on the toolbar handle, otherwise give up
    if {![string match $toolbar.handle* [winfo containing [winfo pointerx $toolbar] [winfo pointery $toolbar]]]} {
      return
    }
  }

  set event [expr {abs($event)}]

  # 1. hide the toolbar by unpacking it
  #    (it is necessarily docked: floating toolbars do not have a handle
  #    nor a context menu, thus no way to be at this place in the code from
  #    a floating toolbar)
  #    this is done for any $event in -2, -1, 1, 2
  pack forget $toolbar.handle $toolbar.widgets
  $toolbar configure -height 1 -width 1 -bd 0

  # 2. additionally make it float,
  #    but only if $event is -1 or 1
  if {$event < 2} {
    CreateToolbarWindow $toolbar
  }

  event generate $toolbar <<ToolBarHide>>

};# ::toolbar::HandleCallback


#
# Display Toolbar Context Sensitive Menu
#

proc ::toolbar::ContextSensitiveMenu {toolbar} {

  variable ToolbarSpecifications

  set menu $toolbar.contextMenu
  catch {destroy $menu}
  menu $menu -tearoff 0

  if {$ToolbarSpecifications(FloatToolbar:$toolbar)} {
    $menu add command -label [::msgcat::mc Floating] -command "::toolbar::HandleCallback $toolbar -1"
  }

  if {$ToolbarSpecifications(HideToolbar:$toolbar)} {
    $menu add command -label [::msgcat::mc Hide]     -command "::toolbar::HandleCallback $toolbar -2"
  }

  tk_popup $menu [winfo pointerx .] [winfo pointery .]

};# ::toolbar::ContextSensitiveMenu


## Click
#  Handler when the user clicks on the toolbar frame...

proc ::toolbar::Click {frame} {

  variable ToolbarSpecifications

  set parent [winfo parent $frame]
  set ToolbarSpecifications(X1:$frame) [expr {[winfo rootx $parent]+20}]
  set ToolbarSpecifications(Y1:$frame) [expr {[winfo rooty $parent]+20}]
  set ToolbarSpecifications(X2:$frame) [expr {$ToolbarSpecifications(X1:$frame)+[winfo width  $parent]-40}]
  set ToolbarSpecifications(Y2:$frame) [expr {$ToolbarSpecifications(X1:$frame)+[winfo height $parent]-40}]

};# Click


proc ::toolbar::Motion {frame iPx iPy} {

  variable ToolbarSpecifications

  ## Get the first child of the parent...
  set parent [winfo parent $frame]
  set sFirst [lindex [pack slaves $parent] 0]

  if {![info exists ToolbarSpecifications(X1:$frame)]} {
    # no click event before motion event (!?)
    return
  }

  set cleanUp 0

  if {$iPx < $ToolbarSpecifications(X1:$frame) && $ToolbarSpecifications(Side:$frame) != "left"} {

    set ToolbarSpecifications(Side:$frame) left
    SetOrientation $frame V
    if {[string length $sFirst]} {
      pack $frame -side left -fill y -before $sFirst
    } else {
      pack $frame -side left -fill y
    }
    ## Is there a decoration?
    if {[winfo exists $frame.toolbar_bottom_decoration]} {
      pack $frame.toolbar_bottom_decoration -side right -fill y -expand 1 -pady 0 -ipady 0
    }
    set cleanUp 1

  } elseif {$iPx > $ToolbarSpecifications(X2:$frame) && $ToolbarSpecifications(Side:$frame) != "right" } {

    set ToolbarSpecifications(Side:$frame) right
    SetOrientation $frame V
    if {[string length $sFirst]} {
      pack $frame -side right -fill y -before $sFirst
    } else {
      pack $frame -side right -fill y
    }
    ## Is there a decoration?
    if {[winfo exists $frame.toolbar_bottom_decoration]} {
      pack $frame.toolbar_bottom_decoration -side right -fill y -expand 1 -pady 0 -ipady 0
    }
    set cleanUp 1

  } elseif {$iPy < $ToolbarSpecifications(Y1:$frame) && $ToolbarSpecifications(Side:$frame) != "top"} {

    set ToolbarSpecifications(Side:$frame) top
    SetOrientation $frame H
    if {[string length $sFirst]} {
      pack $frame -side top -fill x -before $sFirst
    } else {
      pack $frame -side top -fill x
    }
    ## Is there a decoration?
    if {[winfo exists $frame.toolbar_bottom_decoration]} {
      pack $frame.toolbar_bottom_decoration -side bottom -fill x -expand 1 -pady 0 -ipady 0
    }
    set cleanUp 1

  } elseif {$iPy > $ToolbarSpecifications(Y2:$frame) && $ToolbarSpecifications(Side:$frame) != "bottom"} {

    set ToolbarSpecifications(Side:$frame) bottom
    SetOrientation $frame H
    if {[string length $sFirst]} {
      pack $frame -side bottom -fill x -before $sFirst
    } else {
      pack $frame -side bottom -fill x
    }
    ## Is there a decoration?
    if {[winfo exists $frame.toolbar_bottom_decoration]} {
      pack $frame.toolbar_bottom_decoration -side bottom -fill x -expand 1 -pady 0 -ipady 0
    }
    set cleanUp 1

  }

  if {$cleanUp} {
    array unset ToolbarSpecifications X1:*
    array unset ToolbarSpecifications X2:*
    array unset ToolbarSpecifications Y1:*
    array unset ToolbarSpecifications Y2:*
  }

};# Motion


# ::toolbar::Tooltip --
#
#        This function will execute various tooltip-related tasks, like
#        displaying or destroying a tooltip window. This is an internal
#        function and should never be called by users...
#
# Arguments:
#        mode       One of "show" "cancel" "window".
#        widget     The widget under which the tooltip should be shown.
#        toolbar    The toolbar that holds the widget.
#
# Results:
#        Depends on mode...

proc ::toolbar::Tooltip {mode widget toolbar} {

  variable ToolbarSpecifications
  variable DefaultOption

  ## Has this widget a tooltip?
  if {![info exists ToolbarSpecifications(TooltipVar:$widget:$toolbar)] &&
      ![info exists ToolbarSpecifications(Tooltip:$widget:$toolbar)]} {
      return
  }

  ## Has application lost the focus?
  set focus [focus]
  if {![string length $focus]} {
    set mode cancel
  } else {
    ## Is the focus still in the same toplevel?
    if {![string equal [winfo toplevel $widget] [winfo toplevel $focus]]} {
      set mode cancel
    }
  }

  ## Is the mouse still in the same screen as the widget?
  foreach {mx my} [winfo pointerxy $widget] {}
  if {$mx < 0 || $my < 0} {
    set mode cancel
  }

  ## Is the mouse still in the widget?
  set rootx [winfo rootx $widget];
  set rooty [winfo rooty $widget]
  if {$mx < $rootx || $my < $rooty} {
    set mode cancel
  }
  if {$mx > $rootx+[winfo width $widget] || $my > $rooty+[winfo height $widget]} {
    set mode cancel
  }

  switch $mode {

    show {

      ## We should register an event for showing the window...

      catch {after cancel $DefaultOption(TooltipAfterId)}
      catch {after cancel $DefaultOption(TooltipDestroyAfterId)}
      set DefaultOption(TooltipAfterId) [after $DefaultOption(TooltipDelay) "::toolbar::Tooltip window $widget $toolbar"]

      ## If is a registered toolbar widget or variable, save the current value
      ## and place the tooltip...
      if {[info exists ToolbarSpecifications(StatusWidget:$widget:$toolbar)] || \
          [info exists ToolbarSpecifications(StatusVar:$widget:$toolbar)]} {
        if {[info exists ToolbarSpecifications(TooltipVar:$widget:$toolbar)]} {
          set message [set $ToolbarSpecifications(TooltipVar:$widget:$toolbar)]
        } else {
          set message $ToolbarSpecifications(Tooltip:$widget:$toolbar)
        }
        if {[info exists ToolbarSpecifications(StatusWidget:$widget:$toolbar)]} {
          set ToolbarSpecifications(StatusPrev:$widget:$toolbar) [$ToolbarSpecifications(StatusWidget:$widget:$toolbar) cget -text]
          $ToolbarSpecifications(StatusWidget:$widget:$toolbar) configure -text $message
        } else {
          set ToolbarSpecifications(StatusPrev:$widget:$toolbar) [set $ToolbarSpecifications(StatusVar:$widget:$toolbar)]
          set ToolbarSpecifications(StatusVar:$widget:$toolbar) $message
        }
      }

    }

    cancel {

      ## Unregister any after events and destroy any window...

      catch {after cancel $DefaultOption(TooltipAfterId)}
      catch {after cancel $DefaultOption(TooltipDestroyAfterId)}
      catch {destroy .__tooltipWindow__hopeItsUnique}

      ## If is a registered status widget or variable, restore the original
      ## contents...
      if {[info exists ToolbarSpecifications(StatusWidget:$widget:$toolbar)] || \
          [info exists ToolbarSpecifications(StatusVar:$widget:$toolbar)]} {
        ## Get the message, in order to compare it with the current contents...
        if {[info exists ToolbarSpecifications(TooltipVar:$widget:$toolbar)]} {
          set message [set $ToolbarSpecifications(TooltipVar:$widget:$toolbar)]
        } else {
          set message $ToolbarSpecifications(Tooltip:$widget:$toolbar)
        }
        ## Get what the status bar now shows...
        if {[info exists ToolbarSpecifications(StatusWidget:$widget:$toolbar)]} {
          set showing [$ToolbarSpecifications(StatusWidget:$widget:$toolbar) cget -text]
        } else {
          set showing [set $ToolbarSpecifications(StatusVar:$widget:$toolbar)]
        }
        ## If what is now displaying in the status bar is equal to what we
        ## have placed, restore it. Else, forget it, as something else has
        ## changed the status bar text...
        if {[string equal $message $showing]} {
          if {[info exists ToolbarSpecifications(StatusWidget:$widget:$toolbar)]} {
            $ToolbarSpecifications(StatusWidget:$widget:$toolbar) configure -text $ToolbarSpecifications(StatusPrev:$widget:$toolbar)
          } else {
            set $ToolbarSpecifications(StatusVar:$widget:$toolbar) $ToolbarSpecifications(StatusPrev:$widget:$toolbar)
          }
        }
        ## Catch is needed here: If the mouse stays too long in a widget, the
        ## status bar is resetted and this variable is gone. So, in the next
        ## <Leave> event we are called to free it again... (-nocomplain would
        ## also do the job here...)
        catch {unset ToolbarSpecifications(StatusPrev:$widget:$toolbar)}
      }

    }

    window {

      ## We should display a tooltip window...

      set win .__tooltipWindow__hopeItsUnique

      if {[info exists ToolbarSpecifications(TooltipVar:$widget:$toolbar)]} {
        set message [set $ToolbarSpecifications(TooltipVar:$widget:$toolbar)]
      } else {
        set message $ToolbarSpecifications(Tooltip:$widget:$toolbar)
      }

      set x [expr {[winfo rootx $widget] + ([winfo width $widget]/2)}]
      set y [expr {[winfo rooty $widget] + [winfo height $widget] + 4}]

      catch {destroy $win}
      toplevel $win -bg $DefaultOption(TooltipBackground) -highlightthickness 1 \
        -highlightbackground $DefaultOption(TooltipForeground) \
        -highlightcolor $DefaultOption(TooltipForeground)
      wm overrideredirect $win 1

      bind $win <Leave> "destroy $win"

      label $win.l -text $message -relief flat -wraplength 265 \
        -bg $DefaultOption(TooltipBackground) -padx 2 -pady 0 \
        -fg $DefaultOption(TooltipForeground) -anchor w

      pack $win.l -side left -padx 0 -pady 0 -fill both -expand 1

      wm geometry $win +$x+$y

      set DefaultOption(TooltipDestroyAfterId) [after 8000 "::toolbar::Tooltip cancel $widget $toolbar"]

    }

    default {}

  }

};# ::toolbar::Tooltip


# ::toolbar::Init --
#
#        Initialises the toolbar package...
#
# Arguments:
#        none
#
# Results:
#        The array "DefaultOptions" is initialised

proc ::toolbar::Init {} {

  variable DefaultOption

  ## Create a widget in order to get the default background colour...
  set DefaultOption(ToolbarBackground)       [. cget -background]
  set DefaultOption(ToolbarHandleBackground) [. cget -background]
  set w [text .toolbarPackageTestWidgetForGettingDefaultColours__[pid]]
  set DefaultOption(SelectBackground)        [$w cget -selectbackground]
  destroy $w

  ## This option specifies whether toolbars use an image as their handler or not.
  ## If true, the images IToolbar & IToolbarVertical should already
  ## exist (i.e.: they should have been defined previously by the caller of
  ## the toolbar package).
  # If false, the default toolbar handler are two vertical (or horizontal) lines.
  set DefaultOption(ToolbarImageHandle) 0

  ## We register two new events. These events should be virtual ones, i.e. they
  ## should never be sent by the window manager...
  event add <<ToolBarHide>> ToolbarHide
  event add <<ToolBarShow>> ToolbarShow

  ## Finally, add aliases for the needed mouse events. Using these fake events
  ## we allow users to redefine them in anything they consider appropriate...
  event add <<TMotion_1>> <Button1-Motion>
  event add <<TMB_1>>     <ButtonPress-1>
  event add <<TMB_2>>     <ButtonPress-3>

  ## Operating system specific options...
  switch $::tcl_platform(platform) {
    windows {
      array set DefaultOption \
           {ToolbarFrameRelief             flat
            ToolbarRelief                  groove
            ToolbarHandleRelief            flat
            ToolbarFrameReliefBorderWidth  0
            ToolbarReliefBorderWidth       0
            ToolbarHandleReliefBorderWidth 1
            ToolbarDecorate                1
           }
    }
    default {
      array set DefaultOption \
           {ToolbarFrameRelief             raised
            ToolbarRelief                  flat
            ToolbarHandleRelief            raised
            ToolbarFrameReliefBorderWidth  1
            ToolbarReliefBorderWidth       0
            ToolbarHandleReliefBorderWidth 1
            ToolbarDecorate                0
           }
    }
  }

  ## Tooltip support...
  set DefaultOption(TooltipDelay)          700
  set DefaultOption(TooltipAfterId)        0
  set DefaultOption(TooltipDestroyAfterId) 0
  set DefaultOption(TooltipBackground)     #ffffaa
  set DefaultOption(TooltipForeground)     black

};# ::toolbar::Init


## Initialise default values...
::toolbar::Init


## Test our Toolbar package. Comment out for common use...
if {0} {
  package req msgcat
  ::msgcat::mclocale en
  image create photo timage -data \
{R0lGODlhEAAQAKUAAGRjZGJmZ1FQUYSChICFh2KdnyO6u1FlZ4GEhmGeoCO5
ugChogCChFFfYWGhoiK6uwCgoXw1NgDKy+RZWvcICKRfYQC8vepERf8AAPkG
BopiY8VERcUAANYAALQZGYR6fB16fABsbrAYGAO5um9xcgBUVUxCQwBiZABv
cElISWxrbHd1d0xKTIiGiAB2eBRaW01PUQB5exBVV2FwcQC5uglOT2FtbmJr
bf///////////////////////////////yH+Dk1hZGUgd2l0aCBHSU1QACH5
BAEKADgALAAAAAAQABAAAAZxQJxwCCgaAYGhUjBoNgkFw0EpZDYRCcWC0aDi
rI4HhEHuUiNNCXltHk4olYFlXR5eMPiMZk5vbzgdGB4fFiAhbF4iHwMjJCWI
VCZNFicokEopKit8l0MsOC2cdV5CnC4vMKSlDDEyM6pDNDU2sEo3pEEAOw==}

  ## Create a status bar...
  label .status -text {This is a status bar...} -relief sunken -bd 1 \
    -anchor w
  pack .status -fill x -side bottom -padx 0 -pady 0

  ## 1) Create a horizontal toolbar frame...
  set TF [::toolbar::ToolbarFrame .toolbarFrame]
    ## 2) Create a toolbar in this toolbar frame...
    set tb1 [::toolbar::create $TF.tb1]
    ## 3) Add some buttons/widgets in this toolbar...
    ::toolbar::addwidget $tb1 label -text {T 1} -bd 0 -bg red -fg white \
      -tooltip {T 1} -statuswidget .status
    ::toolbar::addbutton $tb1 -image timage -statuswidget .status \
      -tooltip {Button 1} -command {Command {Button 1}}
    ::toolbar::addbutton $tb1 -image timage -statuswidget .status \
      -tooltip {Button 2} -command {Command {Button 2}}
    ::toolbar::addbutton $tb1 -image timage -statuswidget .status \
      -tooltip {Button 3} -command {Command {Button 3}}
    ::toolbar::addseparator $tb1
    ::toolbar::addwidget $tb1 label -text {Exit :} -bd 0 -tooltip Exit... \
      -statuswidget .status
    ::toolbar::addbutton $tb1 -image timage  \
      -tooltip {Exit} -command {exit} -statuswidget .status
    ## 4) Pack the toolbar inside the toolbar frame...
    pack $tb1 -side left -fill y

    ## Create a second toolbar in this toolbar frame...
    set tb2 [::toolbar::create $TF.tb2]
    ## 3) Add some buttons/widgets in this toolbar...
    ::toolbar::addwidget $tb2 label -text {T 3} -bd 0 -bg orange -fg white \
      -tooltip {T 3} -statuswidget .status
    ::toolbar::addwidget $tb2 label -text {Type Here:} -bd 0 \
      -tooltip {The next is an entry widget. You can type there...} \
      -statuswidget .status
    ::toolbar::addwidget $tb2 entry -width 5 -relief sunken -bg white -fg navy\
      -tooltip {This is an entry widget. You can type here...} \
      -statuswidget .status
    ::toolbar::addwidget $tb2 spinbox -width 2 -relief sunken -bg white \
      -fg navy -tooltip {This is a spinbox widget!} -from 0 -to 20 \
      -statuswidget .status
    set mb [::toolbar::addwidget $tb2 menubutton -text {File} -indicatoron 0 \
      -tooltip {This is a menubutton widget!} -statuswidget .status]
    menu $mb.menu -tearoff 0
    $mb.menu add command -label Exit -command exit
    $mb configure -menu $mb.menu
    ::toolbar::addwidget $tb2 checkbutton -text Select \
      -tooltip {This is a checkbutton widget. You can select it...} \
      -statuswidget .status
    ## Pack the toolbar inside the toolbar frame...
    pack $tb2 -side left -fill y
  ## 5) Pack the toolbar frame in our window...
  pack $TF -side top -fill x

  ## Create a vertical toolbar frame...
  set VTF [::toolbar::ToolbarFrame .vtoolbarFrame -orientation vertical]
  ## Create a toolbar in this toolbar frame...
    set tbv1 [::toolbar::create $VTF.tbv1]
    ## Add some buttons/widgets in this toolbar...
    ::toolbar::addwidget $tbv1 label -text {T 2} -bd 0 -bg blue -fg white \
      -tooltip {T 2} -statuswidget .status
    ::toolbar::addbutton $tbv1 -image timage -statuswidget .status \
      -tooltip {Button 1} -command {Command {Button 1}}
    ::toolbar::addbutton $tbv1 -image timage -statuswidget .status \
      -tooltip {Button 2} -command {Command {Button 2}}
    ::toolbar::addbutton $tbv1 -image timage -statuswidget .status \
      -tooltip {Button 3} -command {Command {Button 3}}
    ::toolbar::addseparator $tbv1
    ::toolbar::addwidget $tbv1 entry -width 5 -relief sunken \
      -bg white -fg navy -tooltip {You can type in here!} \
      -statuswidget .status
    ::toolbar::addseparator $tbv1
    ::toolbar::addwidget $tbv1 label -text {Exit :} -bd 0 -tooltip Exit... \
      -statuswidget .status
    ::toolbar::addbutton $tbv1 -image timage  \
      -tooltip {Exit} -command {exit} -statuswidget .status
    ## Pack the toolbar inside the toolbar frame...
    pack $tbv1 -side left -fill y
  ## Pack the toolbar frame in our window...
  pack $VTF -side left -fill y

  ## Add an area with some buttons that do various ops over the toolbars...
  frame .area
    button .area.act1  -text {Activate 1} -bg red -fg white -command \
      "::toolbar::activate $tb1"
    button .area.dact1 -text {Deactivate 1} -bg red -fg white -command \
      "::toolbar::deactivate $tb1"
    button .area.act2  -text {Activate 2} -bg blue -fg white -command \
      "::toolbar::activate $tbv1"
    button .area.dact2 -text {Deactivate 2} -bg blue -fg white -command \
      "::toolbar::deactivate $tbv1"
    button .area.act3  -text {Activate 3} -bg orange -fg white -command \
      "::toolbar::activate $tb2"
    button .area.dact3 -text {Deactivate 3} -bg orange -fg white -command \
      "::toolbar::deactivate $tb2"
    grid .area.act1 .area.dact1 .area.act2 .area.dact2 .area.act3 .area.dact3 \
      -padx 2 -pady 2 -sticky snew
    button .area.shw1  -text {Show 1} -bg red -fg white -command \
      "::toolbar::deiconify $tb1"
    button .area.hide1 -text {Hide 1} -bg red -fg white -command \
      "::toolbar::HandleCallback $tb1 -2"
    button .area.shw2  -text {Show 2} -bg blue -fg white -command \
      "::toolbar::deiconify $tbv1"
    button .area.hide2 -text {Hide 2} -bg blue -fg white -command \
      "::toolbar::HandleCallback $tbv1 -2"
    button .area.shw3  -text {Show 3} -bg orange -fg white -command \
      "::toolbar::deiconify $tb2"
    button .area.hide3 -text {Hide 3} -bg orange -fg white -command \
      "::toolbar::HandleCallback $tb2 -2"
    grid .area.shw1 .area.hide1 .area.shw2 .area.hide2 .area.shw3 .area.hide3 \
      -padx 2 -pady 2 -sticky snew
    button .area.flt1  -text {Float 1} -bg red -fg white -command \
      "::toolbar::HandleCallback $tb1 -1"
    button .area.mnt1 -text {Mount 1} -bg red -fg white -command \
      "catch \"destroy $tb1.fltWin\""
    button .area.flt2  -text {Float 2} -bg blue -fg white -command \
      "::toolbar::HandleCallback $tbv1 -1"
    button .area.mnt2 -text {Mount 2} -bg blue -fg white -command \
      "catch \"destroy $tbv1.fltWin\""
    button .area.flt3  -text {Float 3} -bg orange -fg white -command \
      "::toolbar::HandleCallback $tb2 -1"
    button .area.mnt3 -text {Mount 3} -bg orange -fg white -command \
      "catch \"destroy $tb2.fltWin\""
    grid .area.flt1 .area.mnt1 .area.flt2 .area.mnt2 .area.flt3 .area.mnt3 \
      -padx 2 -pady 2 -sticky snew
    button .area.print -text {Print Variables} -command \
    {catch {console show};puts \n\n###########################\n
     parray ::toolbar::ToolbarSpecifications}
    grid .area.print -columnspan 6 -padx 2 -pady 2 -sticky snew
  pack .area -fill both -expand 1

  proc Command {message} {
    tk_messageBox -icon info -title Info: -type ok -message $message
  }

  wm geometry . 800x400
  focus .
}
