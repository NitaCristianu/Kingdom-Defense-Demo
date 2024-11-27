extends Button

func onClick():
	get_tree().change_scene_to_file("res://components/UI/mainmenu.tscn")

func _ready() -> void:
	self.pressed.connect(onClick)
