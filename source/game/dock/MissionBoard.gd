extends Panel

var character
var landable

func init(l):
	landable = l
	
	character = Core.gameState.player

func _ready():
	_generate_missions()
	_show_missions()

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
	
	var need = landable.administrator.stats['mission_cap']
	need -= len(landable.administrator.providing_missions)

	while need > 0:
		var best = 0
		var bestTrig = null
		var rng = RandomNumberGenerator.new()
		for trig in Core.missionsMgr.triggers:
			if !Core.missionsMgr.can_show(trig, landable.administrator, character):
				continue

			var try = rng.randi_range(0, trig['proba'])
			if try > best:
				bestTrig = trig
				best = try

		if bestTrig == null:
			break

		var miss = Core.missionsMgr.create_resource({
			'type': bestTrig.type,
			'provider': landable.administrator,
			'from': landable,
			'potential_carrier': character
		})

		# This mission apparently still couldn't be carried out, skip.
		if !miss:
			continue

		need -= 1

func _show_missions():
	## TODO: show missions of other characters
	for mission in landable.administrator.providing_missions:
		var item = $Tree.create_item(mission)
		item.set_text(0, mission.mission_title)
		item.set_meta("mission", mission)
		item.set_meta("acceptable", mission.custodian == null)
		item.set_selectable(0, mission.custodian == null)
		if mission.custodian:
			item.set_text(0, mission.mission_title + ' (accepted)')

func _on_accept():
	var sel = $Tree.get_selected()
	sel.set_selectable(0, false)
	sel.deselect(0)
	nothing_selected()
	var miss = sel.get_meta("mission")
	miss.custodian = character
	miss.on_accept(self)

	_show_missions()
