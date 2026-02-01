extends CharacterBody2D
class_name CarCrasher

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Hitbox = $Hitbox

@export var speed: float = 500.0
@export var acceleration: float = 3000.0
@export var friction: float = 3000.0

@export var victim_speed: float = 1000.0

@export var exploder :  ExplosionHandler

var _can_move : bool = true

var _can_explode_delay_timer: ScriptTimer = ScriptTimer.new(self, 0.1)

var direction: float = -1.0 :
	set(value):
		if is_equal_approx(value, 0): return
		direction = signf(value)

func _ready() -> void:
	_can_explode_delay_timer.start()
	velocity.y = 0
	hitbox.hit_hurtbox.connect(_on_hit_hurtbox)
	await get_tree().process_frame
	Utils.flip_if_needed.call_deferred(self, direction)

func _physics_process(delta: float) -> void:

	if(!_can_move) : return

	velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	var prev_pos: Vector2 = global_position
	move_and_slide()

	var collision := get_last_slide_collision()
	if(collision == null) : return
	var collision_obj := collision.get_collider()
	if(collision_obj is StaticBody2D):
		if not _can_move: return
		_can_move = false
		exploder.explode(global_position)
		hide()
	elif _can_explode_delay_timer.is_stopped() and prev_pos.distance_to(global_position) < 10.0:
		if not _can_move: return
		_can_move = false
		exploder.explode(global_position)
		hide()
	
func _on_hit_hurtbox(_hurted_box: Hurtbox, _hit_to_hurt_direction: Vector2) -> void:
	return
	#var victim: Human = hurted_box.owner
	#assert(victim, "only humans are supported for now")
	# for now apply constant speed, could calculate relative speed after
	#victim.apply_hurt_velocity(hit_to_hurt_direction, victim_speed)
