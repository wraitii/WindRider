extends Spatial

var ID : String;

const Star = preload('Star.tscn')
const Landable = preload('Landable.tscn')
const JumpZone = preload('JumpZone.tscn')

func init(systemData):
	ID = systemData.ID;
	_parse_stars(systemData)
	_parse_landables(systemData)
	_parse_jump_zones(systemData)
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
		landable.init(landableDef['ID'])

		self.add_child(landable)
		var pos = landableDef['position']
		landable.translate(Vector3(pos[0],pos[1],pos[2]))
		landable.scale_object_local(Vector3(10,10,10))

func _parse_jump_zones(sysData):
	if !("jump_zones" in sysData):
		return

	for jsd in sysData['jump_zones']:
		var pos = jsd['position']
		var jumpTo = Core.systemsMgr.get(jsd['ID'])
		if !jumpTo: pass

		var jumpZone = JumpZone.instance()
		
		var dir = A2V._3(jumpTo['position']) - A2V._3(sysData['position'])
		dir = dir.normalized()
		
		var up_dir = Vector3(0, 1, 0)
		if dir == up_dir:
			up_dir = Vector3(-1,0,0)

		jumpZone.look_at_from_position(Vector3(pos[0],0.0,pos[1]), dir, up_dir)
		# pretend systems are XY, not XZ aligned
		jumpZone.rotate_object_local(Vector3(1,0,0),PI/2.0)

		jumpZone.init(jumpTo)
		jumpZone.direction = dir

		self.add_child(jumpZone)

