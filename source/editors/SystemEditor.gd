extends Node

func _enter_tree():
	Core.systemsMgr.populate()
	Core.sectorsMgr.populate()
	$SystemMap.get_node('Camera').set_current(true)
	$SystemMap.get_node("MapScript").init("Sol")
