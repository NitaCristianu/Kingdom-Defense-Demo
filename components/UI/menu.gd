extends Panel

signal switch(mode_name: String)

var mode = "menu"

@onready var dictionary_button: Button = $buttons/dictionary
@onready var campaign_button: Button = $buttons/campaign
@onready var inventory_button: Button = $buttons/inventory

var panels: Dictionary

func enter_mode(name: String):
	if mode == name: return
	mode = name
	switch.emit(name)
	
	get_tree().change_scene_to_packed(panels[name])
	

func _ready() -> void:
	# init vars
	
	if not Configuration.read("GAME_DATA", "SKILL_POINTS") and Configuration.read("GAME_DATA", "SKILL_POINTS") != 0:
		Configuration.write("GAME_DATA", "SKILL_POINTS", 6)
	
	
	panels = {
		'campaign' : preload("res://components/UI/campaignmode.tscn"),
		'inventory' : preload("res://components/UI/inventory.tscn"),
		'dictionary' : preload("res://components/UI/dictionary.tscn"),
	}	
	
	for btn: Button in [dictionary_button, campaign_button, inventory_button]:
		btn.pressed.connect(func(): enter_mode(btn.name))
