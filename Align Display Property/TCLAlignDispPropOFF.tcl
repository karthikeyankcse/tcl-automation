
SetOptionBool Journaling True

namespace eval AlignDispPropOff {} {
	
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc AlignDispPropOff::AlignDispPropOfffunc {} {

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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Align_Display_Property_Offpage"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Align Display Property Offpage"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set lStatus [DboState]
	set selectedobjs [GetSelectedObjects]	
	set objlength [llength $selectedobjs] 
	set lNullObj NULL
	for {set i 0} {$i < $objlength} {incr i} {
		set obj [lindex $selectedobjs $i]
		set Offname [DboTclHelper_sMakeCString]
		$obj GetName $Offname
		set InpNetName [DboTclHelper_sGetConstCharPtr $Offname]
		puts $InpNetName
		
		set Wireobj [$obj GetWire $lStatus]
		#puts yes
		set lStartPoint [$Wireobj GetStartPoint $lStatus]
		set lStartPointX [expr [DboTclHelper_sGetCPointX $lStartPoint]/100.0]
		set lStartPointY [expr [DboTclHelper_sGetCPointY $lStartPoint]/100.0]
		#puts "Start: $lStartPointX , $lStartPointY"
		
		set lEndPoint [$Wireobj GetEndPoint $lStatus]
		set lEndPointX [expr [DboTclHelper_sGetCPointX $lEndPoint]/100.0]
		set lEndPointY [expr [DboTclHelper_sGetCPointY $lEndPoint]/100.0]
		#puts "End: $lEndPointX , $lEndPointY"

		set lHotSpotPoint [$obj GetOffsetHotSpot $lStatus]
		set lHotSpotPointX [expr [DboTclHelper_sGetCPointX $lHotSpotPoint]/100.0]
		set lHotSpotPointY [expr [DboTclHelper_sGetCPointY $lHotSpotPoint]/100.0]
		#puts "HotSpotPointY: $lHotSpotPointX , $lHotSpotPointY"
		
		set CreateLoc "DummyVal"
		if {$lHotSpotPointX > $lStartPointX} {
			set CreateLoc "RIGHT"
		} elseif {$lHotSpotPointX < $lStartPointX} {
			set CreateLoc "LEFT"
		} 
		if {$lHotSpotPointX > $lEndPointX} {
			set CreateLoc "RIGHT"
		} elseif {$lHotSpotPointX < $lEndPointX} {
			set CreateLoc "LEFT"
		}
		set lPropsIter [$obj NewDisplayPropsIter $lStatus]
		set lDProp [$lPropsIter NextProp $lStatus]
		while {$lDProp !=$lNullObj } {
			#set PropLoc [$lDProp GetBoundingBox $lStatus]
			#puts [DboTclHelper_sGetCPointX $PropLoc]
			#puts [DboTclHelper_sGetCPointY $PropLoc]
			
			set text_length [string length $InpNetName]
			#puts $text_length
			set txtLen [expr $text_length + 1] 
			if {$CreateLoc == "LEFT"} {
				set passVal 0.10
				for { set a 1}  {$a < $txtLen} {incr a} {
					set passVal [expr $passVal + 0.05] 
				}
				#puts $passVal
				set DXinc [expr -$passVal]
				#set DXinc [expr -1.5]
				set Xinc 0
				set Yinc 5	
				#puts $Xinc
				#puts $Yinc
				set displocation [DboTclHelper_sMakeCPoint [expr $Xinc] [expr $Yinc]]
				$lDProp SetLocation $displocation
				
				UnSelectAll
				set pId [$lDProp GetId $lStatus]
				SelectObjectById $pId
				set GetBObj [GetSelectedObjects]
				set lBBox [$GetBObj GetBoundingBox]
				set left [DboTclHelper_sGetCPointX [DboTclHelper_sGetCRectTopLeft  $lBBox]]
				set top [DboTclHelper_sGetCPointY [DboTclHelper_sGetCRectTopLeft  $lBBox]]
				set right [DboTclHelper_sGetCPointX [DboTclHelper_sGetCRectBottomRight  $lBBox]]
				set Bottom [DboTclHelper_sGetCPointY [DboTclHelper_sGetCRectBottomRight  $lBBox]]
				 
				#puts $left
				#puts $top
				#puts $right
				#puts $Bottom
				
				set CalVal [expr $right + 10]
				set CalXinc [expr -$CalVal]
				set CalYinc 5	
				#puts $Xinc
				#puts $Yinc
				set Caldisplocation [DboTclHelper_sMakeCPoint [expr $CalXinc] [expr $CalYinc]]
				$GetBObj SetLocation $Caldisplocation
				
				UnSelectAll
			} elseif {$CreateLoc == "RIGHT"} {
				#set Xval [expr $text_length * 6]
				#set passVal [expr $Xval + 3] 
				#set Xinc [expr -$passVal]
				set Xinc 17
				set Yinc 5	
				#puts $Xinc
				#puts $Yinc

				set displocation [DboTclHelper_sMakeCPoint [expr $Xinc] [expr $Yinc]]
				$lDProp SetLocation $displocation
			} else {
				puts "Location Not Updated..!"
			}
			
			set lDProp [$lPropsIter NextProp $lStatus]
		}
		delete_DboDisplayPropsIter $lPropsIter
	}
}

AlignDispPropOff::AlignDispPropOfffunc

