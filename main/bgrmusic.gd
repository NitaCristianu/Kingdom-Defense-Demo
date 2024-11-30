extends AudioStreamPlayer3D


		

func _on_enemies_child_exiting_tree(node: Node) -> void:
	var enemies = get_node("/root/main/Enemies")
	var tween = create_tween()
	if is_instance_valid(enemies) and not enemies.get_children().size() > 0:
		tween.tween_property(self, "volume_db", -150, 3)
	else:
		tween.tween_property(self, "volume_db", -20, 3)

func _on_enemies_child_entered_tree(node: Node) -> void:
	var enemies = get_node("/root/main/Enemies")
	var tween = create_tween()
	if is_instance_valid(enemies) and not enemies.get_children().size() > 0:
		tween.tween_property(self, "volume_db", -150, 3)
	else:
		tween.tween_property(self, "volume_db", -20, 3)
		
