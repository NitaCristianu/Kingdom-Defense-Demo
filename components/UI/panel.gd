extends Panel

@export var noise: FastNoiseLite

func _ready() -> void:
	var sb := StyleBoxTexture.new()
	sb.texture = NoiseTexture2D.new()
	sb.texture.noise = noise
	
	add_theme_stylebox_override("", sb)

func _process(delta: float) -> void:
	var material = self.get_theme_stylebox("")
	(material.texture.noise).offset += (Vector3.ONE * delta / 3.)
