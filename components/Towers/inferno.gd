extends Tower

class_name Inferno

enum SEARCH_MODE {NEAREST}

@onready var mesh: MeshInstance3D = $crossbowmesh
@onready var support: MeshInstance3D = $support
@onready var fireball: Node3D = $fireball

var initied := false
var waitTime = 0
var shootTween : Tween
var target : Enemy

func loadData():
	var loaded: Dictionary = Configuration.getData_absolute().get("Entity").get("Tower").get(tower_name)
	speed = loaded["Speed"]
	range = loaded["Range"]
	display_name = loaded["Name"]

func start() -> void:
	loadData()
	cell_size = 3
	
	initied = true

func searchEnemy(mode: SEARCH_MODE = SEARCH_MODE.NEAREST) -> Enemy:
	var enemies = get_node("/root/main/Enemies").get_children()
	# carefull, computing twice the distance
	enemies = enemies.filter(func (enemy:Node3D): return enemy.transform.origin.distance_squared_to(transform.origin) <= range * range)
	if mode == SEARCH_MODE.NEAREST and enemies:
		var nearest : Enemy = null
		var distance : float = INF
		for enemy: Enemy in enemies:
			if not shadow and enemy.shadow: continue
			if not fly and enemy.fly: continue
			
			var dist : float = enemy.transform.origin.distance_squared_to(transform.origin)
			if (dist < distance):
				dist = distance
				nearest = enemy
		return nearest
	return null
	
func searchEnemyGroup(mode: SEARCH_MODE = SEARCH_MODE.NEAREST, _range: float = 3) -> Array[Enemy]:
	var enemies = get_node("/root/main/Enemies").get_children()
	var targets : Array[Enemy] = []
	# carefull, computing twice the distance
	enemies = enemies.filter(func (enemy:Node3D): return (fly or not enemy.fly) and (shadow or not enemy.shadow) and enemy.transform.origin.distance_squared_to(transform.origin) <= range * range)
	if mode == SEARCH_MODE.NEAREST and enemies:
		var nearest : Enemy = null
		var distance : float = INF
		for enemy: Enemy in enemies:
			var dist : float = enemy.transform.origin.distance_squared_to(transform.origin)
			if (dist < distance):
				dist = distance
				nearest = enemy
		targets.append(nearest)
		for enemy in enemies:
			if enemy == nearest: continue
			if (enemy as Enemy).position.distance_squared_to(nearest.position) < _range:
				targets.append(enemy)
		return targets
	return []

func _ready() -> void:
	transform.origin = cell.global_pos_3d() + Vector3.UP * 0.5

func stun(seconds : float) -> void:
	waitTime -= seconds

var foundEnemy = false
func processShoot():
	foundEnemy = false
	if tier == 1 and level == 1:
		var group = searchEnemyGroup(SEARCH_MODE.NEAREST, 3)
		for enemy in group:
			shoot(enemy, false, 0, false)
		if group.size() > 0:
			shoot(group[0], true)
	elif tier == 2 and level == 0:
		var group = searchEnemyGroup(SEARCH_MODE.NEAREST, 3)
		for enemy in group:
			shoot(enemy, false, 1, false)
		if group.size() > 0:
			shoot(group[0], true)
	elif tier == 2 and level == 1:
		var group = searchEnemyGroup(SEARCH_MODE.NEAREST, 3)
		for enemy in group:
			shoot(enemy, false, 2, true)
		if group.size() > 0:
			shoot(group[0], true)
	else:
		shoot(searchEnemy(), true)
	waitTime -= speed

func shoot(enemy: Enemy, willDamage : bool = false, FireCurse : int = 0, StunCurse : bool = false):
	if not enemy: return
	target = enemy
	fireball.enableTrail()
	fireball.trailLookTo(target.global_position)
	foundEnemy = true
	if target and is_instance_valid(target):
		if willDamage:
			target.damage(strength)
		if FireCurse == 1:
			target.setBurn(Enemy.BURNS.FIRE, 3)
		elif FireCurse == 2:
			target.setBurn(Enemy.BURNS.POWERFIRE, 4)
		if StunCurse:
			target.stun(2.5)
	
func _process(delta: float) -> void:
	if not initied: return
	waitTime += delta
	waitTime = min(speed, waitTime)
	if waitTime >= speed: processShoot()
