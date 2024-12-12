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


func leave_game():
	multiplayer.multiplayer_peer.close()


func _on_connected_ok():
	connected_to_server.emit()


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	connection_failed.emit()


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()
