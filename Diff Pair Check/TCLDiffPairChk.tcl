SetOptionBool Journaling True
package require Tk
wm withdraw .
namespace eval TCLDiffPairChk {
    variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc TCLDiffPairChk::compare_strings {str1 str2} {
    set diff_count 0
    set diff_chars {}
    for {set i 0} {$i < [string length $str1]} {incr i} {
        if {[string index $str1 $i] ne [string index $str2 $i]} {
            incr diff_count
            lappend diff_chars [list [string index $str1 $i] [string index $str2 $i]]
        }
    }
    return [list $diff_count $diff_chars]
}

proc TCLDiffPairChk::TCLDiffPairChkfunc {} {

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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/Diff_Pair_Check"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : Diffrential Pair Check"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

	set ::DropdownSelection4 ""

    set user_input [tk_messageBox -title "Diff Pair Check" -message "Please Confirm to Run the Diff Pair Check Program ..!" -type okcancel -icon question -default ok -parent .]
    if {$user_input eq "ok"} {
        toplevel .site_inp_dialog 
        wm title .site_inp_dialog "Diff Pair Check"

        # Grid configuration to handle alignment
        grid columnconfigure .site_inp_dialog 0 -weight 1
        grid columnconfigure .site_inp_dialog 1 -weight 3
        grid columnconfigure .site_inp_dialog 2 -weight 0

        grid rowconfigure .site_inp_dialog 0 -weight 0
        grid rowconfigure .site_inp_dialog 1 -weight 0
        grid rowconfigure .site_inp_dialog 2 -weight 1
        grid rowconfigure .site_inp_dialog 3 -weight 1
        grid rowconfigure .site_inp_dialog 4 -weight 0
        grid rowconfigure .site_inp_dialog 5 -weight 0
        grid rowconfigure .site_inp_dialog 6 -weight 1
        grid rowconfigure .site_inp_dialog 7 -weight 0
        grid rowconfigure .site_inp_dialog 8 -weight 0
        grid rowconfigure .site_inp_dialog 9 -weight 1
        grid rowconfigure .site_inp_dialog 10 -weight 0

        # Font definition
        set font_style {Cambria 12}

        # Label for PIN Name/Number Selection
        label .site_inp_dialog.prompt_NN -text "SELECT S93k/UF OR J750 :" -font $font_style
        grid .site_inp_dialog.prompt_NN -row 3 -column 0 -sticky e -padx 10 -pady 5

        # Dropdown menu for NAME/NUMBER selection
        menu .site_inp_dialog.dropdown_NN
        .site_inp_dialog.dropdown_NN add command -label "S93k" -command {set ::DropdownSelection4 "S93k"; .site_inp_dialog.dropdown_button_NN configure -text "S93k"}
        .site_inp_dialog.dropdown_NN add command -label "UF OR J750" -command {set ::DropdownSelection4 "UF OR J750"; .site_inp_dialog.dropdown_button_NN configure -text "UF OR J750"}

        # Dropdown button for selection
        button .site_inp_dialog.dropdown_button_NN -text "Select" -command {.site_inp_dialog.dropdown_NN post [winfo pointerx .] [winfo pointery .]} -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.dropdown_button_NN -row 3 -column 1 -sticky w -padx 10 -pady 5


        # Frame for buttons
        frame .site_inp_dialog.buttons
        grid .site_inp_dialog.buttons -row 8 -column 0 -columnspan 3 -sticky ew -padx 10 -pady 10

        # OK button to handle form submission
        button .site_inp_dialog.ok -text "CLICK HERE TO CREATE" -command {
            set ::DropdownSelection4 $::DropdownSelection4
            destroy .site_inp_dialog
        } -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.ok -row 9 -column 0 -columnspan 3 -padx 20 -pady 15 -sticky ew

        tkwait window .site_inp_dialog

        # After the window is closed, print the gathered inputs
        puts "DIFF PAIR CHECK"


        set DropdownSelection4 $::DropdownSelection4
        puts "SELECTED (S93K/UF or J750): $DropdownSelection4"


        if {$DropdownSelection4 != ""} {

			set selectedobjs [GetSelectedPMItems]
			set objlength [llength $selectedobjs]
			set lStatus [DboState]
			set lNullObj NULL
			set AllNetList [list]

			for {set j 0} {$j < $objlength} {incr j} {
				
				if {[llength $selectedobjs] == 0} {
						set user_input3 [tk_messageBox -title "Diff Pair Check" -message "Error : Page Not Selected..!" -type okcancel -icon question -default ok -parent .]
				} else {
					set lPage [lindex $selectedobjs $j]
					set OffIter [$lPage NewOffPageConnectorsIter $lStatus $::IterDefs_ALL] 
					set lOff [$OffIter NextOffPageConnector $lStatus] 
					while {$lOff != $lNullObj } { 
						set OffName [DboTclHelper_sMakeCString]
						$lOff GetName $OffName
						set lOffS [DboTclHelper_sGetConstCharPtr $OffName]
						
						lappend AllNetList $lOffS
						
					set lOff [$OffIter NextOffPageConnector $lStatus]
					}
					delete_DboPageOffPageConnectorsIter $OffIter
				}
							
			}
			#puts $AllNetList
			#set myList { "ABCDE" "ABCFE" "ABCGH" "BDGJS" }
			
			set DiffNetList [list]
			foreach str1 $AllNetList {
				foreach str2 $AllNetList {
					if {($str1 ne $str2)} {
						set result [TCLDiffPairChk::compare_strings $str1 $str2]
						set diff_count [lindex $result 0]
						set diff_chars [lindex $result 1]
						
						if {$diff_count == 1} {
							set diff_output "$str1,$str2"
							foreach pair $diff_chars {
								set DiffVal "[join $pair ","]"
								if { $DiffVal == "P,N" || $DiffVal == "P,M" || $DiffVal == "T,C" || $DiffVal == "S,G"} {
									#set ResVal "${diff_output},${DiffVal}"
									set ResVal "${diff_output}"
									#puts $ResVal
									lappend DiffNetList $ResVal
								}
							}
						}
					}
				}
			}
		
			set DiffNetList [lsort -unique $DiffNetList]
			set LenValD 0
			set LenValD [llength $DiffNetList]
			if {$LenValD != 0} {	
				set lStatus [DboState]
				set lNullObj NULL
				set StrList [list]
				
				for {set i 0} {$i < $objlength} {incr i} {
					set lPage [lindex $selectedobjs $i]
					set lPageName [DboTclHelper_sMakeCString]
					$lPage GetName $lPageName
					set lPageName [DboTclHelper_sGetConstCharPtr $lPageName]
					set PlIter [$lPage NewPartInstsIter $lStatus]  
					set lPart [$PlIter NextPartInst $lStatus] 
					while {$lPart != $lNullObj } {
					
						set lRefdes [DboTclHelper_sMakeCString]
						$lPart GetReferenceDesignator $lRefdes
						set lRefdes [DboTclHelper_sGetConstCharPtr $lRefdes]
						
						set lIter [$lPart NewPinsIter $lStatus] 
						set lPin [$lIter NextPin $lStatus] 
						while {$lPin != $lNullObj } { 
							set lPinName [DboTclHelper_sMakeCString]
							$lPin GetPinName $lPinName
							set lPinName [DboTclHelper_sGetConstCharPtr $lPinName]
							
							set lWire [$lPin GetWire $lStatus]	
							if {$lWire != $lNullObj } {
								set netobj [$lWire GetNet $lStatus]
								set lNetName [DboTclHelper_sMakeCString]
								$netobj GetNetName $lNetName
								set lNetName [DboTclHelper_sGetConstCharPtr $lNetName]
								set StrVal "${lPageName},${lRefdes},${lPinName},${lNetName}"
								lappend StrList $StrVal
							}
							
							set lPin [$lIter NextPin $lStatus] 
						} 
						delete_DboPartInstPinsIter $lIter
					
					set lPart [$PlIter NextPartInst $lStatus]
					}
					delete_DboPagePartInstsIter $PlIter		
				}
				
				set StrList [lsort -unique $StrList]
				
				#puts $StrList

				set UpStrList [list]
				
				foreach DiffNetListlp $DiffNetList {
					set PrseDiffNet [split $DiffNetListlp ","]
					set FirstDiffNet [lindex $PrseDiffNet 0]
					set SecDiffNet [lindex $PrseDiffNet 1]
					
					
					set FirstVal "DummyFirst"
					set SecVal "DummySec"
					foreach StrListlp $StrList {
						set PrseStrNet [split $StrListlp ","]
						set StrNetVal [lindex $PrseStrNet 3]
						
						if {$StrNetVal == $FirstDiffNet} {
							set FirstVal $StrListlp
						}
						
						if {$StrNetVal == $SecDiffNet} {
							set SecVal $StrListlp
						}
						
					}
					
					if {$FirstVal != "DummyFirst" && $SecVal != "DummySec"} {
					
						set CombStr "${FirstVal},${SecVal}"
						lappend UpStrList $CombStr
						
					}
					
				}
				
				set UpStrList [lsort -unique $UpStrList]
				
				#puts $UpStrList
				
				set filename1 "DiffPairReport.csv"
				set fileId1 [open $filename1 "w"]
				puts $fileId1 "Positive - Page, Positive - Refdes, Positive - Pin Name, Positive - NetName, Negative - Page, Negative - Refdes, Negative - Pin Name, Negative - NetName"

				foreach item1 $UpStrList {
					set parts1 [split $item1 ","]
					
					puts $fileId1 [join $parts1 ","]
				}

				close $fileId1
				
				set user_input5 [tk_messageBox -title "Diff Pair Check" -message "Report Generated Successfully ..!" -type okcancel -icon question -default ok -parent .]
				
				
				set ErrorList [list]
				foreach UpNetListlp $UpStrList {
					set PrseDiffNetComb [split $UpNetListlp ","]
					set FirstDiffNetPage [lindex $PrseDiffNetComb 0]
					set FirstDiffNetRef [lindex $PrseDiffNetComb 1]
					set FirstDiffNetPin [lindex $PrseDiffNetComb 2]
					set FirstDiffNetNet [lindex $PrseDiffNetComb 3]
					set SecDiffNetPage [lindex $PrseDiffNetComb 4]
					set SecDiffNetRef [lindex $PrseDiffNetComb 5]
					set SecDiffNetPin [lindex $PrseDiffNetComb 6]
					set SecDiffNetNet [lindex $PrseDiffNetComb 7]

					if {$FirstDiffNetPage == $SecDiffNetPage} {
						
						if {$FirstDiffNetRef == $SecDiffNetRef} {
							
							set Fnumbers ""
							set Falphabets ""
							set Snumbers ""
							set Salphabets ""

							set FirstPrsdPin [split $FirstDiffNetPin "_"]
							set SecPrsdPin [split $SecDiffNetPin "_"]
							set Fsymbols "DummyFS"
							set Ssymbols "DummySS"
							foreach ch [split [lindex $FirstPrsdPin 0] ""] {
								if {[regexp {\d} $ch]} {
									append Fnumbers $ch
								} elseif {[regexp {\w} $ch]} {
									append Falphabets $ch
								} elseif {$ch == "+" || $ch == "-"} {
									append Fsymbols $ch
								}
							}
							
							foreach chS [split [lindex $SecPrsdPin 0] ""] {
								if {[regexp {\d} $chS]} {
									append Snumbers $chS
								} elseif {[regexp {\w} $chS]} {
									append Salphabets $chS
								} elseif {$chS == "+" || $chS == "-"} {
									append Ssymbols $chS
								}
							}
							
							if {$Falphabets == $Salphabets} {
								if {$DropdownSelection4 == "S93k"} {
									set PinNum "${Fnumbers}-${Snumbers}"
									if {$PinNum == "02-04" || $PinNum == "06-08" || $PinNum == "10-12" || $PinNum == "14-16" || $PinNum == "01-03" || $PinNum == "05-07" || $PinNum == "09-11" || $PinNum == "13-15"} { 
										#puts $FirstPrsdPin
										#puts $SecPrsdPin
									} elseif { $Fsymbols != "DummyFS" && $Ssymbols != "DummySS" } {
										set PinSym "${Fsymbols}${Ssymbols}"
										if {$PinSym == "+-"} {
											#puts $PinSym
										} else {
											set ErrPin "Error : Diff Pair Net Assigned In Different Pins,${UpNetListlp}"
											lappend ErrorList $ErrPin
										}
									
									} else {
										set ErrPin "Error : Diff Pair Net Assigned In Different Pins,${UpNetListlp}"
										lappend ErrorList $ErrPin
									}
								} else {
									
									regsub {^0+} $Fnumbers "" Fnumbers
									set FnumbersC [expr $Fnumbers]
									
									regsub {^0+} $Snumbers "" Snumbers
									set SnumbersC [expr $Snumbers]
									
									if {$FnumbersC > $SnumbersC} {
										set PNum $SnumbersC
										set NNum $FnumbersC
									} else {
										set PNum $FnumbersC
										set NNum $SnumbersC
									}
									
									if {[expr $PNum % 2] != 0} {
										set SecNum [expr $PNum + 1]
										if {$SecNum == $NNum} {
											#puts $SecNum
										} else {
											set ErrPin "Error : Diff Pair Net Assigned In Different Pins,${UpNetListlp}"
											lappend ErrorList $ErrPin
										}
										
									} else {
										set ErrPin "Error : Diff Pair Net Assigned In Different Pins,${UpNetListlp}"
										lappend ErrorList $ErrPin
									}

								}
								
							} else {
								set ErrPin "Error : Diff Pair Net Assigned In Different Pins,${UpNetListlp}"
								lappend ErrorList $ErrPin
							
							}
							
						} else {
							set ErrRef "Error : Diff Pair Net Assigned In Different Refdes,${UpNetListlp}"
							lappend ErrorList $ErrRef
						
						}
						
					} else {
						set ErrPage "Error : Diff Pair Net Assigned In Different Page,${UpNetListlp}"
						lappend ErrorList $ErrPage
					}
					
				}
				
				set LenVal 0
				set LenVal [llength $ErrorList]
				if {$LenVal != 0} {
					set filename "ErrorDiffPairList.csv"
					set fileId [open $filename "w"]
					puts $fileId "Error, Positive - Page, Positive - Refdes, Positive - Pin Name, Positive - NetName, Negative - Page, Negative - Refdes, Negative - Pin Name, Negative - NetName"

					foreach item $ErrorList {
						set parts [split $item ","]
						
						puts $fileId [join $parts ","]
					}

					close $fileId
					
					set user_input3 [tk_messageBox -title "Diff Pair Check" -message "Error List Generated Successfully ..!" -type okcancel -icon question -default ok -parent .]
					
				} else {
					set user_input2 [tk_messageBox -title "Diff Pair Check" -message "No Error Found ..!" -type okcancel -icon question -default ok -parent .]
				}
				
			
			} else {
				set user_input1 [tk_messageBox -title "Diff Pair Check" -message "Error : No Diff Net Found..!" -type okcancel -icon question -default ok -parent .]
			}
		
		} else {
			set user_input4 [tk_messageBox -title "Diff Pair Check" -message "Error : Required Input is Empty ..!" -type okcancel -icon question -default ok -parent .]
		}
		
		
		
		
		
	}
	
}

TCLDiffPairChk::TCLDiffPairChkfunc
