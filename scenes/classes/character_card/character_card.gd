class_name CharacterCard extends Control

@export var player: Player

@onready var name_label: Label = %NameLabel
@onready var character_display: CharacterPreviewRect = %CharacterDisplay


func _process(delta: float) -> void:
	name_label.text = player.nick
	character_display.kart = player.kart
