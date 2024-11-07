class_name KartMetadata extends Resource

@export var name: String
@export var scene: PackedScene
## ID used for RPC serialization. Should be unique from all other karts.
@export var id: String


func get_kart_name() -> String:
	return name


func get_scene() -> PackedScene:
	return scene


func instantiate() -> Node:
	return scene.instantiate()


func get_kart_id() -> String:
	return id
