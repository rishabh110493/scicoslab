#!/usr/bin/wish
# -*- mode:tcl -*-
# timer --
# This script generates a counter with start and stop buttons.

set w .foo
catch {destroy .foo}

toplevel .foo
wm title .foo "Timer"

label .foo.counter -text 0.00 -relief raised -width 10
button .foo.start -text Start -command {set stopped "false"; tick } 
button .foo.stop -text Stop -command {set stopped "true"}
pack .foo.counter -side bottom -fill both
pack .foo.start -side left -fill both -expand yes
pack .foo.stop -side right -fill both -expand yes

set seconds 0
set hundredths 0
set stopped "flase"

proc tick {} {
    global seconds hundredths stopped
    if  {$stopped == "true"}  return
    after 50 tick
    set hundredths [expr $hundredths+5]
    if {$hundredths >= 100} {
	set hundredths 0
	set seconds [expr $seconds+1]
    }
    .foo.counter config -text [format "%d.%02d" $seconds $hundredths]
}

bind .foo <Control-c> {destroy .}
bind .foo <Control-q> {destroy .}
focus .foo
