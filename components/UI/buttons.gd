extends HBoxContainer

@onready var endless: Button = $endless
@onready var campaign: Button = $campaign
@onready var inventory: Button = $inventory

@export var tween_intensity: float = 1.2
@export var tween_duration: float = .3

func _input(event: InputEvent) -> void:
	btn_hovered(endless)
	btn_hovered(campaign)
	btn_hovered(inventory)
	
func start_tween(object: Button, property, final_val, duration):
	var tween = create_tween()
	tween.tween_property(object, property, final_val, duration)
	
func btn_hovered(button : Button):
	button.pivot_offset = button.size / 2
	
	if button.is_hovered():
		start_tween(button, "modulate", Color(.6, .6, .6), tween_duration)
	else:
		start_tween(button, "modulate", Color(1,1,1), tween_duration)
