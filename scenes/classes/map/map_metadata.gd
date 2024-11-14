class_name MapMetadata extends Resource

@export var id: String
@export var name: String
@export var scene: PackedScene


func get_map_id() -> String:
	return id


func get_map_name() -> String:
	return name


func get_scene() -> PackedScene:
	return scene


func instantiate() -> Node:
	return scene.instantiate()
