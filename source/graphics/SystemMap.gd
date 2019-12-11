extends Node

const Star = preload('../game/Star.tscn')

const Sector = preload('SMSector.tscn')
const SectorJumpZone = preload('SysMapJump.tscn')

var currentSystem = null

var scale = 1;

signal sector_selected(ID)

func on_sector_select(cam, inputEvent, a, b, c, ID):
	if not inputEvent.is_action_released('click_main'):
		return
	emit_signal("sector_selected", ID);

var temporary_nodes = []

func init(system):
	currentSystem = system
	for node in temporary_nodes:
		remove_child(node)
		temporary_nodes = []
	setup(Core.systemsMgr.get(system))
	
func setup(sysData):
	var distance = 0
	if 'stars' in sysData:
		for starData in sysData['stars']:
			var star = Star.instance()
			star.translation = A2V._3(starData['position']) / scale;
			distance = max(star.translation.length(), distance)
			add_child(star)
			temporary_nodes.append(star)
	if 'sectors' in sysData:
		for sectorID in sysData['sectors']:
			var sectorData = Core.sectorsMgr.get(sectorID)
			var sector = Sector.instance()
			sector.translation = A2V._3(sectorData['position']) / scale;
			label(sector.translation, sectorData.ID)
			distance = max(distance, sector.translation.length())
			sector.connect("input_event", self, "on_sector_select", [sectorID])
			add_child(sector)
			temporary_nodes.append(sector)
			if 'jump_zones' in sectorData:
				for jumpZoneData in sectorData['jump_zones']:
					add_jz(sysData, sectorData, jumpZoneData)	
#	get_node('../Camera').look_at_from_position(Vector3(-1,1,1) * distance * 2, Vector3(0,0,0), Vector3(0,1,0))

func label(pos, label):
	var labpos = Control.new()
	labpos.rect_position = get_node('Camera').unproject_position(pos)
	var lab = Label.new()
	lab.align = lab.ALIGN_CENTER
	lab.text = label
	lab.set_anchors_preset(lab.PRESET_CENTER, true)
	labpos.add_child(lab)
	add_child(labpos)
	temporary_nodes.append(labpos)

func add_jz(sysData, sectorData, jumpZoneData):
	var jz = SectorJumpZone.instance()
	var targetData = Core.sectorsMgr.get(jumpZoneData['jump_to'])
	if targetData.system == sectorData.system:
		jz.look_at_from_position(sectorData.position, targetData.position, Vector3(0,1,0))
		jz.scale_object_local(Vector3(3,3,25))
	else:
		var targetSystem = Core.systemsMgr.get(targetData.system)
		var tsp = A2V._3(targetSystem.position)
		var ssp = A2V._3(sysData.position)
		var dir = (tsp - ssp).normalized()
		jz.look_at_from_position(sectorData.position + dir * 25, dir*10000, Vector3(0,1,0))
		jz.scale_object_local(Vector3(10,10,30))
		label(sectorData.position + dir * 50, targetSystem.ID)
		jz.connect("input_event", self, "on_sector_select", [targetData.ID])
	add_child(jz)
	temporary_nodes.append(jz)
