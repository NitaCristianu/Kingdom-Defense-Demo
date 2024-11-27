extends Enemy

@onready var animPlayer : AnimationPlayer = $AnimationPlayer

func animate():
	yLevel = .3
	animPlayer.play("walk", 0, speed / 2)