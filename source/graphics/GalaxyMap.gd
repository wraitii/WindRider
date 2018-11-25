extends Spatial

const System = preload('GMSystem.tscn')
const HyperLink = preload('GMjump.tscn')

### Galaxy Map
## This file is responsible for graphics of the galaxy map

signal system_selected(system)

var sys = {}

func _init():
	InputMap.add_action('galaxy_map_click')
	var event = InputEventMouseButton.new()
	event.button_index = BUTTON_LEFT
	InputMap.action_add_event('galaxy_map_click', event)
	
func _enter_tree():
	init()
	
func init():
	if sys.size() > 0:
		sys = {};
		for child in get_children():
			remove_child(child);

	var systems = Core.systemsMgr.get_systems()
	
	get_node('../Camera').current = true
	
	for name in systems.keys():
		var data = systems[name]
		var system = System.instance()
		system.translation = A2V._3(data.position);
		add_child(system)
		if 'jump_zones' in data:
			for jz in data['jump_zones']:
				var target = Core.systemsMgr.get(jz['name'])
				var dir = A2V._3(target.position) - A2V._3(data.position);
				var hl = HyperLink.instance()
				hl.look_at_from_position(system.translation, dir.normalized(), Vector3(0,1,0))
				hl.scale = Vector3(1,1,dir.length())
				add_child(hl)
		
		var label = [Label.new(), data]
		label[0].text = name
		var pos = get_node('../Camera').unproject_position(system.transform.origin)
		label[0].rect_position = pos
		
		sys[system] = label
		add_child(label[0])

func _physics_process(delta):
	if Input.is_action_just_released('galaxy_map_click'):
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_from = get_node('../Camera').project_ray_origin(mouse_pos)
		var ray_to = ray_from + get_node('../Camera').project_ray_normal(mouse_pos) * 1000
		var space_state = get_world().direct_space_state
		var selection = space_state.intersect_ray(ray_from, ray_to)

		if 'collider' in selection:
			emit_signal('system_selected', sys[selection.collider][1])
	
#func _process(delta):
#	for lab in labels:
#		var pos = get_node('../Camera').unproject_position(lab[1].transform.origin)
#		lab[0].rect_position = pos
