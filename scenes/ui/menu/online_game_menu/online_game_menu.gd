extends Control

signal join_online_game(ip_address: String)

@onready var ip_address_field: LineEdit = %IPAddressField


func _on_join_button_pressed() -> void:
	join_online_game.emit(ip_address_field.text)
