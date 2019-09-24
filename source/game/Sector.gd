extends Spatial

const Star = preload('Star.tscn')
const JumpZone = preload('JumpZone.tscn')
const Sky = preload('res://data/art/system_skies/SystemSky.tscn')

var ID : String;
var position : Vector3
var sky = null;

func init(sectorData):
	ID = sectorData.ID;
	position = A2V._3(sectorData.position)
	_parse_stars(sectorData)
	_parse_landables(sectorData)
	_parse_jump_zones(sectorData)
	pass

func _enter_tree():
	pass
	#sky = Sky.instance()
	#add_child(sky)

func _exit_tree():
	pass
	#remove_child(sky);
	#sky = null;

func _parse_stars(sysData):
	if !("stars" in sysData):
		return

	for starDef in sysData['stars']:
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
		self.add_child(landable)
		landable.sector = self;

func _parse_jump_zones(sysData):
	if !("jump_zones" in sysData):
		return

	for jsd in sysData['jump_zones']:
		var jumpZone = JumpZone.instance()
		jumpZone.init(self, jsd)
		self.add_child(jumpZone)

