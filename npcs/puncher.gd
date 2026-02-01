extends CharacterBody2D
class_name Puncher

@export var speed: float = 500.0
@export var acceleration: float = 3000.0
@export var friction: float = 3000.0

func _physics_process(delta: float) -> void:
	var human_target: Human = Utils.get_closest_human(global_position)
	if not human_target: return
	
	var direction: Vector2 = global_position.direction_to(human_target.global_position)

	velocity.x = move_toward(velocity.x, speed * direction.x, acceleration * delta)
	velocity.y = move_toward(velocity.y, speed * direction.y, friction * delta)

	move_and_slide()