SetOptionBool Journaling True
package require Tk
wm withdraw .
namespace eval TCLAlignDispPropPart {} {
	
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc TCLAlignDispPropPart::TCLAlignDispPropPartfunc {} {
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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Align_Display_Property_Part"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Align Display Property Part"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set user_input [tk_messageBox -title "Part Display Property Align" -message "Please Confirm to Align the Part Display Property..!" -type okcancel -icon question -default ok -parent .]
	if {$user_input eq "ok"} {
		toplevel .site_inp_dialog 
        wm title .site_inp_dialog "Site Name Change"
        
        label .site_inp_dialog.promptP -text "For LEFT and TOP Distance:"
        pack .site_inp_dialog.promptP -side top
        
        entry .site_inp_dialog.entryP -width 20
        pack .site_inp_dialog.entryP -side top
        
		label .site_inp_dialog.promptP1 -text "For RIGHT and BOTTOM Distance:"
        pack .site_inp_dialog.promptP1 -side top
        
        entry .site_inp_dialog.entryP1 -width 20
        pack .site_inp_dialog.entryP1 -side top

        button .site_inp_dialog.ok -text "OK" -command {set ::LDDist [.site_inp_dialog.entryP get]; set ::RTDist [.site_inp_dialog.entryP1 get]; destroy .site_inp_dialog}
        pack .site_inp_dialog.ok -side left
        
        button .site_inp_dialog.cancel -text "Cancel" -command {set ::LDDist ""; destroy .site_inp_dialog}
        pack .site_inp_dialog.cancel -side right
        
        tkwait window .site_inp_dialog
        
        set LDVal $::LDDist
		set FTVal $::RTDist
		set LDValUp [expr -$LDVal]
		
		set lStatus [DboState]
		set selectedobjs [GetSelectedObjects]	
		set objlength [llength $selectedobjs] 
		set lNullObj NULL
		for {set i 0} {$i < $objlength} {incr i} {
			set obj [lindex $selectedobjs $i]
			set lRot [$obj GetRotation $lStatus]
			set lCount [$obj GetPinCount $lStatus]
			if {$lCount < 3} {
				if {$lRot == 3 || $lRot == 1} {
					set lPropsIter [$obj NewDisplayPropsIter $lStatus]
					set lDProp [$lPropsIter NextProp $lStatus]
					set TempVal 0
					set TempVal1 0
					set YIncVal 10
					while {$lDProp !=$lNullObj } {
						set Xinc 0
						set Yinc 0	
						set displocation [DboTclHelper_sMakeCPoint [expr $Xinc] [expr $Yinc]]
						$lDProp SetLocation $displocation
						if {$TempVal == 0} {
							set displocation1 [DboTclHelper_sMakeCPoint [expr $LDValUp] [expr 0]]
							$lDProp SetLocation $displocation1
							set TempVal [expr $TempVal + 1]
						} elseif {$TempVal == 1} {
							set displocation1 [DboTclHelper_sMakeCPoint [expr $FTVal] [expr 0]]
							$lDProp SetLocation $displocation1
							set TempVal [expr $TempVal + 1]
						} else {
							if {$TempVal1 == 0} {
								set displocation1 [DboTclHelper_sMakeCPoint [expr $LDValUp] [expr $YIncVal]]
								$lDProp SetLocation $displocation1
								set TempVal1 [expr $TempVal1 + 1]
							} else {
								set displocation1 [DboTclHelper_sMakeCPoint [expr $FTVal] [expr $YIncVal]]
								$lDProp SetLocation $displocation1
								set TempVal1 0
							}
							set TempVal [expr $TempVal + 1]
							set YIncVal [expr $YIncVal + 10]
						}
						
					
					set lDProp [$lPropsIter NextProp $lStatus] 
					}
					delete_DboDisplayPropsIter $lPropsIter
				} else {
					set lPropsIter [$obj NewDisplayPropsIter $lStatus]
					set lDProp [$lPropsIter NextProp $lStatus]
					set TempVal 0
					set TempVal1 0
					set YIncVal 10
					while {$lDProp !=$lNullObj } {
						set Xinc 0
						set Yinc 0	
						set displocation [DboTclHelper_sMakeCPoint [expr $Xinc] [expr $Yinc]]
						$lDProp SetLocation $displocation
						if {$TempVal == 0} {
							set displocation1 [DboTclHelper_sMakeCPoint [expr 0] [expr $LDValUp]]
							$lDProp SetLocation $displocation1
							set TempVal [expr $TempVal + 1]
						} elseif {$TempVal == 1} {
							set displocation1 [DboTclHelper_sMakeCPoint [expr 0] [expr $FTVal]]
							$lDProp SetLocation $displocation1
							set TempVal [expr $TempVal + 1]
						} else {
							if {$TempVal1 == 0} {
								set displocation1 [DboTclHelper_sMakeCPoint [expr $YIncVal] [expr $LDValUp]]
								$lDProp SetLocation $displocation1
								set TempVal1 [expr $TempVal1 + 1]
							} else {
								set displocation1 [DboTclHelper_sMakeCPoint [expr $YIncVal] [expr $FTVal]]
								$lDProp SetLocation $displocation1
								set TempVal1 0
							}
							set TempVal [expr $TempVal + 1]
							set YIncVal [expr $YIncVal + 10]
						}
						
					set lDProp [$lPropsIter NextProp $lStatus] 
					}
					delete_DboDisplayPropsIter $lPropsIter
				}
			}
		}
		set user_input2 [tk_messageBox -title "Part Display Property Align" -message "Part Display Property Assigned Successfully..!" -type okcancel -icon question -default ok -parent .]
	}
} 
	

TCLAlignDispPropPart::TCLAlignDispPropPartfunc