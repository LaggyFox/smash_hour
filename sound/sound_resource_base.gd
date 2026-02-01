extends Resource
class_name SoundResourceBase

func play(pos: Vector2) -> void:
	if is_2d_sound():
		Sound2D.play(self, pos)
	else:
		Sound.play(self)

func is_2d_sound() -> bool:
	assert(false, "no implemented")
	return false