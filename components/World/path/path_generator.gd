extends Node3D

class_name ChunkPathGenerator

var from : Vector2i
var to : Array[Vector2i]
static var chunk_size: int
var bitmap : BitMap
var curves : Array[Curve3D]
var container : ChunkContainerClass
var chunk: Chunk

static func findLastExit(chunk1 : Chunk, chunk2 : Chunk):
	if chunk2.prev_chunk == chunk1:
		return findLastExit(chunk2, chunk1)
	
	# chunk2 is the prev chunk of chunk1
	var offset: Vector2i = chunk1.chunk_pos - chunk2.chunk_pos
	var i := 0
	for to in chunk2.path.to:
		if deoffsetVector(to).sign() == offset:
			return i
		i+=1
	return null

static func offsetVector(vec: Vector2i) -> Vector2i:
	return vec + Vector2i.ONE * floor(chunk_size/2)

static func deoffsetVector(vec: Vector2i) -> Vector2i:
	return vec - Vector2i.ONE * floor(chunk_size/2)

func setCurves():
	curves = []
		
	var i := 0
	for exit in to:
		var path_3d = Curve3D.new()
		var offseted_from: Vector2i = deoffsetVector(from)
		var offseted_to: Vector2i = deoffsetVector(exit)
		path_3d.add_point(chunk.get_cell_global_v3(Vector2(offseted_to)+Vector2(offseted_to).sign()/2))
		path_3d.add_point(chunk.get_cell_global_v3(Vector2i.ZERO))
		path_3d.add_point(chunk.get_cell_global_v3(Vector2(offseted_from)+Vector2(offseted_from).sign()/2))
		curves.append(path_3d)
		
		i+=1

func is_cell_path(pos : Vector2i) -> bool:
	return bitmap.get_bitv(offsetVector(pos))

func get_prev_chunk():
	assert(chunk != null, "chunk doesn't exist")
	return container.get_chunk(chunk.chunk_pos + deoffsetVector(from).sign())

func initbase(_to: Vector2i) -> void:
	if chunk_size == 0:
		chunk_size = Configuration.read("CHUNK", "SIZE")
	from = offsetVector(Vector2.ZERO)
	to = [_to]
	bitmap = BitMap.new()
	bitmap.create(Vector2i(chunk_size+1, chunk_size+1))
	
	generate_path()

func init(start_point: Vector2i, end_points) -> void:
	
	if chunk_size == 0:
		chunk_size = Configuration.read("CHUNK", "SIZE")
	from = offsetVector(start_point)
	to = []
	for point in end_points:
		to.append(offsetVector(point))
	bitmap = BitMap.new()
	bitmap.create(Vector2i(chunk_size+1, chunk_size+1))
	
	generate_path()
	
func generate_path():
	var from2centerdirection = deoffsetVector(from).sign()
		
	for i in int(chunk_size/2)+1:
		bitmap.set_bitv(from - from2centerdirection * i, true)
	
	for location in to:
		var direction = deoffsetVector(location).sign()
		for i in int(chunk_size/2):
			bitmap.set_bitv(location - direction * i, true)
