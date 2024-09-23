extends Control

signal start_game


func _input(event):
	if event.is_pressed() and self.is_visible_in_tree():
		start_game.emit()
