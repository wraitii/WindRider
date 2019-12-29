extends "res://source/game/Mission.gd"

## This wraps basic functionality for all 'deliver from A to B' mission-types.
## This could be used as-is, but the intent is that missions types
## will want some custom logic now and then so it can also be extended.

var from_landable
var to_ID

func init(d):
	type = "CommonDelivery"
	from_landable = d.from
	
	determine_target()
	
	mission_title = "Shipment to " + to_ID
	
	return self

func should_serialize():
	return custodian != null

func serialize():
	var ret = .serialize()
	ret['title'] = mission_title
	ret['from'] = from_landable.ID
	ret['to'] = to_ID
	return ret

func deserialize(d):
	.deserialize(d)
	mission_title = d['title']
	from_landable = Core.landablesMgr.get(d['from'])
	to_ID = d['to']
	if custodian:
		_watch()

func determine_target():
	## TODO: determine a friendly system to go to.
	## (or not, we could have a bunch of variants)
	var sec = Core.sectorsMgr.get(from_landable.sectorID)
	if !('jump_zones' in sec):
		return null
	var i = randi() % len(sec['jump_zones'])
	var sector_to = Core.sectorsMgr.get(sec['jump_zones'][i]['jump_to'])
	
	if !('landables' in sector_to):
		return null
	i = randi() % len(sector_to['landables'])
	to_ID = sector_to['landables'][i]

const EventPopup = preload('res://source/gui/EventPopup.tscn')

func on_accept(scene):
	var sc = EventPopup.instance()
	sc.get_node('Title').text = mission_title
	sc.get_node('Text').text = "Your mission, should you accept it, is to finish this text."
	sc.anchor_left = 0.2
	sc.anchor_right = 0.8
	sc.anchor_top = 0.2
	sc.anchor_bottom = 0.8
	sc.connect("event_ok_pressed", self, "_start")
	scene.add_child(sc)

func _start(popup):
	NodeHelpers.queue_delete(popup)
	start()

func start():
	_watch()

func _watch():
	if !custodian.ship:
		return
	custodian.ship.connect('docked', self, '_on_docked')

func _on_docked(ship):
	if ship.dockedAt != to_ID:
		return

	custodian.credits += 5000

	var sc = EventPopup.instance()
	sc.get_node('Title').text = mission_title
	sc.get_node('Text').text = "You have completed the mission. Credits + 5000"
	sc.anchor_left = 0.2
	sc.anchor_right = 0.8
	sc.anchor_top = 0.2
	sc.anchor_bottom = 0.8
	sc.connect("event_ok_pressed", self, "_finish")
	Core.gameState.currentScene.add_child(sc)

func _finish(popup):
	NodeHelpers.queue_delete(popup)
	finish()
