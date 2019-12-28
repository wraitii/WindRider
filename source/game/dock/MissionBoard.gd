extends Panel

var character
var landable

func init(l):
	landable = l
	
	character = Core.gameState.player

func _ready():
	_generate_missions()
	$Tree.connect("item_selected", self, '_on_select')
	$Tree.connect("nothing_selected", self, '_on_noselect')

func _on_select():
	$Accept.disabled = !$Tree.get_selected().get_meta("acceptable")

func nothing_selected():
	$Accept.disabled = true

func _input(event):
	if event.is_action_released("default_escape_action"):
		accept_event()
		visible = false

func _generate_missions():
	var rootMissions = $Tree.create_item()
	## TODO: generate missions for local characters too.
	for trig in Core.missionsMgr.triggers:
		if !Core.missionsMgr.can_show(trig, landable.administrator, character):
			continue
		
		var miss = Core.missionsMgr.create_resource({
			'type': trig.type,
			'from': landable,
			'potential_carrier': character
		})
		# This mission apparently still couldn't be carried out, skip.
		if !miss:
			continue

		var item = $Tree.create_item(rootMissions)
		item.set_text(0, miss.mission_title)
		item.set_meta("mission", miss)
		item.set_meta("acceptable", true)
		item.set_selectable(0, true)

func _on_accept():
	var sel = $Tree.get_selected()
	sel.set_selectable(0, false)
	sel.deselect(0)
	nothing_selected()
	var miss = sel.get_meta("mission")
	miss.custodian = character
	miss.on_accept(self)
