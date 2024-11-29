class_name HeadsUpDisplay extends Control

@export var player: Player

@onready var speed_label: Label = $SpeedLabel


func _process(delta: float) -> void:
	if player:
		if is_instance_valid(player.kart):
			speed_label.text = str(player.kart.get_speed())
