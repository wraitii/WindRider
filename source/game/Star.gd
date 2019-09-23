extends Spatial

func _enter_tree():
	get_node('Light').look_at(-translation, Vector3(0,1,0))