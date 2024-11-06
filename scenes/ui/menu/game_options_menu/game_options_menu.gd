extends Control

signal online_game_toggled(enabled: bool)


func _on_online_game_switch_toggled(toggled_on: bool) -> void:
	online_game_toggled.emit(toggled_on)
