extends PinJoint2D

@export_group("Audio Assets")
@export var frame_sfx: AudioStream
@export var wheel_sfx: AudioStream

@export_group("Mixing Settings")
@export var max_vol_speed: float = 400.0
@export var max_distance: float = 2000.0
@export var voice_limit: int = 1

const MIN_SPEED: float = 5.0

var _frame_player: AudioStreamPlayer2D
var _wheel_player: AudioStreamPlayer2D

@onready var frame_body: RigidBody2D = $FrameBody
@onready var wheels: RigidBody2D = $Wheels

func _ready() -> void:
	_frame_player = _create_player(frame_sfx)
	_wheel_player = _create_player(wheel_sfx)

func _physics_process(_delta: float) -> void:
	_process_mix(frame_body, _frame_player)
	_process_mix(wheels, _wheel_player)

func _process_mix(body: RigidBody2D, player: AudioStreamPlayer2D) -> void:
	if not player.stream: 
		return
	
	var speed: float = body.linear_velocity.length()
	
	if speed > MIN_SPEED:
		if not player.playing:
			player.play()
		
		var intensity: float = clampf(speed / max_vol_speed, 0.0, 1.0)
		player.volume_db = linear_to_db(intensity)
		player.pitch_scale = lerp(0.9, 1.3, intensity)
	else:
		if player.playing:
			player.stop()

func _create_player(stream: AudioStream) -> AudioStreamPlayer2D:
	var p: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	p.stream = stream
	p.max_distance = max_distance
	p.panning_strength = 1.5
	p.bus = &"SFX" 
	p.max_polyphony = voice_limit
	
	add_child(p)
	return p