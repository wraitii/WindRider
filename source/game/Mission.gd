extends Reference

## Mission-data holder, similar to Nova or Endless Sky missions.
## These hold all narratives.

var type = "GenericMission"
# Auto-generated
var ID

func init(_data):
	return

func finish():
	Core.missionsMgr.unregister(ID)
