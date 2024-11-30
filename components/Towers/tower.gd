extends Node3D
class_name Tower

var cell: Cell
var speed: float
var range: float
var strength: float
var display_name: String
var tower_name : String
var response_time := 0.1
var player: Player
var level : int = 0
var tier : int = 0
var cell_size : int = 1
var shadow: bool
var fly: bool


func getRawStats():
	var player_skills = Configuration.read("GAME_DATA", "SKILL_DATA")
	if not (player_skills is String): player_skills = "{}"
	var player_skills_parsed = JSON.parse_string(player_skills)
	if not (player_skills_parsed is Dictionary): player_skills_parsed = {}
	return {
		'speed' : speed / (1 - player_skills_parsed.get("speed", 1)),
		'strength' : strength / (1 + player_skills_parsed.get("strength", 1)),
		'range' : range,
	}

func sell():
	var tower_data = Configuration.getData_absolute()['Entity']['Tower'][tower_name]["Price"]
	var player : Player = get_node("/root/main/Player/")
	player.wood += floor(tower_data.get('wood',0) / 4)
	player.stone += floor(tower_data.get('stone',0) / 4)
	player.gold += floor(tower_data.get('gold',0) / 4)
	player.mana += ceil(tower_data.get('mana',0) / 4)
	for _cell in (get_node("/root/main/ChunkContainer") as ChunkContainerClass).getCells(cell, cell.chunk, cell_size):
		_cell.occupied = null
	queue_free()

func levelUp(newLevel: int) -> void:
	var tower_data = Configuration.getData_absolute()['Entity']['Tower'][tower_name]
	var upgrades: Array = tower_data["Upgrades"]
	var data : Dictionary = upgrades[newLevel+tier*tower_data["Upgrade Choices"]]
	
	player.incrementCurrency(-data['wood'], -data['stone'], -data['gold'], -data['mana'])
	
	var player_skills = Configuration.read("GAME_DATA", "SKILL_DATA")
	if not (player_skills is String): player_skills = "{}"
	var player_skills_parsed = JSON.parse_string(player_skills)
	if not (player_skills_parsed is Dictionary): player_skills_parsed = {}
	
	speed = data.Speed - data.Speed * player_skills_parsed.get("speed")
	strength = data.Strength + data.Strength * player_skills_parsed.get("strength")
	range = data.Range
	shadow = data.shadow
	fly = data.fly
	
	level = newLevel
	tier +=1
	
	if self is Worker:
		(self as Worker).thinking.emit()
	
	Configuration.player.inspect_tower(self)
