extends CenterContainer

# actual node
var target;

func init(t):
	target = weakref(t);
	get_node('aligner/ViewportContainer/Viewport/Camera').followedShip = target.get_ref()
	get_node('aligner/ViewportContainer/Viewport/Camera').followerShip = Core.gameState.playerShip
	get_node('aligner/ViewportContainer/Viewport/Camera').switch_mode()
	get_node('aligner/ViewportContainer/Viewport/Camera').switch_mode()

func _process(delta):
	assert(target.get_ref())
	
	get_node('aligner/TargetInfo').text = target.get_ref().data.ID;
	var txt = "";
	txt += 'Shields: ' + str(target.get_ref().shields) + '\n'
	txt += 'Armour: ' + str(target.get_ref().armour) + '\n'
	get_node('aligner/OtherTargetData').text = txt;
