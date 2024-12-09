class_name HeadsUpDisplay extends Control

@export var player: Player

@onready var speed_label: Label = $SpeedLabel
@onready var lap_label: Label = $LapLabel


func _process(delta: float) -> void:
	if is_instance_valid(player):
		if is_instance_valid(player.kart):
			speed_label.text = str(player.kart.get_speed())
		lap_label.text = str(player.lap)
