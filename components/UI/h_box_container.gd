class_name TowerCollectionContainer extends HBoxContainer

signal selected(selectedTowerName : String)

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
	
	if player_skills.inferno:
		towers_unlocked.inferno = true
	if player_skills.tesla:
		towers_unlocked.tesla = true
	if player_skills.energifier:
		towers_unlocked.energifier = true

func stop_selection():
	for button : TowerButton in get_children():
		button.default()

func select_tower(tower_name: String, button: TowerButton) -> void:
	button.focus()
	button.animator.enable_anims = false
	for child_button: TowerButton in get_children():
		if button == child_button or child_button == template: continue
		child_button.unfocus()
	selected.emit(tower_name)

func setup_buttons() -> void:
	for tower: String in towers_unlocked:
		if not towers_unlocked.get(tower): continue # tower not unlocked
		
		var button : TowerButton = template.duplicate()
		button.config(TowerButton.TOWER.get(tower.to_upper()))
		add_child(button)
		
		button.pressed.connect(func(): select_tower(tower, button))
		
		button.appear()
		
