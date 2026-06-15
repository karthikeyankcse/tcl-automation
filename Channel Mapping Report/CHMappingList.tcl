package require Tk
wm withdraw .

namespace eval CHMappingList {} {
    variable dirName [file dirname [info script]]
	variable userName $env(USERNAME)
    variable userProfile $env(USERPROFILE)
}

proc CHMappingList::CHMappingListfunc {} {

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

    set logDir "//sng-psrvr06/Automation-Public/MiscFiles/SKILL_Logs/TCL_Logs/CH_Mapping_List"

    if {![file exists $logDir]} {
        file mkdir $logDir
    }

    set logFile [file join $logDir $CreateFilename]

    set fp [open $logFile "w"]
    puts $fp "User Name     : $userName"
    puts $fp "Opened File   : $filename"
    puts $fp "Opened Date And Time  : $now"
	puts $fp "Used TCL Script  : CH_Mapping_List"
	puts $fp "Developed by: Pactron India Pvt Ltd"
	puts $fp "--------------------------------------------------------------------"
    close $fp

    set ::DropdownSelection4 ""
    set ::input_info ""
	set ::input_infoSkip ""

    set user_input [tk_messageBox -title "CH Mapping List" -message "Please Confirm to Run the CH Mapping List Program ..!" -type okcancel -icon question -default ok -parent .]
    if {$user_input eq "ok"} {
        toplevel .site_inp_dialog 
        wm title .site_inp_dialog "CH Mapping List"

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
        label .site_inp_dialog.prompt_NN -text "SELECT PIN NAME/NUMBER :" -font $font_style
        grid .site_inp_dialog.prompt_NN -row 3 -column 0 -sticky e -padx 10 -pady 5

        # Dropdown menu for NAME/NUMBER selection
        menu .site_inp_dialog.dropdown_NN
        .site_inp_dialog.dropdown_NN add command -label "NAME" -command {set ::DropdownSelection4 "NAME"; .site_inp_dialog.dropdown_button_NN configure -text "NAME"}
        .site_inp_dialog.dropdown_NN add command -label "NUMBER" -command {set ::DropdownSelection4 "NUMBER"; .site_inp_dialog.dropdown_button_NN configure -text "NUMBER"}

        # Dropdown button for selection
        button .site_inp_dialog.dropdown_button_NN -text "Select" -command {.site_inp_dialog.dropdown_NN post [winfo pointerx .] [winfo pointery .]} -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.dropdown_button_NN -row 3 -column 1 -sticky w -padx 10 -pady 5

        # Input Box for PIN names to generate
        label .site_inp_dialog.prompt_input -text "ENTER PIN NAMES TO GENERATE :" -font $font_style
        grid .site_inp_dialog.prompt_input -row 5 -column 0 -sticky e -padx 10 -pady 5

        entry .site_inp_dialog.input_box -font $font_style
        grid .site_inp_dialog.input_box -row 5 -column 1 -sticky w -padx 10 -pady 5

        # Input Box for PIN names to skip
        label .site_inp_dialog.prompt_input1 -text "ENTER PIN NAMES TO SKIP :" -font $font_style
        grid .site_inp_dialog.prompt_input1 -row 7 -column 0 -sticky e -padx 10 -pady 5

        entry .site_inp_dialog.input_box1 -font $font_style
        grid .site_inp_dialog.input_box1 -row 7 -column 1 -sticky w -padx 10 -pady 5

        # Frame for buttons
        frame .site_inp_dialog.buttons
        grid .site_inp_dialog.buttons -row 8 -column 0 -columnspan 3 -sticky ew -padx 10 -pady 10

        # OK button to handle form submission
        button .site_inp_dialog.ok -text "CLICK HERE TO CREATE" -command {
            set ::input_info [.site_inp_dialog.input_box get]
            set ::input_infoSkip [.site_inp_dialog.input_box1 get]
            set ::DropdownSelection4 $::DropdownSelection4
            destroy .site_inp_dialog
        } -background "#2196F3" -foreground "white" -font $font_style
        grid .site_inp_dialog.ok -row 9 -column 0 -columnspan 3 -padx 20 -pady 15 -sticky ew

        tkwait window .site_inp_dialog

        # After the window is closed, print the gathered inputs
        puts "ADDING NETS TCL SCRIPT"

        set input_info $::input_info
        puts "GENERATE NAME: $input_info"
        
        set input_infoSkip $::input_infoSkip
        puts "SKIP NAME: $input_infoSkip"

        set DropdownSelection4 $::DropdownSelection4
        puts "SELECTED (NAME/NUMBER): $DropdownSelection4"


        if {$DropdownSelection4 != "" && $input_info != ""} {
			set selectedobjs [GetSelectedPMItems]
			set objlength [llength $selectedobjs]
			set lStatus [DboState]
			set lNullObj NULL
			set FinalList [list]
			
			if {[llength $selectedobjs] == 0} {
				set user_input3 [tk_messageBox -title "CH Mapping List" -message "Error : Page Not Selected..!" -type okcancel -icon question -default ok -parent .]
			} else {
				#---------------------------------------------------------------------------------------------------------------------------------------------------
				
				for {set j 0} {$j < $objlength} {incr j} {
					set lPage [lindex $selectedobjs $j]
					set lPageNameCS [DboTclHelper_sMakeCString]
					$lPage GetName $lPageNameCS
					set lPageName [DboTclHelper_sGetConstCharPtr $lPageNameCS]
					set PlIter [$lPage NewPartInstsIter $lStatus]
					set lPart [$PlIter NextPartInst $lStatus]
					while {$lPart != $lNullObj } {
						set lReferenceName [DboTclHelper_sMakeCString]
						$lPart GetReference $lReferenceName
						set lReferenceNameS [DboTclHelper_sGetConstCharPtr $lReferenceName]
						
						set lIter [$lPart NewPinsIter $lStatus] 
						set lPin [$lIter NextPin $lStatus] 
						while {$lPin != $lNullObj } { 
							set lPinN [DboTclHelper_sMakeCString]
							set lPinName [DboTclHelper_sMakeCString]
							set lPinNum [DboTclHelper_sMakeCString]
							
							$lPin GetPinName $lPinName
							set lPinName [DboTclHelper_sGetConstCharPtr $lPinName]
							
							$lPin GetPinNumber $lPinNum
							set lPinNum [DboTclHelper_sGetConstCharPtr $lPinNum]
							
							if {$DropdownSelection4 == "NUMBER"} {
								$lPin GetPinNumber $lPinN
								set lPinN [DboTclHelper_sGetConstCharPtr $lPinN]
								
							} else {
								$lPin GetPinName $lPinN
								set lPinN [DboTclHelper_sGetConstCharPtr $lPinN]
							}
						
						set lPinN_UC [string toupper $lPinN]
						set input_info_UC [string toupper $input_info]
						set Skip_UC [string toupper $input_infoSkip]
						set lPinName_UC [string toupper $lPinName]
						
						set DummyVar "BLOCK"
						
						set PrseDt [split $input_info_UC ","] 
						set PrseDtSkp [split $Skip_UC ","] 
						
						set lWire [$lPin GetWire $lStatus]
						if {$lWire != $lNullObj } { 
							set netobj [$lWire GetNet $lStatus]
							set lWireName [DboTclHelper_sMakeCString]
							$netobj GetNetName $lWireName
							set lWireNameStr [DboTclHelper_sGetConstCharPtr $lWireName]
							set FinalDt "${lReferenceNameS}.${lPinN},${lWireNameStr}"
							
							foreach PrseDtlp $PrseDt {
								if {[string first $PrseDtlp $lPinName_UC] >= 0 } {
									set DummyVar "GO"
								} 
							}
							
							foreach PrseDtSkplp $PrseDtSkp {
								if {[string first $PrseDtSkplp $lPinName_UC] >= 0 } {
									set DummyVar "BLOCK"
								} 
							}
							
							if {$DummyVar == "GO"} {
								lappend FinalList $FinalDt
							}
						}
						
						
						set lPin [$lIter NextPin $lStatus] 
						} 
						delete_DboPartInstPinsIter $lIter
						
					set lPart [$PlIter NextPartInst $lStatus]
					}
					delete_DboPagePartInstsIter $PlIter
				}
				
				set FinalList [lsort -unique $FinalList]
				
				set filename "CHMappingList.csv"
				set fileId [open $filename "w"]
				puts $fileId "PIN NAME Or NUMBER, NET NAME"

				foreach item $FinalList {
					set parts [split $item ","]
					
					puts $fileId [join $parts ","]
				}

				close $fileId

				puts "Data has been written to $filename"
				set user_input1 [tk_messageBox -title "CH Mapping List" -message "CHMappingList Generated Successfully ..!" -type okcancel -icon question -default ok -parent .]
			}
        
        } else {
            set user_input1 [tk_messageBox -title "CH Mapping List" -message "Error : Required Input is Empty ..!" -type okcancel -icon question -default ok -parent .]
        }
    }
}

CHMappingList::CHMappingListfunc
