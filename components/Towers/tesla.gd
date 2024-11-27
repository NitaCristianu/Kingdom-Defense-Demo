extends Tower

class_name Tesla

enum SEARCH_MODE {NEAREST}

@onready var mesh: Node3D = $tower
@onready var support: MeshInstance3D = $support
@onready var support_node: Node3D = $support_node
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lighting: Node3D = $lighting

var bullets = []

var initied := false
var waitTime = 0
var shootTween : Tween
var target : Enemy

@onready var arrow: MeshInstance3D = $support_node/support/back/arrow

func loadData():
	var loaded: Dictionary = Configuration.getData_absolute().get("Entity").get("Tower").get(tower_name)
	speed = loaded["Speed"]
	range = loaded["Range"]
	display_name = loaded["Name"]

func start() -> void:
	loadData()
	cell_size = 3
	
	initied = true

func searchEnemy(mode: SEARCH_MODE = SEARCH_MODE.NEAREST) -> Array[Enemy]:
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
			if (enemy as Enemy).position.distance_squared_to(nearest.position) < 4:
				targets.append(enemy)
		return targets
	return []

func _ready() -> void:
	transform.origin = cell.global_pos_3d() + Vector3.UP * 0.5

func stun(seconds : float) -> void:
	waitTime -= seconds

func shoot(enemy: Enemy):
	if not enemy:
		#waitTime = speed-response_time
		return
	var vfx_loaded = preload("res://components/vfx/thunder_editable.tscn")
	var vfx = vfx_loaded.instantiate()
	
	vfx.position = enemy.position
	get_node("/root/").add_child(vfx)
	bullets.append(vfx)
	
	target = enemy
	target.damage(self.strength)

@onready var timer: Timer = $Timer
@onready var circles: Node3D = $tower/circles

func _process(delta: float) -> void:
	if not initied: return

	var i = 0
	for child in circles.get_children():
		if i == 0:
			child.rotation.z += 0.05
		if i == 1:
			child.rotation.z += 0.05
		if i == 2:
			child.rotation.z += 0.05
		i+=1
		
	waitTime += delta
	if waitTime >= speed:
		var enemies := searchEnemy()
		if enemies.size() > 0:
			timer.start()
			for enemy in enemies: 
				waitTime = 0
				shoot(enemy)
			lighting.look_at(enemies[0].global_position)
			lighting.show()
	

func _on_timer_timeout() -> void:
	for bullet: Node3D in bullets:
		bullet.queue_free()
	lighting.hide()
	bullets.clear()
