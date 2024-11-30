extends Node3D

class_name Enemy

var maxhealth: float = 0
var speed : float = 0
var reward: int = 0
var health  : float = maxhealth
var inited = false
var display_name : String = ""
var enemy_name : String = ""
var chunk: Chunk
var pathindex: int
var walked = 0
var shadow: bool
var fly: bool

enum BURNS {FIRE, POWERFIRE}
# Burns represent damage that is dealth after the originl hit with delay
var timers = {}
var burns = {
	BURNS.FIRE : 0,
	BURNS.POWERFIRE : 0
}
var burnDamages = {
	BURNS.FIRE : 5,
	BURNS.POWERFIRE : 8,
}
# in seconds
var burnFrequency = {
	BURNS.FIRE : 1,
	BURNS.POWERFIRE : 1,
}
var yLevel: float = 1

var stunRemained: = 0 # time until gets freed from stun

func init_enemy(_chunk : Chunk, exitIndex : int):
	chunk = _chunk
	pathindex = exitIndex
	var spawn_pos = chunk.get_cell_global_v3(chunk.path.deoffsetVector(chunk.path.to[exitIndex]))
	
	transform.origin = spawn_pos
	inited = true

func burnClocks() -> void:
	var folder = Node.new()
	folder.name = "Burn Timers"
	
	for burnType in BURNS:
		var timer := Timer.new()
		var bt = BURNS.get(burnType)
		timer.wait_time = burnFrequency[bt]
		timer.timeout.connect(func(): self._dealBurnDamage(bt))
		timers[bt] = timer
		folder.add_child(timer)
	
	add_child(folder)

func stun(ammountOfTime : float):
	stunRemained += ammountOfTime

func _dealBurnDamage(burnType : BURNS) -> void:
	if burns[burnType] <= 0: return
	burns[burnType] -= 1
	damage(burnDamages[burnType])
	if burns[burnType] == 0 and not timers[burnType].is_stopped() and timers[burnType]:
		(timers[burnType] as Timer).stop()

func setBurn(burnType : BURNS, repetitions: int = 3):
	burns[burnType] += repetitions
	if timers.has(burnType) and is_instance_valid(timers[burnType]) and (timers[burnType] as Timer).is_stopped():
		timers[burnType].start()

func delete():
	queue_free()

func die():
	get_node("/root/main/Player").incrementCurrency(0, 0, reward, 0)
	delete()
	
func damage(dmg : float):
	if dmg >= health:
		die()
	health -= dmg

func damagebase(ammount : int):
	(get_node("/root/main/Wave/") as WaveHandler).damageBase(ammount)
	delete()
	
func animate():
	pass

func getFuturePos(offset : float) -> Vector3:
	var curve := chunk.path.curves[pathindex]
	var pos = walked + offset
	if pos > curve.get_baked_length():
		if chunk.chunk_type == chunk.chunkType.base:
			return global_position
		var newchunk = chunk.path.get_prev_chunk()
		pathindex = ChunkPathGenerator.findLastExit(chunk, newchunk)
		chunk = newchunk
		return chunk.path.curves[pathindex].sample_baked(pos)
	else:
		return curve.sample_baked(pos)

func _ready() -> void:
	var curve := chunk.path.curves[pathindex]
	look_at(curve.sample_baked(1))
	burnClocks()
	
func _process(delta: float) -> void:
	if not inited or not chunk: return
	
	if stunRemained <= 0:
		walked += speed * delta
	else:
		stunRemained -= delta
		return
	var curve := chunk.path.curves[pathindex]
	
	if walked > curve.get_baked_length():
		if chunk.chunk_type == chunk.chunkType.base:
			damagebase(health)
			return
		walked = 0
		var newchunk = chunk.path.get_prev_chunk()
		pathindex = ChunkPathGenerator.findLastExit(chunk, newchunk)
		chunk = newchunk
	else:
		var location_after = curve.sample_baked(walked + .5)
		var location_before = curve.sample_baked(walked - .5)

		if (location_after - location_before).sign().length_squared() > 1:
			look_at(location_after-location_before+transform.origin)
		transform.origin = curve.sample_baked(walked)
		transform.origin.y = yLevel
