class_name Menu extends Control

@export var players: PlayerList

signal create_local_game
## Emitted when a kart is selected for the local player.
signal kart_selected(karts: KartMetadata)
## Emitted when kart selection finishes.
signal kart_selection_finished
signal join_online_game(ip_address: String)
signal host_online_game
signal stop_online_server
signal map_selected(map: MapMetadata)

enum MenuPage {
	START_MENU,
	MAIN_MENU,
	SETTINGS,
	ONLINE_GAME,
	CHARACTER_SELECTION,
	MAP_SELECTION,
	GAME_OPTIONS,
	MULTIPLAYER_CONNECTING,
}
var menu_stack: Array[MenuPage] = []

## Is the game being created going to be an online game?
var online_game: bool
## Is the user in the process of creating a local game?
## If the user is selecting game options and this is false, the user is joining an online game.
var creating_game: bool
## Has the server already been started?
var server_started: bool
## What menu should the NextButton advance to?
var next_menu: MenuPage
## Should the NextButton be enabled?
var next_menu_enabled: bool

@onready var menu_container: VBoxContainer = %MenuContainer
@onready var next_button: Button = %NextButton

@onready var start_menu: Control = %StartMenu
@onready var main_menu: Control = %MainMenu
@onready var settings_menu: Control = %SettingsMenu
@onready var character_selection_menu: Control = %CharacterSelectionMenu
@onready var map_selection_menu: Control = %MapSelectionMenu
@onready var game_options_menu: Control = %GameOptionsMenu
@onready var online_game_menu: Control = %OnlineGameMenu
@onready var multiplayer_connecting_menu: Control = %MultiplayerConnecting
@onready var player_list: Control = %PlayerList


func _ready() -> void:
	player_list.player_list = players
	map_selection_menu.player_list = players


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
	hide()


## Opens the start menu.
## Intended to be run at the start of the game.
func open_menu_start() -> void:
	open_menu(MenuPage.START_MENU)


func _show_menu(menu: MenuPage) -> void:
	show()
	get_tree().call_group("menus", "hide")
	next_menu_enabled = false
	if (menu == MenuPage.START_MENU):
		start_menu.show()
	elif (menu == MenuPage.MAIN_MENU):
		main_menu.show()
		creating_game = false
	elif (menu == MenuPage.SETTINGS):
		settings_menu.show()
	elif (menu == MenuPage.ONLINE_GAME):
		online_game_menu.show()
	elif (menu == MenuPage.CHARACTER_SELECTION):
		character_selection_menu.show()
		character_selection_menu.start()
	elif (menu == MenuPage.MAP_SELECTION):
		map_selection_menu.show()
		map_selection_menu.start()
	elif (menu == MenuPage.GAME_OPTIONS):
		game_options_menu.show()
		next_menu = MenuPage.CHARACTER_SELECTION
		next_menu_enabled = true
	elif (menu == MenuPage.MULTIPLAYER_CONNECTING):
		multiplayer_connecting_menu.show()
	
	if (menu == MenuPage.START_MENU):
		menu_container.hide()
	else:
		menu_container.show()
	
	if next_menu_enabled:
		next_button.show()
	else:
		next_button.hide()
	
	_start_or_stop_server()


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
	if next_menu_enabled:
		open_menu(next_menu)


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
