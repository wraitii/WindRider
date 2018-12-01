extends Control

signal pressed()

func init(item):
	get_node('Panel/Button').connect('pressed', self, 'on_pressed');
	
	if 'name' in item:
		get_node('Panel/Name').text = item.name

func on_pressed():
	emit_signal('pressed')