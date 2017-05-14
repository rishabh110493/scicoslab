namespace eval ::dnd {
    proc _load {dir} {
        set version 1.0
        switch $::tcl_platform(platform) {
            windows {
                set filename tkdnd[string map {. {}} $version][info sharedlibextension]
                # try first to load the 32 bits version of the dll
                if {[catch {load [file join $dir Windows x86_32 $filename] tkdnd} error32]} {
                    # The 32 bits dll file could not be loaded, try the 64 bits version
                    if {[catch {load [file join $dir Windows x86_64 $filename] tkdnd} error64]} {
                        # Failed again!
                        # Neither the 32 bits nor the 64 bits version of the dll could be loaded
                        return -code error "$error32\n$error64"
                    }
                }
            }
            unix {
                set filename libtkdnd$version[info sharedlibextension]
                if {[catch {load [file join $dir Linux x86_32 $filename] tkdnd} error32]} {
                    # The 32 bits .so file could not be loaded, try the 64 bits version
                    if {[catch {load [file join $dir Linux x86_64 $filename] tkdnd} error64]} {
                        # Failed again!
                        # Neither the 32 bits nor the 64 bits version of the .so could be loaded
                        return -code error "$error32\n$error64"
                    }
                }
            }
            default {
                return -code error "Platform $::tcl_platform(platform) is not supported by tkdnd"
            }
        }
        source [file join $dir tkdnd.tcl]
        package provide tkdnd $version
    }
}

package ifneeded tkdnd 1.0  [list ::dnd::_load $dir]

