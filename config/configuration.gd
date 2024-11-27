extends Node3D

class_name Configuration
const path = "res://config/constants.cfg"
static var _config := ConfigFile.new()
static var is_loaded := false
static var Data: Dictionary = {}

static var player : Player

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
