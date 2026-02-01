@tool
extends SoundResourceBase
class_name MultiSoundResource

@export_tool_button("Use first sound's 2D settings globally", "Callable") var button_action : Callable = use_first_sound_2d_settings_globally

@export var global_db_offset: float = 0.0
## overrides an individual sound resource 'is_2d' variable
@export var is_2d: bool = false
@export var sounds: Array[SoundResource]

func get_random_sound() -> SoundResource:
	return sounds.pick_random()

func is_2d_sound() -> bool:
	return is_2d

func use_first_sound_2d_settings_globally() -> void:
	var first_sound: SoundResource = sounds[0]
	var attenuation: float = first_sound.attenuation
	var max_distance: float = first_sound.max_distance
	for sound in sounds:
		sound.attenuation = attenuation
		sound.max_distance = max_distance
	print("set all sounds' attenuation to {0} and max_distance to {1}".format({"0": attenuation, "1": max_distance}))