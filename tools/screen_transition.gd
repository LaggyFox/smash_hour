extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func to_black() -> void:
	animation_player.play("to_black")
	await animation_player.animation_finished

func to_transparent() -> void:
	animation_player.play("to_transparent")
	await animation_player.animation_finished