SetOptionBool Journaling True

namespace eval WireANameUp {} {
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc WireANameUp::WireANameUpfunc {} { 
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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Wire_Alias_Name_Update_In_Property"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Wire Alias Name Update In Property"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set lNullObj NULL
	set lStatus [DboState]
	set lAllWire [GetSelectedObjects]
	set name [DboTclHelper_sMakeCString]
	foreach lObject $lAllWire {
		set lPage [$lObject GetOwner]
		set lNet [$lObject GetNet $lStatus]
		set lschNet [$lNet GetSchematicNet]
		set lAliasIter [$lObject NewAliasesIter $lStatus]
		set lAlias [$lAliasIter NextAlias $lStatus]
		while { $lAlias!=$lNullObj} {
			$lAlias GetName $name
			$lschNet SetName $name
			set lAlias [$lAliasIter NextAlias $lStatus]
		}
		DboTclHelper_sEvalPage $lPage
		delete_DboWireAliasesIter $lAliasIter
	}
}
WireANameUp::WireANameUpfunc

