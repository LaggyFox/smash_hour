extends SoundResourceBase
class_name SoundResource

@export var sound_stream: AudioStream 
@export var volume_db: float = 0 
@export var min_pitch: float = 1 
@export var max_pitch: float = 1 
@export var seek: float = 0
@export var is_2d: bool = false

## 2D mode only: Maximum distance from which audio is still hearable.
@export var max_distance: float = 1200

## 2D mode only: The volume is attenuated over distance with this as an exponent.
@export_exp_easing var attenuation: float = 2.0

func is_2d_sound() -> bool:
	return is_2d