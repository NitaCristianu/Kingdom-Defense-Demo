extends HBoxContainer

var rewards : Array[int] = [2, 8, 20]

func pressed(i : int):
	Configuration.write("GAME_DATA", "REWARD", rewards[i])
	var game_scene = preload("res://main/main.tscn")
	get_tree().change_scene_to_packed(game_scene)

func _ready() -> void:
	var i = 0;
	
	for child: Button in get_children():
		#child.mouse_exited.connect(func(): print(i))
		child.pressed.connect(func(): pressed(i) )
		i+=1
