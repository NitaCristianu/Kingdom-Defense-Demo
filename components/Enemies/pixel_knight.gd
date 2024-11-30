extends Enemy

@onready var blockbench_export: Node3D = $blockbench_export

func anim():
	(blockbench_export.get_child(1) as AnimationPlayer).play("walking", 0, speed)

func animate():
	call_deferred("anim")
