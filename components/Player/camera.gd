extends Camera3D

class_name PlayerCamera

const SCROLL_SPEED = 10
var UP:bool = false
var DOWN:bool = false
var LEFT:bool = false
var RIGHT:bool = false

@onready var camera: Camera3D = %Camera

func get_mouse_3d() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to

	return space.intersect_ray(ray_query)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask&(MOUSE_BUTTON_MASK_MIDDLE+MOUSE_BUTTON_MASK_LEFT):
			self.rotate(Vector3(0, 1, 0), event.relative.x * -0.004)
		
	if Input.is_action_pressed("ZoomIn"):
		if camera.fov < 120:
			camera.fov += 2
			
	if Input.is_action_pressed("ZoomOut"):
		if camera.fov > 30:
			camera.fov -= 2

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("MoveFront") or UP:
		self.translate(Vector3(0, 0, -SCROLL_SPEED*delta))
		self.transform.origin.y = 0
		
	if Input.is_action_pressed("MoveBack") or DOWN:
		self.translate(Vector3(0, 0, SCROLL_SPEED*delta))
		self.transform.origin.y = 0
		
	if Input.is_action_pressed("MoveLeft") or LEFT:
		self.translate(Vector3(-SCROLL_SPEED*delta, 0, 0))
		self.transform.origin.y = 0
		
	if Input.is_action_pressed("MoveRight") or RIGHT:
		self.translate(Vector3(SCROLL_SPEED*delta, 0, 0))
		self.transform.origin.y = 0
	
