extends Menu

signal local_game
signal online_game
signal settings


func _on_local_game_button_pressed() -> void:
	local_game.emit()


func _on_online_game_button_pressed() -> void:
	online_game.emit()


func _on_settings_button_pressed() -> void:
	settings.emit()
