extends KnockbackResource
class_name RelativeKnockbackResource

@export var knockback_speed: float = 1500.0

func compute_knockback_velocity(hitbox: Hitbox, hurtbox: Hurtbox) -> Vector2:
	var hitbox_owner: Node2D = hitbox.owner
	var hurtbox_owner: Node2D = hurtbox.owner
	var hit_to_hurt_direction: Vector2 = hitbox_owner.global_position.direction_to(hurtbox_owner.global_position)
	var knockback_velocity: Vector2 = hit_to_hurt_direction * knockback_speed 
	return knockback_velocity