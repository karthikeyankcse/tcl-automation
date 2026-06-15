package require Tk
wm withdraw .
namespace eval AddingNetsOffPortMM {} {
    variable dirName [file dirname [info script]]
    variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc AddingNetsOffPortMM::AddingNetsOffPortMMfunc {} {

    variable userName
    variable userProfile

    set lSession $::DboSession_s_pDboSession
    DboSession -this $lSession
    set lNullObj NULL
    set lStatus [DboState]
    set lDesign [$lSession GetActiveDesign]
	
    if {$lDesign != "NULL"} {
        set lDesignName [DboTclHelper_sMakeCString]
        $lDesign GetName $lDesignName
        set filename [DboTclHelper_sGetConstCharPtr $lDesignName]
    } else {
        set filename "No Active Design"
    }

    set now [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    set nowForFile [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]

    set Prsefilename1 [lindex [split $filename "\\"] end]
    set Prsefilename [lindex [split $Prsefilename1 "."] 0]

    set CreateFilename "${Prsefilename}_${userName}_${nowForFile}.log"

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Adding_Nets_Off_Port"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Adding_Nets_Off_Port"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

    set ::DropdownSelection ""
    set ::DropdownSelection1 ""
    set ::DropdownSelection2 ""
    set ::DropdownSelection3 ""
    set ::DropdownSelection4 ""
    set ::input_info ""

    set user_input [tk_messageBox -title "Adding Nets-Offs-Ports" -message "Please Confirm to Run the Adding Nets-Offs-Ports Program ..!" -type okcancel -icon question -default ok -parent .]
    if {$user_input eq "ok"} {
        toplevel .site_inp_dialog 
        wm title .site_inp_dialog "Adding Nets-Offs-Ports"

        # Grid configuration to handle alignment
        grid columnconfigure .site_inp_dialog 0 -weight 1
        grid columnconfigure .site_inp_dialog 1 -weight 3
        grid columnconfigure .site_inp_dialog 2 -weight 0

        grid rowconfigure .site_inp_dialog 0 -weight 0
        grid rowconfigure .site_inp_dialog 1 -weight 0
        grid rowconfigure .site_inp_dialog 2 -weight 1
        grid rowconfigure .site_inp_dialog 3 -weight 1
        grid rowconfigure .site_inp_dialog 4 -weight 0
        grid rowconfigure .site_inp_dialog 5 -weight 0
        grid rowconfigure .site_inp_dialog 6 -weight 1
        grid rowconfigure .site_inp_dialog 7 -weight 0
        grid rowconfigure .site_inp_dialog 8 -weight 0
        grid rowconfigure .site_inp_dialog 9 -weight 1
        grid rowconfigure .site_inp_dialog 10 -weight 0

        # Font definition
        set font_style {Cambria 12}

        # Page selection label and button
        label .site_inp_dialog.prompt_page -text "SELECT THE PAGE :" -font $font_style
        grid .site_inp_dialog.prompt_page -row 3 -column 0 -sticky e -padx 10 -pady 5

        menu .site_inp_dialog.dropdown_page
        .site_inp_dialog.dropdown_page add command -label "HIERARCHICAL" -command {set ::DropdownSelection "HIERARCHICAL"; .site_inp_dialog.dropdown_button_page configure -text "HIERARCHICAL"}
        .site_inp_dialog.dropdown_page add command -label "NON HIERARCHICAL" -command {set ::DropdownSelection "NON HIERARCHICAL"; .site_inp_dialog.dropdown_button_page configure -text "NON HIERARCHICAL"}

        button .site_inp_dialog.dropdown_button_page -text "Select" -command {.site_inp_dialog.dropdown_page post [winfo pointerx .] [winfo pointery .]} -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.dropdown_button_page -row 3 -column 1 -sticky w -padx 10 -pady 5

        # Pin or Part selection label and button
        label .site_inp_dialog.prompt_pin_part -text "SELECT PIN OR PART :" -font $font_style
        grid .site_inp_dialog.prompt_pin_part -row 5 -column 0 -sticky e -padx 10 -pady 5

        menu .site_inp_dialog.dropdown_pin_part
        .site_inp_dialog.dropdown_pin_part add command -label "PIN" -command {set ::DropdownSelection1 "PIN"; .site_inp_dialog.dropdown_button_pin_part configure -text "PIN"}
        .site_inp_dialog.dropdown_pin_part add command -label "PART" -command {set ::DropdownSelection1 "PART"; .site_inp_dialog.dropdown_button_pin_part configure -text "PART"}

        button .site_inp_dialog.dropdown_button_pin_part -text "Select" -command {.site_inp_dialog.dropdown_pin_part post [winfo pointerx .] [winfo pointery .]} -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.dropdown_button_pin_part -row 5 -column 1 -sticky w -padx 10 -pady 5

        # Offpage/Port/Nets selection label and button
        label .site_inp_dialog.prompt_OPN -text "SELECT OFFPAGE - PORT - NETS:" -font $font_style
        grid .site_inp_dialog.prompt_OPN -row 7 -column 0 -sticky e -padx 10 -pady 5

        menu .site_inp_dialog.dropdown_OPN
        .site_inp_dialog.dropdown_OPN add command -label "OFFPAGE" -command {set ::DropdownSelection2 "OFFPAGE"; .site_inp_dialog.dropdown_button_OPN configure -text "OFFPAGE"}
        .site_inp_dialog.dropdown_OPN add command -label "PORT" -command {set ::DropdownSelection2 "PORT"; .site_inp_dialog.dropdown_button_OPN configure -text "PORT"}
        .site_inp_dialog.dropdown_OPN add command -label "NETS" -command {set ::DropdownSelection2 "NETS"; .site_inp_dialog.dropdown_button_OPN configure -text "NETS"}

        button .site_inp_dialog.dropdown_button_OPN -text "Select" -command {.site_inp_dialog.dropdown_OPN post [winfo pointerx .] [winfo pointery .]} -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.dropdown_button_OPN -row 7 -column 1 -sticky w -padx 10 -pady 5


        label .site_inp_dialog.prompt_NN -text "SELECT NAME - NUMBER:" -font $font_style
        grid .site_inp_dialog.prompt_NN -row 9 -column 0 -sticky e -padx 10 -pady 5

        menu .site_inp_dialog.dropdown_NN
        .site_inp_dialog.dropdown_NN add command -label "NAME" -command {set ::DropdownSelection4 "NAME"; .site_inp_dialog.dropdown_button_NN configure -text "NAME"}
        .site_inp_dialog.dropdown_NN add command -label "NUMBER" -command {set ::DropdownSelection4 "NUMBER"; .site_inp_dialog.dropdown_button_NN configure -text "NUMBER"}


        button .site_inp_dialog.dropdown_button_NN -text "Select" -command {.site_inp_dialog.dropdown_NN post [winfo pointerx .] [winfo pointery .]} -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.dropdown_button_NN -row 9 -column 1 -sticky w -padx 10 -pady 5

        # Input Box
        label .site_inp_dialog.prompt_input -text "ENTER ADDITIONAL NAME:" -font $font_style
        grid .site_inp_dialog.prompt_input -row 11 -column 0 -sticky e -padx 10 -pady 5

        entry .site_inp_dialog.input_box -font $font_style
        grid .site_inp_dialog.input_box -row 11 -column 1 -sticky w -padx 10 -pady 5

        label .site_inp_dialog.prompt_PS -text "SELECT PREFIX,SUFFIX OR REFDES:" -font $font_style
        grid .site_inp_dialog.prompt_PS -row 13 -column 0 -sticky e -padx 10 -pady 5

        menu .site_inp_dialog.dropdown_PS
        .site_inp_dialog.dropdown_PS add command -label "PREFIX" -command {set ::DropdownSelection3 "PREFIX"; .site_inp_dialog.dropdown_button_PS configure -text "PREFIX"}
        .site_inp_dialog.dropdown_PS add command -label "SUFFIX" -command {set ::DropdownSelection3 "SUFFIX"; .site_inp_dialog.dropdown_button_PS configure -text "SUFFIX"}
		.site_inp_dialog.dropdown_PS add command -label "REFDES" -command {set ::DropdownSelection3 "REFDES"; .site_inp_dialog.dropdown_button_PS configure -text "REFDES"}
		
        button .site_inp_dialog.dropdown_button_PS -text "Select" -command {.site_inp_dialog.dropdown_PS post [winfo pointerx .] [winfo pointery .]} -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.dropdown_button_PS -row 13 -column 1 -sticky w -padx 10 -pady 5

        frame .site_inp_dialog.buttons
        grid .site_inp_dialog.buttons -row 14 -column 0 -columnspan 3 -sticky ew -padx 10 -pady 10

        button .site_inp_dialog.ok -text "CLICK HERE TO CREATE" -command {
            set ::DropdownSelection $::DropdownSelection
            set ::DropdownSelection1 $::DropdownSelection1
            set ::DropdownSelection2 $::DropdownSelection2
            set ::input_info [.site_inp_dialog.input_box get]
            set ::DropdownSelection3 $::DropdownSelection3
            set ::DropdownSelection4 $::DropdownSelection4
            destroy .site_inp_dialog
        } -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.ok -row 15 -column 0 -columnspan 3 -padx 20 -pady 15 -sticky ew

        tkwait window .site_inp_dialog

        puts "ADDING NETS TCL SCRIPT"

        set DropdownSelection $::DropdownSelection
        puts "SELECTED PAGE: $DropdownSelection"

        set DropdownSelection1 $::DropdownSelection1
        puts "SELECTED (Pin/Part): $DropdownSelection1"

        set DropdownSelection2 $::DropdownSelection2
        puts "SELECTED (Offpage/Port/Nets): $DropdownSelection2"

        set input_info $::input_info
        puts "ADDITIONAL NAME: $input_info"

        set DropdownSelection3 $::DropdownSelection3
        puts "SELECTED (PREFIX/SUFFIX/REFDES): $DropdownSelection3"

        set DropdownSelection4 $::DropdownSelection4
        puts "SELECTED (NAME/NUMBER): $DropdownSelection4"

        if {$DropdownSelection != "" && $DropdownSelection1 != "" && $DropdownSelection2 != "" && $DropdownSelection4 != ""} {
        set selectedobjs [GetSelectedObjects]
        set objlength [llength $selectedobjs]
        set lStatus [DboState]
        set lNullObj NULL

        for {set i 0} {$i < $objlength} {incr i} {
		    set obj [lindex $selectedobjs $i]
            if {$DropdownSelection1 != ""} {
                if {$DropdownSelection1 == "PIN"} {
                    set PassVar "Go"
                    set lWire [$obj GetWire $lStatus]
                    if {$lWire != $lNullObj} {
                        set PassVar "Block"
                    }
                    if {$PassVar == "Go"} {
                        set lPinNum [DboTclHelper_sMakeCString]
                        set lPinName [DboTclHelper_sMakeCString]
                        $obj GetPinNumber $lPinNum
                        $obj GetPinName $lPinName
                        set lPinNum [DboTclHelper_sGetConstCharPtr $lPinNum]
                        set lPinName [DboTclHelper_sGetConstCharPtr $lPinName]

                        set PassName "Dummy Name"
						
						set lPartInst [$obj GetOwner]
						set lRefDesCS [DboTclHelper_sMakeCString]
						$lPartInst GetReferenceDesignator $lRefDesCS
						set lRefdes [DboTclHelper_sGetConstCharPtr $lRefDesCS]

                        if {$DropdownSelection3 != ""} {
                            if {$DropdownSelection3 == "PREFIX"} {
                                if {$DropdownSelection4 == "NAME"} {
                                    set PassName "${input_info}${lPinName}"
                                } elseif {$DropdownSelection4 == "NUMBER"} {
                                    set PassName "${input_info}${lPinNum}"
                                }
                            } elseif {$DropdownSelection3 == "SUFFIX"} {
                                if {$DropdownSelection4 == "NAME"} {
                                    set PassName "${lPinName}${input_info}"
                                } elseif {$DropdownSelection4 == "NUMBER"} {
                                    set PassName "${lPinNum}${input_info}"
                                }
                            } elseif {$DropdownSelection3 == "REFDES"} {
                                if {$DropdownSelection4 == "NAME"} {
                                    set PassName "${lRefdes}_${lPinName}"
                                } elseif {$DropdownSelection4 == "NUMBER"} {
                                    set PassName "${lRefdes}_${lPinNum}"
                                }
							}
                        } else {
                            if {$DropdownSelection4 == "NAME"} {
                                set PassName "${lPinName}"
                            } elseif {$DropdownSelection4 == "NUMBER"} {
                                set PassName "${lPinNum}"
                            }
                        }
                        set PassName [string map { "]" "" "[" "_" } $PassName]

                        if {$DropdownSelection != ""} {
                            if {$DropdownSelection == "HIERARCHICAL"} {
                                # lWireLength was originally inches (0.2"). Convert to mm:
                                set lWireLength 5.08   ;# 0.2 inch -> 5.08 mm

                                set lStartPoint [$obj GetStartPoint $lStatus]
                                set lStartPointX [expr ([DboTclHelper_sGetCPointX $lStartPoint]/100.0) * 25.4]
                                set lStartPointY [expr ([DboTclHelper_sGetCPointY $lStartPoint]/100.0) * 25.4]
                                #puts "Start: $lStartPointX , $lStartPointY"
                                

                                set lHotSpotPoint [$obj GetOffsetHotSpot $lStatus]
                                set lHotSpotPointX [expr ([DboTclHelper_sGetCPointX $lHotSpotPoint]/100.0) * 25.4]
                                set lHotSpotPointY [expr ([DboTclHelper_sGetCPointY $lHotSpotPoint]/100.0) * 25.4]
                                #puts "HotSpotPointY: $lHotSpotPointX , $lHotSpotPointY"

                                set CreateLoc "DummyVal"
                                set offsetX 0
                                set offsetY 0
                                if {$lStartPointX == 0.0 } {
                                    set offsetX $lWireLength
                                    set CreateLoc "RIGHT"
                                } else {
                                    set offsetX [expr -$lWireLength]
                                    set CreateLoc "LEFT"
                                }

                                if {$DropdownSelection2 == "OFFPAGE"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX-$offsetX] [expr $lHotSpotPointY]
                                    set OffXloc [expr $lHotSpotPointX-$offsetX]
                                    set OffYloc [expr $lHotSpotPointY]
                                    set OffXlocup [expr $OffXloc-2.54]    ;# was -0.1" -> -2.54 mm
                                    set OffYlocUp [expr $OffYloc-2.54]    ;# was -0.1" -> -2.54 mm

                                    if {$CreateLoc == "LEFT"} {
                                        PlaceOffPage $OffXloc $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGELEFT-L.OLB" "OFFPAGELEFT-L" $PassName
                                    } elseif {$CreateLoc == "RIGHT"} {
                                        PlaceOffPage $OffXlocup $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGERIGHT-R.OLB" "OFFPAGERIGHT-R" $PassName
                                    } else {
                                        puts "OLB File Missing Please Check"
                                    }
                                    
                                    if {$offsetY != 0} {
                                        set lWire [$obj GetWire $lStatus]
                                        set lAliasIter [$lWire NewAliasesIter $lStatus] 
                                        #get the first alias of wire  
                                        set lAlias [$lAliasIter NextAlias $lStatus] 
                                        $lAlias SetRotation 3
                                        delete_DboWireAliasesIter $lAliasIter
                                    }
                                } elseif {$DropdownSelection2 == "NETS"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX-$offsetX] [expr $lHotSpotPointY]
									PlaceNetAlias [expr $lHotSpotPointX] [expr $lHotSpotPointY] $PassName
                                } elseif {$DropdownSelection2 == "PORT"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX-$offsetX] [expr $lHotSpotPointY]
                                    set OffXloc [expr $lHotSpotPointX-$offsetX]
                                    set OffYloc [expr $lHotSpotPointY]
                                    set OffXlocUp [expr $OffXloc-7.62]   ;# was -0.3" -> -7.62 mm
                                    set OffYlocUp [expr $OffYloc-2.54]   ;# was -0.1" -> -2.54 mm
                                    if {$CreateLoc == "LEFT"} {
                                        PlacePort $OffXloc $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\PORTBOTH-L.OLB" "PORTBOTH-L" $PassName
                                    } elseif {$CreateLoc == "RIGHT"} {
                                        PlacePort $OffXlocUp $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\PORTBOTH-R.OLB" "PORTBOTH-R" $PassName
                                    } else {
                                        puts "OLB File Missing Please Check"
                                    }
                                    
                                    if {$offsetY != 0} {
                                        set lWire [$obj GetWire $lStatus]
                                        set lAliasIter [$lWire NewAliasesIter $lStatus] 
                                        #get the first alias of wire  
                                        set lAlias [$lAliasIter NextAlias $lStatus] 
                                        $lAlias SetRotation 3
                                        delete_DboWireAliasesIter $lAliasIter
                                    }

                                }

                            } elseif {$DropdownSelection == "NON HIERARCHICAL"} {
                                # lWireLength was originally 0.5" -> convert to mm
                                set lWireLength 12.7   ;# 0.5 inch -> 12.7 mm

                                set lStartPoint [$obj GetOffsetStartPoint $lStatus]
                                set lStartPointX [expr ([DboTclHelper_sGetCPointX $lStartPoint]/100.0) * 25.4]
                                set lStartPointY [expr ([DboTclHelper_sGetCPointY $lStartPoint]/100.0) * 25.4]
                                
                                set lHotSpotPoint [$obj GetOffsetHotSpot $lStatus]
                                set lHotSpotPointX [expr ([DboTclHelper_sGetCPointX $lHotSpotPoint]/100.0) * 25.4]
                                set lHotSpotPointY [expr ([DboTclHelper_sGetCPointY $lHotSpotPoint]/100.0) * 25.4]

                                set CreateLoc "DummyVal"
                                set offsetX 0
                                set offsetY 0
                                if {$lHotSpotPointX > $lStartPointX} {
                                    set offsetX $lWireLength
                                    set CreateLoc "LEFT"
                                } elseif {$lHotSpotPointX < $lStartPointX} {
                                    set offsetX [expr -$lWireLength]
                                    set CreateLoc "RIGHT"
                                }
                                if {$lHotSpotPointY > $lStartPointY} {
                                    set offsetY $lWireLength
                                } elseif {$lHotSpotPointY < $lStartPointY} {
                                    set offsetY [expr -$lWireLength]
                                } 

                                if {$DropdownSelection2 == "OFFPAGE"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+$offsetX] [expr $lHotSpotPointY+$offsetY]
                                    #PlaceNetAlias [expr $lHotSpotPointX+$offsetX/2] [expr $lHotSpotPointY+$offsetY/2] $lPinNum
                                    
                                    set OffXloc [expr $lHotSpotPointX+$offsetX]
                                    set OffYloc [expr $lHotSpotPointY+$offsetY]
                                    set OffXlocup [expr $OffXloc-2.54]
                                    set OffYlocUp [expr $OffYloc-2.54]
                                    
                                    if {$CreateLoc == "LEFT"} {
                                        PlaceOffPage $OffXloc $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGELEFT-L.OLB" "OFFPAGELEFT-L" $PassName
                                    } elseif {$CreateLoc == "RIGHT"} {
                                        PlaceOffPage $OffXlocup $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGERIGHT-R.OLB" "OFFPAGERIGHT-R" $PassName
                                    } else {
                                        puts "OLB File Missing Please Check"
                                    }
                                    
                                    if {$offsetY != 0} {
                                        set lWire [$obj GetWire $lStatus]
                                        set lAliasIter [$lWire NewAliasesIter $lStatus] 
                                        #get the first alias of wire  
                                        set lAlias [$lAliasIter NextAlias $lStatus] 
                                        $lAlias SetRotation 3
                                        delete_DboWireAliasesIter $lAliasIter
                                    }
                                } elseif {$DropdownSelection2 == "PORT"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+$offsetX] [expr $lHotSpotPointY+$offsetY]
                                    #PlaceNetAlias [expr $lHotSpotPointX+$offsetX/2] [expr $lHotSpotPointY+$offsetY/2] $lPinName
                                    
                                    set OffXloc [expr $lHotSpotPointX+$offsetX]
                                    set OffYloc [expr $lHotSpotPointY+$offsetY]
                                    set OffYlocUp [expr $OffYloc-2.54]
                                    if {$CreateLoc == "LEFT"} {
                                        set OffXlocup [expr $OffXloc]
                                        PlacePort $OffXlocup $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\PORTBOTH-L.OLB" "PORTBOTH-L" $PassName
                                    } elseif {$CreateLoc == "RIGHT"} {
                                        set OffXlocup [expr $OffXloc-7.62]
                                        PlacePort $OffXlocup $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\PORTBOTH-R.OLB" "PORTBOTH-R" $PassName
                                    } else {
                                        puts "OLB File Missing Please Check"
                                    }
                                    
                                    if {$offsetY != 0} {
                                        set lWire [$lWire GetWire $lStatus]
                                        set lAliasIter [$lWire NewAliasesIter $lStatus] 
                                        set lAlias [$lAliasIter NextAlias $lStatus] 
                                        $lAlias SetRotation 3
                                        delete_DboWireAliasesIter $lAliasIter
                                    }
                                } elseif {$DropdownSelection2 == "NETS"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+$offsetX] [expr $lHotSpotPointY+$offsetY]
									PlaceNetAlias [expr $lHotSpotPointX+$offsetX/2] [expr $lHotSpotPointY+$offsetY/2] $PassName
                                }  

                            }

                        } 
                    }
                } elseif {$DropdownSelection1 == "PART"} {
                    set lIter [$obj NewPinsIter $lStatus] 
                    set lPin [$lIter NextPin $lStatus] 
                    while {$lPin != $lNullObj } { 
                        set PassVar "Go"
                        set lWire [$lPin GetWire $lStatus]
                        if {$lWire != $lNullObj} {
                            set PassVar "Block"
                        }

                        if {$PassVar == "Go"} {
                            set lPinNum [DboTclHelper_sMakeCString]
                            set lPinName [DboTclHelper_sMakeCString]
                            $lPin GetPinNumber $lPinNum
                            $lPin GetPinName $lPinName
                            set lPinNum [DboTclHelper_sGetConstCharPtr $lPinNum]
                            set lPinName [DboTclHelper_sGetConstCharPtr $lPinName]
							
							set lPartInst [$lPin GetOwner]
							set lRefDesCS [DboTclHelper_sMakeCString]
							$lPartInst GetReferenceDesignator $lRefDesCS
							set lRefdes [DboTclHelper_sGetConstCharPtr $lRefDesCS]

                        set PassName "Dummy Name"

                        if {$DropdownSelection3 != ""} {
                            if {$DropdownSelection3 == "PREFIX"} {
                                if {$DropdownSelection4 == "NAME"} {
                                    set PassName "${input_info}${lPinName}"
                                } elseif {$DropdownSelection4 == "NUMBER"} {
                                    set PassName "${input_info}${lPinNum}"
                                }
                            } elseif {$DropdownSelection3 == "SUFFIX"} {
                                if {$DropdownSelection4 == "NAME"} {
                                    set PassName "${lPinName}${input_info}"
                                } elseif {$DropdownSelection4 == "NUMBER"} {
                                    set PassName "${lPinNum}${input_info}"
                                }
                            } elseif {$DropdownSelection3 == "REFDES"} {
                                if {$DropdownSelection4 == "NAME"} {
                                    set PassName "${lRefdes}_${lPinName}"
                                } elseif {$DropdownSelection4 == "NUMBER"} {
                                    set PassName "${lRefdes}_${lPinNum}"
                                }
							}
                        } else {
                            if {$DropdownSelection4 == "NAME"} {
                                set PassName "${lPinName}"
                            } elseif {$DropdownSelection4 == "NUMBER"} {
                                set PassName "${lPinNum}"
                            }
                        }
                        set PassName [string map { "]" "" "[" "_" } $PassName]

                        if {$DropdownSelection != ""} {
                            if {$DropdownSelection == "HIERARCHICAL"} {
                                set lWireLength 5.08

                                set lStartPoint [$lPin GetStartPoint $lStatus]
                                set lStartPointX [expr ([DboTclHelper_sGetCPointX $lStartPoint]/100.0) * 25.4]
                                set lStartPointY [expr ([DboTclHelper_sGetCPointY $lStartPoint]/100.0) * 25.4]

                                set lHotSpotPoint [$lPin GetOffsetHotSpot $lStatus]
                                set lHotSpotPointX [expr ([DboTclHelper_sGetCPointX $lHotSpotPoint]/100.0) * 25.4]
                                set lHotSpotPointY [expr ([DboTclHelper_sGetCPointY $lHotSpotPoint]/100.0) * 25.4]

                                set CreateLoc "DummyVal"
                                set offsetX 0
                                set offsetY 0
                                if {$lStartPointX == 0.0 } {
                                    set offsetX $lWireLength
                                    set CreateLoc "RIGHT"
                                } else {
                                    set offsetX [expr -$lWireLength]
                                    set CreateLoc "LEFT"
                                }

                                if {$DropdownSelection2 == "OFFPAGE"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX-$offsetX] [expr $lHotSpotPointY]
                                    set OffXloc [expr $lHotSpotPointX-$offsetX]
                                    set OffYloc [expr $lHotSpotPointY]
                                    set OffXlocup [expr $OffXloc-2.54]
                                    set OffYlocUp [expr $OffYloc-2.54]

                                    if {$CreateLoc == "LEFT"} {
                                        PlaceOffPage $OffXloc $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGELEFT-L.OLB" "OFFPAGELEFT-L" $PassName
                                    } elseif {$CreateLoc == "RIGHT"} {
                                        PlaceOffPage $OffXlocup $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGERIGHT-R.OLB" "OFFPAGERIGHT-R" $PassName
                                    } else {
                                        puts "OLB File Missing Please Check"
                                    }
                                    
                                    if {$offsetY != 0} {
                                        set lWire [$obj GetWire $lStatus]
                                        set lAliasIter [$lWire NewAliasesIter $lStatus] 
                                        #get the first alias of wire  
                                        set lAlias [$lAliasIter NextAlias $lStatus] 
                                        $lAlias SetRotation 3
                                        delete_DboWireAliasesIter $lAliasIter
                                    }
                                } elseif {$DropdownSelection2 == "NETS"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX-$offsetX] [expr $lHotSpotPointY]
									PlaceNetAlias [expr $lHotSpotPointX] [expr $lHotSpotPointY] $PassName
                                } elseif {$DropdownSelection2 == "PORT"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX-$offsetX] [expr $lHotSpotPointY]
                                    set OffXloc [expr $lHotSpotPointX-$offsetX]
                                    set OffYloc [expr $lHotSpotPointY]
                                    set OffXlocUp [expr $OffXloc-7.62]
                                    set OffYlocUp [expr $OffYloc-2.54]
                                    if {$CreateLoc == "LEFT"} {
                                        PlacePort $OffXloc $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\PORTBOTH-L.OLB" "PORTBOTH-L" $PassName
                                    } elseif {$CreateLoc == "RIGHT"} {
                                        PlacePort $OffXlocUp $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\PORTBOTH-R.OLB" "PORTBOTH-R" $PassName
                                    } else {
                                        puts "OLB File Missing Please Check"
                                    }
                                    
                                    if {$offsetY != 0} {
                                        set lWire [$obj GetWire $lStatus]
                                        set lAliasIter [$lWire NewAliasesIter $lStatus] 
                                        #get the first alias of wire  
                                        set lAlias [$lAliasIter NextAlias $lStatus] 
                                        $lAlias SetRotation 3
                                        delete_DboWireAliasesIter $lAliasIter
                                    }

                                }

                            } elseif {$DropdownSelection == "NON HIERARCHICAL"} {
                                set lWireLength 12.7

                                set lStartPoint [$obj GetOffsetStartPoint $lStatus]
                                set lStartPointX [expr ([DboTclHelper_sGetCPointX $lStartPoint]/100.0) * 25.4]
                                set lStartPointY [expr ([DboTclHelper_sGetCPointY $lStartPoint]/100.0) * 25.4]
                                
                                set lHotSpotPoint [$obj GetOffsetHotSpot $lStatus]
                                set lHotSpotPointX [expr ([DboTclHelper_sGetCPointX $lHotSpotPoint]/100.0) * 25.4]
                                set lHotSpotPointY [expr ([DboTclHelper_sGetCPointY $lHotSpotPoint]/100.0) * 25.4]

                                set CreateLoc "DummyVal"
                                set offsetX 0
                                set offsetY 0
                                if {$lHotSpotPointX > $lStartPointX} {
                                    set offsetX $lWireLength
                                    set CreateLoc "LEFT"
                                } elseif {$lHotSpotPointX < $lStartPointX} {
                                    set offsetX [expr -$lWireLength]
                                    set CreateLoc "RIGHT"
                                }
                                if {$lHotSpotPointY > $lStartPointY} {
                                    set offsetY $lWireLength
                                } elseif {$lHotSpotPointY < $lStartPointY} {
                                    set offsetY [expr -$lWireLength]
                                } 

                                if {$DropdownSelection2 == "OFFPAGE"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+$offsetX] [expr $lHotSpotPointY+$offsetY]
                                    set OffXloc [expr $lHotSpotPointX+$offsetX]
                                    set OffYloc [expr $lHotSpotPointY+$offsetY]
                                    set OffXlocup [expr $OffXloc-2.54]
                                    set OffYlocUp [expr $OffYloc-2.54]
                                    
                                    if {$CreateLoc == "LEFT"} {
                                        PlaceOffPage $OffXloc $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGELEFT-L.OLB" "OFFPAGELEFT-L" $PassName
                                    } elseif {$CreateLoc == "RIGHT"} {
                                        PlaceOffPage $OffXlocup $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGERIGHT-R.OLB" "OFFPAGERIGHT-R" $PassName
                                    } else {
                                        puts "OLB File Missing Please Check"
                                    }
                                    
                                    if {$offsetY != 0} {
                                        set lWire [$obj GetWire $lStatus]
                                        set lAliasIter [$lWire NewAliasesIter $lStatus] 
                                        #get the first alias of wire  
                                        set lAlias [$lAliasIter NextAlias $lStatus] 
                                        $lAlias SetRotation 3
                                        delete_DboWireAliasesIter $lAliasIter
                                    }
                                } elseif {$DropdownSelection2 == "PORT"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+$offsetX] [expr $lHotSpotPointY+$offsetY]
                                    set OffXloc [expr $lHotSpotPointX+$offsetX]
                                    set OffYloc [expr $lHotSpotPointY+$offsetY]
                                    set OffXlocUp [expr $OffXloc-7.62]
                                    set OffYlocUp [expr $OffYloc-2.54]
                                    if {$CreateLoc == "LEFT"} {
                                        PlacePort $OffXloc $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\PORTBOTH-L.OLB" "PORTBOTH-L" $PassName
                                    } elseif {$CreateLoc == "RIGHT"} {
                                        PlacePort $OffXlocUp $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\PORTBOTH-R.OLB" "PORTBOTH-R" $PassName
                                    } else {
                                        puts "OLB File Missing Please Check"
                                    }
                                    
                                    if {$offsetY != 0} {
                                        set lWire [$obj GetWire $lStatus]
                                        set lAliasIter [$lWire NewAliasesIter $lStatus] 
                                        #get the first alias of wire  
                                        set lAlias [$lAliasIter NextAlias $lStatus] 
                                        $lAlias SetRotation 3
                                        delete_DboWireAliasesIter $lAliasIter
                                    }

                                } elseif {$DropdownSelection2 == "NETS"} {
                                    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+$offsetX] [expr $lHotSpotPointY+$offsetY]
									PlaceNetAlias [expr $lHotSpotPointX+$offsetX/2] [expr $lHotSpotPointY+$offsetY/2] $PassName
                                }  

                            }

                        }

                        }
                        
                        set lPin [$lIter NextPin $lStatus] 
                    } 
                    delete_DboPartInstPinsIter $lIter
                }
            }   
        }
        } else {
            set user_input1 [tk_messageBox -title "Adding Nets-Offs-Ports" -message "Error : Required Input is Not Selected ..!" -type okcancel -icon question -default ok -parent .]
        }
    }
}

AddingNetsOffPortMM::AddingNetsOffPortMMfunc
