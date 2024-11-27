extends Label

func updateText():
	text = "%s Skill Points" % Configuration.read("GAME_DATA", "SKILL_POINTS")

func _ready() -> void:
	updateText()

func _process(delta: float) -> void:
	updateText()
