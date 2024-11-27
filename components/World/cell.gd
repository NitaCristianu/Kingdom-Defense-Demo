class_name Cell

enum types {path, grass1, grass2, grass3}
const render_debug: bool = false

var index_pos
var instance : MeshInstance3D
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

	if _type == types.grass1:
		setHeight()
	
func setHeight():
	var uv: Vector2i = Vector2i(index_pos%(chunk.chunk_size+1), index_pos/(chunk.chunk_size+1)) + chunk.chunk_pos * chunk.chunk_size
	var val := chunk_container.ChunkNoiseTexture.noise.get_noise_2dv(uv)
	
	if (val > 0.32):
		type = types.grass3
	elif(val > 0.28):
		type = types.grass2

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

func get_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	
	if type == types.path:
		material.albedo_color = Color(0.859, 0.843, 0.576)
	else:
		material.albedo_color = Color(0.131, 0.461, 0.245)
	if render_debug and chunk.path:
		if chunk.path.from == chunk.path.offsetVector(position2D()):
			material.albedo_color = Color(0.859, 0.143, 0.176)
		elif chunk.path.to.find(chunk.path.offsetVector(position2D())) > -1:
			material.albedo_color = Color(0.159, 0.143, 0.876)
		
	return material

func get_instance() -> MeshInstance3D:
	if instance:
		instance.free()
	instance = MeshInstance3D.new()
	instance.mesh = BoxMesh.new()
	instance.mesh.surface_set_material(0, get_material())
	instance.transform.origin = position3D()
	var pos2D = position2D()
	instance.name = 'Cell(%s, %s)[%s, %s]' % [pos2D.x, pos2D.y, chunk.chunk_pos.x, chunk.chunk_pos.y]
	if type == types.path:
		instance.translate(Vector3(0, -0.05, 0))
		instance.scale.y = 0.95
	elif type == types.grass2:
		instance.translate(Vector3(0, 0.25, 0))
		instance.scale.y = 1.5
	elif type == types.grass3:
		instance.translate(Vector3(0, 0.5, 0))
		instance.scale.y = 2
	
	if render_debug:
		var label = Label3D.new()
		label.text = "p:"+str(position2D())+"\nc:"+str(chunk.chunk_pos)+"\n%s" % types.find_key(type)
		label.rotate_x(deg_to_rad(90))
		label.rotate_z(deg_to_rad(180))
		label.transform.origin = Vector3(0, .51, 0) 
		instance.add_child(label)
	
	return instance
