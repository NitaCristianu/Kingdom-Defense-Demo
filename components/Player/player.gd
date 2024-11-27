extends Node3D

class_name Player

var wood = 1000
var stone = 100
var gold = 5000
var mana = 3000

enum STATES {BUILDING, GAME}
var state: STATES = STATES.GAME
var state_props = {}
var chunk_size = -1
var _mouse_on_ui = false

signal state_changed
signal currency_changed(_wood: int, _stone : int, _gold : int, _mana : int)

@onready var camera: PlayerCamera = %Camera
@onready var ingame: IngameUI = %ingame_ui
@onready var building_mark: MeshInstance3D = %BuildingMark
@onready var chunk_container: ChunkContainerClass = %ChunkContainer

var building_marks: Array[MeshInstance3D] = []
var selectedCells = []

func incrementCurrency(_wood: int = 0, _stone : int = 0, _gold : int = 0, _mana : int = 0):
	wood += _wood
	stone += _stone
	gold += _gold
	mana += _mana
	
	if _wood != 0 or _stone != 0 or _gold != 0 or _mana != 0:
		currency_changed.emit(wood, stone, gold, mana)

func setState(newState: STATES = STATES.GAME) -> void:
	state_props.clear()
	state = newState
	state_changed.emit(state)
	
func setStateProperty(key: String, val) -> void:
	state_props[key] = val
	
func getStateProperty(key: String):
	return state_props.get(key, null)
	
func build():
	if not getStateProperty("valid location"): return
	var placing = getStateProperty("placing")
	var cell = getStateProperty("location")
	if not cell: return
	PlacementSystem.ProcessPlacement(placing, cell)
	for mark: Node3D in building_marks:
		mark.queue_free()
	building_marks.clear()
	
	setState(STATES.GAME)

func display_mouse_location():
	var data = camera.get_mouse_3d()
	if data.is_empty(): return
	var pos : Vector3 = data.position 
	pos.y = 0
	
	var chunk = Vector2.ZERO
	var cell = Vector2.ZERO
	chunk.x = round((pos.x + chunk_size * 0.5) / (chunk_size + 1)) * (chunk_size + 1) / (chunk_size+1)
	chunk.y = round((pos.z + chunk_size * 0.5) / (chunk_size + 1)) * (chunk_size + 1) / (chunk_size+1)
	
	if not chunk_container.chunk_exists(chunk):
		return
	cell.x = round(pos.x) + chunk_size/2
	cell.y = round(pos.z) + chunk_size/2
	cell.x = int(int(cell.x) - (chunk.x) * chunk_size - chunk.x ) 
	cell.y = int(int(cell.y) - (chunk.y) * chunk_size - chunk.y  )
	
	var chunk_class: Chunk = chunk_container.get_chunk(chunk)
	var cell_index = chunk_class.getIndexFromPos(cell)
	
	var cell_class = chunk_class.cells[cell_index]
	setStateProperty("location", cell_class)
	setStateProperty("valid location", false)
	var color: Color
	var tower_name = getStateProperty("placing")
	var i: int = 0
	var size : int = Configuration.Data["Entity"]["Tower"][tower_name]["Size"]
	
	color = Color(.2, .8, .2)
	setStateProperty("valid location", true)
	var chunk_cells_size = (chunk_size+1) * (chunk_size+1)
	for mark in building_marks:
		var offset = Vector2(i%(size) -1, i/(size) -1)
		var cell_with_offset: Vector2i = Vector2i(cell + offset)
			
		var half_chunk_size: int = chunk_size / 2
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
				
			var nextChunk = chunk + dir
			
			if chunk_container.chunk_exists(nextChunk):
				chunk_class = chunk_container.get_chunk(nextChunk)
				cell_class = chunk_class.cells[chunk_class.getIndexFromPos(cell_with_offset)]
			else:
				setStateProperty("valid location", false)
		else:
			chunk_class = chunk_container.get_chunk(chunk)
			cell_class = chunk_class.cells[chunk_class.getIndexFromPos(cell_with_offset)]
		
		#print(cell_class.occupied)
		if cell_class.occupied:
			setStateProperty("valid location", false)
		
		if not PlacementSystem.CanPlaceTower(tower_name, cell_class):
			setStateProperty("valid location", false)
		
		var cell_instance = cell_class.instance
		
		building_marks[i].scale = cell_instance.scale * 1.05 / 2
		building_marks[i].transform.origin = cell_instance.transform.origin + Vector3(chunk_class.chunk_pos.x, 0, chunk_class.chunk_pos.y) * (chunk_size+1)
		i+=1
	
	if getStateProperty("valid location") == false:
		color = Color(.8, .2, .2)
		
	for mark in building_marks:
		((mark.mesh as BoxMesh).material as StandardMaterial3D).albedo_color = color
		(mark.get_child(0) as SpotLight3D).light_color = color

func deselect_tower(tower: Tower, alsoUnInspect: bool = true):
	if tower == null: return
	for child in get_node("/root/main/VFXContainer").get_children():
		if child is InspectRange:
			child.queue_free()
			child.destroy()
	if alsoUnInspect:
		print("also uninspec")
		ingame.uninspect(tower)

func inspect_tower(tower : Tower):
	#if (getStateProperty("inspecting") == tower): return
	if getStateProperty("inspecting") == tower:
		deselect_tower(tower, false)
	elif getStateProperty("inspecting") != null:
		deselect_tower(tower)
	var position = tower.position
	var range_tscn = preload("res://components/Systems/range.tscn")
	var range = range_tscn.instantiate()
	
	range.init(tower.range, tower.cell.global_pos_3d())
	
	ingame.inspect(tower)
	get_node("/root/main/VFXContainer").add_child(range)
	setStateProperty("inspecting", tower)

func perform_cast_nonplacing():
	var data = camera.get_mouse_3d()
	if data.is_empty(): return
	var zone : StaticBody3D = data.collider
	
	if zone.name == "extendzone" and zone.get_parent_node_3d().visible:
		# extend map
		var parent = zone.get_parent()
		(get_node("/root/main/Wave") as WaveHandler).startWave(parent.chunk.chunk_pos, parent.index)
	elif zone.name == "towerstatic":
		var parent : Tower = zone.get_parent() as Tower
		inspect_tower(parent)
	elif not _mouse_on_ui:
		var prop = getStateProperty("inspecting")
		if prop: deselect_tower(prop)

func _ready() -> void:
	chunk_size = Configuration.read("CHUNK", "SIZE")
	
	var player_skills = Configuration.read("GAME_DATA", "SKILL_DATA")
	if not (player_skills is String): player_skills = "{}"
	var player_skills_parsed = JSON.parse_string(player_skills)
	if not (player_skills_parsed is Dictionary): player_skills_parsed = {}
	mana += player_skills_parsed.get("manaboost", 0)
	currency_changed.emit(wood, stone, gold, mana)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Place"):
		if state == STATES.GAME:
			perform_cast_nonplacing()
		elif state == STATES.BUILDING:
			deselect_tower(getStateProperty("inspecting"))
			build()
		else:
			pass
	elif state == STATES.BUILDING:
		display_mouse_location()
		if event.is_action_pressed("QuitAction"):
			for mark : Node in building_marks:
				mark.queue_free()
			building_marks.clear()
			setState(STATES.GAME)

func _on_state_changed(state : STATES) -> void:
	if state == STATES.BUILDING:
		ingame.hide_buttons()
	elif state == STATES.GAME:
		ingame.show_buttons()

func _on_currency_changed(wood, stone, gold, mana) -> void:
	ingame.setWood(wood)
	ingame.setStone(stone)
	ingame.setGold(gold)
	ingame.setMana(mana)

func _on_ingame_mouse_entered() -> void:
	_mouse_on_ui = false

func _on_ingame_mouse_exited() -> void:
	_mouse_on_ui = true

func _on_ingame_ui_enterbuildmode(placing: String) -> void:
	var tower_size : int = Configuration.getData_absolute()["Entity"]["Tower"][placing]["Size"]
	var radius: int = tower_size / 2
	for i in tower_size * tower_size:
		var clone : MeshInstance3D =  building_mark.duplicate()
		clone.show()
		building_marks.push_front(clone)
		get_node("/root/main").add_child(clone)
		
	setState(STATES.BUILDING)
	setStateProperty("valid location", false)
	setStateProperty("placing", placing)
