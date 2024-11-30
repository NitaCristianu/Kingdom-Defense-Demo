class_name AnimationComponent extends Node

# animation node
@export var from_center:bool = true
@export var hover_scale : Vector2 = Vector2.ONE * 1.2
@export var time : float = 0.33
@export var transition_type : Tween.TransitionType = Tween.TRANS_CUBIC
@export var enable_anims : bool = true
#@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var target : Control
var default_scale : Vector2

func _ready() -> void:
	target = get_parent()
	
	connect_signals()
	call_deferred("setup") # helps in idle

func connect_signals() -> void:
	target.mouse_entered.connect(on_hover)
	target.mouse_exited.connect(off_hover)
	if target is BaseButton:
		target.button_up.connect(on_pressed)
	
func setup() -> void:
	if from_center:
		target.pivot_offset = target.size / 2
	default_scale = target.scale

func on_hover() -> void:
	if is_queued_for_deletion() or not is_instance_valid(self) or not get_tree(): return
	if enable_anims:
		add_tween("scale", hover_scale, time)
	
func off_hover() -> void:
	if is_queued_for_deletion() or not is_instance_valid(self): return
	if enable_anims:
		if get_tree():
			add_tween("scale", default_scale, time)

func on_pressed() -> void:
	if is_queued_for_deletion() or not is_instance_valid(self): return
	if enable_anims:
		#audio_stream_player_2d.play()
		if get_tree():
			add_tween("scale", default_scale, time / 2).finished.connect(func(): add_tween("scale", hover_scale, time / 2))

func add_tween(property : String, value: Variant, seconds : float) -> Tween:
	if is_queued_for_deletion() or not is_instance_valid(self) or not get_tree(): return
	var tween : Tween = get_tree().create_tween()
	if value is Callable: value = value.call()
	tween.tween_property(target, property, value, seconds).set_trans(transition_type)
	return tween
