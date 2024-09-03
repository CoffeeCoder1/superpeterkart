extends Node3D

var players = []


func new_game(karts: Array[Node]) -> void:
	for e in karts:
		e.get_parent().remove_child(e)
		add_child(e)
		players.append(e)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# var camera = Camera3D.new()
	# $TestKart.add_child(camera)
	# camera.owner = self
	# camera.make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
