extends Spatial
const Projectile = preload('Projectile.tscn')

var ownerShip = null;
var ownerComponent = null;
var weaponData;

var firing = false;
var firingData = null

func init(c, s, d):
	ownerShip = s;
	ownerComponent = c;
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

func _fire_projectile():
	if ownerShip.energy < weaponData['firing_energy']:
		return;
	ownerShip.energy -= weaponData['firing_energy'];

	var data = Core.dataMgr.get('projectiles/' + weaponData.kind)
	
	var proj = Projectile.instance()
	proj.init(data)
	
	var angle = ownerShip.transform.basis.xform(Vector3(0,0,-1))
	proj.apply_central_impulse(ownerShip.linear_velocity + angle * 150);
	proj.translation = ownerShip.translation + angle*4
	Core.gameState.currentScene.add_child(proj)
