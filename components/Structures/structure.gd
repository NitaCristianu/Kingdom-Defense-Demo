extends Node3D

class_name Structure

enum structs {TREE, ROCK}

var cell : Cell
var type : structs
var meshinstance : MeshInstance3D
var hp : int = 3
var dead: bool = false
var targeted: Worker = null

var wood: int = 0
var stone: int = 0
var gold: int = 0
var mana: int = 0
var struct_name := "Name"

func getmesh() -> Mesh:
	if type == structs.TREE:
		var s = SphereMesh.new()
		s.material = StandardMaterial3D.new()
		s.material.albedo_color = Color(.3, .8, .4)
		
		return s
	elif type == structs.ROCK:
		var b = BoxMesh.new()
		b.material = StandardMaterial3D.new()
		b.material.albedo_color = Color(.2, .2, .2)
		return b
	return null

func init(_cell = Cell, _type : structs = structs.TREE):
	cell = _cell
	type = _type
	struct_name = (structs.find_key(_type) as String).to_lower()
	meshinstance = MeshInstance3D.new()
	meshinstance.mesh = getmesh()
	cell.occupied = self
	
	var data := Configuration.getData_absolute()
	var struct_data: Dictionary = data.get("Structure").get(struct_name, null)
	if struct_data:
		wood = struct_data['Resources']['wood']
		stone = struct_data['Resources']['stone']
		gold = struct_data['Resources']['gold']
		mana = struct_data['Resources']['mana']
	
	spawn()

func damage(ammount : int) -> bool:
	hp -= ammount
	if hp <= 0:
		destroy()
		return true
	return false

func _ready() -> void:
	
	add_child(meshinstance)

func respawn() -> void:
	scale = Vector3.ONE
	dead = false

func spawn():
	respawn()
	var pos: Vector2 = cell.position2D()
	transform.origin = Vector3(pos.x, 0.5, pos.y) - Vector3(cell.chunk.chunk_size/2, 0, cell.chunk.chunk_size/2)
	
	meshinstance.show()
	
func destroy():
	dead = true
	targeted = null
	scale *= 0.2
