extends Control

const System = preload('GMSystem.tscn')
const HyperLink = preload('GMjump.tscn')

const JumpZone = preload('../game/JumpZone.gd')

const look = [Vector3(-1, 2, 1) * 100, Vector3(0,250,0), Vector3(0,500,0)]
const up = [Vector3(0,1,0),Vector3(-1,0,0),Vector3(-1,0,0)]
const show_labels = [true, true, false]
var switch = 0

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
	var sys = "Sol"
	if Core.gameState and Core.gameState.playerShip:
		sys = Core.sectorsMgr.get(Core.gameState.playerShip.currentSector).system
	sys = Core.systemsMgr.get(sys)
	$Camera.look_at_from_position(A2V._3(sys.position) + look[switch], A2V._3(sys.position), up[switch])
	init()

func init():
	if sys.size() > 0:
		sys = {};
		for child in $Objects.get_children():
			NodeHelpers.queue_delete(child)

	var systems = Core.systemsMgr.get_systems()

	get_node('Camera').set_current(true)
	
	for name in systems.keys():
		var data = systems[name]
		var system = System.instance()
		system.translation = A2V._3(data.position);
		if Core.gameState and Core.gameState.playerShip:
			if Core.sectorsMgr.get(Core.gameState.playerShip.currentSector).system == data.ID:
				system.get_node("ActiveSystem").show()
		$Objects.add_child(system)
		system.connect('input_event', self, '_on_input_event', [data])
		
		var jump_to_systems = {}
		for sectorID in data.sectors:
			var sectorData = Core.sectorsMgr.get(sectorID)
			if 'jump_zones' in sectorData:
				for jz in sectorData['jump_zones']:
					jump_to_systems[Core.sectorsMgr.get(jz['jump_to']).system] = true
		for neighbor in jump_to_systems:
			var target = Core.systemsMgr.get(neighbor)
			var dir = A2V._3(target.position) - system.translation;
			var hl = HyperLink.instance()
			hl.look_at_from_position(system.translation, A2V._3(target.position), up[switch])
			hl.scale = Vector3(1,1,dir.length())
			$Objects.add_child(hl)
		
		var label = [Label.new(), data]
		label[0].text = name
		var pos = get_node('Camera').unproject_position(system.transform.origin)
		label[0].rect_position = pos
		label[0].visible = show_labels[switch]
		
		sys[system] = label
		$Objects.add_child(label[0])

func _on_input_event(a, input_event, c, d, e, system):
	if input_event.is_action_released('click_main'):
		emit_signal('system_selected', system)
		$Camera.look_at_from_position(A2V._3(system.position) + look[switch], A2V._3(system.position), up[switch])
		init()


#func _process(delta):
#	for lab in labels:
#		var pos = get_node('../Camera').unproject_position(lab[1].transform.origin)
#		lab[0].rect_position = pos
