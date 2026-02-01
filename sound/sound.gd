extends Node

var size: int = 64 : set = set_size
var _next_index: int = 0

var played_this_frame: Array[SoundResourceBase]

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	set_size(size)

func _physics_process(_delta: float) -> void:
	played_this_frame.clear()

func play(sound_resource: SoundResourceBase) -> void:
	assert(not sound_resource.is_2d_sound(), "called a 2D sound with normal sound player")
	if sound_resource in played_this_frame:
		return

	played_this_frame.append(sound_resource)

	if sound_resource is SoundResource:
		play_single(sound_resource as SoundResource)
	else:
		play_random(sound_resource as MultiSoundResource)

func play_single(sound_resource: SoundResource, db_offset: float = 0.0) -> void:
	assert(sound_resource, "null sound resource")
	var sr: SoundResource = sound_resource

	var sound_player: AudioStreamPlayer

	for i in range(size):
		sound_player = get_children()[_next_index]
		_next_index = (_next_index + 1) % size
		if not sound_player.is_playing(): break

	var need_size_increase_as_all_sound_players_are_playing: bool = sound_player.is_playing()
	if need_size_increase_as_all_sound_players_are_playing: 
		size = size * 2
		sound_player = get_children()[_next_index]
		assert(not sound_player.is_playing(), "bug encountered while increasing the pool size")

	_next_index = (_next_index + 1) % size
	
	sound_player.pitch_scale = randf_range(sr.min_pitch, sr.max_pitch)
	sound_player.volume_db = sr.volume_db + db_offset
	sound_player.stream = sr.sound_stream
	sound_player.play(sr.seek)

func play_random(sound_resource: MultiSoundResource) -> void:
	play_single(sound_resource.get_random_sound(), sound_resource.global_db_offset)

func set_size(value: int) -> void:
	assert(value > 0, "size must be greater than 0")

	# ensure we're comparing to the actual size since 'size' might not be correct after the export var assignment
	size = get_child_count() 
	if value == size: return

	if value > size:
		_next_index = size
		var diff: int = value - size
		_init_sound_players(diff)

	elif value < size:
		_next_index = 0
		var diff: int = size - value
		var children: Array[Node] = get_children()
		for i in range(diff):
			remove_child(children[children.size() - i])
	
	assert(value == get_child_count(), "new size should be equal to the number of children")
	size = value

func _init_sound_players(num_streams: int) -> void:
	for i in range(num_streams):
		var sound_player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(sound_player)
