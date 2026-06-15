SetOptionBool Journaling True
package require Tk
wm withdraw .
namespace eval NetConnectionRep {} {
	variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}


proc NetConnectionRep::NetConnectionRepFunc {} {
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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Net_Connection_Report"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Net_Connection_Report"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set lSession $::DboSession_s_pDboSession
	DboSession -this $lSession
	set lNullObj NULL
	set lStatus [DboState]
	set lDesign [$lSession GetActiveDesign]
	
	set SchNetList [list]
	set NetAndAliasList [list]
	
	if {$lDesign != $lNullObj} {
		set lSchematicIter [$lDesign NewViewsIter $lStatus $::IterDefs_ALL]
		set lView [$lSchematicIter NextView $lStatus]
		set lPage_Name [DboTclHelper_sMakeCString]
        while { $lView != $lNullObj} {
			set lSchematic [DboViewToDboSchematic $lView]
			set lSchi_Name [DboTclHelper_sMakeCString]
			$lSchematic GetName $lSchi_Name
			set lPagesIter [$lSchematic NewPagesIter $lStatus]
			set lPage [$lPagesIter NextPage $lStatus]
			set lSchName [DboTclHelper_sGetConstCharPtr $lSchi_Name]
			while {$lPage!=$lNullObj} {	
				#set lPageNameCS [DboTclHelper_sMakeCString]
				#$lPage GetName $lPageNameCS
				#set lPageName [DboTclHelper_sGetConstCharPtr $lPageNameCS]
				#puts $lPageName
				
				set lWiresIter [$lPage NewWiresIter $lStatus]
				set lWire [$lWiresIter NextWire $lStatus]
				set lNullObj NULL
				while {$lWire != $lNullObj} {
				
					set WireNetName [DboTclHelper_sMakeCString]
					$lWire GetNetName $WireNetName
					set WireNetNameStr [DboTclHelper_sGetConstCharPtr $WireNetName]


					set lSchnet [[$lWire GetNet $lStatus ] GetSchematicNet]
					set schilist {}
					set lname [DboTclHelper_sMakeCString]
					set schiter [$lSchnet NewNetsIter $lStatus]
					set lschinet [$schiter NextNet $lStatus]
					while {$lschinet != "NULL"} {
						$lschinet GetNetName $lname
						set schiname [DboTclHelper_sGetConstCharPtr $lname]
						if {[lsearch $schilist $schiname] == -1} {
							lappend schilist $schiname
						}
						set lschinet [$schiter NextNet $lStatus]
					}
					lappend SchNetList $schilist
					
					
					set lAliasNameCString [DboTclHelper_sMakeCString]
					set lAliasIter [$lWire NewAliasesIter $lStatus]

					set lAlias [$lAliasIter NextAlias $lStatus]
					while { $lAlias != "NULL"} {
						$lAlias GetName $lAliasNameCString
						set lAliasName [DboTclHelper_sGetConstCharPtr $lAliasNameCString]
						set NetAndAlias "${WireNetNameStr},${lAliasName}"
						lappend NetAndAliasList $NetAndAlias
					set lAlias [$lAliasIter NextAlias $lStatus]
					}
				
					set lWire [$lWiresIter NextWire $lStatus]
				}
				
				delete_DboPageWiresIter $lWiresIter
				
				set lPage [$lPagesIter NextPage $lStatus]
			}
			delete_DboSchematicPagesIter $lPagesIter
			set lView [$lSchematicIter NextView $lStatus]
		}
		delete_DboLibViewsIter $lSchematicIter
		
		set SchNetList [lsort -unique $SchNetList]
		set NetAndAliasList [lsort -unique $NetAndAliasList]
	
		
		set FinalList [list]
		foreach SchNetListlp $SchNetList {
			foreach SchNetListlpSec $SchNetListlp {
				
				foreach NetAndAliasListlp $NetAndAliasList {
					
					set NetName [lindex [split $NetAndAliasListlp ","] 0]
					set AliasName [lindex [split $NetAndAliasListlp ","] 1]
					
					if {$NetName == $SchNetListlpSec} {
						set DummyList {}
						lappend DummyList $AliasName
						
						foreach SchNetListlpThrd $SchNetListlp {
							lappend DummyList $SchNetListlpThrd
						}
						set DummyList [lsort -unique $DummyList]
						set DummyStr [join $DummyList ","]
						lappend FinalList $DummyStr
					}
				
				}
			}
		}
		
		set FinalList [lsort -unique $FinalList]
		
		set filename [tk_getSaveFile \
			-title "Save CSV File" \
			-defaultextension ".csv"]

		if {$filename eq ""} {
			puts "No file selected. Exiting."
			return
		}
		
		if {[catch {open $filename "w"} fp]} {
			puts "Error: Could not open file '$filename' for writing."
			exit
		}
		
		foreach item $FinalList {
			set csvline [join $item ","]
			puts $fp $csvline
		}

		close $fp
		puts "CSV file saved to: $filename"
		set user_input [tk_messageBox -title "Net Connection Report" -message "Report Generated Successfully..!" -type okcancel -icon question -default ok -parent .]
	}
} 



NetConnectionRep::NetConnectionRepFunc