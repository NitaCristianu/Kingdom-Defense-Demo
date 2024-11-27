extends Structure

func _ready():
	var children = get_children()
	
	var n = randi() % 6
	for child in children:
		if child.name != "Rock %s" % [n]:
			child.queue_free()
		else:
			child.transform.origin.x = 0
			child.transform.origin.z = 0
