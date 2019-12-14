extends Control

signal hold_cell_selected(x,y,z)

var selected_cells = []
var hold

func _enter_tree():
	hold = load('res://source/game/ShipHold.gd').new()
	hold.init(IO.read_json('res://data/ships/Cycles.json'))

	hold.connect('hold_content_changed', self, '_on_hold_changed')
	_update()

const active = preload('../graphics/ship_hold_view/HoldMatActive.tres')
const inactive = preload('../graphics/ship_hold_view/HoldMat.tres')

func on_cell_selected(cam, inputEvent, a, b, c, holdCell):
	if not inputEvent.is_action_released('click_main'):
		return	
	selected_cells = [holdCell.get_meta('idx')]
	emit_signal("hold_cell_selected", holdCell.get_meta('x'),holdCell.get_meta('y'), holdCell.get_meta('z'))
	_update()

func inspect():
	if !selected_cells:
		$Inspector/Title.text = 'No Selection'
		$Inspector/Desc.text = '...'
		return

	var cell = selected_cells[0]
	if !cell in hold.holdContent:
		$Inspector/Title.text = 'Empty'
		$Inspector/Desc.text = 'Nothing in there.'
	else:
		$Inspector/Title.text = hold.holdContent[cell].ID
		$Inspector/Desc.text = str(hold.holdContent[cell].amount)

func _on_hold_changed(idx):
	_update()

func _update():
	NodeHelpers.remove_all_children(get_node("ViewportContainer/Viewport/HoldView/Items"))
	var y_range = len(hold.holdSpace[0])
	var x_range = len(hold.holdSpace[0][0])
	for y in range(0, y_range):
		for x in range(0, x_range):
			if hold.holdSpace[0][y][x] == 0:
				continue
			var hi = get_node("ViewportContainer/Viewport/HoldView/HoldSpace").duplicate()
			var px = floor(y % 2) * 1;
			var pos = Vector3(px + x*2,0, y*1.6);
			pos -= Vector3(x_range/2 * 2, 0, y_range/2 * 1.6)
			hi.translation = pos
			hi.visible = true;
			hi.set_meta('x', x)
			hi.set_meta('y', y)
			hi.set_meta('z', 0)
			hi.set_meta('idx', Vector3(x, y, 0))
			hi.set_meta('hold', hold)
			if Vector3(x, y, 0) in selected_cells:
				hi.get_node('MeshInstance').set_material_override(active)
			get_node("ViewportContainer/Viewport/HoldView/Items").add_child(hi)
			hi.connect("input_event",self, "on_cell_selected", [hi])
	
	inspect()

