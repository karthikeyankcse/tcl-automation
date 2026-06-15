SetOptionBool Journaling True
namespace eval hiePinAlign {} {	
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc hiePinAlign::hiePinAlignfunc {} {

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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Hie_Pin_Align_WO_Space"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Hie Pin Align WO Space"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set lStatus [DboState]
	set lNullObj NULL
	set selectedobjs [GetSelectedObjects]	
	set objlength [llength $selectedobjs]
	set PinOrderList [list]
	for {set i 0} {$i < $objlength} {incr i} {
		set obj [lindex $selectedobjs $i]
		set lHotSpotPoint [$obj GetStartPoint $lStatus] 
		set lHotSpotPointX [expr [DboTclHelper_sGetCPointX $lHotSpotPoint]]
		set lHotSpotPointY [expr [DboTclHelper_sGetCPointY $lHotSpotPoint]]
		#puts "HotSpotPoint: $lHotSpotPointX , $lHotSpotPointY"
		lappend PinOrderList $lHotSpotPointY
	}
	set UnqPinOrderList [lsort -integer $PinOrderList]
	puts $UnqPinOrderList
	set DummyVal 1
	set Yinc 10
	foreach Chklp $UnqPinOrderList {
		for {set j 0} {$j < $objlength} {incr j} {
			set Uobj [lindex $selectedobjs $j]
			set UlHotSpotPoint [$Uobj GetStartPoint $lStatus]
			set UlHotSpotPointX [expr [DboTclHelper_sGetCPointX $UlHotSpotPoint]]
			set UlHotSpotPointY [expr [DboTclHelper_sGetCPointY $UlHotSpotPoint]]
			if {$Chklp == $UlHotSpotPointY} {
				if {$DummyVal == 1} {
					set InpCalVal $UlHotSpotPointY
					set DummyVal [expr $DummyVal + 1]
				} else {
					set YincPass [expr $InpCalVal + $Yinc]   
					set displocation [DboTclHelper_sMakeCPoint [expr $UlHotSpotPointX] [expr $YincPass]]
					$Uobj SetStartPoint $displocation
					$Uobj SetHotSpot $displocation
					set Yinc [expr $Yinc + 10]
				}
			}
		}
	
	}
}
hiePinAlign::hiePinAlignfunc