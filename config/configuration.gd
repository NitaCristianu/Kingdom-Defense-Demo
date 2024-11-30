extends Node3D

class_name Configuration
const path = "res://config/constants.cfg"
static var _config := ConfigFile.new()
static var is_loaded := false
static var Data: Dictionary = {}

static var player : Player

static var WaveData: Array = [
	# JESTER
	[
		[ # 1
			["r6", 1, .7],
		],
		[ # 2
			["r6", 2, .7],
		],
		[ # 3
			["r6", 3, .7],
		],
		[ # 4
			["super slime", 2, 1],
		],
		[ # 5
			["r6", 3, .7],
			["super slime", 2, 1],
		],
		[ # 6
			["r6", 8, .7],
			["super slime", 3, 1],
		],
		[ # 7
			["golden slime", 3, .7],
			["super slime", 3, 1],
		],
		[ # 8
			["r6", 3, .7],
			["glass golem", 1, 1],
		],
	],
	# COMMANDER
	[
		[ # 1
			["r6", 1, .7],
		],
		[ # 2
			["r6", 3, .7],
		],
		[ # 3
			["r6", 5, 1],
			["golden slime", 2, 1],
		],
		[ # 4
			["r6", 2, .7],
			["super slime", 2, 1],
		],
		[ # 5
			["r6", 2, .7],
			["super slime", 3, 1],
		],
		[ # 6
			["golden slime", 3, 1],
		],
		[ # 7
			["pixel knight", 2, 1],
		],
		[ # 8
			["pixel knight", 2, 1],
			["super slime", 2, 2],
			["pixel knight", 2, 1],
		],
		[ # 9
			["pixel knight", 2, 1],
			["goblin", 2, 1],
		],
		[ # 10
			["glass golem", 1, 1],
		],
		[ # 11
			['golden slime', 8, .6],
		],
		[ # 12
			["glass golem", 1, 3],
			["goblin", 2, 1],
		],
		[ # 13
			["pixel knight", 5, 1],
			["golden slime", 5, 2],
			["pixel knight", 5, 1],
		],
		[ # 14
			["golden slime", 10, 2],
		],
		[ # 15
			["spider", 1, 1]
		],
	],
	# CHAMPION
	[
			[ # 1
			["r6", 1, .7],
		],
		[ # 2
			["r6", 3, .7],
		],
		[ # 3
			["r6", 5, 1],
			["golden slime", 2, 1],
		],
		[ # 4
			["r6", 2, .7],
			["super slime", 2, 1],
		],
		[ # 5
			["r6", 2, .7],
			["super slime", 3, 1],
		],
		[ # 6
			["golden slime", 3, 1],
		],
		[ # 7
			["pixel knight", 2, 1],
		],
		[ # 8
			["pixel knight", 2, 1],
			["super slime", 2, 2],
			["pixel knight", 2, 1],
		],
		[ # 9
			["pixel knight", 2, 1],
			["goblin", 2, 1],
		],
		[ # 10
			["glass golem", 1, 1],
		],
		[ # 11
			['golden slime', 8, .6],
		],
		[ # 12
			["glass golem", 1, 3],
			["goblin", 2, 1],
		],
		[ # 13
			["pixel knight", 5, 1],
			["golden slime", 5, .5],
			["pixel knight", 5, 1],
		],
		[ # 14
			["golden slime", 10, .5],
		],
		[ # 15
			["spider", 1, 1]
		],
		[ # 16
			["pixel knight", 5, 1],
			["golden slime", 5, .5],
			["pixel knight", 8, 1],
		],
		[ # 17
			["spider", 1, 1],
			["golem", 1, 1]	
		],
		[ # 18
			["golden slime", 15, .5],
		],
		[ # 19
			["spider", 2, 3],
		],
		[ # 20
			["goblin", 8, 1], 
		],
		[ # 21
			["golden slime", 15, .5],
		],
		[ # 22
			["solider", 1, .5],
		],
		[ # 23
			["solider", 1, 3],
			["golem", 1, 2],
		],
		[ # 24
			["solider", 1, 3],
			["golem", 2, 2],
		],
		[ # 25
			["solider", 3, 3],
		],
	],
]

static func readData() -> Dictionary:
	var DataFIle := FileAccess.open("res://staticdata/DATA.json", FileAccess.READ)
	return JSON.parse_string(DataFIle.get_as_text())

static func getData_absolute() -> Dictionary:
	# returns npc data even if not ready
	Data = Data if not Data.is_empty() else readData()
	return Data

static func loadconfig():
	if not is_loaded:
		var err = _config.load(path)
		assert(err == OK, "Couldn't read constants file")
		is_loaded = true

static func read(section : String, value_name : String):
	loadconfig()
	return _config.get_value(section, value_name)

static func write_ws(section : String, value_name : String, value: Variant):
	loadconfig()

	_config.set_value(section, value_name, value)

static func write(section : String, value_name, value: Variant):
	write_ws(section, value_name, value)
	_config.save(path)  # Save only when explicitly needed

# init game systems
func _ready():
	PlacementSystem.initSystem(%Player,%Towers,%ChunkContainer)
	Data = Data if not Data.is_empty() else readData()
	player = get_node("/root/main/Player")
