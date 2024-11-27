extends Panel

func setImage(hp : int):
	var text = load("res://assets/healthbar/%s.png" % hp)
	var style = StyleBoxTexture.new()
	style.texture = text
	add_theme_stylebox_override("panel", style)
	print("damage")
