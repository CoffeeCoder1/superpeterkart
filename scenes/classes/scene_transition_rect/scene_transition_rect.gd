class_name SceneTransitionRect extends ColorRect

@export var fade_time: float = 1.0

signal finished

var tween: Tween


func fade_in() -> void:
	_fade_to(0.0);


func fade_out() -> void:
	_fade_to(1.0);


func _fade_to(alpha: float) -> void:
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", alpha, fade_time)
	tween.finished.connect(finished.emit)
