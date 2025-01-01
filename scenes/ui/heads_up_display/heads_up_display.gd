class_name HeadsUpDisplay extends Control

@export var player: Player
## Total number of laps in this map.
@export var lap_count: int
@export var lap_text: String = "Lap {current_lap}/{lap_count}"

@onready var speedometer: Speedometer = %Speedometer
@onready var lap_label: Label = %LapLabel
@onready var fps_counter: FPSCounter = %FPSCounter


func _ready() -> void:
	GameSettings.fps_counter_enabled_changed.connect(_on_fps_counter_enabled_changed)
	_on_fps_counter_enabled_changed(GameSettings.is_fps_counter_enabled())


func _process(delta: float) -> void:
	if is_instance_valid(player):
		if is_instance_valid(player.kart):
			speedometer.speed = player.kart.get_speed() / 50
		lap_label.text = lap_text.format({
				"current_lap": player.lap,
				"lap_count": lap_count,
			})


func _on_fps_counter_enabled_changed(enabled: bool) -> void:
	if enabled:
		fps_counter.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		fps_counter.process_mode = Node.PROCESS_MODE_DISABLED
	fps_counter.visible = enabled
