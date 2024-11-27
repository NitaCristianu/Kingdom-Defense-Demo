extends Tower

class_name CrossBow

enum SEARCH_MODE {NEAREST}

@onready var mesh: MeshInstance3D = $crossbowmesh
@onready var support: MeshInstance3D = $support
@onready var support_node: Node3D = $support_node
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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

func _ready() -> void:
	transform.origin = cell.global_pos_3d() + Vector3.UP * 0.5

func stun(seconds : float) -> void:
	waitTime -= seconds

func arrowTween(newPos: Vector3):
	arrow.global_position = newPos
	if target and is_instance_valid(target):
		arrow.look_at(-target.global_position)

func shoot(enemy: Enemy):
	waitTime -= speed
	if not enemy:
		#waitTime = speed-response_time
		return
	target = enemy
	if mesh:
		var direction = (enemy.global_position - global_position)
		var angle = atan2(direction.x, direction.z)
		support_node.global_rotation.y = angle + PI/2
		animation_player.play("shoot")
		
		var futurePos = enemy.getFuturePos(enemy.speed/5)
		shootTween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE).set_ease(Tween.EASE_IN_OUT)
		arrow.look_at(-futurePos)
		shootTween.tween_method(arrowTween, arrow.global_position, futurePos, .2)
		shootTween.connect("finished", self.reset_shoot)


func reset_shoot():
	arrow.position = Vector3(-0.097, -0.303, 0.085)
	arrow.rotation_degrees = Vector3(76.5, -38.7, -26.9)
	
	if target and is_instance_valid(target):
		target.damage(strength)
	
func _process(delta: float) -> void:
	if not initied: return
	waitTime += delta
	if waitTime >= speed: shoot(searchEnemy())
