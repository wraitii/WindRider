extends RigidBody

var data;

var lifetime = 0.0;

func init(d):
	data = d;
	lifetime = 0.0;
	get_node('Area').connect('body_entered', self, '_collide')

func _physics_process(delta):
	lifetime += delta
	if lifetime >= data['lifetime']:
		NodeHelpers.queue_delete(self)

func _collide(body):
	pass