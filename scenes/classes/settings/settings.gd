class_name Settings extends Node

@export var profile: PlayerProfile

signal profile_changed(new_profile: PlayerProfile)


#func serialize() -> Dictionary:
#	return {"profile": profile.serialize()}


func save_settings() -> void:
#	var save_file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	
	# JSON provides a static method to serialized JSON string.
#	var json_string = JSON.stringify(serialize())
	
	# Store the save dictionary as a new line in the save file.
#	save_file.store_line(json_string)
	
	ResourceSaver.save(profile, "user://profile.tres")
	print("saved")


func load_settings() -> void:
	#if FileAccess.file_exists("user://settings.save"):
		## Load the file line by line and process that dictionary.
		#var save_file = FileAccess.open("user://settings.save", FileAccess.READ)
		#while save_file.get_position() < save_file.get_length():
			#var json_string = save_file.get_line()
			#
			## Creates the helper class to interact with JSON.
			#var json = JSON.new()
			#
			## Check if there is any error while parsing the JSON string, skip in case of failure.
			#var parse_result = json.parse(json_string)
			#if not parse_result == OK:
				#print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				#continue
			#
			## Get the data from the JSON object.
			#var node_data = json.data
			#
			## Now we set the remaining variables.
			#for key in node_data.keys():
				#set(key, node_data[key])
	
	if FileAccess.file_exists("user://profile.tres"):
		profile = ResourceLoader.load("user://profile.tres") as PlayerProfile
	else:
		profile = PlayerProfile.new()
	profile.nickname_changed.connect(_on_nickname_changed)
	profile_changed.emit(profile)


func _on_nickname_changed(new_nickname: String) -> void:
	profile_changed.emit(profile)
	save_settings()
