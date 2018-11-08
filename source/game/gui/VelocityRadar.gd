extends Node2D

export (Vector2) var velocity = Vector2(0,0) setget set_velocity;
export (float) var maxSpeed = 10.0;

var angle;

var following = null setget set_follower, get_follower;

func _process(delta):
	if following:
		velocity = following.get_linear_velocity()
		velocity = Vector2(velocity.x, -velocity.z);
		angle = velocity.normalized().angle_to(Vector2(0,1).rotated(following.rotation.y))
	else:
		velocity = Vector2(0,0)
		angle = 0

	var pos = velocity.length()/ maxSpeed * -64.0 * Vector2(0,1).rotated(angle) + Vector2(64, 64);
	get_node('Container/Sprite').position = pos;
	
	#rotation = angle;

func set_velocity(vel):
	velocity = vel;

func set_follower(f):
	following = f;
	maxSpeed = following.shipStats.get('max_speed');
	if maxSpeed == 0:
		maxSpeed = 1.0

func get_follower():
	return following;