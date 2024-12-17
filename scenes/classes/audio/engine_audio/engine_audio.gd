class_name EngineAudio extends Node3D

@export var kart_speed: float = 0.5
## Where in the rev sound should the crossfade start?
@export var rev_fade_point: float = 0.5
## Where in the rev sound sample does the revving stop?
@export var rev_stop_point: float = 1
## What speed should the engine sound start at when the fade starts?
@export var engine_start_point: float = 0.46
## How quickly should the speed of the engine change?
@export var responsiveness: float = 2.0

@onready var engine_sound: AudioStreamPlayer3D = $EngineSound
@onready var rev_sound: AudioStreamPlayer3D = $RevSound

enum EngineState {
	STOPPED,
	STARTING,
	RUNNING,
	STOPPING,
}

var engine_state: EngineState = EngineState.STOPPED


func _process(delta: float) -> void:
	if kart_speed == 0:
		if engine_state == EngineState.RUNNING:
			engine_sound.stop()
			engine_state = EngineState.STOPPED
	else:
		engine_sound.pitch_scale = lerpf(engine_sound.pitch_scale, kart_speed, delta * responsiveness)
		if engine_state == EngineState.STOPPED:
		#	rev_sound.play()
		#	engine_state = EngineState.STARTING
			engine_sound.pitch_scale = 0.01
			engine_sound.play()
			engine_state = EngineState.RUNNING
		elif engine_state == EngineState.STARTING and rev_sound.get_playback_position() >= rev_fade_point:
			var rev_fade_length := rev_fade_point - rev_stop_point
			var rev_fade_position := rev_fade_point - rev_sound.get_playback_position()
			var rev_fade_progress := clampf(rev_fade_position / rev_fade_length, 0, 1)
			
			rev_sound.set_volume_db(clampf(0 - (80 * rev_fade_progress), -80, 0))
			print(linear_to_db(rev_fade_progress))
			engine_sound.set_volume_db(linear_to_db(rev_fade_progress))
			
			if not engine_sound.playing:
				engine_sound.play()
			#engine_sound.pitch_scale = engine_start_point
			#rev_sound.stop()
			#engine_state = EngineState.RUNNING
