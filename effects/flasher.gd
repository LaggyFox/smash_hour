extends Node
class_name Flasher

signal finished

## this module assumes that the target has a material with a shader that has a mix_value and flash_color parameter

@export var target: CanvasItem : set = set_target
@onready var instant_flash_timer: ScriptTimer = ScriptTimer.new(self, 0.05)

var _cur_tween : Tween
var _allow_flash_override: bool = true
var _is_flashing: bool = false

## incremented each time the flasher 'flash' method is called, you can use this to stop the flash if your
## flash id is currently in use
var current_flash_id: int = 0

func _ready() -> void:
	instant_flash_timer.timeout.connect(finished.emit)
	instant_flash_timer.timeout.connect(_on_flash_end)

func set_target(value: CanvasItem) -> Flasher:
	target = value
	return self

## returns the current flash id, can be used to stop the flash mid-way if it still plays
## returns "-1" if didn't flash for whatever reason
func flash(flash_resource: FlashResource) -> int:
	assert(flash_resource, "flash resource is null")
	assert(flash_resource is TweenFlashResource or flash_resource is InstantFlashResource, 
			"Using base flash resource instead of instant/tween flash resource")

	if not _can_flash(): return -1

	if flash_resource is TweenFlashResource:
		_tween_flash(flash_resource as TweenFlashResource)
	else:
		_instant_flash(flash_resource as InstantFlashResource)

	_is_flashing = true

	current_flash_id += 1
	if current_flash_id < 0: current_flash_id = 0
	return current_flash_id

func _instant_flash(flash_resource: InstantFlashResource) -> void:
	assert(flash_resource, "flash resource is null")
	assert(target, "target is not set")
	var fr: InstantFlashResource = flash_resource

	instant_flash_timer.start(fr.instant_duration)

	_set_material_flash_color(fr.instant_color)
	_set_material_flash_strength_factor(1)
	_set_material_max_flash_strength(1)

	_allow_flash_override = fr.can_be_overridden

func _tween_flash(flash_resource: TweenFlashResource) -> void:
	assert(flash_resource, "flash resource is null")
	assert(target, "target is not set")
	var fr: TweenFlashResource = flash_resource

	_set_material_flash_strength_factor(fr.flash_strength_factor)
	_set_material_max_flash_strength(fr.max_flash_strength)
	_set_material_use_flash_color_as_final_color(fr.use_flash_color_as_final_color)

	_cur_tween = target.create_tween().set_ease(fr.ease_type).set_trans(fr.transition_type)
	_cur_tween.tween_method(_set_material_flash_color_from_gradient.bind(fr.color_gradient), 0.0, 1.0, fr.tween_duration)
	_cur_tween.finished.connect(_on_flash_end)
	_cur_tween.finished.connect(finished.emit)
	if fr.loop:
		_cur_tween.set_loops()

	_allow_flash_override = fr.can_be_overridden

func is_flashing() -> bool:
	return _is_flashing

func stop_flash_if_still_playing(flash_id: int) -> void:
	if current_flash_id != flash_id: return

	instant_flash_timer.stop()
	if _cur_tween:
		_cur_tween.kill()
	_on_flash_end()

func stop() -> void:
	instant_flash_timer.stop()
	if _cur_tween:
		_cur_tween.kill()
	_on_flash_end()
		
func _set_material_flash_color(value: Color) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("flash_color", value)

func _set_material_flash_color_from_gradient(sample_offset: float, gradient: Gradient) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("flash_color", gradient.sample(sample_offset))

func _set_material_use_flash_color_as_final_color(value: bool) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("use_flash_color_as_final_color", value)

func _on_flash_end() -> void:
	_set_material_flash_color(Color(1, 1, 1, 0))
	_set_material_use_flash_color_as_final_color(false)
	_is_flashing = false

func _set_material_flash_strength_factor(value: float) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("flash_strength_factor", value)

func _set_material_max_flash_strength(value: float) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("max_flash_strength", value)

func _can_flash() -> bool:
	var currently_tween_flashing: bool = _cur_tween and _cur_tween.is_running()
	if currently_tween_flashing:
		if _allow_flash_override:
			_cur_tween.kill()
			return true
		else:
			return false

	var currently_instant_flashing: bool = not instant_flash_timer.is_stopped()
	if currently_instant_flashing:
		if _allow_flash_override:
			instant_flash_timer.stop()
			return true
		else:
			return false
	
	return true
