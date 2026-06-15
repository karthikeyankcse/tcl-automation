package require Tk
wm withdraw .

namespace eval Library_AutoCreate {
    variable dirName [file dirname [info script]]
}

proc Library_AutoCreate::Library_AutoCreatefunc {} {
    set user_input [tk_messageBox -title "Library Auto Create" -message "Please Confirm to Run the Auto Library Creation Program ..!" -type okcancel -icon question -default ok -parent .]
    if {$user_input eq "ok"} {
        tk_messageBox -title "Library Auto Create" -message "Please Select The .CSV Input File ..!" -type ok -icon warning -parent .
        set filename [tk_getOpenFile \
                -title "Open CSV File" \
                -filetypes {{"CSV Files" {.csv}} {"All Files" {*}}} \
                -defaultextension ".csv"]

        if {$filename ne ""} {
            set fh [open $filename r]
            fconfigure $fh -encoding utf-8 -translation auto

            set InpPinList {}
            set SplitCount {}

            set isFirstLine 1
            while {[gets $fh line] >= 0} {
                if {$isFirstLine} {
                    if {[string first "\uFEFF" $line] == 0} {
                        set line [string range $line 1 end]
                    }
                    set isFirstLine 0
                }

                set line [string trim $line]

                if {$line ne ""} {
                    set cols [split $line ","]
                    
                    if {[llength $cols] >= 3} {
                        set colA [lindex $cols 0]
                        set colB [lindex $cols 1]
                        set colC [lindex $cols 2]

                        set combined "$colA,$colB,$colC"
                        lappend InpPinList $combined
                        lappend SplitCount $colA
                    }
                }
            }

            close $fh

            set SplitCount [lsort -integer -unique $SplitCount]
            set SplitMaxCount [lindex [lsort -integer $SplitCount] end]

            puts $SplitMaxCount
			
			array set groups {}

			foreach item $InpPinList {
				set fields [split $item ","]
				set key [lindex $fields 0]
				lappend groups($key) $item
			}

			set UpdatedList {}

			foreach key [lsort -integer [array names groups]] {
				set groupItems $groups($key)
				set count [llength $groupItems]
				set leftCount [expr {int(ceil($count / 2.0))}]
				
				for {set i 0} {$i < $count} {incr i} {
					set side [expr {$i < $leftCount ? "Left" : "Right"}]
					set newItem "[lindex $groupItems $i],$side"
					lappend UpdatedList $newItem
				}
			}

			
			set PartName "Lib_Auto_Create"
			set RefName "U"
			set RefNum "0"
			
			set current_directory [pwd]
			set Filepath [string map {/ \\\\} $current_directory]
			set outString "${Filepath}\\\\AUTO_CREATE_LIBRARY.OLB"
			
			set FinalList [list]
			set Pass [list $PartName $SplitMaxCount $RefName $RefNum]
			lappend FinalList $Pass
			
			foreach InpPinListlp $UpdatedList {
				set CrctPNum [lindex [split $InpPinListlp ","] 2]
				set CrctPName [lindex [split $InpPinListlp ","] 1]
				set CrctPType "Passive"
				set CrctPVisibility "1"
				set CrctPLine "Line"
				set CrctPGrp "5"
				set CrctPPage [lindex [split $InpPinListlp ","] 0]
				set CrctPSide [lindex [split $InpPinListlp ","] 3]
				set PassList [list $CrctPNum $CrctPName $CrctPType $CrctPVisibility $CrctPLine $CrctPGrp $CrctPSide $CrctPPage]
				lappend FinalList $PassList
			}
			
			set parts_data1 [list $FinalList]
			capCreatePartsFromData "false" $outString $parts_data1
			tk_messageBox -title "Library Auto Create" -message "Part Created Successfully..!" -type ok -icon warning -parent .
			
        } else {
			tk_messageBox -title "Library Auto Create" -message "No File Selected..!" -type ok -icon warning -parent .
		}
    }
}



Library_AutoCreate::Library_AutoCreatefunc
