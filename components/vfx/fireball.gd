extends Node3D

@onready var trail_add: GPUParticles3D = $TrailADD
@onready var trail_ab: GPUParticles3D = $TrailAB

func trailLookTo(lookAt: Vector3):
	look_at(lookAt)

func enableTrail():
	trail_ab.show()
	trail_add.show()
	
func disableTrail():
	trail_ab.hide()
	trail_add.hide()
