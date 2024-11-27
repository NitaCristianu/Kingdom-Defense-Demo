class_name TowerButton extends TextureButton

enum TOWER {TESLA, MORTAR, INFERNO, CROSSBOW, ENERGIFIER, WORKER}

var icons = {
	"WORKER" : "res://assets/Icons/worker.png",
	"CROSSBOW" : "res://assets/Icons/crossbow.png",
	"TESLA" : "res://assets/Icons/tesla.png",
	"MORTAR" : "res://assets/Icons/mortar.png",
	"INFERNO" : "res://assets/Icons/inferno.png",
	"ENERGIFIER" : "res://assets/Icons/energifier.png",
}

@export var tower_type : TOWER
@onready var icon: Panel = $icon
@onready var animator: AnimationComponent = $Animator

func config(tower_name : TOWER) -> void:
	tower_type = tower_name
	call_deferred("config_safe")

func config_safe() -> void:
	var style := StyleBoxTexture.new()
	style.texture = ResourceLoader.load(icons.get(TOWER.find_key(tower_type)))
	icon.add_theme_stylebox_override("panel", style)
	icon.pivot_offset = icon.size / 2
	icon.scale *= .8

func unfocus():
	var ingame: Control = get_node("/root/main/ingame_ui").get_child(0)
	animator.add_tween("position:y", 30, .5)
	animator.add_tween("scale", Vector2.ONE, .5)
	animator.add_tween("modulate", Color(.8,.8,.8, .5), .5)

func focus():
	var ingame: Control = get_node("/root/main/ingame_ui").get_child(0)
	animator.add_tween("position:y", -30, .5)
	animator.add_tween("scale", Vector2.ONE * 1.2, .5)
	animator.add_tween("modulate", Color(1, 1, 1), .5)

func default():
	animator.add_tween("position:y", 0, .5)
	animator.add_tween("scale", Vector2.ONE, .5)
	animator.add_tween("modulate", Color(1, 1, 1), .5)
	animator.enable_anims = true

func appear() -> void:
	scale = Vector2.ZERO
	
	show()
	animator.add_tween("scale", Vector2.ONE, .4)
	animator.default_scale = Vector2.ONE
