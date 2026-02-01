class_name SoundArea extends Area2D

@export var on_enter_sound : SoundResource



func _on_area_entered(_area: Area2D) -> void:
	print("push")
	on_enter_sound.play(global_position)
