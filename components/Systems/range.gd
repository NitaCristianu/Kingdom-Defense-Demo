extends Node3D

class_name InspectRange

func _ready() -> void:
	name = "INSPECTRANGE"

func init(radius: float, global_pos : Vector3):
	scale.x = radius * 2
	scale.z = radius * 2
	transform.origin = global_pos
	transform.origin.y = max(transform.origin.y, 0.51)
	
func destroy():
	queue_free()
