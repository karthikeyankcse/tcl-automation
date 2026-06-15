SetOptionBool Journaling True
package require Tk
namespace eval SiteNameChangeA {} {
	
	variable dirName [file dirname [info script]]
}

proc SiteNameChangeA::SiteNameChangeAfunc {} {
	set user_input [tk_messageBox -title "Site Name Change" -message "Please Confirm to Change the Site Name..!" -type okcancel -icon question -default ok -parent .]
	if {$user_input eq "ok"} {
		toplevel .site_inp_dialog 
        wm title .site_inp_dialog "Site Name Change"
        
        label .site_inp_dialog.prompt -text "Find Name:"
        pack .site_inp_dialog.prompt -side top
        
        entry .site_inp_dialog.entry -width 20
        pack .site_inp_dialog.entry -side top
        
		label .site_inp_dialog.prompt1 -text "Replace Name:"
        pack .site_inp_dialog.prompt1 -side top
        
        entry .site_inp_dialog.entry1 -width 20
        pack .site_inp_dialog.entry1 -side top
		
		label .site_inp_dialog.prompt1 -text "No Of Char:"
        pack .site_inp_dialog.prompt1 -side top
        
        entry .site_inp_dialog.entry1 -width 20
        pack .site_inp_dialog.entry1 -side top
		
		checkbutton .site_inp_dialog.checkbox -text "Parts" -variable parts -font {Helvetica 10} -background white
		pack .site_inp_dialog.checkbox -padx 10 -pady 10
		
		checkbutton .site_inp_dialog.checkbox1 -text "Alias" -variable alias -font {Helvetica 10} -background white
		pack .site_inp_dialog.checkbox1 -padx 10 -pady 10
		
		checkbutton .site_inp_dialog.checkbox2 -text "OffPage" -variable offpage -font {Helvetica 10} -background white
		pack .site_inp_dialog.checkbox2 -padx 10 -pady 10
		
		checkbutton .site_inp_dialog.checkbox3 -text "Port" -variable port -font {Helvetica 10} -background white
		pack .site_inp_dialog.checkbox3 -padx 10 -pady 10
		
		checkbutton .site_inp_dialog.checkbox4 -text "Global" -variable global -font {Helvetica 10} -background white
		pack .site_inp_dialog.checkbox4 -padx 10 -pady 10

        button .site_inp_dialog.ok -text "OK" -command {set ::FindNameInput [.site_inp_dialog.entry get]; set ::RepNameInput [.site_inp_dialog.entry1 get]; destroy .site_inp_dialog}
        pack .site_inp_dialog.ok -side left
        
        button .site_inp_dialog.cancel -text "Cancel" -command {set ::FindNameInput ""; destroy .site_inp_dialog}
        pack .site_inp_dialog.cancel -side right
        
        tkwait window .site_inp_dialog
        
        set FName $::FindNameInput
		set RName $::RepNameInput
		puts $FName
		puts $RName
		set selectedobjs [GetSelectedPMItems]
		set objlength [llength $selectedobjs]
		set lStatus [DboState]
		set lNullObj NULL
		
		if {$::parts} {
			puts "Part is selected"
			for {set j 0} {$j < $objlength} {incr j} {
				set lPage [lindex $selectedobjs $j]
				set lPageNameCS [DboTclHelper_sMakeCString]
				$lPage GetName $lPageNameCS
				set lPageName [DboTclHelper_sGetConstCharPtr $lPageNameCS]
				#puts $lPageName
				set PlIter [$lPage NewPartInstsIter $lStatus]  
				set lPart [$PlIter NextPartInst $lStatus] 
				while {$lPart != $lNullObj } { 
					set lRefDesCS [DboTclHelper_sMakeCString]
					$lPart GetReferenceDesignator $lRefDesCS
					set lRefdes [DboTclHelper_sGetConstCharPtr $lRefDesCS]
					#puts $lRefdes
					
					set lReferenceName [DboTclHelper_sMakeCString] 
					$lPart GetReference $lReferenceName
					set lReferenceNameS [DboTclHelper_sGetConstCharPtr $lReferenceName]
					#puts $lReferenceNameS
					
					set searchString "_S2"
					set replacementString "_S3"
					set modifiedString [string map [list $FName $RName] $lReferenceNameS]
					
					set upName [DboTclHelper_sMakeCString $modifiedString] 
					$lPart SetReference $upName
					#puts $modifiedString

				set lPart [$PlIter NextPartInst $lStatus]
				}
				delete_DboPagePartInstsIter $PlIter
			}
		}
		
		if {$::alias} {
			puts "Alias is selected"
			for {set k 0} {$k < $objlength} {incr k} {
				set lPage [lindex $selectedobjs $k]
				set lWireIter [$lPage NewWiresIter $lStatus]
				set lWire [$lWireIter NextWire $lStatus]
				while {$lWire!=$lNullObj} {
					set lAliasIter [$lWire NewAliasesIter $lStatus]
					set lAlias [$lAliasIter NextAlias $lStatus]
					while {$lAlias!=$lNullObj} {
						set Wname [DboTclHelper_sMakeCString]
						$lAlias GetName $Wname
						set WnameS [DboTclHelper_sGetConstCharPtr $Wname]
						#puts $WnameS
						set WsearchString "_S2"
						set WreplacementString "_S3"
						set WmodifiedString [string map [list $FName $RName] $WnameS]
						
						set WupName [DboTclHelper_sMakeCString $WmodifiedString] 
						$lAlias SetName $WupName
						set lAlias [$lAliasIter NextAlias $lStatus]
					}
					delete_DboWireAliasesIter $lAliasIter
					set lWire [$lWireIter NextWire $lStatus]
				}
				delete_DboPageWiresIter $lWireIter
			}
		}
		
		
		if {$::offpage} {
			puts "OffPage is selected"
			for {set l 0} {$l < $objlength} {incr l} {
				set lPage [lindex $selectedobjs $l]
				set OffIter [$lPage NewOffPageConnectorsIter $lStatus $::IterDefs_ALL] 
				set lOff [$OffIter NextOffPageConnector $lStatus] 
				while {$lOff != $lNullObj } { 
					set OffName [DboTclHelper_sMakeCString]
					$lOff GetName $OffName
					set lOffS [DboTclHelper_sGetConstCharPtr $OffName]
					#puts $lOffS
					set OsearchString "_S2"
					set OreplacementString "_S3"
					set OmodifiedString [string map [list $FName $RName] $lOffS]
					
					set OupName [DboTclHelper_sMakeCString $OmodifiedString] 
					$lOff SetName $OupName
					
				set lOff [$OffIter NextOffPageConnector $lStatus]
				}
				delete_DboPageOffPageConnectorsIter $OffIter
			}
		}
		
		if {$::port} {
			puts "Port is selected"
			for {set m 0} {$m < $objlength} {incr m} {
				set lPage [lindex $selectedobjs $m]
				set PortIter [$lPage NewPortsIter $lStatus] 
				set lPort [$PortIter NextPort $lStatus] 
				while {$lPort != $lNullObj } { 
					set PortName [DboTclHelper_sMakeCString]
					$lPort GetName $PortName
					set lPortS [DboTclHelper_sGetConstCharPtr $PortName]
					#puts $lPortS
					set PsearchString "_S2"
					set PreplacementString "_S3"
					set PmodifiedString [string map [list $FName $RName] $lPortS]
					
					set PupName [DboTclHelper_sMakeCString $PmodifiedString] 
					$lPort SetName $PupName
					
				set lPort [$PortIter NextPort $lStatus]
				}
				delete_DboPagePortsIter $PortIter
			}
		}
		
		if {$::global} {
			puts "Global is selected"
			for {set n 0} {$n < $objlength} {incr n} {
				set lPage [lindex $selectedobjs $n]
				set GlobalIter [$lPage NewGlobalsIter $lStatus] 
				set lGlobal [$GlobalIter NextGlobal $lStatus] 
				while {$lGlobal != $lNullObj } { 
					set GlobalName [DboTclHelper_sMakeCString]
					$lGlobal GetName $GlobalName
					set lGlobalS [DboTclHelper_sGetConstCharPtr $GlobalName]
					#puts $lGlobalS
					set GsearchString "_S2"
					set GreplacementString "_S3"
					set GmodifiedString [string map [list $FName $RName] $lGlobalS]
					
					set GupName [DboTclHelper_sMakeCString $GmodifiedString] 
					$lGlobal SetName $GupName
					
				set lGlobal [$GlobalIter NextGlobal $lStatus]
				}
				delete_DboPageGlobalsIter $GlobalIter
			}
		}
	}
} 
	

SiteNameChangeA::SiteNameChangeAfunc