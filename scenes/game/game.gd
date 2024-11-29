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
	CREATING,
	PLAYING,
}

## What state is the game in?
var game_state: GameState = GameState.CREATING


func _ready() -> void:
	kart_loader.players = players


## Starts the game.
## Should only be called on the server.
func start_game() -> void:
	_start_game.rpc()


## Starts the game on the client.
## Called by the authority.
@rpc("authority", "reliable", "call_local")
func _start_game() -> void:
	game_state = GameState.PLAYING
	game_started.emit()


## Ends the game.
## Should only be called on the server.
@rpc("any_peer", "reliable", "call_local")
func end_game() -> void:
	kart_loader.set_players_enabled(false)
	_end_game.rpc()
	kart_loader.spawn_queued_players()


## Ends the game on the client.
## Called by the authority.
@rpc("authority", "reliable", "call_local")
func _end_game() -> void:
	game_state = GameState.CREATING
	game_ended.emit()
	map_loader.unload_map()


## Adds a player to the game and syncs the map and karts to it.
func add_player(player_id: int) -> void:
	_add_player.rpc(player_id, game_state == GameState.PLAYING)
	
	# Load the current map and karts.
	map_loader.sync_to_client(player_id)
	kart_loader.sync_to_client(player_id)


@rpc("authority", "reliable", "call_local")
func _add_player(player_id: int, queued: bool = true) -> void:
	var player := Player.new()
	player.player_id = player_id
	
	# Queue the player
	player.queued = queued
	
	players.add_player(player)
	
	if player_id == multiplayer.get_unique_id():
		heads_up_display.player = player


## Loads a map and prepares the players.
func load_map(map: MapMetadata) -> void:
	map_loader.load_map(map)
	kart_loader.prepare_players(map_loader.get_spawn_location())


## Sets the kart of the local player.
func set_player_kart(kart: KartMetadata) -> void:
	kart_loader.set_local_player_kart(kart)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		## TODO: Actually add proper game end logic.
		end_game.rpc_id(1)
