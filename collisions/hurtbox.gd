extends Area2D
class_name Hurtbox

signal got_hurt(hitting_box: Hitbox, direction: Vector2)

var invincible: bool = false :
	set(value):
		invincible = value
		Utils.set_area_collisions(self, not invincible)