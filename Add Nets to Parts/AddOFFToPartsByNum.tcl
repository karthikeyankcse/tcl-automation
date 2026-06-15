package require Tcl 8.4
#package require DboTclWriteBasic 16.3.0
# package provide capGUIUtilsOffByNum 1.0
 
namespace eval ::capGUIUtilsOffByNum {
    # namespace export capAddNetsToPartOffByNumEnablerNum
    # namespace export capAddNetsToPartOffByNum
 
    RegisterAction "Add OFF To Part By Number" "::capGUIUtilsOffByNum::capAddNetsToPartOffByNumEnablerNum" "" "::capGUIUtilsOffByNum::capAddNetsToPartOffByNum" "Schematic"
}
 
proc ::capGUIUtilsOffByNum::capAddNetsToPartOffByNumEnablerNum {} {
    set lEnableAdd 0
    # Get the selected objects
    set lSelObjs [GetSelectedObjects]
 
    # Enable only for single object selection
    if { [llength $lSelObjs] == 1 } { 
        # Enable only if a part or a hierarchical block is selected 
        set lObj [lindex $lSelObjs 0] 
        set lObjType [DboBaseObject_GetObjectType $lObj] 
        puts "objType: $lObjType"
        if { $lObjType == 13} { 
            set lEnableAdd 1 
        } 
    } 
            
    return $lEnableAdd
}
 
proc ::capGUIUtilsOffByNum::capAddNetsToPartOffByNum {} {    
    set lPage [GetActivePage]
    set lUnits [$lPage GetIsMetric]
    if { $lUnits } {
        capDisplayMessageBox "Page Units inch" "Error"
        return
    }
    
    set lStatus [DboState]
    set lNullObj NULL
    
    set lSelObjs [GetSelectedObjects]
    set lInst [lindex $lSelObjs 0] 
    
    set lIter [$lInst NewPinsIter $lStatus] 
 
    #get the first pin of the part 
    set lPin [$lIter NextPin $lStatus] 
 
    while {$lPin != $lNullObj } { 
        #placeholder: do your processing on $lPin 
        ::capGUIUtilsOffByNum::capAddNetToPin $lPin
 
        #get the next pin of the part 
        set lPin [$lIter NextPin $lStatus] 
    } 
    delete_DboPartInstPinsIter $lIter 
}
 
proc ::capGUIUtilsOffByNum::capAddNetToPin {lPin} {    
    set lStatus [DboState]
    set lNullObj NULL
    set lWireLength 0.5
    

    set lWire [$lPin GetWire $lStatus]
    puts "lWire：$lWire"
    if {$lWire != $lNullObj} {
        return
    }
    

    set lPinNum [DboTclHelper_sMakeCString]
    $lPin GetPinNumber $lPinNum
    set lPinNum [DboTclHelper_sGetConstCharPtr $lPinNum]
    puts "lPinNum: $lPinNum"
    

    set lStatus [DboState]
    set lStartPoint [$lPin GetOffsetStartPoint $lStatus]
    set lStartPointX [expr [DboTclHelper_sGetCPointX $lStartPoint]/100.0]
    set lStartPointY [expr [DboTclHelper_sGetCPointY $lStartPoint]/100.0]
    puts "Start: $lStartPointX , $lStartPointY"
    

    set lHotSpotPoint [$lPin GetOffsetHotSpot $lStatus]
    set lHotSpotPointX [expr [DboTclHelper_sGetCPointX $lHotSpotPoint]/100.0]
    set lHotSpotPointY [expr [DboTclHelper_sGetCPointY $lHotSpotPoint]/100.0]
    puts "HotSpotPointY: $lHotSpotPointX , $lHotSpotPointY"
    
 
 

    set CreateLoc "DummyVal"
	set offsetX 0
	set offsetY 0
	if {$lHotSpotPointX > $lStartPointX} {
		set offsetX $lWireLength
		set CreateLoc "OFFPAGELEFT"
	} elseif {$lHotSpotPointX < $lStartPointX} {
		set offsetX [expr -$lWireLength]
		set CreateLoc "OFFPAGERIGHT"
	}
	if {$lHotSpotPointY > $lStartPointY} {
		set offsetY $lWireLength
	} elseif {$lHotSpotPointY < $lStartPointY} {
		set offsetY [expr -$lWireLength]
	}    
	puts "offset: $offsetX , $offsetY"
	PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX+$offsetX] [expr $lHotSpotPointY+$offsetY]
	#PlaceNetAlias [expr $lHotSpotPointX+$offsetX/2] [expr $lHotSpotPointY+$offsetY/2] $lPinNum
	
	set OffXloc [expr $lHotSpotPointX+$offsetX]
	set OffYloc [expr $lHotSpotPointY+$offsetY]
	set OffXlocup [expr $OffXloc-0.1]
	set OffYlocUp [expr $OffYloc-0.1]
	
	if {$CreateLoc == "OFFPAGELEFT"} {
		PlaceOffPage $OffXloc $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGELEFT-L.OLB" "OFFPAGELEFT-L" $lPinNum
	} elseif {$CreateLoc == "OFFPAGERIGHT"} {
		PlaceOffPage $OffXlocup $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGERIGHT-R.OLB" "OFFPAGERIGHT-R" $lPinNum
	} else {
		puts "OLB File Missing Please Check"
	}
    
    if {$offsetY != 0} {
        set lWire [$lPin GetWire $lStatus]
        set lAliasIter [$lWire NewAliasesIter $lStatus] 
        #get the first alias of wire  
        set lAlias [$lAliasIter NextAlias $lStatus] 
        $lAlias SetRotation 3
        delete_DboWireAliasesIter $lAliasIter
    }
	}