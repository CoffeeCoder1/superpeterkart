@tool
class_name Map extends Node3D

@onready var spawn_location: Marker3D = $SpawnLocation
@onready var drive_path: Path3D = $DrivePath


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if !has_node("SpawnLocation"):
		warnings.append("Map must have a SpawnLocation.")
	
	if !has_node("DriveMesh"):
		warnings.append("Map must have a DriveMesh.")
	
	if !has_node("DrivePath"):
		warnings.append("Map must have a DrivePath.")
	
	return warnings


func get_spawn_location() -> Transform3D:
	return spawn_location.transform


func get_drive_path() -> Path3D:
	return drive_path


func get_drive_curve() -> Curve3D:
	return drive_path.curve
