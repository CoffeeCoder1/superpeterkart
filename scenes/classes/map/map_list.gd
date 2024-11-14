class_name MapList extends Resource

@export var maps: Array[MapMetadata]


func get_maps() -> Array[MapMetadata]:
	return maps


## Gets an ID string that can be used to get the map back with get_map_by_id.
## Used to identify maps in RPCs.
func get_map_id(map: MapMetadata) -> String:
	return map.get_map_id()


func get_kart_by_id(id: String) -> MapMetadata:
	for map in maps:
		if map.get_map_id() == id:
			return map
	return null
