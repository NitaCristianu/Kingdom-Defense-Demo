extends Tower

class_name Mortar

enum SEARCH_MODE {STRONGEST}

@onready var mesh: Node3D = $tower
@onready var support: MeshInstance3D = $support
@onready var support_node: Node3D = $support_node
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var toskyball: Node3D = $toskyball

var toskyballInitialPosition: Vector3 = Vector3.ONE
var toskyballInitialScale: Vector3 = Vector3.ONE

@onready var explosion: AudioStreamPlayer3D = $explosion
@onready var hit: AudioStreamPlayer3D = $hit

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

func searchEnemy(mode: SEARCH_MODE = SEARCH_MODE.STRONGEST, _range : float = 4) -> Array[Enemy]:
	var enemies = get_node("/root/main/Enemies").get_children()
	var targets : Array[Enemy] = []
	# carefull, computing twice the distance
	enemies = enemies.filter(func (enemy:Node3D): return (fly or not enemy.fly) and (shadow or not enemy.shadow) and enemy.transform.origin.distance_squared_to(transform.origin) <= range * range)
	if mode == SEARCH_MODE.STRONGEST and enemies:
		var nearest : Enemy = null
		var distance : float = -INF
		for enemy: Enemy in enemies:
			var dist : float = enemy.health # replace dist with health
			if (dist > distance):
				dist = distance
				nearest = enemy
		targets.append(nearest)
		for enemy in enemies:
			if enemy == nearest: continue
			if (enemy as Enemy).position.distance_squared_to(nearest.position) < _range * _range:
				targets.append(enemy)
		return targets
	return []

func _ready() -> void:
	toskyballInitialPosition = toskyball.position
	toskyballInitialScale = toskyball.scale
	transform.origin = cell.global_pos_3d() + Vector3.UP * 0.5

func stun(seconds : float) -> void:
	waitTime -= seconds

func shoot(enemy: Enemy):
	if not enemy or not is_instance_valid(enemy):
		#waitTime = speed-response_time
		return
	target = enemy
	target.damage(self.strength)

var found_enemies : Array[Enemy] = []
func castBall():
	var tween : Tween = get_tree().create_tween()
	toskyball.position = toskyballInitialPosition
	toskyball.scale = toskyballInitialScale
	hit.play()
	tween.tween_property(toskyball, "position", toskyballInitialPosition+Vector3.UP * 30, 1).set_trans(Tween.TransitionType.TRANS_LINEAR).finished.connect(func():
		hitEnemies()
		)

func hitEnemies():
	if found_enemies.size() > 0:
		
		for enemy in found_enemies:
			if is_instance_valid(enemy):
				shoot(enemy)
		
		if is_instance_valid(found_enemies[0]) and not found_enemies[0].is_queued_for_deletion():
			var location = found_enemies[0].position
			var tween : Tween = get_tree().create_tween()
			tween.tween_property(toskyball, "scale", Vector3.ONE * 0.6, 1).set_trans(Tween.TransitionType.TRANS_CUBIC)
			tween.tween_property(toskyball, "global_position", location, 1).set_trans(Tween.TransitionType.TRANS_LINEAR).finished.connect(func():
				var sceneLoaded = preload("res://components/BigExplosion/BigExplosionScene.tscn")
				var vfx = sceneLoaded.instantiate()
				vfx.position.y += 1.5
				for child: GPUParticles3D in vfx.get_children():
					child.restart()
				toskyball.hide()
				explosion.play()
				get_tree().create_timer(5).timeout.connect(func():
					if is_instance_valid(vfx):
						vfx.queue_free()
					)
				if found_enemies.size() > 0 and is_instance_valid(found_enemies[0]) and not found_enemies[0].is_queued_for_deletion():
					found_enemies[0].add_child(vfx)
				)

func _process(delta: float) -> void:
	if not initied: return

	waitTime += delta
	if waitTime >= speed:
		var range = 4
		found_enemies = searchEnemy(SEARCH_MODE.STRONGEST, range)
		if found_enemies.size() > 0:
			toskyball.position = toskyballInitialPosition
			toskyball.scale = toskyballInitialScale
			toskyball.show()
			castBall()
			waitTime = 0
