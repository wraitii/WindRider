extends Spatial

#const Star = preload('Star.tscn')
#const JumpZone = preload('JumpZone.tscn')
#const Sky = preload('res://data/art/system_skies/SystemSky.tscn')

var ID : String;
var position : Vector3
#var sky = null;

func init(systemData):
	ID = systemData.ID;
	position = A2V._3(systemData.position)
	#_parse_stars(sectorData)
	#_parse_landables(sectorData)
	#_parse_jump_zones(sectorData)
	pass

func _enter_tree():
	pass
	#sky = Sky.instance()
	#add_child(sky)

func _exit_tree():
	pass
	#remove_child(sky);
	#sky = null;
