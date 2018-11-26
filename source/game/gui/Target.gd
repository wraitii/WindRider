extends CenterContainer

# actual node
var target;

func init(t):
	target = weakref(t);

func _process(delta):
	assert(target.get_ref())
	
	get_node('aligner/TargetInfo').text = target.get_ref().data.ID;
	var txt = "";
	txt += 'Shields: ' + str(target.get_ref().shields) + '\n'
	txt += 'Armour: ' + str(target.get_ref().armour) + '\n'
	get_node('aligner/OtherTargetData').text = txt;