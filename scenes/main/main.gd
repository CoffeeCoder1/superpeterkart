extends Node3D

@onready var menu: Node = $Menu
@onready var multiplayer_lobby: MultiplayerLobby = $MultiplayerLobby


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.open_menu(menu.Menu.START_MENU)


func _on_menu_game_started(karts: Array[KartMetadata], map: MapMetadata) -> void:
	menu.close_menu()
	$Game.new_game(karts, map)
	multiplayer_lobby.load_game.rpc("unreal")


func _on_menu_join_online_game() -> void:
	multiplayer_lobby.join_game()


func _on_menu_host_online_game() -> void:
	multiplayer_lobby.create_game()
