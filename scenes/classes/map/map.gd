@tool
class_name Map extends Node3D

@export var environment: Environment
@export var compositor: Compositor

@onready var spawn_location: Marker3D = $SpawnLocation
@onready var drive_path: Path3D = $DrivePath

var world_environment: WorldEnvironment


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if !has_node("SpawnLocation"):
		warnings.append("Map must have a SpawnLocation.")
	
	if !has_node("DriveMesh"):
		warnings.append("Map must have a DriveMesh.")
	
	if !has_node("DrivePath"):
		warnings.append("Map must have a DrivePath.")
	
	return warnings


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		# Create a world environment if needed
		if is_instance_valid(environment) or is_instance_valid(compositor):
			if not is_instance_valid(world_environment):
				world_environment = WorldEnvironment.new()
				add_child(world_environment)
			world_environment.environment = environment
			world_environment.compositor = compositor
	else:
		# Free the world environment if it exists
		if is_instance_valid(world_environment):
			world_environment.queue_free()


func get_spawn_location() -> Transform3D:
	return spawn_location.transform


func get_drive_path() -> Path3D:
	return drive_path


func get_drive_curve() -> Curve3D:
	return drive_path.curve
