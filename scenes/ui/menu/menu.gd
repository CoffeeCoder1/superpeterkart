class_name Menu extends Control

signal game_started(karts: Array[KartMetadata], map: MapMetadata)
## Emitted when karts are selected in multiplayer.
signal karts_selected(karts: Array[KartMetadata])
signal join_online_game(ip_address: String)
signal host_online_game
signal stop_online_server

enum MenuPage {
	START_MENU,
	MAIN_MENU,
	SETTINGS,
	ONLINE_GAME,
	PLAYER_NUMBER_SELECTION,
	CHARACTER_SELECTION,
	MAP_SELECTION,
	GAME_OPTIONS,
}
var menu_stack: Array[MenuPage] = []

var karts: Array[KartMetadata]
## Is the game being created going to be an online game?
var online_game: bool
## Is the user in the process of creating a local game?
## If the user is selecting game options and this is false, the user is joining an online game.
var creating_game: bool
## Has the server already been started?
var server_started: bool

@onready var menu_container: VBoxContainer = %MenuContainer
@onready var game_options_button: Button = %GameOptionsButton

@onready var start_menu: Control = %StartMenu
@onready var main_menu: Control = %MainMenu
@onready var settings_menu: Control = %SettingsMenu
@onready var player_number_selection_menu: Control = %PlayerNumberSelectionMenu
@onready var character_selection_menu: Control = %CharacterSelectionMenu
@onready var map_selection_menu: Control = %MapSelectionMenu
@onready var game_options_menu: Control = %GameOptionsMenu
@onready var online_game_menu: Control = %OnlineGameMenu


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
	self.hide()


func _show_menu(menu: MenuPage) -> void:
	self.show()
	get_tree().call_group("menus", "hide")
	if (menu == MenuPage.START_MENU):
		start_menu.show()
	elif (menu == MenuPage.MAIN_MENU):
		main_menu.show()
		creating_game = false
	elif (menu == MenuPage.SETTINGS):
		settings_menu.show()
	elif (menu == MenuPage.PLAYER_NUMBER_SELECTION):
		player_number_selection_menu.show()
	elif (menu == MenuPage.ONLINE_GAME):
		online_game_menu.show()
	elif (menu == MenuPage.CHARACTER_SELECTION):
		character_selection_menu.show()
	elif (menu == MenuPage.MAP_SELECTION):
		map_selection_menu.show()
	elif (menu == MenuPage.GAME_OPTIONS):
		game_options_menu.show()
	
	if (menu == MenuPage.START_MENU):
		menu_container.hide()
	else:
		menu_container.show()
	
	if creating_game:
		game_options_button.show()
	else:
		game_options_button.hide()
	
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


func _on_start_menu_start_game() -> void:
	open_menu(MenuPage.MAIN_MENU)


func _on_main_menu_local_game() -> void:
	creating_game = true
	open_menu(MenuPage.PLAYER_NUMBER_SELECTION)
	_start_or_stop_server()


func _on_main_menu_online_game() -> void:
	creating_game = false
	open_menu(MenuPage.ONLINE_GAME)


func _on_main_menu_settings() -> void:
	open_menu(MenuPage.SETTINGS)


func _on_player_number_selection_menu_player_number_selected(number: int) -> void:
	open_menu(MenuPage.CHARACTER_SELECTION)


func _on_game_options_button_pressed() -> void:
	open_menu(MenuPage.GAME_OPTIONS)


func _on_back_button_pressed() -> void:
	back_menu()


func _on_character_selection_menu_character_selected(selected_karts: Array[KartMetadata]) -> void:
	karts = selected_karts
	if creating_game:
		open_menu(MenuPage.MAP_SELECTION)
	else:
		close_menu()
		karts_selected.emit(karts)


func _on_map_selection_menu_map_selected(map: MapMetadata) -> void:
	close_menu()
	game_started.emit(karts, map)


func _on_game_options_menu_online_game_toggled(enabled: bool) -> void:
	online_game = enabled
	_start_or_stop_server()


func _on_online_game_menu_join_online_game(ip_address: String) -> void:
	join_online_game.emit(ip_address)
	close_menu()
