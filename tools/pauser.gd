extends Node

signal paused
signal unpaused

var currently_paused: bool
var allow_multiple_freezes: bool = true
var freeze_timer: Timer = Timer.new()

var allow_pausing: bool = true
var is_paused : bool = false: set = set_pause

const default_time_freeze_resource = preload("res://effects/resources/default_time_freeze_resource.tres")

func freeze_time(time_freeze_resource: TimeFreezeResource = default_time_freeze_resource) -> void:
	if not freeze_timer.is_stopped() and not allow_multiple_freezes: return
	var tfr := time_freeze_resource
	freeze_timer.start(tfr.duration * tfr.time_scale)
	Engine.time_scale = tfr.time_scale

func pause_game() -> void:
	set_pause(true)

func unpause_game() -> void:
	set_pause(false)

func set_pause(value: bool) -> void:
	if value and not allow_pausing: return
	is_paused = value
	get_tree().paused = is_paused
	currently_paused = is_paused
	if is_paused: paused.emit()
	else: unpaused.emit()

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	freeze_timer.autostart = false
	freeze_timer.one_shot = true
	freeze_timer.timeout.connect(func() -> void:
		Engine.time_scale = 1
	)
	add_child(freeze_timer)

## temporarily disable this as we're trying to figure out the UI
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		is_paused = not is_paused
