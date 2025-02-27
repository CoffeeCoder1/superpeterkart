class_name Game extends Node3D

@export var players: PlayerList

## Emitted when the game starts.
signal game_started
## Emitted when the game ends.
signal game_ended

@onready var heads_up_display: HeadsUpDisplay = $HeadsUpDisplay
@onready var map_loader: MapLoader = %MapLoader
@onready var kart_loader: KartLoader = %KartLoader

enum GameState {
	LOBBY,
	CREATING,
	PLAYING,
}

## What state is the game in?
var game_state: GameState = GameState.LOBBY
## What is the highest lap that has been reached this game?
var highest_lap: int
## What will the place of the next player to win be?
var current_place: int


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	kart_loader.players = players
	GameSettings.profile_changed.connect(set_player_profile)
	hide()


func _on_visibility_changed() -> void:
	heads_up_display.visible = visible


## Sets the current game state.
func set_game_state(new_state: GameState):
	_set_game_state.rpc(new_state)


@rpc("authority", "reliable", "call_local")
func _set_game_state(new_state: GameState):
	game_state = new_state


## Starts the game.
## Should only be called on the server.
func start_game() -> void:
	_start_game.rpc()
	set_game_state(GameState.PLAYING)


## Starts the game on the client.
## Called by the authority.
@rpc("authority", "reliable", "call_local")
func _start_game() -> void:
	highest_lap = 0
	current_place = 0
	game_started.emit()


## Ends the game.
## Should only be called on the server.
func end_game() -> void:
	kart_loader.set_players_enabled(false)
	set_game_state(GameState.CREATING)
	_end_game.rpc()
	kart_loader.spawn_queued_players()


## Ends the game on the client.
## Called by the authority.
@rpc("authority", "reliable", "call_local")
func _end_game() -> void:
	game_ended.emit()
	for player in players.players:
		player.lap = 0


## Unloads things.
func unload() -> void:
	map_loader.unload_map()
	hide()


## Adds a player to the game and syncs the map and karts to it.
func add_player(player_id: int) -> void:
	# Sync game state
	_set_game_state.rpc_id(player_id, game_state)
	
	for player in players.players:
		sync_player_to_client(player_id, player)
	
	_add_player.rpc(player_id, game_state == GameState.PLAYING)
	
	sync_player_profile.rpc_id(player_id)
	
	# Load the current map and karts.
	map_loader.sync_to_client(player_id)
	kart_loader.sync_to_client(player_id)


## Adds a player to a client by ID.
func sync_player_to_client(client_id: int, player: Player) -> void:
	_add_player.rpc_id(client_id, player.player_id, player.queued)


@rpc("authority", "reliable", "call_local")
func _add_player(player_id: int, queued: bool = true) -> void:
	var player := Player.new()
	player.player_id = player_id
	
	# Queue the player
	player.queued = queued
	
	players.add_player(player)
	
	if player_id == multiplayer.get_unique_id():
		heads_up_display.player = player


## Removes a player from the game.
func remove_player(player_id: int) -> void:
	_remove_player.rpc(player_id)


@rpc("authority", "reliable", "call_local")
func _remove_player(player_id: int) -> void:
	players.remove_player_by_id(player_id)


## Loads a map and prepares the players.
## Should only be called on the server.
func load_map(map: MapMetadata) -> void:
	map_loader.load_map(map)
	kart_loader.prepare_players(map_loader.get_spawn_location())


## Sets the kart of the local player.
func set_player_kart(kart: KartMetadata) -> void:
	kart_loader.set_local_player_kart(kart)


func sync_player_profile() -> void:
	set_player_profile(GameSettings.profile)


func set_player_profile(new_profile: PlayerProfile) -> void:
	_set_player_profile.rpc(new_profile.nickname)


@rpc("any_peer", "reliable", "call_local")
func _set_player_profile(nickname: String) -> void:
	var player := players.get_player_by_id(multiplayer.get_remote_sender_id())
	
	if is_instance_valid(player):
		# Create a new profile if one doesn't already exist.
		if !is_instance_valid(player.profile):
			player.profile = PlayerProfile.new()
		
		# Sync profile parameters to client.
		player.profile.nickname = nickname


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_game_end") and multiplayer.get_unique_id() == get_multiplayer_authority():
		## TODO: Actually add proper game end logic.
		end_game()


func _on_map_loader_map_loaded(map: Map) -> void:
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		kart_loader.set_players_map(map)
	heads_up_display.lap_count = map_loader.get_lap_count()


func _on_lap_finished(player_id: int) -> void:
	_increment_player_lap.rpc(player_id)


@rpc("authority", "reliable", "call_local")
func _increment_player_lap(player_id: int) -> void:
	var player := players.get_player_by_id(player_id)
	player.lap += 1
	
	# Player finished last lap
	if player.lap == map_loader.get_lap_count():
		print(player_id, "won! :3")
		player.kart.kart_enabled = false
		
		player.place = current_place
		current_place += 1
		
		if current_place == len(players.players):
			print("game end")
			end_game()
	
	# Player is the first to enter next lap
	if player.lap > highest_lap:
		highest_lap = player.lap
		
		if highest_lap == map_loader.get_lap_count() - 1:
			print("final lap")
		elif highest_lap == map_loader.get_lap_count():
			print("final lap finished")
