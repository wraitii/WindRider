extends Spatial

var systemName : String;

const Star = preload('Star.tscn')
const Landable = preload('Landable.tscn')

func init(systemData):
	systemName = systemData.name;
	_parse_stars(systemData)
	_parse_landables(systemData)
	pass

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

	for landableDef in sysData['landables']:
		var landable = Landable.instance()
		self.add_child(landable)
		var pos = landableDef['position']
		landable.translate(Vector3(pos[0],pos[1],pos[2]))
		landable.scale_object_local(Vector3(10,10,10))