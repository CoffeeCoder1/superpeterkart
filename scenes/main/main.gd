extends Node3D

@onready var menu: Node = $Menu
@onready var multiplayer_lobby: MultiplayerLobby = $MultiplayerLobby
@onready var multiplayer_status_label: Label = $MultiplayerStatusLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.open_menu(menu.Menu.START_MENU)
	multiplayer.connected_to_server.connect(_on_server_connected_ok)


func _on_menu_game_started(karts: Array[KartMetadata], map: MapMetadata) -> void:
	menu.close_menu()
	$Game.new_game(karts, map)
	multiplayer_lobby.load_game.rpc("unreal")


func _on_menu_join_online_game() -> void:
	multiplayer_lobby.join_game()
	multiplayer_status_label.text = "Connecting..."
	multiplayer_status_label.show()


func _on_menu_host_online_game() -> void:
	multiplayer_lobby.create_game()


func _on_server_connected_ok() -> void:
	multiplayer_status_label.hide()


func _on_multiplayer_lobby_connection_failed() -> void:
	multiplayer_status_label.text = "Connection failed"
	multiplayer_status_label.show()
	await get_tree().create_timer(2.0).timeout
	multiplayer_status_label.hide()
	menu.open_menu(menu.Menu.ONLINE_GAME)


func _on_multiplayer_lobby_server_disconnected() -> void:
	menu.open_menu(menu.Menu.MAIN_MENU)


func _on_multiplayer_lobby_connected_to_server() -> void:
	multiplayer_status_label.hide()
