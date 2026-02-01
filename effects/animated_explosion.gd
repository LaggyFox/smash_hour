extends Node2D

@export var spawn_sound: SoundResource

func _ready() -> void:
	spawn_sound.play(global_position)
