extends Control

signal join_online_game


func _on_join_button_pressed() -> void:
	join_online_game.emit()
