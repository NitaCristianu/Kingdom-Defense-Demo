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
@onready var resources: VBoxContainer = $resources
@onready var resource_anim: AnimationComponent = $resources/AnimationComponent

func config(tower_name : TOWER) -> void:
	tower_type = tower_name
	call_deferred("config_safe")

func config_safe() -> void:
	var style := StyleBoxTexture.new()
	style.texture = ResourceLoader.load(icons.get(TOWER.find_key(tower_type)))
	icon.add_theme_stylebox_override("panel", style)
	icon.pivot_offset = icon.size / 2
	icon.scale *= .8

func displayStats() -> void:
	if not (tower_type is TOWER): return
	
	var data = Configuration.getData_absolute()["Entity"]["Tower"][(TOWER.find_key(tower_type) as String).to_lower()]["Price"]
	
	for child in resources.get_children():
		if child is AnimationComponent: continue
		var val: int = data[child.name]
		if val == 0: child.hide()
		else: child.show()
		var label = child.get_child(1)
		label.text = str(val)
	
	resource_anim.add_tween("modulate:a", 1, 0.4)
	resource_anim.add_tween("scale", Vector2.ONE * .74, .4)

func hideStats() -> void:
	resource_anim.add_tween("modulate:a", 0, 0.4)
	resource_anim.add_tween("scale", Vector2.ONE * .3, .4)

func unfocus():
	animator.add_tween("position:y", 230, .5)
	animator.add_tween("scale", Vector2.ONE, .5)
	animator.add_tween("modulate", Color(.8,.8,.8, .5), .5)

func focus():
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

func _on_mouse_entered() -> void:
	displayStats()

func _on_mouse_exited() -> void:
	hideStats()
