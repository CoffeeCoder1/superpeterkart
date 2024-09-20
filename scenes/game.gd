extends Node3D

var players: Array[Node] = []
var loaded_map: Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Instantiates and adds players and loads the map
func new_game(karts: Array[Node], map: Map) -> void:
	for e in karts:
		add_child(e)
		players.append(e)
	load_map(map)
	print(map.get_path())


# Loads a new map and moves the players to their starting positions
func load_map(map: Map) -> void:
	var map_node = map.instantiate()
	if loaded_map:
		loaded_map.get_parent().remove_child(loaded_map)
	add_child(map_node)
	loaded_map = map_node
