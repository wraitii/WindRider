extends Spatial

var lightDir setget set_light_dir, get_light_dir

func set_light_dir(dir):
	get_node('Light').look_at(dir, Vector3(0,1,0))

func get_light_dir():
	return lightDir
