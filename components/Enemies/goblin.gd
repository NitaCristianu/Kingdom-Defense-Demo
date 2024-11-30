extends Enemy

@onready var goblin_proyect_end: Node3D = $Goblin_ProyectEnd

func animate():
	(goblin_proyect_end.get_child(1) as AnimationPlayer).play("G_Walk")
