class_name HeadsUpDisplay extends Control

@export var player: Kart

@onready var speed_label: Label = $SpeedLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		speed_label.text = str(player.get_speed())
