class_name TowerCollectionContainer extends HBoxContainer

signal selected(selectedTowerName : String)
@onready var escapekey: Label = $"../escapekey"
@onready var canceltower: AudioStreamPlayer2D = $"../canceltower"
@onready var placetower: AudioStreamPlayer2D = $"../placetower"

var towers_unlocked = {
	'crossbow' : true,
	'mortar' : true,
	'worker' : true,
	'inferno' : false,
	'tesla' : false,
	'energifier' : false,
}

@onready var template: TextureButton = $template

func _ready() -> void:
	process_skills()
	setup_buttons()

func get_player_skills() -> Dictionary:
	var player_skills = Configuration.read("GAME_DATA", "SKILL_DATA")
	if not (player_skills is String): player_skills = "{}"
	var player_skills_parsed = JSON.parse_string(player_skills)
	if not (player_skills_parsed is Dictionary): player_skills_parsed = {}
	return player_skills_parsed

func process_skills() -> void:
	var player_skills = get_player_skills()
	
	if player_skills.get("inferno"):
		towers_unlocked.inferno = true
	if player_skills.get("tesla"):
		towers_unlocked.tesla = true

func stop_selection():
	for button : TowerButton in get_children():
		button.default()
	escapekey.hide()
	canceltower.play()

func select_tower(tower_name: String, button: TowerButton) -> void:
	button.focus()
	button.animator.enable_anims = false
	for child_button: TowerButton in get_children():
		if button == child_button or child_button == template: continue
		child_button.unfocus()
	#selected.emit(tower_name)
	var plr: Player = get_node("/root/main/Player/")
	plr._on_game_ui_enterbuildmode(tower_name)
	placetower.play()
	escapekey.show()

func setup_buttons() -> void:
	for tower: String in towers_unlocked:
		if not towers_unlocked.get(tower): continue # tower not unlocked
		
		var button : TowerButton = template.duplicate()
		button.config(TowerButton.TOWER.get(tower.to_upper()))
		add_child(button)
		
		button.pressed.connect(func(): select_tower(tower, button))
		
		button.appear()
