@tool
class_name Map extends Node3D


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if !has_node("SpawnLocation"):
		warnings.append("Map must have a SpawnLocation.")
	
	return warnings


func get_spawn_location() -> Transform3D:
	return $SpawnLocation.transform
