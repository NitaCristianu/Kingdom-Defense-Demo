class_name Cell

enum types {path, grass1, grass2, grass3}
const render_debug: bool = false

var index_pos
var chunk : Chunk
var chunk_container: ChunkContainerClass
var occupied
var type : types

func _init(_index_pos : int, _chunk : Chunk, _chunk_container : Node3D, _type = types.grass1) -> void:
	type = _type
	index_pos = _index_pos
	chunk = _chunk
	chunk_container = _chunk_container
	occupied = null

func position2D()->Vector2i:
	var chunk_size: int = chunk.chunk_size
	var u = index_pos%(chunk_size + 1)
	var v = index_pos/(chunk_size + 1)
	var x = u - ceil(chunk_size / 2)
	var y = v - ceil(chunk_size / 2)
	
	return Vector2i(x, y)

func global_pos_3d() -> Vector3:
	return chunk.get_cell_global_v3(position2D())

func position3D()->Vector3:
	var pos = position2D()
	var chunk_size: int = chunk.chunk_size
	return Vector3(pos.x, 0, pos.y) - Vector3(chunk_size/2, 0, chunk_size/2)

func get_instance() -> Label3D:
	var label: Label3D
	
	#var instance = MeshInstance3D.new()
	#instance.mesh = BoxMesh.new()
	#instance.position = position3D()
	#chunk.add_child(instance)
	
	if render_debug:
		label = Label3D.new()
		label.text = "p:"+str(position2D())+"\nc:"+str(chunk.chunk_pos)+"\n%s" % types.find_key(type)
		label.modulate 
		label.rotate_x(deg_to_rad(90))
		label.rotate_z(deg_to_rad(180))
		label.transform.origin = Vector3(0, .51, 0) 
		chunk.add_child(label)
	
	return label
