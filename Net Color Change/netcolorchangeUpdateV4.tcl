#NetColorChnage
SetOptionBool Journaling True
namespace eval netPropChange {} {
	
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
	# return $dirName
}

# puts $netPropChange::dirName

proc netPropChange::netCOlorChange {} {
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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Highlight_By_Bus"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Highlight By Bus"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

    # global i
	# set lPropList {50_OHM_SE_LS 100_OHM_DIFF_LY_LS 20_MIL_TRACE}
	set fp [open "input.txt" r]
	set InplPropList [list]
	while { [gets $fp data] >= 0 } {
		 #puts $data
		 lappend InplPropList $data
	}
	close $fp
	set UnqUpDtList [lsort -unique $InplPropList]
	#set lPropList [lsort -unique $InplPropList]
	#puts $lPropList
	#puts [llength $lPropList]
	
	#set a 1
	#set UpDtList [list]
	foreach x $UnqUpDtList {
		#set val [expr $a * 2]
		#set a [expr $a + 1]
		set UsrBN [lindex [split $x ","] 0] 
		set UsrClr [lindex [split $x ","] 1]
		set outString "${UsrBN} - Bus Name Color Is - ${UsrClr}"
		puts $outString
		#set UpString "${x},${val}"
		#lappend UpDtList $UpString
	}
	#set UnqUpDtList [lsort -unique $UpDtList]
	#puts $UnqUpDtList
	
	#puts [lindex $lPropList 9]
	set lPropName [DboTclHelper_sMakeCString "BUS_NAME"]
	set lPropValue [DboTclHelper_sMakeCString ]
	set lSession $::DboSession_s_pDboSession
	DboSession -this $lSession
	set lNullObj NULL
	set lStatus [DboState]
	set lDesign [$lSession GetActiveDesign]
	set lSchi_Name [DboTclHelper_sMakeCString]
	set lWireNameCS [DboTclHelper_sMakeCString]
	set lPageNameCS [DboTclHelper_sMakeCString]
	set lPrpName [DboTclHelper_sMakeCString]
	set lPrpValue [DboTclHelper_sMakeCString]
	set lPrpType [DboTclHelper_sMakeDboValueType]
	set lEditable [DboTclHelper_sMakeInt]
	set InstOcc [GetInstanceOccurrence]
	set designobj [$InstOcc GetOwner]

	UnSelectAll
	if {$lDesign != $lNullObj} {

		set lSchematicIter [$lDesign NewViewsIter $lStatus $::IterDefs_ALL]
		#get the first schematic view
		set lView [$lSchematicIter NextView $lStatus]
		set lPage_Name [DboTclHelper_sMakeCString]
        while { $lView != $lNullObj} {
			#dynamic cast from DboView to DboSchematic
			set lSchematic [DboViewToDboSchematic $lView]
			$lSchematic GetName $lSchi_Name
			set lPagesIter [$lSchematic NewPagesIter $lStatus]
			#get the first page
			set lPage [$lPagesIter NextPage $lStatus]
			# puts [DboTclHelper_sGetConstCharPtr $lSchi_Name]
			set lSchName [DboTclHelper_sGetConstCharPtr $lSchi_Name]
			while {$lPage!=$lNullObj} {				
				$lPage GetName $lPageNameCS
				set lPageName [DboTclHelper_sGetConstCharPtr $lPageNameCS]
				# OPage $lSchName $lPageName
				set lWiresIter [$lPage NewWiresIter $lStatus]
				# get the first wire
				set lWire [$lWiresIter NextWire $lStatus]
				set lNullObj NULL
				while {$lWire != $lNullObj} {
					UnSelectAll
					set lStatus [$lWire GetEffectivePropStringValue $lPropName $lPropValue]
					set lUserValue [DboTclHelper_sGetConstCharPtr $lPropValue]
					set netobj [$lWire GetNet $lStatus]
					set lNetName [DboTclHelper_sMakeCString]
					$netobj GetNetName $lNetName
					set schNet [$netobj GetSchematicNet]
					$schNet GetName $lNetName
					set netocc [$schNet GetOccurrenceFromParent $InstOcc]
					set netoccObj [DboOccurrenceToDboNetOccurrence $netocc]
					set FlNullObj NULL
					if {$netoccObj != $FlNullObj} {
						set flatnetobj [$netoccObj GetFlatNet $lStatus]
						set stringobj [DboTclHelper_sMakeCString]
						set FltNN NULL
						if {$flatnetobj != $FltNN} {
							$flatnetobj GetName $stringobj
							set lStatus [$flatnetobj GetEffectivePropStringValue $lPropName $lPropValue]
							set lUserValue [DboTclHelper_sGetConstCharPtr $lPropValue]
							foreach inpdt $UnqUpDtList {
								set inpPrse1 [lindex [split $inpdt ","] 0] 
								set inpPrse2 [lindex [split $inpdt ","] 1]
								set inpPrse3 [lindex [split $inpdt ","] 2]
									if {$inpPrse1 == $lUserValue } {
										#puts $lUserValue
										$lWire SetColor $inpPrse2
										$lWire SetLineWidth $::DboValue_MEDIUM_WIDTH
										if {$inpPrse3 == "SOLID" } {
											$lWire SetLineStyle $::DboValue_SOLID_LINE
										} elseif {$inpPrse3 == "DASH" } {
											$lWire SetLineStyle $::DboValue_DASH_LINE
										} elseif {$inpPrse3 == "DOT" } {
											$lWire SetLineStyle $::DboValue_DOT_LINE
										} elseif {$inpPrse3 == "DASH_DOT" } {
											$lWire SetLineStyle $::DboValue_DASH_DOT_LINE
										} elseif {$inpPrse3 == "DASH_DOT_DOT" } {
											$lWire SetLineStyle $::DboValue_DASH_DOT_DOT_LINE
										} else {
											$lWire SetLineStyle $::DboValue_DEFAULT_LINE_STYLE
										}
										UnSelectAll
									}
							}
						}
					}
					set lWire [$lWiresIter NextWire $lStatus]
				}
				
				delete_DboPageWiresIter $lWiresIter
				#get the next page
				set lPage [$lPagesIter NextPage $lStatus]
			}
			delete_DboSchematicPagesIter $lPagesIter
			#get the next schematic view
			set lView [$lSchematicIter NextView $lStatus]
		}
		delete_DboLibViewsIter $lSchematicIter
		
		
	}
	
} 
	

netPropChange::netCOlorChange