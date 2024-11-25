class_name CharacterCard extends Control

@export var player: Player

@onready var name_label: Label = %NameLabel
@onready var character_display: CharacterPreviewRect = %CharacterDisplay


func _process(delta: float) -> void:
	name_label.text = player.nick
	# If no preview kart exists, create one
	# TODO: Remove this from process loop
	if !is_instance_valid(player.preview_kart) and player.kart_metadata:
		player.preview_kart = player.kart_metadata.instantiate()
	character_display.kart = player.preview_kart
