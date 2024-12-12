class_name MenuSystem extends Control

@export var players: PlayerList
@export var game: Game
## Is the next button timed?
@export var next_button_timed: bool = true
@export var next_button_timing: float = 15.0
@export var next_button_label: String = "Next"

signal create_local_game
## Emitted when a kart is selected for the local player.
signal kart_selected(karts: KartMetadata)
## Emitted when kart selection finishes.
signal kart_selection_finished
signal join_online_game(ip_address: String)
signal host_online_game
signal stop_online_server
signal map_selected(map: MapMetadata)
signal end_game
signal exit

enum MenuPage {
	START_MENU,
	MAIN_MENU,
	SETTINGS,
	ONLINE_GAME,
	CHARACTER_SELECTION,
	MAP_SELECTION,
	GAME_OPTIONS,
	MULTIPLAYER_CONNECTING,
	LEADERBOARD,
	PAUSE_MENU,
}
var menu_stack: Array[MenuPage] = []

## Is the game being created going to be an online game?
var online_game: bool
## Is the user in the process of creating a local game?
## If the user is selecting game options and this is false, the user is joining an online game.
var creating_game: bool
## Has the server already been started?
var server_started: bool
## What menu is currently selected?
var current_menu: Menu
## Used to automatically advance to the next menu.
var next_button_time_left: float
## Is the pause menu active?
var pause_menu_active: bool

@onready var menu_container: VBoxContainer = %MenuContainer
@onready var next_button: Button = %NextButton
@onready var player_list: PlayerListDisplay = %PlayerList

@onready var start_menu: Menu = %StartMenu
@onready var main_menu: Menu = %MainMenu
@onready var settings_menu: Menu = %SettingsMenu
@onready var character_selection_menu: Menu = %CharacterSelectionMenu
@onready var map_selection_menu: Menu = %MapSelectionMenu
@onready var game_options_menu: Menu = %GameOptionsMenu
@onready var online_game_menu: Menu = %OnlineGameMenu
@onready var multiplayer_connecting_menu: Menu = %MultiplayerConnecting
@onready var leaderboard: Menu = %Leaderboard
@onready var pause_menu: Menu = %PauseMenu


func _ready() -> void:
	player_list.player_list = players
	map_selection_menu.player_list = players
	leaderboard.player_list = players
	character_selection_menu.game = game
	
	next_button.hide()


func _process(delta: float) -> void:
	# Next button timer
	if is_instance_valid(current_menu) and visible:
		if next_button_timed and current_menu.has_method("_on_next_button"):
			if multiplayer.get_unique_id() == get_multiplayer_authority():
				if next_button_time_left <= 0:
					# Timout
					_next_button_timeout_reached.rpc()
				else:
					# Decrement timer
					next_button_time_left -= delta
					_sync_next_button_time.rpc(next_button_time_left)
			next_button.text = next_button_label + " (" + str(int(next_button_time_left)) + ")"
		else:
			next_button.text = next_button_label
	
	next_button.set_disabled(!multiplayer.get_unique_id() == get_multiplayer_authority())


@rpc("authority", "reliable", "call_local")
func open_menu(menu: MenuPage) -> void:
	menu_stack.append(menu)
	_show_menu(menu)


func back_menu() -> void:
	menu_stack.pop_back()
	if !menu_stack.is_empty():
		_show_menu(menu_stack[-1])
	else:
		close_menu()


func close_menu() -> void:
	menu_stack = []
	pause_menu_active = false
	hide()


## Opens the start menu.
## Intended to be run at the start of the game.
func open_menu_start() -> void:
	open_menu(MenuPage.START_MENU)


## Opens the character selection menu on local client and doesn't wait for the server.
func select_local_character() -> void:
	next_button_timed = false
	open_menu(MenuPage.CHARACTER_SELECTION)


## Opens the character selection menu and waits for the server.
func select_characters() -> void:
	next_button_timed = true
	open_menu(MenuPage.CHARACTER_SELECTION)


## Initializes the menu for a given player.
func initialize_player(id: int) -> void:
	if not game.game_state == Game.GameState.LOBBY:
		open_menu.rpc_id(id, MenuPage.CHARACTER_SELECTION)


## Opens the pause menu for the local player.
func pause() -> void:
	if len(menu_stack) == 0:
		pause_menu_active = true
		open_menu(MenuPage.PAUSE_MENU)


func _show_menu(menu: MenuPage) -> void:
	show()
	get_tree().call_group("menus", "hide")
	if (menu == MenuPage.START_MENU):
		current_menu = start_menu
	elif (menu == MenuPage.MAIN_MENU):
		current_menu = main_menu
		creating_game = false
		game.game_state = Game.GameState.LOBBY
	elif (menu == MenuPage.SETTINGS):
		current_menu = settings_menu
	elif (menu == MenuPage.ONLINE_GAME):
		current_menu = online_game_menu
	elif (menu == MenuPage.CHARACTER_SELECTION):
		current_menu = character_selection_menu
	elif (menu == MenuPage.MAP_SELECTION):
		current_menu = map_selection_menu
	elif (menu == MenuPage.GAME_OPTIONS):
		current_menu = game_options_menu
	elif (menu == MenuPage.MULTIPLAYER_CONNECTING):
		current_menu = multiplayer_connecting_menu
	elif (menu == MenuPage.LEADERBOARD):
		current_menu = leaderboard
	elif (menu == MenuPage.PAUSE_MENU):
		current_menu = pause_menu
	
	if (menu == MenuPage.START_MENU):
		menu_container.hide()
	else:
		menu_container.show()
	
	if current_menu.has_method("_update"):
		current_menu.call("_update")
	
	if current_menu.has_method("_on_next_button") and !pause_menu_active:
		next_button.show()
	else:
		next_button.hide()
	
	next_button_time_left = current_menu.get_meta("next_button_timing", next_button_timing)
	player_list.visible = current_menu.get_meta("show_player_list", false)
	player_list.show_map_vote = current_menu.get_meta("show_player_map_vote", false)
	
	current_menu.show()
	
	_start_or_stop_server()


## Syncs next button timer to a client.
@rpc("authority", "reliable")
func _sync_next_button_time(time: float) -> void:
	next_button_time_left = time


## Called by the authority when the menu timeout is reached.
## Called locally when timed is false.
@rpc("authority", "reliable", "call_local")
func _next_button_timeout_reached() -> void:
	_on_next_button_pressed()


## Starts or stops the server depending on the state of the menu.
func _start_or_stop_server() -> void:
	if creating_game and online_game:
		if !server_started:
			host_online_game.emit()
			server_started = true
	else:
		if server_started:
			stop_online_server.emit()
			server_started = false


func _on_next_button_pressed() -> void:
	if is_instance_valid(current_menu):
		if current_menu.has_method("_on_next_button"):
			current_menu.call("_on_next_button")


func _on_back_button_pressed() -> void:
	back_menu()


func _on_start_menu_start_game() -> void:
	open_menu(MenuPage.MAIN_MENU)


func _on_main_menu_settings() -> void:
	open_menu(MenuPage.SETTINGS)


func _on_main_menu_local_game() -> void:
	creating_game = true
	create_local_game.emit()
	open_menu(MenuPage.GAME_OPTIONS)


func _on_game_options_menu_online_game_toggled(enabled: bool) -> void:
	online_game = enabled
	_start_or_stop_server()


func _on_game_options_menu_menu_advance() -> void:
	open_menu.rpc(MenuPage.CHARACTER_SELECTION)
	game.set_game_state(Game.GameState.CREATING)


func _on_main_menu_online_game() -> void:
	creating_game = false
	open_menu(MenuPage.ONLINE_GAME)


func _on_online_game_menu_join_online_game(ip_address: String) -> void:
	join_online_game.emit(ip_address)
	open_menu(MenuPage.MULTIPLAYER_CONNECTING)


func _on_character_selection_menu_character_selected(kart: KartMetadata) -> void:
	kart_selected.emit(kart)


func _on_character_selection_menu_menu_advance() -> void:
	kart_selection_finished.emit()


func _on_map_selection_menu_map_selected(map: MapMetadata) -> void:
	map_selected.emit(map)


func _on_leaderboard_menu_advance() -> void:
	open_menu(MenuPage.MAP_SELECTION)


func _on_pause_menu_game_options() -> void:
	open_menu(MenuPage.GAME_OPTIONS)


func _on_pause_menu_change_character() -> void:
	select_local_character()


func _on_pause_menu_end_game() -> void:
	pause_menu_active = false
	end_game.emit()


func _on_pause_menu_exit() -> void:
	pause_menu_active = false
	exit.emit()
