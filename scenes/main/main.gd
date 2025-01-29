extends Node3D

@export var kart_list: KartList
@export var map_list: MapList

@onready var menu: MenuSystem = $MenuSystem
@onready var game: Game = $Game
@onready var multiplayer_lobby: MultiplayerLobby = $MultiplayerLobby
@onready var multiplayer_status_label: Label = $MultiplayerStatusLabel
@onready var scene_transition_rect: SceneTransitionRect = $SceneTransitionRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	
	GameSettings.load_settings()
	
	if (OS.get_cmdline_args().has("host")):
		menu._on_main_menu_local_game()
	elif (OS.get_cmdline_args().has("join")):
		_on_menu_join_online_game("127.0.0.1")
	else:
		menu.open_menu_start()
	
	scene_transition_rect.fade_in()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and game.game_state == Game.GameState.PLAYING:
		menu.pause()


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
	menu.open_menu(MenuSystem.MenuPage.ONLINE_GAME)


func _on_multiplayer_lobby_server_disconnected() -> void:
	get_tree().reload_current_scene()


func _on_menu_kart_selected(kart: KartMetadata) -> void:
	game.set_player_kart(kart)


func _on_menu_kart_selection_finished() -> void:
	# Open the next menu
	if game.game_state == Game.GameState.CREATING:
		menu.open_menu(MenuSystem.MenuPage.MAP_SELECTION)
	elif game.game_state == Game.GameState.PLAYING:
		menu.close_menu()


func _on_menu_map_selected(map: MapMetadata) -> void:
	# Only load a map if calling on the authority
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		game.load_map(map)
		game.start_game()


func _on_game_started() -> void:
	scene_transition_rect.fade_out()
	await scene_transition_rect.finished
	menu.close_menu()
	game.show()
	scene_transition_rect.fade_in()


## Called on all clients when the game ends.
func _on_game_ended() -> void:
	menu.open_menu(MenuSystem.MenuPage.LEADERBOARD)
	print("end", multiplayer.get_unique_id())


func _on_player_connected(id: int) -> void:
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		game.add_player(id)
		menu.initialize_player(id)


func _on_player_disconnected(id: int) -> void:
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		game.remove_player(id)


func _on_menu_system_leaderboard_end() -> void:
	scene_transition_rect.fade_out()
	await scene_transition_rect.finished
	game.unload()
	menu.open_menu(MenuSystem.MenuPage.MAP_SELECTION)
	scene_transition_rect.fade_in()


func _on_menu_system_end_game() -> void:
	game.end_game()


func _on_menu_system_exit() -> void:
	# TODO: Gracefully disconnect clients
	if not multiplayer.get_unique_id() == get_multiplayer_authority():
		multiplayer_lobby.leave_game()
	get_tree().reload_current_scene()
