extends SubViewport

var kart_node: Kart

@export var kart: KartMetadata:
	set(new_kart):
		# Swap the kart out if the kart has changed
		if kart != new_kart:
			# If a kart already exists, delete it
			if kart_node:
				kart_node.queue_free()
			
			# Instantiate the new kart
			kart_node = new_kart.instantiate()
			kart_node.kart_preview = true
			add_child(kart_node)
		
		# Set the kart to the new kart
		kart = new_kart


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
