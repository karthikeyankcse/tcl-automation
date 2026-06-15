SetOptionBool Journaling True
package require Tk
wm withdraw .
namespace eval OffConcSpace {} {
	
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc OffConcSpace::OffConcSpacefunc {} {
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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Offpage_Spacing_Alignment"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Offpage Spacing Alignment"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp
	set user_input [tk_messageBox -title "User Input" -message "Enter a value:" -type okcancel -icon question -default ok -parent .]
	if {$user_input eq "ok"} {
        toplevel .user_input_dialog
        wm title .user_input_dialog "User Input"
        
        label .user_input_dialog.prompt -text "Enter the value:"
        pack .user_input_dialog.prompt -side top
        
        entry .user_input_dialog.entry -width 20
        pack .user_input_dialog.entry -side top
        
        button .user_input_dialog.ok -text "OK" -command {set ::user_input_value [.user_input_dialog.entry get]; destroy .user_input_dialog}
        pack .user_input_dialog.ok -side left
        
        button .user_input_dialog.cancel -text "Cancel" -command {set ::user_input_value ""; destroy .user_input_dialog}
        pack .user_input_dialog.cancel -side right
        
        tkwait window .user_input_dialog
        
        set value $::user_input_value

        puts "User entered: $value"
		set lStatus [DboState]
		set selectedobjs [GetSelectedObjects]	
		set objlength [llength $selectedobjs] 
		set YLocOff [list]
		for {set i 0} {$i < $objlength} {incr i} {
			set obj [lindex $selectedobjs $i]
			set lHotSpotPoint [$obj GetOffsetHotSpot $lStatus]
			set lHotSpotPointX [expr [DboTclHelper_sGetCPointX $lHotSpotPoint]/100.0]
			set lHotSpotPointY [expr [DboTclHelper_sGetCPointY $lHotSpotPoint]/100.0]
			#puts "HotSpotPointY: $lHotSpotPointX , $lHotSpotPointY"
			#puts $lHotSpotPointY 
			lappend YLocOff $lHotSpotPointY
		}
		set UnqYLocOff [lsort -unique $YLocOff]
		set DummyVal 1
		set InpDt $value
		set InpDtPass $value
		foreach Chklp $UnqYLocOff {
			for {set j 0} {$j < $objlength} {incr j} {
				set objS [lindex $selectedobjs $j]
				set Offname [DboTclHelper_sMakeCString]
				$objS GetName $Offname
				set InpNetName [DboTclHelper_sGetConstCharPtr $Offname]
				set lHotSpotPointS [$objS GetOffsetHotSpot $lStatus]
				set lHotSpotPointSX [expr [DboTclHelper_sGetCPointX $lHotSpotPointS]/100.0]
				set lHotSpotPointSY [expr [DboTclHelper_sGetCPointY $lHotSpotPointS]/100.0]
				#puts "HotSpotPointSY: $lHotSpotPointSX , $lHotSpotPointSY"
				#puts $lHotSpotPointSY 
				if {$Chklp == $lHotSpotPointSY} {
					#puts "HotSpotPointSY: $lHotSpotPointSX , $lHotSpotPointSY"
					if {$DummyVal == 1} {
						set InpCalVal $lHotSpotPointSY
						set DummyVal [expr $DummyVal + 1]
					} else {
						set CalVal [expr $lHotSpotPointSY - $InpCalVal]
						set MCalVal [expr -$CalVal]
						UnSelectAll
						set pId [$objS GetId $lStatus]
						SelectObjectById $pId 
						Drag 0.00 $MCalVal TRUE
						Drag 0.00 $InpDt TRUE
						UnSelectAll
						set InpDt [expr $InpDtPass + $InpDt]
					}
				}
			}
		}
	} else {

        puts "User cancelled input."
    }
} 
	

OffConcSpace::OffConcSpacefunc