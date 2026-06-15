SetOptionBool Journaling True
package require Tk
namespace eval SiteNetListCompare {} {
	
	variable dirName [file dirname [info script]]
}

proc SiteNetListCompare::SiteNetListComparefunc {} {
	set user_input [tk_messageBox -title "Site Compare" -message "Please Confirm to Compare Sites..!" -type okcancel -icon question -default ok -parent .]
	if {$user_input eq "ok"} {
		toplevel .site_inp_dialog 
        wm title .site_inp_dialog "Site Compare"
        
        label .site_inp_dialog.prompt -text "Common Value:"
        pack .site_inp_dialog.prompt -side top
        
        entry .site_inp_dialog.entry -width 20
        pack .site_inp_dialog.entry -side top
        
		label .site_inp_dialog.prompt1 -text "No of Sites:"
        pack .site_inp_dialog.prompt1 -side top
        
        entry .site_inp_dialog.entry1 -width 20
        pack .site_inp_dialog.entry1 -side top
		
        button .site_inp_dialog.ok -text "OK" -command {set ::CommonValue [.site_inp_dialog.entry get]; set ::NoOfSites [.site_inp_dialog.entry1 get]; destroy .site_inp_dialog}
        pack .site_inp_dialog.ok -side left
        
        button .site_inp_dialog.cancel -text "Cancel" -command {set ::CommonValue ""; destroy .site_inp_dialog}
        pack .site_inp_dialog.cancel -side right
        
        tkwait window .site_inp_dialog
        
        set Cval $::CommonValue
		set SName $::NoOfSites
		set SiteListDt [list]
		for {set i 1} {$i <= $SName} {incr i} {
			set pos [string first "*" $Cval]
			set tempVal [string replace $Cval $pos $pos $i]
			lappend SiteListDt $tempVal
		}
		set fp [open "input.txt" r]
		set NetListDt [list]
		while { [gets $fp data] >= 0 } {
			set data [string toupper $data]
			lappend NetListDt $data
		}
		close $fp
		
		set UpdateList [list]
		set MissList [list]
		foreach SiteListDtlp $SiteListDt {
			foreach NetListDtlp $NetListDt {
				regsub -all $SiteListDtlp $NetListDtlp $Cval new_string
				if {[string first "*" $new_string] != -1} {
					set new_string [string trimright $new_string]
					lappend UpdateList $new_string
					lappend MissList $NetListDtlp
				} 
			}
		}
		array set count_array {}
		foreach item $UpdateList {
			if {[info exists count_array($item)]} {
				incr count_array($item)
			} else {
				set count_array($item) 1
			}
		}

		foreach {value count} [array get count_array] {
			if {$count != $SName} {
				puts "Error: $value Found in only $count instead of $SName Sites...!"
			}
		}
		
		set non_members_list1 {}
		foreach item1 $NetListDt {
			if {[lsearch -exact $MissList $item1] == -1} {
				lappend non_members_list1 $item1
			}
		}
		
		foreach non_members_list1lp $non_members_list1 {
			puts "Error: $non_members_list1lp Site Name is Missing or Wrong...!"
		}
	}
} 
	

SiteNetListCompare::SiteNetListComparefunc