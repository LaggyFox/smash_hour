extends AudioStreamPlayer2D


func _on_panicking_state_entered() -> void:
	play()


func _on_panicking_state_exited() -> void:
	stop()
