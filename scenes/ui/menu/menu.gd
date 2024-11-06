extends Control

signal game_started(karts: Array[KartMetadata], map: MapMetadata)
signal join_online_game
signal host_online_game
signal stop_online_server

enum Menu {
	START_MENU,
	MAIN_MENU,
	SETTINGS,
	ONLINE_GAME,
	PLAYER_NUMBER_SELECTION,
	CHARACTER_SELECTION,
	MAP_SELECTION,
	GAME_OPTIONS,
}
var menu_stack: Array[Menu] = [Menu.START_MENU]

var karts: Array[KartMetadata]
## Is the game being created going to be an online game?
var online_game: bool
## Is the user in the process of creating a local game?
var creating_game: bool
## Has the server already been started?
var server_started: bool


func open_menu(menu: Menu) -> void:
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


func _show_menu(menu: Menu) -> void:
	self.show()
	get_tree().call_group("menus", "hide")
	if (menu == Menu.START_MENU):
		$StartMenu.show()
	elif (menu == Menu.MAIN_MENU):
		$VBoxContainer/PanelContainer/MainMenu.show()
		creating_game = false
	elif (menu == Menu.SETTINGS):
		$VBoxContainer/PanelContainer/SettingsMenu.show()
	elif (menu == Menu.PLAYER_NUMBER_SELECTION):
		$VBoxContainer/PanelContainer/PlayerNumberSelectionMenu.show()
	elif (menu == Menu.ONLINE_GAME):
		$VBoxContainer/PanelContainer/OnlineGameMenu.show()
	elif (menu == Menu.CHARACTER_SELECTION):
		$VBoxContainer/PanelContainer/CharacterSelectionMenu.show()
	elif (menu == Menu.MAP_SELECTION):
		$VBoxContainer/PanelContainer/MapSelectionMenu.show()
	elif (menu == Menu.GAME_OPTIONS):
		$VBoxContainer/PanelContainer/GameOptionsMenu.show()
	
	if (menu == Menu.START_MENU):
		$VBoxContainer.hide()
	else:
		$VBoxContainer.show()
	
	if creating_game:
		$VBoxContainer/HBoxContainer/GameOptionsButton.show()
	else:
		$VBoxContainer/HBoxContainer/GameOptionsButton.hide()
	
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
	open_menu(Menu.MAIN_MENU)


func _on_main_menu_local_game() -> void:
	creating_game = true
	open_menu(Menu.PLAYER_NUMBER_SELECTION)
	_start_or_stop_server()


func _on_main_menu_online_game() -> void:
	open_menu(Menu.ONLINE_GAME)


func _on_main_menu_settings() -> void:
	open_menu(Menu.SETTINGS)


func _on_player_number_selection_menu_player_number_selected(number: int) -> void:
	open_menu(Menu.CHARACTER_SELECTION)


func _on_game_options_button_pressed() -> void:
	open_menu(Menu.GAME_OPTIONS)


func _on_back_button_pressed() -> void:
	back_menu()


func _on_character_selection_menu_character_selected(selected_karts: Array[KartMetadata]) -> void:
	karts = selected_karts
	open_menu(Menu.MAP_SELECTION)


func _on_map_selection_menu_map_selected(map: MapMetadata) -> void:
	close_menu()
	game_started.emit(karts, map)


func _on_game_options_menu_online_game_toggled(enabled: bool) -> void:
	online_game = enabled
	_start_or_stop_server()


func _on_online_game_menu_join_online_game() -> void:
	join_online_game.emit()
	close_menu()
