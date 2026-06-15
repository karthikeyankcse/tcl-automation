package require Tcl 8.4
#package require DboTclWriteBasic 16.3.0
# package provide capGUIUtilsHBByName 1.0
 
namespace eval ::capGUIUtilsHBByName {
    # namespace export capAddNetsToHBByNameEnabler
    # namespace export capAddNetsToHBByName
 
    RegisterAction "Add OFF Nets To HBlock By Name With Site Num" "::capGUIUtilsHBByName::capAddNetsToHBByNameEnabler" "" "::capGUIUtilsHBByName::capAddNetsToHBByName" "Schematic"
}
 
proc ::capGUIUtilsHBByName::capAddNetsToHBByNameEnabler {} {
	set lEnableDS 0
    # Get the selected objects
    set lSelObjs [GetSelectedObjects]

    # Enable only for single object selection
    if { [llength $lSelObjs] == 1 } {
        # Enable only if a part or a hierarchical block is selected
        set lObj [lindex $lSelObjs 0]
        set lObjType [DboBaseObject_GetObjectType $lObj]
	
	if { $lObjType == 12 || $lObjType == 13 } {
            set lEnableDS 1
        }
            

    }
    return $lEnableDS
}
 
proc ::capGUIUtilsHBByName::capAddNetsToHBByName {} {    
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
        ::capGUIUtilsHBByName::capAddNetToPin $lPin
 
        #get the next pin of the part 
        set lPin [$lIter NextPin $lStatus] 
    } 
    delete_DboPartInstPinsIter $lIter 
}
 
proc ::capGUIUtilsHBByName::capAddNetToPin {lPin} {
    set lStatus [DboState]
    set lNullObj NULL
    set lWireLength 0.2
	set lWire [$lPin GetWire $lStatus]
    #puts "lWire：$lWire"
    if {$lWire != $lNullObj} {
        return
    }
    set lPinName [DboTclHelper_sMakeCString]
    $lPin GetPinName $lPinName
    set lPinName [DboTclHelper_sGetConstCharPtr $lPinName]
    #puts "lPinName: $lPinName"
	
	set lStatus [DboState]
    set lStartPoint [$lPin GetStartPoint $lStatus]
    set lStartPointX [expr [DboTclHelper_sGetCPointX $lStartPoint]/100.0]
    set lStartPointY [expr [DboTclHelper_sGetCPointY $lStartPoint]/100.0]
    #puts "Start: $lStartPointX , $lStartPointY"
    

    set lHotSpotPoint [$lPin GetOffsetHotSpot $lStatus]
    set lHotSpotPointX [expr [DboTclHelper_sGetCPointX $lHotSpotPoint]/100.0]
    set lHotSpotPointY [expr [DboTclHelper_sGetCPointY $lHotSpotPoint]/100.0]
    #puts "HotSpotPointY: $lHotSpotPointX , $lHotSpotPointY"
	
	set CreateLoc "DummyVal"
	set offsetX 0
	set offsetY 0
	if {$lStartPointX == 0.0 } {
		set offsetX $lWireLength
		set CreateLoc "OFFPAGERIGHT"
	} else {
		set offsetX [expr -$lWireLength]
		set CreateLoc "OFFPAGELEFT"
	}
    PlaceWire $lHotSpotPointX $lHotSpotPointY [expr $lHotSpotPointX-$offsetX] [expr $lHotSpotPointY]
	
	set OffXloc [expr $lHotSpotPointX-$offsetX]
	set OffYloc [expr $lHotSpotPointY]
	set OffXlocup [expr $OffXloc-0.1]
	set OffYlocUp [expr $OffYloc-0.1]
	
	set lPartInst [$lPin GetOwner]
	set lRefDesCS [DboTclHelper_sMakeCString]
	$lPartInst GetReferenceDesignator $lRefDesCS
	set lRefdes [DboTclHelper_sGetConstCharPtr $lRefDesCS]
	set OffName "${lRefdes}_${lPinName}"
	
	if {$CreateLoc == "OFFPAGELEFT"} {
		PlaceOffPage $OffXloc $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGELEFT-L.OLB" "OFFPAGELEFT-L" $OffName
	} elseif {$CreateLoc == "OFFPAGERIGHT"} {
		PlaceOffPage $OffXlocup $OffYlocUp "\\\\sng-psrvr06\\Cadence_Skills\\Pactron-tcl\\OFFPAGERIGHT-R.OLB" "OFFPAGERIGHT-R" $OffName
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