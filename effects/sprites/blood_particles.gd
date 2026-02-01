extends Node2D
class_name BloodParticles

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func play(num_repeats: int, _direction: Vector2) -> void:
	for i in range(num_repeats):
		animation_player.play("splatter")
		rotation = Vector2.from_angle(randf() * TAU).angle()
		await animation_player.animation_finished
