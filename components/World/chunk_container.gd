extends Node3D

class_name ChunkContainerClass

@export var ChunkNoiseTexture : NoiseTexture2D
@onready var waveHandler: WaveHandler = %Wave

const CHUNK_SIZE = 12

static func pos2str(pos : Vector2i) -> String:
	return "chunk [%s,%s]" % [pos.x, pos.y]

func getCells(center: Cell, chunk : Chunk, size : int) -> Array[Cell]:
	var cell_class = center
	var chunk_class = chunk
	var cells: Array[Cell] = []
	
	for i in size * size:
		var offset = Vector2i(i%(size) -1, i/(size) -1)
		var cell_with_offset: Vector2i = offset + center.position2D()
			
		var half_chunk_size: int = CHUNK_SIZE / 2
		if abs(cell_with_offset.x) > half_chunk_size or abs(cell_with_offset.y) > half_chunk_size:
			var dir = Vector2.ZERO

			#print("START PROCESS")
			while abs(cell_with_offset.x) > half_chunk_size or abs(cell_with_offset.y) > half_chunk_size:
				#print("loop it: ", cell_with_offset)
				#print("direction: ", dir)
				if cell_with_offset.x > half_chunk_size:
					var offset_ = cell_with_offset.x % half_chunk_size - 1
					var multiple_below = 0
					while (multiple_below <= cell_with_offset.x):
						multiple_below += half_chunk_size
						
					multiple_below -= half_chunk_size
					cell_with_offset.x = multiple_below * -1
					cell_with_offset.x += offset_
					
					dir += Vector2(1, 0)
				#print("x > cw | cell : ", cell_with_offset, ", direction : ", dir)
				if cell_with_offset.y > half_chunk_size:
					var offset_ = cell_with_offset.y % half_chunk_size - 1
					var multiple_below = 0
					while (multiple_below <= cell_with_offset.y):
						multiple_below += half_chunk_size
						
					multiple_below -= half_chunk_size
					cell_with_offset.y = multiple_below * -1
					cell_with_offset.y += offset_
					dir += Vector2(0, 1)
				#print("y > cw | cell : ", cell_with_offset, ", direction : ", dir)
				if cell_with_offset.x < -half_chunk_size:
					var offset_ = cell_with_offset.x % half_chunk_size + 1
					var multiple_below = 0
					while (multiple_below >= cell_with_offset.x):
						multiple_below -= half_chunk_size
					multiple_below += half_chunk_size
					
					cell_with_offset.x = multiple_below * -1
					cell_with_offset.x += offset_
					dir += Vector2(-1, 0)
				#print("x < -cw | cell : ", cell_with_offset, ", direction : ", dir)
				if cell_with_offset.y < -half_chunk_size:
					var offset_ = cell_with_offset.y % half_chunk_size + 1
					var multiple_below = 0
					while (multiple_below >= cell_with_offset.y):
						multiple_below -= half_chunk_size
					multiple_below += half_chunk_size
					
					cell_with_offset.y = multiple_below * -1
					cell_with_offset.y += offset_
					dir += Vector2(0, -1)
				#print("y < -cw | cell : ", cell_with_offset, ", direction : ", dir)
				
			var nextChunk = Vector2(chunk.chunk_pos) + dir
			
			if chunk_exists(nextChunk):
				chunk_class = get_chunk(nextChunk)
				cell_class = chunk_class.cells[chunk_class.getIndexFromPos(cell_with_offset)]
		else:
			chunk_class = get_chunk(chunk.chunk_pos)
			cell_class = chunk_class.cells[chunk_class.getIndexFromPos(cell_with_offset)]
		cells.append(cell_class)
	return cells

func get_directions(count : int, chunk_pos : Vector2i, from : Vector2i) -> Array:
	var choices := [Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]
	
	choices = choices.filter(func (choice) : return not chunk_exists(choice + chunk_pos))
	
	var len: int = choices.size()
	while (len > count):
		choices.remove_at(randi()%len)
		len -= 1

	if len == 0:
		pass # no choices available
		
	return choices.map(func (choice) : return choice * floor(CHUNK_SIZE/2))

func add_chunk(pos : Vector2i, type : Chunk):
	var chunk := preload('res://components/World/chunk.tscn')
	var instance := chunk.instantiate()
	instance.chunk_container = self
	instance.init_chunk(pos)
	instance.name = pos2str(pos)
	instance.render_chunk()
	
	add_child(instance)
	return instance

func add_base(pos: Vector2i, to : Vector2i):
	var chunk := preload("res://components/World/chunk.tscn")
	var instance := chunk.instantiate()
	instance.chunk_container = self
	instance.init_chunk(pos, instance.chunkType.base)
	instance.name = pos2str(pos)
	var path = ChunkPathGenerator.new()
	path.initbase(to)
	instance.start(path)
	instance.render_chunk()
	
	add_child(instance)
	return instance

func add_chunk_wpath(pos : Vector2i, from : Vector2i, to : Array[Vector2i]):
	var chunk := preload('res://components/World/chunk.tscn')
	var instance := chunk.instantiate()
	instance.chunk_container = self
	instance.init_chunk(pos)
	instance.name = pos2str(pos)
	
	var path = ChunkPathGenerator.new()
	path.init(from, to)
	instance.start(path)
	instance.render_chunk()
	
	add_child(instance)
	return instance

# extends the chunk at pos, the new chunk has an offseted position
func extend_chunk(pos : Vector2i, exitIndex:int = 0):
	var chunk_class := preload('res://components/World/chunk.tscn')
	var chunk := get_chunk(pos)
	var extension := chunk_class.instantiate()
	
	var from: Vector2i = -chunk.path.deoffsetVector(chunk.path.to[exitIndex])
	var chunk_to : Vector2i = chunk.path.deoffsetVector(chunk.path.to[exitIndex])
	var newcoord: Vector2i = pos + chunk_to.sign()
	#var exits: int = 2 if (randi() % 15 == 1) else 1
	var exits: int = 1
	var directions := get_directions(exits, newcoord, from)
	
	if directions.size() == 0:
		print("STOP")
		return null
		
	if from == -directions[0]:
		extension.chunk_instance_type = extension.chunkInstanceType.STRAIGHT
	else: extension.chunk_instance_type = extension.chunkInstanceType.TURN
		
	extension.prev_chunk = chunk
	var path: ChunkPathGenerator = ChunkPathGenerator.new()
	path.init(from, directions)
	
	extension.chunk_container = self
	extension.init_chunk(newcoord)
	extension.name = pos2str(newcoord)
		
	extension.start(path)
	extension.render_chunk()
	
	if chunk.removeWhenExtendedatIndex.get(exitIndex):
		for child: Node in chunk.removeWhenExtendedatIndex[exitIndex]:
			child.free()
	add_child(extension)
		
	return extension

func chunk_exists(pos : Vector2i) -> bool:
	var strfied := pos2str(pos)
	for child in get_children():
		if strfied == child.name:
			return true
	return false

func get_chunk(pos : Vector2i) -> Chunk:
	var strfied := pos2str(pos)
	for child in get_chunks():
		if strfied == child.name:
			return child
	assert(false, "chunk doesn't exist")
	return null

func get_chunks() -> Array:
	return get_children().slice(1)
	
func set_config_file():
	Configuration.write("CHUNK", "SIZE", CHUNK_SIZE)
	Configuration.write("CHUNK", "NOISE_ID", randi())

func set_terrain():
	ChunkNoiseTexture.noise = FastNoiseLite.new()
	
var chunk: Chunk
func _ready() -> void:
	set_config_file()
	set_terrain()
	chunk = add_base(Vector2i(0,0),Vector2(0, CHUNK_SIZE/2))
