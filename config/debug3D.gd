class_name Debug3D

static func drawPointAt(parent : Node, pos : Vector3):
	var instance : MeshInstance3D = MeshInstance3D.new()
	instance.mesh = SphereMesh.new()
	instance.transform.origin = pos
	instance.scale *= 0.2
	
	parent.add_child(instance)
