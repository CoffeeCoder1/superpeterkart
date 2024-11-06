class_name MultiplayerLobby extends Node

@export var default_server_ip: String = "127.0.0.1"
@export var port: int = 7000
## The maximum number of clients that can connect to the server.
@export var max_connections: int = 20
@export var game_node: Game

## Emitted when a connection to the server is successfully made.
signal connected_to_server
## Emitted when disconnected from the server.
signal server_disconnected
## Emitted when the connection failed.
signal connection_failed


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address: String = ""):
	if address.is_empty():
		address = default_server_ip
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_connections)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func _on_player_connected(id) -> void:
	# Send player info about the current game
	if game_node.is_game_loaded():
		load_game.rpc_id(id, "unreal")


@rpc("any_peer", "reliable")
func load_game(map_id: String) -> void:
	game_node.load_map(game_node.get_map_metadata_by_id(map_id))


func _on_connected_ok():
	connected_to_server.emit()


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	connection_failed.emit()


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()
