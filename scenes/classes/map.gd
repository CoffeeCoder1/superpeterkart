@tool
class_name Map extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if !has_node("SpawnLocation"):
		warnings.append("Map must have a SpawnLocation.")
	
	return warnings


func get_spawn_location() -> Transform3D:
	return $SpawnLocation.transform
