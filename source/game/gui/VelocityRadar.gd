extends Container

export (Vector2) var velocity = Vector2(0,0) setget set_velocity;
export (float) var maxSpeed = 10.0;

var following = null setget set_follower, get_follower;

func _process(delta):
	if following:
		velocity = following.get_linear_velocity()
		velocity = Vector2(velocity.x, velocity.z);
	var pos = velocity / maxSpeed * 50.0 + Vector2(50, 50);
	get_node('Sprite').position = pos;

func set_velocity(vel):
	velocity = vel;

func set_follower(f):
	following = f;
	maxSpeed = following.shipStats.get('max_speed');

func get_follower():
	return following;