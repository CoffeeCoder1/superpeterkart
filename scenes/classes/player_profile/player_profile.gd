class_name PlayerProfile extends Resource

@export var nickname: String:
	set(new_nickname):
		var changed: bool = false
		if nickname != new_nickname:
			changed = true
		nickname = new_nickname
		if changed:
			nickname_changed.emit(new_nickname)

signal nickname_changed(new_nickname: String)
