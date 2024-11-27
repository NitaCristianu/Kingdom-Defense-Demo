extends Control

var last_mouse_pos : Vector2
var delta : Vector2

var skills = {
	'strength' : 0,
	'manaboost' : 0,
	'speed' : 0,
	'tesla' : 0,
	'inferno' : 0,
	'energifier' : 0,
}

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos = get_viewport().get_mouse_position()
		if not last_mouse_pos: last_mouse_pos = mouse_pos
		delta = mouse_pos - last_mouse_pos
		if delta.length_squared() < 16:
			delta = Vector2.ZERO
		last_mouse_pos = mouse_pos

func _ready():
	if not Configuration.read("GAME_DATA", "SKILL_DATA"):
		var skill_data := JSON.stringify(skills)
		Configuration.write("GAME_DATA", "SKILL_DATA", skill_data)

func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("Drag"): 
		if (position+delta).length_squared() < get_viewport_rect().size.x * get_viewport_rect().size.y / 4:
			position += delta
		else:
			position -= delta
		for child in get_children():
			if child is SkillPoint:
				child.ondragged()
