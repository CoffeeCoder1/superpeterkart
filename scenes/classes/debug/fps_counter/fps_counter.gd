class_name FPSCounter extends Label


func _process(delta: float) -> void:
	text = str(floor(1 / delta))
