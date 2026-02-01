extends Node2D
class_name DirectionMarker

func _physics_process(_delta: float) -> void:
	var player: Player = MainInstances.player
	global_position = player.global_position
	var marker_direction: Vector2 = player.global_position.direction_to(get_global_mouse_position())
	rotation = marker_direction.angle()
	#pass