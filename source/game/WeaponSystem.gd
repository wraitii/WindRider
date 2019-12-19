extends Spatial

var ownerShip = null;
var comp = null;
var weaponData;

var hardpoint;
var firing = false;
var firingData = null

func init(c, s, d):
	ownerShip = s;
	comp = c;
	weaponData = d;
	
func start_firing():
	firing = true
	if firingData:
		return;
	firingData = Timer.new()
	firingData.process_mode = Timer.TIMER_PROCESS_PHYSICS;
	firingData.one_shot = true
	firingData.connect('timeout', self, '_fire_timeout')
	add_child(firingData)
	_fire_timeout()

func stop_firing():
	firing = false;
	
func _fire_timeout():
	if !firing:
		remove_child(firingData)
		firingData = null;
		return;
	_fire();
	firingData.start(weaponData['repeat_rate']/1000.0)

func _fire():
	match weaponData.type:
		'projectile':
			_fire_projectile();

func max_angle(angle, max_angle):
	var best = max_angle * PI / 180
	return max(-best, min(angle, best))

func _fire_projectile():
	if ownerShip.energy < weaponData['firing_energy']:
		return;
	ownerShip.energy -= weaponData['firing_energy'];

	get_node('WeaponSound').set_stream(preload('res://data/sounds/blaster_crappy_1.wav'));
	get_node('WeaponSound').play();

	var data = Core.dataMgr.get('projectiles/' + weaponData.kind)

	var proj = load('res://data/art/projectiles/' + data['scene'] + '.tscn').instance()
	proj.init(data)
	
	var angle = ownerShip.transform.basis.xform(Vector3(0,0,-1))
	var rot = ownerShip.transform.basis
	var pos = ownerShip.graphics.get_node('Hardpoints').get_node(hardpoint).translation
	
	if ownerShip.targetingSystem.get_active_target():
		if 'turret_angle' in weaponData:
			# Adjust angle-of-firing.
			# TODO: support the hardpoint having a max angle
			var idealAngle = Intercept.simple_intercept(ownerShip, ownerShip.targetingSystem.get_active_target(), weaponData['firing_speed'])[0]
			if !idealAngle:
				idealAngle = (ownerShip.targetingSystem.get_active_target().translation - ownerShip.translation - pos).normalized()
			var best = Transform.looking_at(idealAngle, Vector3(0,1,0))
			var current = Transform.looking_at(angle, Vector3(0,1,0))
			var angles = (best.basis * current.basis.transposed()).get_euler();
			angles[0] = max_angle(angles[0], weaponData['turret_angle'][0])
			angles[1] = max_angle(angles[1], weaponData['turret_angle'][0])
			angles[2] = max_angle(angles[2], weaponData['turret_angle'][0])
			
			var rot_adj = Basis()
			rot_adj = rot_adj.rotated(Vector3(0,0,1), angles[2])
			rot_adj = rot_adj.rotated(Vector3(1,0,0), angles[0])
			rot_adj = rot_adj.rotated(Vector3(0,1,0), angles[1])
			angle = rot_adj.xform(ownerShip.transform.basis.xform(Vector3(0,0,-1)))
			rot = rot_adj*rot
			
	proj.linear_velocity = ownerShip.linear_velocity + angle * weaponData['firing_speed'];

	var offset = proj.get_node('SpawnPoint').translation
	pos = ownerShip.transform.basis.xform(pos-offset)
	proj.translation = ownerShip.translation + pos
	proj.rotation = rot.get_euler()
	Core.gameState.currentScene.add_child(proj)
