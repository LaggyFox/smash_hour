extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

signal fade_completed

const MUSIC_BUS_STRING: String = "Music"

var _pending_bgm: BackgroundMusicResource
var _pending_one_shot: bool
var _pending_fade_in_duration: float

## an offset that would apply to the volume additionally to the bus volume and music-specific volume offset.
## useful for changing the volume not matter what the music track is, without touching the volume bus, which might be changed by the user.
## example: lowering the volume when entering menus
var volume_db_offset_from_bus: float = 0.0 :
	set(val):
		volume_db_offset_from_bus = val

		# don't mess with the volume if it's in the process of fading
		if _current_bgm_resource and not is_fading():
			_apply_volume(_current_bgm_resource)

var _current_bgm_resource: BackgroundMusicResource
var _one_shot: bool = true: set = _set_one_shot
var _fade_tween: Tween
var _fade_in_tween: Tween

func _ready() -> void:
	_one_shot = _one_shot 

func is_playing() -> bool:
	return audio_stream_player.is_playing()

## returns true if the given music resource is currently playing
func is_playing_song(bgm_resource: BackgroundMusicResource) -> bool:
	return is_playing() and bgm_resource == _current_bgm_resource

func play(bgm_resource: BackgroundMusicResource, fade_in_duration: float = 0.0, one_shot: bool = false) -> void:
	if not bgm_resource:
		assert(false, "called without a bgm resource")
		return

	_one_shot = one_shot
	_current_bgm_resource = bgm_resource

	_stop_fade_in()
	if fade_in_duration > 0:
		_fade_in_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		_fade_in_tween.tween_property(audio_stream_player, "volume_db", _compute_volume(bgm_resource), fade_in_duration).from(-80)
	else:
		_apply_volume(bgm_resource)

	audio_stream_player.stream = bgm_resource.song
	audio_stream_player.play()

func stop() -> void:
	_stop_fade_in()
	audio_stream_player.stop()

func fade(duration: float = 0.75) -> void:
	if is_fading(): return

	_stop_fade_in()

	if audio_stream_player.playing and duration > 0:
		_fade_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		_fade_tween.tween_property(audio_stream_player, "volume_db", -80, duration)
		_fade_tween.finished.connect(_finish_fade, CONNECT_ONE_SHOT)
		return

	_finish_fade()

func _finish_fade() -> void:
	_fade_tween = null
	stop()
	fade_completed.emit()

func is_fading() -> bool:
	return _fade_tween and _fade_tween.is_running()

## makes the music fade, and then plays it.
## bgm_resource: the music that will be played
## one_shot: if false, the music will repeat after it ends
## fade_duration: the time in seconds for the music to fade
## replay_if_already_playing: if the track is already playing and this flag is set to 'true', it would fade and replay, 
## otherwise this call will be ignored
func fade_then_play(
	bgm_resource: BackgroundMusicResource, fade_duration: float = 0.75, fade_in_duration: float = 0.0, one_shot: bool = false, replay_if_already_playing: bool = false) -> void:
	if not bgm_resource:
		assert(false, "called without a music resource")
		return
		
	if not is_fading() and is_playing_song(bgm_resource) and not replay_if_already_playing:
		return

	_pending_bgm = bgm_resource
	_pending_one_shot = one_shot
	_pending_fade_in_duration = fade_in_duration

	Utils.connect_to_signal_if_not_connected(fade_completed, _on_fade_and_play_completed, CONNECT_ONE_SHOT)
	fade(fade_duration)

func _on_fade_and_play_completed() -> void:
	play(_pending_bgm, _pending_fade_in_duration, _pending_one_shot)

func _get_bus_volume_db() -> float:
	var music_bus_index := AudioServer.get_bus_index(MUSIC_BUS_STRING)
	assert(music_bus_index != -1, "the music bus does not exist")
	return AudioServer.get_bus_volume_db(music_bus_index)

func _set_one_shot(val: bool) -> void:
	_one_shot = val
	if _one_shot:
		Utils.safely_disconnect_from_signal(audio_stream_player.finished, _repeat_on_finish)
	else:
		Utils.connect_to_signal_if_not_connected(audio_stream_player.finished, _repeat_on_finish)

func _repeat_on_finish() -> void:
	if _current_bgm_resource:
		play(_current_bgm_resource)

func _apply_volume(bgm_resource: BackgroundMusicResource) -> void:
	audio_stream_player.volume_db = _compute_volume(bgm_resource)

func _compute_volume(bgm_resource: BackgroundMusicResource) -> float:
	return _get_bus_volume_db() + bgm_resource.volume_db_offset_from_bus + volume_db_offset_from_bus

func _stop_fade_in() -> void:
	if _fade_in_tween:
		_fade_in_tween.kill()
		_fade_in_tween = null
		
