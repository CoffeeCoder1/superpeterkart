extends SubViewport

@export var kart: KartMetadata:
	set(new_kart):
		# Set the kart to the new kart
		kart = new_kart
		
		# Instantiate the kart
		var kart_node: Kart = kart.instantiate()
		kart_node.kart_preview = true
		add_child(kart_node)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
