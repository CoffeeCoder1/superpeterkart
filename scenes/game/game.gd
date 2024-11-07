class_name Game extends Node3D

@onready var players_node: Node3D = $Players

var players: Array[Kart] = []
var loaded_map: Node

var map_metadatas: Dictionary = {
	"test_map": "res://scenes/maps/test_map/test_map.tres",
	"unreal": "res://scenes/maps/unreal/unreal.tres",
}

var kart_metadatas: Dictionary = {
	"debug_kart": "res://scenes/karts/debug_kart/debug_kart.tres",
	"suzanne": "res://scenes/karts/suzanne/suzanne.tres",
}


## Loads a map with the provided karts.
func new_game(karts: Array[KartMetadata], map: MapMetadata) -> void:
	load_map(map)
	add_karts(karts)


## Loads a new map.
func load_map(map: MapMetadata) -> void:
	# Instantiate the map
	var map_node = map.instantiate()
	
	# Remove the last map if one was loaded
	if loaded_map:
		loaded_map.get_parent().remove_child(loaded_map)
		# Schedules the map to be deleted from memory
		loaded_map.queue_free()
	
	# Add the map to the scene
	add_child(map_node)
	
	# Save the map so it can be unloaded later
	loaded_map = map_node


## Adds karts to the game.
func add_karts(karts: Array[KartMetadata]) -> void:
	for kart in karts:
		var kart_node = kart.instantiate()
		kart_node.transform = loaded_map.get_spawn_location()
		players_node.add_child(kart_node)
		players.append(kart_node)


func is_game_loaded() -> bool:
	if loaded_map:
		return true
	else:
		return false


func get_map_metadata_by_id(id: String) -> MapMetadata:
	return load(map_metadatas.get(id)) as MapMetadata


func get_kart_metadata_by_id(id: String) -> KartMetadata:
	return load(kart_metadatas.get(id)) as KartMetadata


@rpc("any_peer", "reliable")
func add_kart_by_id(id: String) -> void:
	add_karts([get_kart_metadata_by_id(id)])
