class_name MapLoader extends Node

@export var map_list: MapList

var loaded_map_id: String
var loaded_map: Map


## Loads a new map on all clients.
## Should only be called on the authority.
func load_map(map: MapMetadata) -> void:
	var map_id := map_list.get_map_id(map)
	loaded_map_id = map_id
	_load_map.rpc(map_id)


## Loads a new map.
## Called by the authority on all clients.
@rpc("authority", "reliable", "call_local")
func _load_map(map_id: String) -> void:
	# Instantiate the map
	var map_node := map_list.get_map_by_id(map_id).instantiate() as Map
	
	unload_map()
	
	# Add the map to the scene
	add_child(map_node)
	
	# Save the map so it can be unloaded later
	loaded_map = map_node


## Tells a client what the current map is.
func sync_to_client(player_id: int):
	if loaded_map_id:
		_load_map.rpc_id(player_id, loaded_map_id)


## Unloads a map if one is currently loaded.
func unload_map() -> void:
	if is_instance_valid(loaded_map):
		# Schedules the map to be deleted from memory
		loaded_map.queue_free()


## Gets the spawn location of the loaded map.
func get_spawn_location() -> Transform3D:
	return loaded_map.get_spawn_location()
