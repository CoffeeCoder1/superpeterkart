class_name DriveMesh extends Area3D

## Amount of drag to apply when the kart is on this DriveMesh.
@export var track_drag = 0.0


## Gets the track drag value of this DriveMesh.
func get_track_drag() -> float:
	return track_drag
