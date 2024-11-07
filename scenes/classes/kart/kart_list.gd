class_name KartList extends Resource

@export var karts: Array[KartMetadata]


func get_karts() -> Array[KartMetadata]:
	return karts


## Gets an ID string that can be used to get the kart back with get_kart_by_id.
## Used to identify karts in RPCs.
func get_kart_id(kart: KartMetadata) -> String:
	return kart.get_kart_id()


func get_kart_by_id(id: String) -> KartMetadata:
	for kart in karts:
		if kart.get_kart_id() == id:
			return kart
	return null
