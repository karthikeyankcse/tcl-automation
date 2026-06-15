
SetOptionBool Journaling True

namespace eval NetSwapTCLWire {} {
	
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}


proc NetSwapTCLWire::NetSwapTCLWirefunc {} {

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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/NetSwapTCLWire"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : NetSwapTCLWire"
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
		
		set DelPropListid [list]
		set DelPropListName [list]
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
			set lWireIter [$obj NewWiresIter $lStatus]
			set lWire [$lWireIter NextWire $lStatus]
			while {$lWire!=$lNullObj} {
				set lPage [$lWire GetOwner]
				set lAliasIter [$lWire NewAliasesIter $lStatus]
				set lAlias [$lAliasIter NextAlias $lStatus]
				while { $lAlias!=$lNullObj} {
					set name [DboTclHelper_sMakeCString]
					$lAlias GetName $name
					set lAliasName [DboTclHelper_sGetConstCharPtr $name]
					#puts $lAliasName
					foreach inpdt $UnqUpDtList {
						set inpPrse1 [lindex [split $inpdt ","] 0] 
						set inpPrse2 [lindex [split $inpdt ","] 1]
						if {$inpPrse1 == $lAliasName } {
							OPage $ClSchematicNameStr $UPPageName
							set pId [$lWire GetId $lStatus]
							SelectObjectById $pId
							set UpVal [DboTclHelper_sMakeCString $inpPrse2]
							$lAlias SetName $UpVal
							set DelStringVal "${pId},${inpPrse2}"
							lappend DelPropListId $pId
							lappend DelPropListName $inpPrse2
							UnSelectAll	
						}
					}
					set lAlias [$lAliasIter NextAlias $lStatus]
				}
				DboTclHelper_sEvalPage $lPage
				delete_DboWireAliasesIter $lAliasIter
				
				set lWire [$lWireIter NextWire $lStatus]
			}
			delete_DboPageWiresIter $lWireIter
			ui::PMActivate $folderpath
		}
		
		set DelPropListId [lsort -unique $DelPropListId]
		set DelPropListName [lsort -unique $DelPropListName]
		for {set k 0} {$k < $objlength} {incr k} {
			set Delobj [lindex $selectedobjs $k]
			set DelUPPageNameCS [DboTclHelper_sMakeCString]
			$Delobj GetName $DelUPPageNameCS
			set DelUPPageName [DboTclHelper_sGetConstCharPtr $DelUPPageNameCS]
			#puts $DelUPPageName
			set DelClSchematicName [DboTclHelper_sMakeCString]
			set DelClSchematic [$Delobj GetOwner]
			$DelClSchematic GetName $DelClSchematicName
			set DelClSchematicNameStr [DboTclHelper_sGetConstCharPtr $DelClSchematicName]
			#puts $DelClSchematicNameStr
			set DellWireIter [$Delobj NewWiresIter $lStatus]
			set DellWire [$DellWireIter NextWire $lStatus]
			while {$DellWire!=$lNullObj} {
				set DellPage [$DellWire GetOwner]
				set DellAliasIter [$DellWire NewAliasesIter $lStatus]
				set DellAlias [$DellAliasIter NextAlias $lStatus]
				while { $DellAlias!=$lNullObj} {
					set Delname [DboTclHelper_sMakeCString]
					$DellAlias GetName $Delname
					set DellAliasName [DboTclHelper_sGetConstCharPtr $Delname]
					#puts $DellAliasName
					set DummyVal "DELETE"
					foreach Delinplpname $DelPropListName {
						if {$Delinplpname == $DellAliasName } {
							set DelpId [$DellWire GetId $lStatus]
							foreach Delinplpid $DelPropListId {
								if {$Delinplpid == $DelpId } {
									set DummyVal "NOTDELETE"
								}
							}
						if {$DummyVal == "DELETE" } {
							set DelUpVal [DboTclHelper_sMakeCString "NET_NEED_TO_DELETE"]
							$DellAlias SetName $DelUpVal
						}
						}
					}
					
				set DellAlias [$DellAliasIter NextAlias $lStatus]
				}
				DboTclHelper_sEvalPage $DellPage
				delete_DboWireAliasesIter $DellAliasIter
				set DellWire [$DellWireIter NextWire $lStatus]
			}
			delete_DboPageWiresIter $DellWireIter
			ui::PMActivate $folderpath
		}

	}
}

NetSwapTCLWire::NetSwapTCLWirefunc

