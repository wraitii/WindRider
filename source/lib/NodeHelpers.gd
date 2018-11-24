extends Node

static func queue_delete(node):
	node.get_parent().remove_child(node)
	node.queue_free()