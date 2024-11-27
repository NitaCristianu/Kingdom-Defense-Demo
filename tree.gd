extends Structure

func _ready():
	var tree_children = get_children()
	
	var n = randi() % 6
	for tree in tree_children:
		if tree.name != "Tree %s" % [n]:
			tree.queue_free()
		else:
			tree.transform.origin.x = 0
			tree.transform.origin.z = 0
