
SetOptionBool Journaling True

namespace eval NetSwapTCLOffWOD {} {
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}
proc NetSwapTCLOffWOD::NetSwapTCLOfffuncWOD {} {

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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/NetSwapTCLOffWOD"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : NetSwapTCLOffWOD"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set selectedobjs [GetSelectedPMItems]	
	set objlength [llength $selectedobjs]
	set lNullObj NULL
	set lStatus [DboState]
	set lSession $::DboSession_s_pDboSession
	DboSession -this $lSession
	set lDesign [$lSession GetActiveDesign]
	set DesName [DboTclHelper_sMakeCString]
	$lDesign GetName $DesName
	set lDesName [DboTclHelper_sGetConstCharPtr $DesName]
	if {$lDesign != $lNullObj} {
		for {set j 0} {$j < $objlength} {incr j} {
				set objG [lindex $selectedobjs $j]
				set UPPageNameCSG [DboTclHelper_sMakeCString]
				$objG GetName $UPPageNameCSG
				set UPPageNameG [DboTclHelper_sGetConstCharPtr $UPPageNameCSG]
				set ClSchematicNameG [DboTclHelper_sMakeCString]
				set ClSchematicG [$objG GetOwner]
				$ClSchematicG GetName $ClSchematicNameG
				set ClSchematicNameStrG [DboTclHelper_sGetConstCharPtr $ClSchematicNameG]
				OPage $ClSchematicNameStrG $UPPageNameG
				set fp [open "input.txt" r]
					set InplPropList [list]
					while { [gets $fp data] >= 0 } {
						 #puts $data
						 lappend InplPropList $data
					}
					close $fp
					set UnqUpDtList [lsort -unique $InplPropList]
					set UsrBN [lindex [split $lDesName "."] 0]
					set outString "${UsrBN}.opj"
					set upval [string tolower $outString]
					set folderpath [string map {\\ /} $upval]
					#puts $folderpath
					ui::PMActivate $folderpath
					break		
		}
		
		set DelPropList [list]
		for {set i 0} {$i < $objlength} {incr i} {
			set obj [lindex $selectedobjs $i]
			set UPPageNameCS [DboTclHelper_sMakeCString]
			$obj GetName $UPPageNameCS
			set UPPageName [DboTclHelper_sGetConstCharPtr $UPPageNameCS]
			#puts $UPPageName
			set ClSchematicName [DboTclHelper_sMakeCString]
			set ClSchematic [$obj GetOwner]
			$ClSchematic GetName $ClSchematicName
			set ClSchematicNameStr [DboTclHelper_sGetConstCharPtr $ClSchematicName]
			#puts $ClSchematicNameStr			
			set pOffPageConnectorsIter [$obj NewOffPageConnectorsIter $lStatus $::IterDefs_ALL]
			set pOffPageConnector [$pOffPageConnectorsIter NextOffPageConnector $lStatus]
			while {$pOffPageConnector!=$lNullObj} {
				set partName [DboTclHelper_sMakeCString]
				$pOffPageConnector GetName $partName
				set InpNetName [DboTclHelper_sGetConstCharPtr $partName]
				#puts $InpNetName
				foreach inpdt $UnqUpDtList {
					set inpPrse1 [lindex [split $inpdt ","] 0] 
					set inpPrse2 [lindex [split $inpdt ","] 1]
					if {$inpPrse1 == $InpNetName } {
						OPage $ClSchematicNameStr $UPPageName
						set pId [$pOffPageConnector GetId $lStatus]
						SelectObjectById $pId
						SetProperty {Name} $inpPrse2
						set DelStringVal "${pId},${inpPrse2}"
						lappend DelPropList $DelStringVal
						UnSelectAll	
					}
				}
				set pOffPageConnector [$pOffPageConnectorsIter NextOffPageConnector $lStatus]
			}
			delete_DboPageOffPageConnectorsIter $pOffPageConnectorsIter
			ui::PMActivate $folderpath
		}
		
	}
}

NetSwapTCLOffWOD::NetSwapTCLOfffuncWOD

