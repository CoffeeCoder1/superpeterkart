extends Menu

signal game_options
signal change_character
signal end_game
signal exit

@onready var end_game_button: Button = $GridContainer/EndGameButton


func _process(delta: float) -> void:
	end_game_button.disabled = multiplayer.get_unique_id() != get_multiplayer_authority()


func _on_game_options_button_pressed() -> void:
	game_options.emit()


func _on_change_character_button_pressed() -> void:
	change_character.emit()


func _on_end_game_button_pressed() -> void:
	end_game.emit()


func _on_exit_button_pressed() -> void:
	exit.emit()
