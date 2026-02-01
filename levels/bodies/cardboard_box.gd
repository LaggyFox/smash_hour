extends RigidBody2D

@export var box_sfx: AudioStream
@export var max_vol_speed: float = 300.0
@export var max_distance: float = 1500.0

const MIN_SPEED: float = 10.0

var _player: AudioStreamPlayer2D

func _ready() -> void:
	_player = _create_player(box_sfx)
	contact_monitor = true
	max_contacts_reported = 1

func _physics_process(_delta: float) -> void:
	var speed: float = linear_velocity.length()
	
	if speed > MIN_SPEED and state_is_sliding():
		if not _player.playing:
			_player.play()
		
		var intensity: float = clampf(speed / max_vol_speed, 0.0, 1.0)
		_player.volume_db = linear_to_db(intensity)
		_player.pitch_scale = lerp(0.8, 1.2, intensity)
	else:
		if _player.playing:
			_player.stop()

func state_is_sliding() -> bool:
	return get_contact_count() > 0

func _create_player(stream: AudioStream) -> AudioStreamPlayer2D:
	var p: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	p.stream = stream
	p.max_distance = max_distance
	p.bus = &"SFX"
	add_child(p)
	return p