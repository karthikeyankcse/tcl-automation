SetOptionBool Journaling True
namespace eval PinNameUp {} {
	
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc PinNameUp::PinNameUpfunc {} {

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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Library_Sym_Duplicate_Pinname_Rename"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Library Symbol Duplicate Pinname Rename"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set selectedobjs [GetSelectedPMItems]
	set objlength [llength $selectedobjs]
	set lStatus [DboState]
	set lNullObj NULL
	set PinNameList [list]
	for {set j 0} {$j < $objlength} {incr j} {
		set obj [lindex $selectedobjs $j]
		set PlIter [$obj NewPartsIter $lStatus]  
		set lPart [$PlIter NextPart $lStatus] 
		while {$lPart != $lNullObj } { 
			set lIter [$lPart NewPinsIter $lStatus]  
			set lPin [$lIter NextPin $lStatus] 
			while {$lPin != $lNullObj } { 
				set lPinName [DboTclHelper_sMakeCString]
				$lPin GetPinName $lPinName
				set lPinName [DboTclHelper_sGetConstCharPtr $lPinName]
				lappend PinNameList $lPinName
			set lPin [$lIter NextPin $lStatus] 
			}
		set lPart [$PlIter NextPart $lStatus]
		}
	}
	lappend PinNameList "DummyVal"
	set k 0
	foreach n $PinNameList {
	 set myArr($k) $n
	 incr k
	}
	set IncVal 1
	set AddVal 1
	for {set i 0} {$i < $objlength} {incr i} {
		set Uobj [lindex $selectedobjs $i]
		set UPlIter [$Uobj NewPartsIter $lStatus]  
		set UlPart [$UPlIter NextPart $lStatus] 
		while {$UlPart != $lNullObj } { 
			set UlIter [$UlPart NewPinsIter $lStatus]  
			set UlPin [$UlIter NextPin $lStatus] 
			while {$UlPin != $lNullObj } { 
				set UlPinName [DboTclHelper_sMakeCString]
				$UlPin GetPinName $UlPinName
				set UlPinName [DboTclHelper_sGetConstCharPtr $UlPinName]
				set ArrVal $myArr($IncVal) 
				if {$ArrVal == $UlPinName} {
					set UpVal "${UlPinName}_${AddVal}"
					set UpVal [DboTclHelper_sMakeCString $UpVal]
					$UlPin SetPinName $UpVal
					$UlPin SetName $UpVal
					set AddVal [expr $AddVal + 1]
				} else {
					if {$IncVal == 1} {
						set AddVal 1
					} else {
						set Revval [expr $IncVal - 2]
						set RevDt $myArr($Revval)
						if {$RevDt == $UlPinName} {
							set UpVal "${UlPinName}_${AddVal}"
							set UpVal [DboTclHelper_sMakeCString $UpVal]
							$UlPin SetPinName $UpVal
							$UlPin SetName $UpVal
							set AddVal 1
						} else {
							set AddVal 1
						}
					}
				}
				set IncVal [expr $IncVal + 1]
			set UlPin [$UlIter NextPin $lStatus] 
			}
		set UlPart [$UPlIter NextPart $lStatus]
		}
	}
	
} 
	

PinNameUp::PinNameUpfunc