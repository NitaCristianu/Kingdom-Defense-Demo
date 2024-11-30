extends Control

class_name EnemyDataClass

@onready var animation_component: AnimationComponent = $AnimationComponent
@onready var title: Label = $container/container/container/title
@onready var description: Label = $container/container/container/description
@onready var progress_bar: ProgressBar = $container/container/container/ProgressBar

var isOpen = false

func _ready() -> void:
	animation_component.add_tween("modulate:a", 0, 0)
	animation_component.add_tween("scale", Vector2.ONE * 0.7, 0)
	
func pop(enemy : Enemy):
	isOpen = true
	animation_component.add_tween("modulate:a", 1, .6)
	animation_component.add_tween("scale", Vector2.ONE, 0.6)
	title.text = enemy.display_name
	description.text = Configuration.getData_absolute()["Entity"]["Enemy"][enemy.enemy_name]["Description"]
	progress_bar.value = (enemy.health / enemy.maxhealth) * 100

func dissapear():
	if isOpen:
		animation_component.add_tween("modulate:a", 0, .6)
		animation_component.add_tween("scale", Vector2.ONE * 0.7, 0.6)
		isOpen = false
