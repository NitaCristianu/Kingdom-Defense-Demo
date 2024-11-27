class_name PlacementSystem

static var player: Player = null
static var towerContainer: Node3D = null
static var chunkContainer: ChunkContainerClass = null

static func initSystem(pl: Player, cont : Node3D, chct : ChunkContainerClass):
	player = pl
	towerContainer = cont
	chunkContainer = chct

static func ProcessPlacement(tower_name: String, cell: Cell):
	if CanPlaceTower(tower_name, cell, true): PlaceTower(tower_name, cell)

static func PlaceTower(tower_name: String, cell: Cell):
	var tower: Tower
	
	if tower_name == "worker":
		var data = preload("res://components/Towers/worker.tscn")
		tower = data.instantiate()
	elif tower_name == "crossbow":
		var data = preload("res://components/Towers/crossbow.tscn")
		tower = data.instantiate()
	elif tower_name == "tesla":
		var data = preload("res://components/Towers/tesla.tscn")
		tower = data.instantiate()
	elif tower_name == "inferno":
		var data = preload("res://components/Towers/inferno.tscn")
		tower = data.instantiate()
	else:
		var data = preload("res://components/Towers/tower.tscn")
		tower = data.instantiate()
	tower.cell = cell

	var player_skills = Configuration.read("GAME_DATA", "SKILL_DATA")
	if not (player_skills is String): player_skills = "{}"
	var player_skills_parsed = JSON.parse_string(player_skills)
	if not (player_skills_parsed is Dictionary): player_skills_parsed = {}
	
	var tower_speed = Configuration.Data['Entity']['Tower'][tower_name]['Speed']
	var tower_strength =  Configuration.Data['Entity']['Tower'][tower_name]['Strength']
	
	tower.tower_name = tower_name
	tower.display_name = Configuration.Data['Entity']['Tower'][tower_name]['Name']
	tower.cell_size = Configuration.Data['Entity']['Tower'][tower_name]['Size']
	tower.speed = tower_speed - tower_speed * player_skills_parsed.get("speed", 0)
	tower.range = Configuration.Data['Entity']['Tower'][tower_name]['Range']
	tower.strength = tower_strength + tower_strength * player_skills_parsed.get("strength", 0)
	tower.shadow = Configuration.Data['Entity']['Tower'][tower_name]['shadow']
	tower.fly = Configuration.Data['Entity']['Tower'][tower_name]['fly']
	
	tower.player = player
	
	var cells = chunkContainer.getCells(cell, cell.chunk, tower.cell_size)
	for _cell in cells:
		_cell.occupied = tower
	
	towerContainer.add_child(tower)
	tower.start()
	
static func CanPlaceTower(tower_name: String, cell : Cell, also_buy: bool = false) -> bool:
	#print(tower_name)
	if cell.occupied != null: return false
	#print("test0")
	if cell.type == cell.types.path: return false
	#print("test1")
	var db := Configuration.getData_absolute()
	var tower_data : Dictionary = db['Entity']['Tower'].get(tower_name, null)
	if not tower_data: return false
	#print("test2")
	var price = tower_data.get("Price")
	
	if not (player.gold >= price.gold and player.wood >= price.wood and player.stone >= price.stone and player.mana >= price.mana):
		return false
	#print("test3")
		
	if also_buy: player.incrementCurrency(-price.wood, -price.stone, -price.gold, -price.mana)
	
	#print("passed")
	return true
