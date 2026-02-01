extends CharacterBody2D
class_name Terrorist

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var spawn_sound: SoundResource
@export var speed: float = 150.0
@export var acceleration: float = 2000.0
@export var time_to_explode: float = 2.0

@export var exploder :  ExplosionHandler

var direction: Vector2 = Vector2.LEFT
var look_direction: float = 1.0
var _explode_timer: ScriptTimer = ScriptTimer.new(self, time_to_explode, _on_explode_timer_timeout)

func _ready() -> void:
	spawn_sound.play(global_position)
	_explode_timer.start()
	await get_tree().process_frame
	Utils.flip_if_needed.call_deferred(self, look_direction)

func _physics_process(delta: float) -> void:
	aim_at_closest_human()
	velocity = velocity.move_toward(speed * direction, acceleration * delta)
	move_and_slide()

func _on_explode_timer_timeout() -> void:
	hide()
	exploder.explode(global_position)

func aim_at_closest_human() -> void:
	var closest_human := Utils.get_closest_human(global_position, true)
	direction = global_position.direction_to(closest_human.global_position)
	look_direction = signf(direction.x)