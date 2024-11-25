class_name CharacterPreviewWorld extends SubViewport

@export var kart: Kart:
	set(new_kart):
		if new_kart != kart and new_kart is Kart:
			new_kart.kart_enabled = false
			new_kart.position = Vector3.ZERO
			if new_kart.get_parent():
				new_kart.get_parent().remove_child(new_kart)
			add_child(new_kart)
		
		# Set the kart to the new kart
		kart = new_kart
