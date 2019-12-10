extends Control

const System = preload('GMSystem.tscn')
const HyperLink = preload('GMjump.tscn')

const JumpZone = preload('../game/JumpZone.gd')

### Galaxy Map
## This file is responsible for graphics of the galaxy map

signal system_selected(systemData)

var sys = {}

func _init():
	InputMap.add_action('galaxy_map_click')
	var event = InputEventMouseButton.new()
	event.button_index = BUTTON_LEFT
	InputMap.action_add_event('galaxy_map_click', event)
	
func _ready():
	init()
	
func init():
	if sys.size() > 0:
		sys = {};
		for child in get_children():
			remove_child(child);

	Core.societyMgr.populate()
	Core.landablesMgr.populate()
	Core.systemsMgr.populate()

	var systems = Core.systemsMgr.get_systems()

	get_node('Camera').set_current(true)
	
	for name in systems.keys():
		var data = systems[name]
		var system = System.instance()
		system.translation = A2V._3(data.position);
		add_child(system)
		system.connect('input_event', self, '_on_input_event', [data])
		for jz in data.get_children():
			if jz is JumpZone:
				var target = Core.systemsMgr.get(jz.jumpTo)
				var dir = A2V._3(target.position) - system.translation;
				var hl = HyperLink.instance()
				hl.look_at_from_position(system.translation, A2V._3(target.position), Vector3(0,1,0))
				hl.scale = Vector3(1,1,dir.length())
				add_child(hl)
		
		var label = [Label.new(), data]
		label[0].text = name
		var pos = get_node('Camera').unproject_position(system.transform.origin)
		label[0].rect_position = pos
		
		sys[system] = label
		add_child(label[0])

func _on_input_event(a, input_event, c, d, e, system):
	if input_event.is_action_released('click_main'):
		emit_signal('system_selected', system)

#func _process(delta):
#	for lab in labels:
#		var pos = get_node('../Camera').unproject_position(lab[1].transform.origin)
#		lab[0].rect_position = pos
