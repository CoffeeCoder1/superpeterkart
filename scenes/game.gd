extends Node3D

var players: Array[Node] = []
var loaded_map: Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Adds players and loads the map
func new_game(karts: Array[Node], map: MapMetadata) -> void:
	# Add players
	for e in karts:
		add_child(e)
		players.append(e)
	
	# Load map
	load_map(map)


# Loads a new map and moves the players to their starting positions
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
	
	# Move the players to the spawn location
	for player in players:
		player.transform = loaded_map.get_spawn_location()
