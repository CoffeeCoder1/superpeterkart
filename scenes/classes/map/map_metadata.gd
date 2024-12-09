class_name MapMetadata extends Resource

@export var id: String
@export var name: String
@export var scene: PackedScene
## How many laps does this map have?
@export var lap_count: int = 3


func get_map_id() -> String:
	return id


func get_map_name() -> String:
	return name


func get_scene() -> PackedScene:
	return scene


func get_lap_count() -> int:
	return lap_count


func instantiate() -> Node:
	return scene.instantiate()
