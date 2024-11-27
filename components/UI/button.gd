extends Button

@export var duration = 0.1
@export var intensity = 1.1

var tween: Tween

func _ready() -> void:
	tween = create_tween()
	pivot_offset = size/2
	
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)

func on_mouse_entered() -> void:
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * intensity, duration)
	
func on_mouse_exited() -> void:
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, duration)
