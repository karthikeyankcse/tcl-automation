SetOptionBool Journaling True
namespace eval PlaceNetAl {} {
	
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc PlaceNetAl::PlaceNetAlfunc {} {

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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Netname_As_OffPage_Name"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Netname As OffPage Name"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set lStatus [DboState]
	set lNullObj NULL
	set selectedobjs [GetSelectedObjects]	
	set objlength [llength $selectedobjs]
	set PinNameList [list]
	for {set i 0} {$i < $objlength} {incr i} {
		set obj [lindex $selectedobjs $i]

		set OffName [DboTclHelper_sMakeCString]
		$obj GetName $OffName
		set OffName [DboTclHelper_sGetConstCharPtr $OffName]
		set lWire [$obj GetWire $lStatus]
		set lStartPoint [$lWire GetStartPoint $lStatus]
		set lStartPointX [expr [DboTclHelper_sGetCPointX $lStartPoint]/100.0]
		set lStartPointY [expr [DboTclHelper_sGetCPointY $lStartPoint]/100.0]
		#puts "Start: $lStartPointX , $lStartPointY"
		

		set lEndPoint [$lWire GetEndPoint $lStatus]
		set lEndPointX [expr [DboTclHelper_sGetCPointX $lEndPoint]/100.0]
		set lEndPointY [expr [DboTclHelper_sGetCPointY $lEndPoint]/100.0]
		#puts "lEndPoint: $lEndPointX , $lEndPointY"
		
		if {$lStartPointX > $lEndPointX} {
			PlaceNetAlias [expr $lEndPointX] [expr $lEndPointY] $OffName
		} else {
			PlaceNetAlias [expr $lStartPointX] [expr $lStartPointY] $OffName
		}
	}
}
PlaceNetAl::PlaceNetAlfunc