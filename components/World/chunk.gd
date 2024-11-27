extends Node3D

class_name Chunk

@onready var camera_3d: Camera3D = %Camera
@onready var camera_light: SpotLight3D = %CameraLight

enum chunkType {base, path}

var chunk_container: ChunkContainerClass
var cells: Array[Cell] = []
var structs : Array[Structure] = []
var prev_chunk: Chunk
var chunk_size = -1 # inited in the init function
var chunk_pos : Vector2i
var chunk_type: chunkType
const render_debug: bool = false
var path : ChunkPathGenerator
var removeWhenExtendedatIndex : Dictionary = {}

func getPosFromIndex(index : int):
	var u = index%(chunk_size + 1)
	var v = index/(chunk_size + 1)
	var x = u - ceil(chunk_size / 2)
	var y = v - ceil(chunk_size / 2)
	
	return Vector2i(x, y)

func getIndexFromPos(pos : Vector2i) -> int:
	var u = pos.x + ceil(chunk_size / 2)
	var v = pos.y + ceil(chunk_size / 2)
	return v * (chunk_size + 1) + u

func get_chunk_staticbody() -> StaticBody3D:
	var instance := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.shape.extents = Vector3(chunk_size+1, 0.5, chunk_size+1)
	instance.add_child(collision)
	var pos = Vector2(chunk_pos) * (chunk_size+1)/2
	instance.transform.origin = Vector3(pos.x, 0, pos.y)
	return instance

func get_neighbours(radius: float = 1.5) -> Array:
	return chunk_container.get_chunks().filter(func (chunk): return chunk.chunk_pos.distance_squared_to(chunk_pos) <= radius * radius)

func load_structs():
	var struct_class = preload("res://components/Structures/structure.tscn")
	var tree_class = preload("res://components/Structures/tree.tscn")
	var rock_class = preload("res://components/Structures/rock.tscn")
	
	for i in 5:
		var index = randi_range(0, (chunk_size+1)*(chunk_size+1)-1)
		var xy = getPosFromIndex(index)
		if path.is_cell_path(xy) or cells[index].type != Cell.types.grass1: continue
		var struct: Structure
		if randi() % 2 == 0:
			struct = tree_class.instantiate()
			struct.init(cells[index], struct.structs.TREE)
		else:
			struct = rock_class.instantiate()
			struct.init(cells[index], struct.structs.ROCK)
		structs.append(struct)
		add_child(struct)

func get_global_v3():
	var pos : Vector2 = (Vector2(chunk_pos) - Vector2.ONE * 0.5) * (chunk_size+1) + Vector2.ONE * 0.5 
	return Vector3(pos.x, 0, pos.y)

func get_cell_global_v3(pos : Vector2):
	return get_global_v3() + Vector3(pos.x, 0, pos.y)

func set_cell(pos : Vector2i, type : Cell.types):
	var half_size := int(chunk_size/2)
	assert(pos.x >= -half_size && pos.y >= -half_size && pos.x <= half_size && pos.y <= half_size, "pos is outside chunk limits")
	var cell := cells[(pos.y+half_size) * (chunk_size+1) + (pos.x+half_size)]
	
	if cell.type != type:
		cell.type = type
		add_child(cell.get_instance())
		
func init_chunk(pos : Vector2i, type = chunkType.path):
	var size: int = Configuration.read("CHUNK", "SIZE")
	chunk_size = size
	chunk_pos = pos
	chunk_type = type
	for x in size + 1:
		for y in size + 1:
			var mod_y := y > 0 || y < size # size = size + 1 (-1)
			var cell := Cell.new(x * (size+1) + (y+1 if !mod_y else y), self, chunk_container, Cell.types.grass1)
			cells.append(cell)
	
	add_child(get_chunk_staticbody())
	transform.origin = Vector3(pos.x * (size+1) ,0, pos.y * (size+1))
	
func add_extend_button()->void:
	var loaded = preload("res://components/Systems/new_wave_button.tscn")
	
	var i :int = 0
	for exit in path.to:
		var pos = path.deoffsetVector(exit)
		var nextChunkPos = chunk_pos + pos.sign()
		
		if chunk_container.chunk_exists(nextChunkPos): continue
		var object = loaded.instantiate()
		object.add_to_group("wave_starters")
		
		object.global_position = Vector3(pos.x - chunk_size/2 + sign(pos.x) * 2, 1.5, pos.y - chunk_size/2 + sign(pos.y) * 2)
		object.chunk = self
		object.index = i
		add_child(object)
		if not removeWhenExtendedatIndex.get(i):
			removeWhenExtendedatIndex[i] = []
		removeWhenExtendedatIndex[i].append(object)
		i+=1

func render_chunk():
	for x in chunk_size + 1:
		for y in chunk_size + 1:
			var cell := cells[x+y*(chunk_size+1)]
			add_child(cell.get_instance())
	
	add_extend_button()

func start(_path):
	# the post init
	path = _path
	if path:
		var bitmap := path.bitmap
		for x in chunk_size + 1:
			for y in chunk_size + 1:
				var ind = x + y * (chunk_size+1)
				
				if bitmap.get_bit(x, y):
					cells[ind].type = Cell.types.path

	path.container = chunk_container
	path.chunk = self
	path.setCurves()
	load_structs()
