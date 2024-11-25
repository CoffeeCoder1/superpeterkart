class_name Game extends Node3D

@export var kart_list: KartList
@export var map_list: MapList
@export var players: PlayerList

## Emitted when the game starts.
signal game_started
## Emitted when the game ends.
signal game_ended

@onready var players_node: Node3D = $Players
@onready var heads_up_display: HeadsUpDisplay = $HeadsUpDisplay

enum GameState {
	CREATING,
	PLAYING,
}

var current_map_id: String
var loaded_map: Map
var loaded_karts: Array[Kart]
## What state is the game in?
var game_state: GameState = GameState.CREATING


## Starts the game.
func start_game() -> void:
	_start_game.rpc()


@rpc("authority", "reliable", "call_local")
func _start_game() -> void:
	game_state = GameState.PLAYING
	game_started.emit()


## Ends the game.
@rpc("any_peer", "reliable", "call_local")
func end_game() -> void:
	_set_players_enabled.rpc(false)
	_end_game.rpc()
	_spawn_queued_players()


@rpc("authority", "reliable", "call_local")
func _end_game() -> void:
	game_state = GameState.CREATING
	game_ended.emit()
	_unload_map()


## Loads a new map.
func load_map(map: MapMetadata) -> void:
	var map_id := map_list.get_map_id(map)
	current_map_id = map_id
	_load_map.rpc(map_id)
	
	for i in len(players.players):
		var player := players.players[i]
		# Move the karts to the spawn location and set their velocities to 0
		if player.kart:
			player.kart.transform = loaded_map.get_spawn_location().translated(Vector3.RIGHT * (2 * i))
			player.kart.velocity = Vector3.ZERO
	
	# Enable players
	_set_players_enabled.rpc(true)


## Loads a new map.
@rpc("authority", "reliable", "call_local")
func _load_map(map_id: String) -> void:
	# Instantiate the map
	var map_node := map_list.get_map_by_id(map_id).instantiate() as Map
	
	_unload_map()
	
	# Add the map to the scene
	add_child(map_node)
	
	# Save the map so it can be unloaded later
	loaded_map = map_node


## Adds a player to the game
func add_player(player_id: int) -> void:
	_add_player.rpc(player_id, game_state == GameState.PLAYING)
	
	# Load the current map.
	if current_map_id:
		_load_map.rpc_id(player_id, current_map_id)
	
	# Add the current players
	for player in players.players:
		if player.kart:
			_spawn_kart(player.player_id, kart_list.get_kart_id(player.kart_metadata))


@rpc("authority", "reliable", "call_local")
func _add_player(player_id: int, queued: bool = true) -> void:
	var player := Player.new()
	player.player_id = player_id
	
	# Queue the player
	player.queued = queued
	
	players.add_player(player)


## Sets a player's kart.
@rpc("any_peer", "reliable", "call_local")
func set_player_kart(kart_id: String) -> void:
	var player_id := multiplayer.get_remote_sender_id()
	var player := players.get_player_by_id(player_id)
	
	print(player.queued)
	
	player.kart_metadata = kart_list.get_kart_by_id(kart_id)
	
	# Spawn in the new player's kart
	if !player.queued:
		_spawn_kart.rpc(player_id, kart_id)


## Spawn a kart.
@rpc("authority", "reliable", "call_local")
func _spawn_kart(player_id: int, kart_id: String) -> void:
	var kart_node := kart_list.get_kart_by_id(kart_id).instantiate() as Kart
	# Used to place the new kart in the same place the last one was.
	var old_transform: Transform3D
	
	var player := players.get_player_by_id(player_id)
	if player:
		if is_instance_valid(player.kart):
			old_transform = player.kart.transform
			player.kart.queue_free()
		player.kart = kart_node
	
	# Set the player's ID so the player can control the kart they spawned.
	kart_node.player_id = player_id
	
	if player_id == multiplayer.get_unique_id():
		heads_up_display.player = kart_node
	
	# Disable the kart if the game hasn't started yet
	kart_node.kart_enabled = (game_state == GameState.PLAYING)
	
	# Spawn in the new kart.
	kart_node.set_name(kart_id + str(player_id))
	players_node.add_child(kart_node)
	
	if multiplayer.get_unique_id() == get_multiplayer_authority() and old_transform:
		kart_node.transform = old_transform


## Unloads a map if one is currently loaded.
func _unload_map() -> void:
	if is_instance_valid(loaded_map):
		# Schedules the map to be deleted from memory
		loaded_map.queue_free()


# Spawns in any queued players
func _spawn_queued_players() -> void:
	for player in players.players:
		if player.kart_metadata and player.queued:
			player.queued = false
			_spawn_kart(player.player_id, kart_list.get_kart_id(player.kart_metadata))


## Enables or disables the players
@rpc("authority", "reliable", "call_local")
func _set_players_enabled(enabled: bool) -> void:
	for player in players.players:
		if player.kart:
			player.kart.kart_enabled = enabled


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		## TODO: Actually add proper game end logic.
		end_game.rpc_id(1)
