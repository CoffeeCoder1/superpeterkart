extends Node3D

var players = []


func new_game(karts) -> void:
	for e in karts:
		var kart = load(e)
		add_child(kart.instantiate())
		players.append(kart)


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
