extends Node

static func queue_delete(node):
	node.get_parent().remove_child(node)
	node.queue_free()

static func remove_all_children(node):
	for child in node.get_children():
		node.remove_child(child)
