extends Node

## Mission-data holder, similar to Nova or Endless Sky missions.
## These hold all narratives.

func _finish():
	NodeHelpers.queue_delete(self)
