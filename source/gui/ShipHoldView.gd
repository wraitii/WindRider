extends Control

signal hold_cell_selected(x,y,z)

var selected_cells = []
var hold

#hold = load('res://source/game/ShipHold.gd').new()
#hold.init(IO.read_json('res://data/ships/Cycles.json'))

func init(h):
	hold = h
	hold.connect('hold_content_changed', self, '_on_hold_changed')
	_update()

const active = preload('../graphics/ship_hold_view/HoldMatActive.tres')
const inactive = preload('../graphics/ship_hold_view/HoldMat.tres')
const engine = preload('../graphics/ship_hold_view/HoldMatEngine.tres')
const hardpoint = preload('../graphics/ship_hold_view/HoldMatHardPoint.tres')

func on_cell_selected(cam, inputEvent, a, b, c, holdCell):
	if not inputEvent.is_action_released('click_main'):
		return
	selected_cells = [holdCell.get_meta('idx')]
	emit_signal("hold_cell_selected", holdCell.get_meta('x'),holdCell.get_meta('y'), holdCell.get_meta('z'))
	_update()

## Hack around https://github.com/godotengine/godot/issues/26181
func _on_pseudobackground_input_event(camera, event, click_position, click_normal, shape_idx):
	if not event.is_action_released('click_main'):
		return
	selected_cells = []
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
		var t = hold.holdContent[cell]
		$Inspector/Title.text = hold.holdContent[cell].ID
		var st = str(hold.holdContent[cell].amount)
		st += '/' + str(hold.holdContent[cell].max_amount())
		st += '\n' + str(hold.holdContent[cell].components)
		$Inspector/Desc.text = st

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
			if hold._idx(x, y, 0) in hold.holdContent:
				hi.get_node('Full').visible = true
			hi.set_meta('x', x)
			hi.set_meta('y', y)
			hi.set_meta('z', 0)
			hi.set_meta('idx', hold._idx(x, y, 0))
			hi.set_meta('hold', hold)
			if hold._idx(x, y, 0) in selected_cells:
				hi.get_node('MeshInstance').set_material_override(active)
			elif hold.holdSpace[0][y][x] == hold.HOLD_TYPE.ENGINE:
				hi.get_node('MeshInstance').set_material_override(engine)
			elif hold.holdSpace[0][y][x] == hold.HOLD_TYPE.WEAPON:
				hi.get_node('MeshInstance').set_material_override(hardpoint)
				
			get_node("ViewportContainer/Viewport/HoldView/Items").add_child(hi)
			hi.connect("input_event",self, "on_cell_selected", [hi])
	inspect()
