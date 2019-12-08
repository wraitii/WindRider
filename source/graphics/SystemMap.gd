extends Node

const Star = preload('../game/Star.tscn')

const Sector = preload('SMSector.tscn')

var currentSystem = null

var scale = 100;

func _enter_tree():
	init('Sol')

func init(system):
	currentSystem = system
	Core.societyMgr.populate()
	Core.landablesMgr.populate()
	Core.sectorsMgr.populate()
	Core.systemsMgr.populate()
	setup(Core.systemsMgr.get_source(system))
	
func setup(sysData):
	var distance = 0

	if 'stars' in sysData:
		for starData in sysData['stars']:
			var star = Star.instance()
			star.translation = A2V._3(starData['position']) / scale;
			distance = star.translation.length()
			add_child(star)
	if 'sectors' in sysData:
		for sectorData in sysData['sectors']:
			var sector = Sector.instance()
			sector.translation = A2V._2y0(sectorData['position']) / scale;
			distance = sector.translation.length()
			add_child(sector)
	get_node('../Camera').look_at_from_position(Vector3(1,1,1) * distance * 2, Vector3(0,0,0), Vector3(0,1,0))
