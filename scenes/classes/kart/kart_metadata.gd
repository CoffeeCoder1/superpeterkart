class_name KartMetadata extends Resource

@export var name: String
@export var scene: PackedScene


func get_kart_name() -> String:
	return name


func get_scene() -> PackedScene:
	return scene


func instantiate() -> Node:
	return scene.instantiate()
