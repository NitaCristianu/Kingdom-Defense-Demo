extends Label

@onready var animator: AnimationComponent = $Animator

func get_canvas_size() -> Vector2:
	return get_node("/root/main/ingame_ui").size
var original_pos: int
func _ready() -> void:
	original_pos = position.y
	position.y = -500

func allert(waveInt: int) -> void:
	pivot_offset = size / 2
	animator.add_tween("position:y", original_pos, 1)
	text = "Wave %s" % waveInt
	await get_tree().create_timer(2.5).timeout
	animator.add_tween("position:y", -500, 3)
	
