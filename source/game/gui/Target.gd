extends CenterContainer

# actual node
var target;
var from;

func init(t):
	target = weakref(t);
	from = weakref(Core.gameState.playerShip);
	get_node('aligner/ViewportContainer/Viewport/Camera').followedShip = target.get_ref()
	get_node('aligner/ViewportContainer/Viewport/Camera').followerShip = from.get_ref()
	get_node('aligner/ViewportContainer/Viewport/Camera').switch_mode()
	get_node('aligner/ViewportContainer/Viewport/Camera').switch_mode()

func _process(delta):
	assert(target.get_ref())
	assert(from.get_ref())
	
	get_node('aligner/TargetName').text = target.get_ref().data.ID;
	var txt = "";
	txt += 'S/A ' + str(target.get_ref().shields) + '/' + str(target.get_ref().shields) + '\n'
	get_node('aligner/TargetInfo').text = txt;
	
	var dist = target.get_ref().translation.distance_to(from.get_ref().translation)
	txt = "Distance: " + str(ceil(dist))
	txt += "\nSpeed: " + str(ceil(target.get_ref().linear_velocity.length()))
	get_node('aligner/OtherTargetData').text = txt;
