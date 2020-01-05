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

	nothing_selected()

func _on_select():
	$Accept.disabled = !$Tree.get_selected().get_meta("acceptable")
	var miss = $Tree.get_selected().get_meta("mission")
	$Description.text = miss.description

func nothing_selected():
	$Accept.disabled = true
	$Description.text = "Select a mission above to read the requirements."

func _input(event):
	if event.is_action_released("default_escape_action"):
		accept_event()
		visible = false

func _generate_missions():
	var rootMissions = $Tree.create_item()
	## TODO: generate missions for local characters too.
	
	# TODO: use a dynamic number to not replenish every time.
	var baseNeed = landable.administrator.stats['mission_cap']
	baseNeed -= landable.administrator.missionCooldown
	if baseNeed <= 0:
		return

	# To generate missions for a character:
	# we get N = how many missions they want
	# We K = count * 100 the number of available triggers
	# We throw up to K N times, where it ends up we trigger.
	var total_proba = 0
	var weights = {}
	var trigs = {}

	for trigID in Core.missionsMgr.triggers:
		var trig = Core.missionsMgr.triggers[trigID]

		if !Core.missionsMgr.can_show(trig, landable.administrator, character):
			continue
		weights[trigID] = trig['proba']
		trigs[trigID] = trig
		total_proba += 100
	
	var rng = RandomNumberGenerator.new()
	var i = 0
	while i < baseNeed * 100:
		i += 100
		var trig = null
		var throw = rng.randi_range(0, total_proba - 1)
		var rs = 0
		for trigID in weights:
			rs += weights[trigID]
			if rs > throw:
				trig = trigs[trigID]
				# Special case to let some corner-case overrul, but not too mucH
				if weights[trigID] > 100:
					weights[trigID] -= 100
					i -= 100
				break

		if trig == null:
			continue

		# TODO: overcome laziness
		var trigData = {}
		if 'data' in trig:
			trigData = trig.data
		
		var miss = Core.missionsMgr.create_resource({
			'type': trig.type,
			'data': trigData,
			'provider': landable.administrator,
			'from': landable,
			'potential_carrier': character
		})

		# This mission apparently still couldn't be carried out, skip.
		if !miss:
			continue
		landable.administrator.missionCooldown += 1

func _show_missions():
	## TODO: show missions of other characters
	for mission in landable.administrator.providingMissions:
		var item = $Tree.create_item(mission)
		item.set_text(0, mission.missionTitle)
		item.set_meta("mission", mission)
		item.set_meta("acceptable", mission.custodian == null)
		item.set_selectable(0, mission.custodian == null)
		if mission.custodian:
			item.set_text(0, mission.missionTitle + ' (accepted)')

func _on_accept():
	var sel = $Tree.get_selected()
	sel.set_selectable(0, false)
	sel.deselect(0)
	nothing_selected()
	var miss = sel.get_meta("mission")
	miss.custodian = character
	miss.on_accept(self)

	_show_missions()
