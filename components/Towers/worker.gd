extends Tower

class_name Worker

signal thinking

@onready var mesh: MeshInstance3D = $mesh

var from : Vector2
var to : Vector2
var direction : Vector2 = Vector2(0,0)
var target : Structure = null
var y_level := 1
var mining_range := .8
var arrived: bool = false
var base_pos: Vector3

func isStructureValid(object: Structure) -> bool:
	if object.dead: return false
	if object.targeted && object.targeted != self: return false
	if object.cell.global_pos_3d().distance_squared_to(base_pos) > range * range: return false
	return true

func findStructure() -> Structure:
	var structs = []
	
	var neighbours = cell.chunk.get_neighbours(4)
	for chunk in neighbours:
		structs += chunk.structs.filter(isStructureValid)
	if structs.size() == 0: return null
	return structs[randi()%structs.size()]

func walkTo():
	var to3d = target.cell.global_pos_3d()
	to = Vector2(to3d.x, to3d.z)
	from = Vector2(transform.origin.x, transform.origin.z)
	
	direction = (to-from).normalized()

func search():
	if arrived and target and not target.dead:
		player.incrementCurrency(target.wood, target.stone, target.gold, target.mana)
		if target.damage(strength):
			# target has died
			arrived = false

		get_tree().create_timer(0.7).timeout.connect(thinking.emit)
	else:
		arrived = false
		target = findStructure()
		if target:
			target.targeted = self
			walkTo()
	
func hasArrived() -> bool:
	var dist : float = Vector2(transform.origin.x, transform.origin.z).distance_squared_to(to)
	return dist < mining_range * mining_range

func _process(delta: float) -> void:
	transform.origin.x +=  speed * direction.x * delta
	transform.origin.z +=  speed * direction.y * delta
	
	if arrived == false and hasArrived() and target and not target.dead:
		direction = Vector2.ZERO
		arrived = true
		
		thinking.emit()
	if not target:
		direction = Vector2.ZERO
	
func kill():
	thinking.disconnect(search)
	
func start() -> void:
	transform.origin = cell.global_pos_3d()
	base_pos = transform.origin
	
	thinking.emit()

func _on_thinking() -> void:
	search()
