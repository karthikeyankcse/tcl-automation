package require Tk
wm withdraw .

namespace eval PartDetailReport {
    variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc PartDetailReport::PartDetailReportFunc {} {
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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Part_Detail_Report"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Part_Detail_Report"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set user_input [tk_messageBox -title "Part Detail Report" -message "Please Confirm to Run the Part Detail Report Program ..!" -type okcancel -icon question -default ok -parent .]
    if {$user_input eq "ok"} {
		set lNullObj NULL
		set lStatus [DboState]
		set lLib [GetSelectedPMItems] 
		set ListLen [llength $lLib]
		set AddList [list]
		set TitleVal "LIBRARY_NAME,SPLIT_NUMBER,PIN_NAME,X_LOCATION,Y_LOCATION"
		lappend AddList $TitleVal

		if {$ListLen != 0} {
			foreach lObject $lLib {
				set LibName [DboTclHelper_sMakeCString]
				$lObject GetName $LibName
				set LibNameStr [DboTclHelper_sGetConstCharPtr $LibName]
				set SplitNo 0

				set plIter [$lObject NewDevicesIter $lStatus]
				set lDevice [$plIter NextDevice $lStatus]
				while {$lDevice != $lNullObj} {
					set lCell [$lDevice GetCell $lStatus]
					set lLipPartIter [$lCell NewPartsIter $lStatus]
					set lPart [$lLipPartIter NextPart $lStatus]
					while {$lPart != $lNullObj} {
						set SplitNo [expr $SplitNo + 1]
						set lPinIter [$lPart NewLPinsIter $lStatus]
						set lPin [$lPinIter NextPin $lStatus]
						while {$lPin != $lNullObj} {
							set lPinName [DboTclHelper_sMakeCString]
							$lPin GetPinName $lPinName
							set lPinNameString [DboTclHelper_sGetConstCharPtr $lPinName]

							set lStartPoint [$lPin GetStartPoint $lStatus]
							set lStartX [DboTclHelper_sGetCPointX $lStartPoint]
							set lStartY [DboTclHelper_sGetCPointY $lStartPoint]

							set combined "$LibNameStr,$SplitNo,$lPinNameString,$lStartX,$lStartY"
							lappend AddList $combined

							set lPin [$lPinIter NextPin $lStatus]
						}
						set lPart [$lLipPartIter NextPart $lStatus]
					}
					set lDevice [$plIter NextDevice $lStatus]
				}
			}

			set filename [tk_getSaveFile \
				-title "Save CSV Report" \
				-filetypes {{"CSV Files" {.csv}} {"All Files" {*}}} \
				-defaultextension ".csv"]

			if {$filename ne ""} {
				set fp [open $filename "w"]
				foreach line $AddList {
					puts $fp $line
				}
				close $fp
				tk_messageBox -title "Part Detail Report" -message "Yooo..! File Saved Successfully..!" -type ok -icon warning -parent .
			} else {
				tk_messageBox -title "Part Detail Report" -message "Error: File Save Cancelled..!" -type ok -icon error -parent .
			}
		} else {
			tk_messageBox -title "Part Detail Report" -message "Error: None Of The Part Selected..!" -type ok -icon error -parent .
		}
	} else {
		tk_messageBox -title "Part Detail Report" -message "Program Cancelled..!" -type ok -icon error -parent .
	}
}

PartDetailReport::PartDetailReportFunc
