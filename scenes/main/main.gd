extends Node3D

@export var kart_list: KartList
@export var map_list: MapList

@onready var menu: Menu = $Menu
@onready var game: Game = $Game
@onready var multiplayer_lobby: MultiplayerLobby = $MultiplayerLobby
@onready var multiplayer_status_label: Label = $MultiplayerStatusLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	
	if (OS.get_cmdline_args().has("host")):
		menu._on_main_menu_local_game()
	elif (OS.get_cmdline_args().has("join")):
		_on_menu_join_online_game("127.0.0.1")
	else:
		menu.open_menu_start()


func _on_menu_create_local_game() -> void:
	# Add the server to the new game
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		game.add_player(1)


func _on_menu_join_online_game(ip_address: String) -> void:
	multiplayer_lobby.join_game(ip_address)


func _on_menu_host_online_game() -> void:
	multiplayer_lobby.create_game()


func _on_multiplayer_lobby_connection_failed() -> void:
	multiplayer_status_label.text = "Connection failed"
	multiplayer_status_label.show()
	await get_tree().create_timer(2.0).timeout
	multiplayer_status_label.hide()
	menu.open_menu(Menu.MenuPage.ONLINE_GAME)


func _on_multiplayer_lobby_server_disconnected() -> void:
	menu.open_menu(Menu.MenuPage.MAIN_MENU)


func _on_menu_kart_selected(kart: KartMetadata) -> void:
	game.set_player_kart(kart)


func _on_menu_kart_selection_finished() -> void:
	# Open the next menu
	if game.game_state == Game.GameState.CREATING:
		menu.open_menu(Menu.MenuPage.MAP_SELECTION)
	elif game.game_state == Game.GameState.PLAYING:
		menu.close_menu()


func _on_menu_map_selected(map: MapMetadata) -> void:
	# Only load a map if calling on the authority
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		game.load_map(map)
		game.start_game()


func _on_game_started() -> void:
	menu.close_menu()


func _on_game_ended() -> void:
	menu.open_menu(Menu.MenuPage.MAP_SELECTION)
	print("end", multiplayer.get_unique_id())


func _on_player_connected(id: int) -> void:
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		# Sends the current game's info to the new player.
		set_game_info.rpc_id(id, game.game_state)
		
		game.add_player(id)


## Called by the server when a player joins the game.
@rpc("authority", "reliable")
func set_game_info(current_state: Game.GameState) -> void:
	game.game_state = current_state
	
	if game.game_state == Game.GameState.PLAYING:
		menu.select_local_character()
	else:
		menu.select_characters()
