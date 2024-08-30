extends Control

# Number of local players (0-3 - 0-indexed)
signal player_number_selected(number: int)


func _on_one_player_button_pressed() -> void:
	player_number_selected.emit(0)


func _on_two_players_button_pressed() -> void:
	player_number_selected.emit(1)


func _on_three_players_button_pressed() -> void:
	player_number_selected.emit(2)


func _on_four_players_button_pressed() -> void:
	player_number_selected.emit(3)
