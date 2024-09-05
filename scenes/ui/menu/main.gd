extends Control

signal game_started(karts: Array[Node])

enum Menu {START_MENU, MAIN_MENU, SETTINGS, ONLINE_GAME, PLAYER_NUMBER_SELECTION, CHARACTER_SELECTION}
var menu_stack: Array[Menu] = [Menu.START_MENU]

var karts: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


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
	elif (menu == Menu.SETTINGS):
		$VBoxContainer/PanelContainer/SettingsMenu.show()
	elif (menu == Menu.PLAYER_NUMBER_SELECTION):
		$VBoxContainer/PanelContainer/PlayerNumberSelectionMenu.show()
	elif (menu == Menu.ONLINE_GAME):
		pass
	elif (menu == Menu.CHARACTER_SELECTION):
		$VBoxContainer/PanelContainer/CharacterSelectionMenu.show()
	
	if (menu == Menu.START_MENU):
		$VBoxContainer.hide()
	else:
		$VBoxContainer.show()


func _on_start_menu_start_game() -> void:
	open_menu(Menu.MAIN_MENU)


func _on_main_menu_local_game() -> void:
	open_menu(Menu.PLAYER_NUMBER_SELECTION)


func _on_main_menu_online_game() -> void:
	open_menu(Menu.ONLINE_GAME)


func _on_main_menu_settings() -> void:
	open_menu(Menu.SETTINGS)


func _on_player_number_selection_menu_player_number_selected(number: int) -> void:
	open_menu(Menu.CHARACTER_SELECTION)


func _on_back_button_pressed() -> void:
	back_menu()


func _on_character_selection_menu_character_selected(selected_karts: Array[Node]) -> void:
	karts = selected_karts
	close_menu()
	game_started.emit(karts)
