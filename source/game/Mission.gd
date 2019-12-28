extends Reference

## Mission-data holder, similar to Nova or Endless Sky missions.
## These hold all narratives.

var type = "GenericMission"

# Auto-generated
var ID

# Used to show in the mission board and the player ongoing missions.
var mission_title = "Generic Mission"
# must be a character
var custodian = null setget set_custodian, get_custodian

func set_custodian(c):
	if c != null:
		c.missions.append(self)
	elif custodian != null:
		custodian.missions.erase(self)
	custodian = c

func get_custodian():
	return custodian

## Not intended to be overloaded, or at least parent must be called at the end.
func finish():
	if custodian:
		custodian.missions.erase(self)
	Core.missionsMgr.call_deferred("_unregister", self)

#### These are intended to be overloaded

func init(_data):
	return

func on_accept(parentScene):
	start()

func start():
	pass

func should_serialize():
	return true

func serialize():
	return {
		'ID': ID,
		'type': type,
		'custodian': custodian.ID
	}

func deserialize(d):
	ID = d['ID']
	type = d['type']
	if d['custodian']:
		custodian = Core.societyMgr.get(d['custodian'])
		custodian.missions.append(self)
