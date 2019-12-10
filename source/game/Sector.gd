extends Spatial

const Star = preload('Star.tscn')
const JumpZone = preload('JumpZone.tscn')
const Sky = preload('res://data/art/system_skies/SystemSky.tscn')

var ID;

func init(sectorID):
	ID = sectorID;
	var sectorData = Core.sectorsMgr.get(ID)
	_parse_stars(sectorData)
	_parse_landables(sectorData)
	_parse_jump_zones(sectorData)
	return self

func _exit_tree():
	# Since for now I'm fetching landables, I have to unparent them.
	NodeHelpers.remove_all_children(self)

func _parse_stars(sectorData):
	var systemData = Core.systemsMgr.get(sectorData['system'])
	if !("stars" in systemData):
		return

	for starDef in systemData['stars']:
		var star = Star.instance()
		self.add_child(star)
		var pos = starDef['position']
		star.translate(Vector3(pos[0],pos[1],pos[2]))
		star.scale_object_local(Vector3(100,100,100))

func _parse_landables(sysData):
	if !("landables" in sysData):
		return

	for landableID in sysData['landables']:
		var landable = Core.landablesMgr.get(landableID)
		landable.sectorID = ID;
		self.add_child(landable)

func _parse_jump_zones(sysData):
	if !("jump_zones" in sysData):
		return

	for jsd in sysData['jump_zones']:
		var jumpZone = JumpZone.instance()
		jumpZone.init(self, jsd)
		self.add_child(jumpZone)

