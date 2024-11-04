extends Kart

@onready var front_axle: Node3D = $FrontAxle
@onready var rear_axle: Node3D = $RearAxle


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Debug things
	front_axle.global_position = front_wheel
	rear_axle.global_position = rear_wheel
