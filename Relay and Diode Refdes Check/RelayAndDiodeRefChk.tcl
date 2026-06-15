SetOptionBool Journaling True
package require Tk
wm withdraw .
namespace eval RelayAndDiodeRefChk {} {
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}
proc RelayAndDiodeRefChk::RelayAndDiodeRefChkfunc {} {

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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Relay_And_Diode_Ref_Check_Multi_Site"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Relay And Diode Ref Check Multi_Site"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set selectedobjs [GetSelectedPMItems]
	set objlength [llength $selectedobjs]
	set lStatus [DboState]
	set lNullObj NULL
	set ErrorList [list]
	set SkipList [list]
	if {[llength $selectedobjs] == 0} {
		set user_input3 [tk_messageBox -title "Relay And Diode Reference Check" -message "Error : Page Not Selected..!" -type okcancel -icon question -default ok -parent .]
	} else {
		
	#---------------------------------------------------------------------------------------------------------------------------------------------------
	set PortChkList [list]
	set PortChkListN [list]
	set lDesign [GetActivePMDesign]
	set lSchematicIter [$lDesign NewViewsIter $lStatus $::IterDefs_SCHEMATICS]
	set lView [$lSchematicIter NextView $lStatus]
	while { $lView != $lNullObj} {
		set lSchematic [DboViewToDboSchematic $lView]
		set lPagesIter [$lSchematic NewPagesIter $lStatus]
		set lPage [$lPagesIter NextPage $lStatus]
		while {$lPage!=$lNullObj} {
			set PageNameRes [DboTclHelper_sMakeCString]
			$lPage GetName $PageNameRes
			set PageNameSRes [DboTclHelper_sGetConstCharPtr $PageNameRes]
			#puts $PageNameSRes
			set PlIterRes [$lPage NewPartInstsIter $lStatus]
			set lPartRes [$PlIterRes NextPartInst $lStatus]
			while {$lPartRes != $lNullObj } {
				set PartNameRes [DboTclHelper_sMakeCString]
				$lPartRes GetName $PartNameRes
				set PartNameRes [DboTclHelper_sGetConstCharPtr $PartNameRes]
				set lIter [$lPartRes NewPinsIter $lStatus]  
				set lPin [$lIter NextPin $lStatus] 
				while {$lPin != $lNullObj } { 
					set lPinName [DboTclHelper_sMakeCString]
					$lPin GetPinName $lPinName
					set lPinName [DboTclHelper_sGetConstCharPtr $lPinName]
					
					if {[string first "UP5V" $lPinName] >= 0 || [string first "USR-P5V" $lPinName] >= 0 || [string first "UT_P5V" $lPinName] >= 0} {
						set lWirePort [$lPin GetWire $lStatus]
						
						set OffIterPort [$lWirePort NewOffPageConnectorsIter $lStatus] 
						set lOffPort [$OffIterPort NextOffPageConnector $lStatus] 
						while {$lOffPort != $lNullObj } { 
							set OffName [DboTclHelper_sMakeCString]
							$lOffPort GetName $OffName
							set lOffPortS [DboTclHelper_sGetConstCharPtr $OffName]
							set PortStrOff "${PageNameSRes},${PartNameRes},${lPinName},${lOffPortS}"
							#puts $PortStrOff
							lappend PortChkList $PortStrOff
						set lOffPort [$OffIterPort NextOffPageConnector $lStatus]
						}
						delete_DboWireOffPageConnectorsIter $OffIterPort
						
						set GlobalIter [$lWirePort NewGlobalsIter $lStatus] 
						set lGlobal [$GlobalIter NextGlobal $lStatus] 
						while {$lGlobal != $lNullObj } { 
							set GlobalName [DboTclHelper_sMakeCString]
							$lGlobal GetName $GlobalName
							set lGlobalS [DboTclHelper_sGetConstCharPtr $GlobalName]
							set PortStrGlb "${PageNameSRes},${PartNameRes},${lPinName},${lGlobalS}"
							#puts $PortStrGlb
							lappend PortChkList $PortStrGlb						
						set lGlobal [$GlobalIter NextGlobal $lStatus]
						}
						delete_DboWireGlobalsIter $GlobalIter
						
					} elseif {[string first "UT_CT" $lPinName] >= 0 || [string first "UTI" $lPinName] >= 0 || [string first "UDB" $lPinName] >= 0} {
						set lWirePort [$lPin GetWire $lStatus]
						
						set OffIterPort [$lWirePort NewOffPageConnectorsIter $lStatus] 
						set lOffPort [$OffIterPort NextOffPageConnector $lStatus] 
						while {$lOffPort != $lNullObj } { 
							set OffName [DboTclHelper_sMakeCString]
							$lOffPort GetName $OffName
							set lOffPortS [DboTclHelper_sGetConstCharPtr $OffName]
							set PortStrOff "${PageNameSRes},${PartNameRes},${lPinName},${lOffPortS}"
							#puts $PortStrOff
							lappend PortChkListN $PortStrOff
						set lOffPort [$OffIterPort NextOffPageConnector $lStatus]
						}
						delete_DboWireOffPageConnectorsIter $OffIterPort
						
						set GlobalIter [$lWirePort NewGlobalsIter $lStatus] 
						set lGlobal [$GlobalIter NextGlobal $lStatus] 
						while {$lGlobal != $lNullObj } { 
							set GlobalName [DboTclHelper_sMakeCString]
							$lGlobal GetName $GlobalName
							set lGlobalS [DboTclHelper_sGetConstCharPtr $GlobalName]
							set PortStrGlb "${PageNameSRes},${PartNameRes},${lPinName},${lGlobalS}"
							#puts $PortStrGlb
							lappend PortChkListN $PortStrGlb						
						set lGlobal [$GlobalIter NextGlobal $lStatus]
						}
						delete_DboWireGlobalsIter $GlobalIter
					}
					
					
					
					
				set lPin [$lIter NextPin $lStatus] 
				}
				delete_DboPartInstPinsIter $lIter
				
				set lPartRes [$PlIterRes NextPartInst $lStatus]
			}
			delete_DboPagePartInstsIter $PlIterRes
			
			set lPage [$lPagesIter NextPage $lStatus]
		}
		delete_DboSchematicPagesIter $lPagesIter
		
		set lView [$lSchematicIter NextView $lStatus]
	}
	delete_DboLibViewsIter $lSchematicIter
	#--------------------------------------------------------------------------------------------------------------------------------------------
	#puts $PortChkList
	#puts $PortChkListN
	
	for {set j 0} {$j < $objlength} {incr j} {
		set lPage [lindex $selectedobjs $j]
		set lPageNameCS [DboTclHelper_sMakeCString]
		$lPage GetName $lPageNameCS
		set lPageName [DboTclHelper_sGetConstCharPtr $lPageNameCS]
		#puts $lPageName
		set PlIter [$lPage NewPartInstsIter $lStatus]
		set lPart [$PlIter NextPartInst $lStatus]
		while {$lPart != $lNullObj } {
			set lReferenceName [DboTclHelper_sMakeCString]
			$lPart GetReference $lReferenceName
			set lReferenceNameS [DboTclHelper_sGetConstCharPtr $lReferenceName]
			#puts $lReferenceNameS
			set firstLetter [string range $lReferenceNameS 0 0]
			if {$firstLetter == "K" } {
				set lOccCount [$lPart GetOccurrencesCount]
				for {set i 0} {$i < $lOccCount} {incr i} {
					set lOcc [$lPart GetOccurrencesAtPos $i]
					set lReferenceName1 [DboTclHelper_sMakeCString]
					$lOcc GetPathName $lReferenceName1
					set lReferenceNameS1 [DboTclHelper_sGetConstCharPtr $lReferenceName1]
					#puts $lReferenceNameS1
					set inpPrse [lindex [split $lReferenceNameS1 "/"] 1]
					set lIter [$lPart NewPinsIter $lStatus] 
					set lPin [$lIter NextPin $lStatus] 
					while {$lPin != $lNullObj } { 
						set lPinName [DboTclHelper_sMakeCString]
						$lPin GetPinName $lPinName
						set lPinName [DboTclHelper_sGetConstCharPtr $lPinName]
						if {[string first "+" $lPinName] >= 0} {
							set lWire [$lPin GetWire $lStatus]
							set netobj [$lWire GetNet $lStatus]
							set lWireName [DboTclHelper_sMakeCString]
							$netobj GetNetName $lWireName
							set lWireNameStr [DboTclHelper_sGetConstCharPtr $lWireName]
							if {[string first "UP5V" $lWireNameStr] >= 0 || [string first "USR-P5V" $lWireNameStr] >= 0 || [string first "UT_P5V" $lWireNameStr] >= 0} {
								foreach PortChkListlp $PortChkList {
									set PageNameStr [lindex [split $PortChkListlp ","] 0] 
									set PortNameStr [lindex [split $PortChkListlp ","] 1]
									set PinNamestr [lindex [split $PortChkListlp ","] 2]
									set OffOrGlbNamestr [lindex [split $PortChkListlp ","] 3]
									if {$PinNamestr == $lWireNameStr} {
										if {[string first "P5V" $OffOrGlbNamestr] >= 0 || [string first "UP5V" $OffOrGlbNamestr] >= 0 || [string first "USR-P5V" $OffOrGlbNamestr] >= 0 || [string first "VP5" $OffOrGlbNamestr] >= 0} {
											set ValStr "${PageNameStr} - ${PortNameStr} - Pin Name - ${PinNamestr} - Connection Name - ${OffOrGlbNamestr}"
											#puts $ValStr
										} else {
											set ErrValStr "Error : ${PageNameStr} - ${PortNameStr} - Pin Name - ${PinNamestr} - Connection Name - ${OffOrGlbNamestr}"
											lappend ErrorList $ErrValStr
											#puts $ErrValStr
										}
									}
								}
							} else {
								set ErrString "Error : ${lPageName} - ${lReferenceNameS1} - Pin Name - ${lPinName} - Connection Name - ${lWireNameStr}"
								#puts $ErrString
								lappend ErrorList $ErrString
							}
							
							
						#-------------------------------------------------------------------------------------------------------------------------------------
						
						# Res Case
						
						set PortIterI [$lWire NewPortInstsIter $lStatus $::IterDefs_ALL] 
						set lPortI [$PortIterI NextPortInst $lStatus] 
						while {$lPortI != $lNullObj } { 
							set PortNameI [DboTclHelper_sMakeCString]
							$lPortI GetPinName $PortNameI
							set lPortSI [DboTclHelper_sGetConstCharPtr $PortNameI]
							if {$lPinName != $lPortSI} { 
								set ResPart [$lPortI GetOwner]
								set lIter1 [$ResPart NewPinsIter $lStatus] 
								set lPin1 [$lIter1 NextPin $lStatus] 
								while {$lPin1 != $lNullObj } { 
									set lPinName1 [DboTclHelper_sMakeCString]
									$lPin1 GetPinName $lPinName1
									set lPinName1 [DboTclHelper_sGetConstCharPtr $lPinName1]
									if {$lPinName1 != $lPortSI} { 
										set lWireRes [$lPin1 GetWire $lStatus]
										
										
										set PortIter1 [$lWireRes NewPortsIter $lStatus $::IterDefs_ALL] 
										set lPort1 [$PortIter1 NextPort $lStatus] 
										while {$lPort1 != $lNullObj } { 
											set PortName1 [DboTclHelper_sMakeCString]
											$lPort1 GetName $PortName1
											set lPortS1 [DboTclHelper_sGetConstCharPtr $PortName1]
											if {[string first "UP5V" $lPortS1] >= 0 || [string first "USR-P5V" $lPortS1] >= 0 || [string first "UT_P5V" $lPortS1] >= 0} {
												lappend SkipList $lWireNameStr
												foreach PortChkListlp $PortChkList {
													set PageNameStr [lindex [split $PortChkListlp ","] 0] 
													set PortNameStr [lindex [split $PortChkListlp ","] 1]
													set PinNamestr [lindex [split $PortChkListlp ","] 2]
													set OffOrGlbNamestr [lindex [split $PortChkListlp ","] 3]
													if {$PinNamestr == $lPortS1} {
														if {[string first "P5V" $OffOrGlbNamestr] >= 0 || [string first "UP5V" $OffOrGlbNamestr] >= 0 || [string first "USR-P5V" $OffOrGlbNamestr] >= 0 || [string first "VP5" $OffOrGlbNamestr] >= 0} {
															set ValStr "${PageNameStr} - ${PortNameStr} - Pin Name - ${PinNamestr} - Connection Name - ${OffOrGlbNamestr}"
															#puts $ValStr
														} else {
															set ErrValStr "Error : ${PageNameStr} - ${PortNameStr} - Pin Name - ${PinNamestr} - Connection Name - ${OffOrGlbNamestr}"
															lappend ErrorList $ErrValStr
															#puts $ErrValStr
														}
													}
												}
											} else {
												set ErrStringPort1 "Error : ${lPageName} - ${lReferenceNameS1} - Connection Name - ${lPortS1}"
												#puts $ErrStringPort1
												lappend ErrorList $ErrStringPort1
											}
										set lPort1 [$PortIter1 NextPort $lStatus]
										}
										delete_DboWirePortsIter $PortIter1
										
										set OffIter1 [$lWireRes NewOffPageConnectorsIter $lStatus] 
										set lOff1 [$OffIter1 NextOffPageConnector $lStatus] 
										while {$lOff1 != $lNullObj } { 
											set OffName1 [DboTclHelper_sMakeCString]
											$lOff1 GetName $OffName1
											set lOffS1 [DboTclHelper_sGetConstCharPtr $OffName1]
											if {[string first "UP5V" $lOffS1] >= 0 || [string first "USR-P5V" $lOffS1] >= 0 || [string first "UT_P5V" $lOffS1] >= 0} {
												#puts $lOffS
												lappend SkipList $lWireNameStr
											} else {
												set ErrStringOff1 "Error : ${lPageName} - ${lReferenceNameS1} - Connection Name - ${lOffS1}"
												#puts $ErrStringOff1
												lappend ErrorList $ErrStringOff1
											}
										set lOff1 [$OffIter1 NextOffPageConnector $lStatus]
										}
										delete_DboWireOffPageConnectorsIter $OffIter1
										
										
									}
								set lPin1 [$lIter1 NextPin $lStatus] 
								}
								delete_DboPartInstPinsIter $lIter1
							}
						set lPortI [$PortIterI NextPortInst $lStatus]
						}
						
						#delete_DboWirePortInstsIter $PortIter
						} elseif {[string first "-" $lPinName] >= 0} {
							set lWire [$lPin GetWire $lStatus]
							set netobj [$lWire GetNet $lStatus]
							set lWireName [DboTclHelper_sMakeCString]
							$netobj GetNetName $lWireName
							set lWireNameStr [DboTclHelper_sGetConstCharPtr $lWireName]
							if {[string first "UT_CT" $lWireNameStr] >= 0 || [string first "UTI" $lWireNameStr] >= 0 || [string first "UDB" $lWireNameStr] >= 0} {
								foreach PortChkListlp $PortChkListN {
									set PageNameStr [lindex [split $PortChkListlp ","] 0] 
									set PortNameStr [lindex [split $PortChkListlp ","] 1]
									set PinNamestr [lindex [split $PortChkListlp ","] 2]
									set OffOrGlbNamestr [lindex [split $PortChkListlp ","] 3]
									if {$PinNamestr == $lWireNameStr} {
										if {[string first "UT_CT" $OffOrGlbNamestr] >= 0 || [string first "UTI" $OffOrGlbNamestr] >= 0 || [string first "UDB" $OffOrGlbNamestr] >= 0} {
											set ValStr "${PageNameStr} - ${PortNameStr} - Pin Name - ${PinNamestr} - Connection Name - ${OffOrGlbNamestr}"
											#puts $ValStr
										} else {
											set ErrValStr "Error : ${PageNameStr} - ${PortNameStr} - Pin Name - ${PinNamestr} - Connection Name - ${OffOrGlbNamestr}"
											lappend ErrorList $ErrValStr
											#puts $ErrValStr
										}
									}
								}
							} else {
								set ErrString "Error : ${lPageName} - ${lReferenceNameS1} - Pin Name - ${lPinName} - Connection Name - ${lWireNameStr}"
								#puts $ErrString
								lappend ErrorList $ErrString
							}
								
							
						#-------------------------------------------------------------------------------------------------------------------------------------
						
						# Res Case
						set PortIterI [$lWire NewPortInstsIter $lStatus $::IterDefs_ALL] 
						set lPortI [$PortIterI NextPortInst $lStatus] 
						while {$lPortI != $lNullObj } { 
							set PortNameI [DboTclHelper_sMakeCString]
							$lPortI GetPinName $PortNameI
							set lPortSI [DboTclHelper_sGetConstCharPtr $PortNameI]
							if {$lPinName != $lPortSI} { 
								set ResPart [$lPortI GetOwner]
								set lIter1 [$ResPart NewPinsIter $lStatus] 
								set lPin1 [$lIter1 NextPin $lStatus] 
								while {$lPin1 != $lNullObj } { 
									set lPinName1 [DboTclHelper_sMakeCString]
									$lPin1 GetPinName $lPinName1
									set lPinName1 [DboTclHelper_sGetConstCharPtr $lPinName1]
									if {$lPinName1 != $lPortSI} { 
										set lWireRes [$lPin1 GetWire $lStatus]
										
										
										set PortIter1 [$lWireRes NewPortsIter $lStatus $::IterDefs_ALL] 
										set lPort1 [$PortIter1 NextPort $lStatus] 
										while {$lPort1 != $lNullObj } { 
											set PortName1 [DboTclHelper_sMakeCString]
											$lPort1 GetName $PortName1
											set lPortS1 [DboTclHelper_sGetConstCharPtr $PortName1]
											if {[string first "UT_CT" $lPortS1] >= 0 || [string first "UTI" $lPortS1] >= 0 || [string first "UTI" $lPortS1] >= 0} {
												lappend SkipList $lWireNameStr
												foreach PortChkListlp $PortChkListN {
													set PageNameStr [lindex [split $PortChkListlp ","] 0] 
													set PortNameStr [lindex [split $PortChkListlp ","] 1]
													set PinNamestr [lindex [split $PortChkListlp ","] 2]
													set OffOrGlbNamestr [lindex [split $PortChkListlp ","] 3]
													if {$PinNamestr == $lPortS1} {
														if {[string first "UT_CT" $OffOrGlbNamestr] >= 0 || [string first "UTI" $OffOrGlbNamestr] >= 0 || [string first "UTI" $OffOrGlbNamestr] >= 0} {
															set ValStr "${PageNameStr} - ${PortNameStr} - Pin Name - ${PinNamestr} - Connection Name - ${OffOrGlbNamestr}"
															#puts $ValStr
														} else {
															set ErrValStr "Error : ${PageNameStr} - ${PortNameStr} - Pin Name - ${PinNamestr} - Connection Name - ${OffOrGlbNamestr}"
															lappend ErrorList $ErrValStr
															#puts $ErrValStr
														}
													}
												}
											} else {
												set ErrStringPort1 "Error : ${lPageName} - ${lReferenceNameS1} - Connection Name - ${lPortS1}"
												#puts $ErrStringPort1
												lappend ErrorList $ErrStringPort1
											}
										set lPort1 [$PortIter1 NextPort $lStatus]
										}
										delete_DboWirePortsIter $PortIter1
										
										set OffIter1 [$lWireRes NewOffPageConnectorsIter $lStatus] 
										set lOff1 [$OffIter1 NextOffPageConnector $lStatus] 
										while {$lOff1 != $lNullObj } { 
											set OffName1 [DboTclHelper_sMakeCString]
											$lOff1 GetName $OffName1
											set lOffS1 [DboTclHelper_sGetConstCharPtr $OffName1]
											if {[string first "UP5V" $lOffS1] >= 0 || [string first "USR-P5V" $lOffS1] >= 0 || [string first "UT_P5V" $lOffS1] >= 0} {
												lappend SkipList $lWireNameStr
											} else {
												set ErrStringOff1 "Error : ${lPageName} - ${lReferenceNameS1} - Connection Name - ${lOffS1}"
												#puts $ErrStringOff1
												lappend ErrorList $ErrStringOff1
											}
										set lOff1 [$OffIter1 NextOffPageConnector $lStatus]
										}
										delete_DboWireOffPageConnectorsIter $OffIter1
										
										
									}
								set lPin1 [$lIter1 NextPin $lStatus] 
								}
								delete_DboPartInstPinsIter $lIter1
							}
						set lPortI [$PortIterI NextPortInst $lStatus]
						}
						
						
						
						#delete_DboWirePortInstsIter $PortIter
						}
						
					set lPin [$lIter NextPin $lStatus] 
					}
					delete_DboPartInstPinsIter $lIter
					
				}
			}
		
			set lPart [$PlIter NextPartInst $lStatus]
		}
		delete_DboPagePartInstsIter $PlIter
		
	}
	
	
	# Diode Name Compare Check
	set lReferenceName [DboTclHelper_sMakeCString ]
	set lPropName1 [DboTclHelper_sMakeCString ]
	set lPropName2 [DboTclHelper_sMakeCString]
	set DiodeList [list]
	for {set j 0} {$j < $objlength} {incr j} {
		set lPage [lindex $selectedobjs $j]
		set lPageNameCS [DboTclHelper_sMakeCString]
		$lPage GetName $lPageNameCS
		set lPageName [DboTclHelper_sGetConstCharPtr $lPageNameCS]
		set lPartInstsIter [$lPage NewPartInstsIter $lStatus]
		set lInst [$lPartInstsIter NextPartInst $lStatus]
		while {$lInst!=$lNullObj} {
			set lPlacedInst [DboPartInstToDboPlacedInst $lInst]
			if {$lPlacedInst != $lNullObj} {
				set lObjType [$lPlacedInst GetObjectType]
					if {$lObjType == 13} {
						$lPlacedInst GetReference $lReferenceName
						set lRefName [DboTclHelper_sGetConstCharPtr $lReferenceName]
						if {[regexp {^D} $lRefName]== 1} {
							set lOccCount [$lPlacedInst GetOccurrencesCount]
							for {set k 0} {$k < $lOccCount} {incr k} {
								set lOcc [$lPlacedInst GetOccurrencesAtPos $k]
								set lReferenceName1 [DboTclHelper_sMakeCString]
								$lOcc GetPathName $lReferenceName1
								set lReferenceNameS1 [DboTclHelper_sGetConstCharPtr $lReferenceName1]
								#puts $lReferenceNameS1
								set lPinIter [$lPlacedInst NewPinsIter $lStatus]
									set lPin [$lPinIter NextPin $lStatus]
									while {$lPin != $lNullObj} {
										set lWire [$lPin GetWire $lStatus]
										if {$lWire != $lNullObj} {
											set lWireIter1 [$lWire NewConnectedWiresIter $lStatus]
											set lWire2 [$lWireIter1 NextWire $lStatus]
											while {$lWire2!=$lNullObj} {
												set lConnpinIter [$lWire2 NewPortInstsIter $lStatus $::IterDefs_PORTS]
												set lConnPin [$lConnpinIter NextPortInst $lStatus]
												while {$lConnPin != $lNullObj} {
													#puts $lConnPin
													set lPrentObject [$lConnPin GetOwner]
													set lOccCount1 [$lPrentObject GetOccurrencesCount]
													for {set l 0} {$l < $lOccCount1} {incr l} {
														set lOcc1 [$lPrentObject GetOccurrencesAtPos $l]
														$lOcc1 GetPathName $lPropName1
														set lPrentRfdes [DboTclHelper_sGetConstCharPtr $lPropName1]
														$lPrentObject GetReference $lPropName2
														set lPrentRfdes1 [DboTclHelper_sGetConstCharPtr $lPropName2]
														set inpPrse3 [lindex [split $lPrentRfdes "/"] 0]
														set inpPrse4 [lindex [split $lReferenceNameS1 "/"] 0]
														if {$inpPrse3 == $inpPrse4} {	
															if {[regexp {^K} $lPrentRfdes1] == 1 } {
																set inpPrse1 [lindex [split $lPrentRfdes "/"] 1]
																set inpPrse2 [lindex [split $lReferenceNameS1 "/"] 1]
																set DiodeStr "${inpPrse1},${inpPrse2},${lPageName}"
																lappend DiodeList $DiodeStr
															}
														}
														set lConnPin [$lConnpinIter NextPortInst $lStatus]
													}
												}
												set lWire2 [$lWireIter1 NextWire $lStatus]
											}
										}
										set lPin [$lPinIter NextPin $lStatus]
									}
							}
					}
				}
			}
			set lInst [$lPartInstsIter NextPartInst $lStatus]
		}
		delete_DboPagePartInstsIter $lPartInstsIter
	}
	set UnqDiodeList [lsort -unique $DiodeList]
	
	foreach Ditem $UnqDiodeList {
		set Dparts [split $Ditem ","]
		set DinpPrse3 [string range [lindex $Dparts 0] 1 end]
		set DinpPrse4 [string range [lindex $Dparts 1] 1 end]
		if {$DinpPrse3 != $DinpPrse4} {
			set DinpPrse5 [lindex [split $Ditem ","] 0]
			set DinpPrse6 [lindex [split $Ditem ","] 1]
			set DinpPrse7 [lindex [split $Ditem ","] 2]
			set ErrStringDiode "Error : ${DinpPrse7} - ${DinpPrse5} - Diode Name MissMatch - ${DinpPrse6}"
			lappend ErrorList $ErrStringDiode
		}
	}
	
	
	set UnqErrorList [lsort -unique $ErrorList]
	set UnqSkipList [lsort -unique $SkipList]
	
	set MainListUpdate [list]

	foreach mainStr $UnqErrorList {
		set skipFlag 0
		foreach skipStr $UnqSkipList {
			if {[string match "*$skipStr*" $mainStr]} {
				set skipFlag 1
				break
			}
		}
		if {!$skipFlag} {
			lappend MainListUpdate $mainStr
		}
	}

	if {[llength $MainListUpdate] == 0} {
		set user_input1 [tk_messageBox -title "Relay And Diode Reference Check" -message "No Error Found..!" -type okcancel -icon question -default ok -parent .]
	} else {
		set fileId [open "ErrorList.txt" "w"]
		puts "Error Data:"
		foreach item $MainListUpdate {
			puts $fileId $item
			puts $item
		}
		close $fileId
		set user_input1 [tk_messageBox -title "Relay And Diode Reference Check" -message "ErrorList.Txt Saved In Your Working Directory..!" -type okcancel -icon question -default ok -parent .]
	}
}
	
}
RelayAndDiodeRefChk::RelayAndDiodeRefChkfunc