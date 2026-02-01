extends Node
class_name Outliner

signal finished

## Controls the outline of the given target.
## This module assumes that the target has a material with a shader that has an outline_color parameter

@export var target: CanvasItem : set = set_target
@onready var instant_outline_timer: ScriptTimer = ScriptTimer.new(self, 0.05)

var _cur_tween : Tween
var _allow_outline_override: bool = true
var _is_playing: bool = false

## incremented each time the outliner 'outline' method is called, you can use this to stop the outline if your
## outline id is currently in use
var current_outline_id: int = 0

func _ready() -> void:
	instant_outline_timer.timeout.connect(finished.emit)
	instant_outline_timer.timeout.connect(_on_outline_end)

func set_target(value: CanvasItem) -> Outliner:
	target = value
	return self

## returns the current outline id, can be used to stop the outline mid-way if it still plays
## returns "-1" if didn't outline for whatever reason
func outline(outline_resource: OutlineResource) -> int:
	assert(outline_resource, "outline resource is null")
	assert(outline_resource is TweenOutlineResource or outline_resource is InstantOutlineResource, 
			"Using base outline resource instead of instant/tween outline resource")

	if not _can_outline(): return -1

	if outline_resource is TweenOutlineResource:
		_tween_outline(outline_resource as TweenOutlineResource)
	else:
		_instant_outline(outline_resource as InstantOutlineResource)

	_is_playing = true

	current_outline_id += 1
	if current_outline_id < 0: current_outline_id = 0
	return current_outline_id

func _instant_outline(outline_resource: InstantOutlineResource) -> void:
	assert(outline_resource, "outline resource is null")
	assert(target, "target is not set")
	var fr: InstantOutlineResource = outline_resource

	instant_outline_timer.start(fr.duration())
	_set_material_outline_color(fr.outline_color)
	#_set_material_outline_strength_factor(1)
	#_set_material_max_outline_strength(1)

	_allow_outline_override = fr.can_be_overridden

func _tween_outline(outline_resource: TweenOutlineResource) -> void:
	assert(outline_resource, "outline resource is null")
	assert(target, "target is not set")
	var fr: TweenOutlineResource = outline_resource

	#_set_material_outline_strength_factor(fr.outline_strength_factor)
	#_set_material_max_outline_strength(fr.max_outline_strength)
	#_set_material_use_outline_color_as_final_color(fr.use_outline_color_as_final_color)

	_cur_tween = target.create_tween().set_ease(fr.ease_type).set_trans(fr.transition_type)
	_cur_tween.tween_method(_set_material_outline_color_from_gradient.bind(fr.color_gradient), 0.0, 1.0, fr.tween_duration)
	_cur_tween.finished.connect(_on_outline_end)
	_cur_tween.finished.connect(finished.emit)
	if fr.loop:
		_cur_tween.set_loops()

	_allow_outline_override = fr.can_be_overridden

func is_playing() -> bool:
	return _is_playing

func stop_outline_if_still_playing(outline_id: int) -> void:
	if current_outline_id != outline_id: return

	instant_outline_timer.stop()
	if _cur_tween:
		_cur_tween.kill()
	_on_outline_end()

func stop() -> void:
	instant_outline_timer.stop()
	if _cur_tween:
		_cur_tween.kill()
	_on_outline_end()
		
func _set_material_outline_color(value: Color) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("outline_color", value)

func _set_material_outline_color_from_gradient(sample_offset: float, gradient: Gradient) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("outline_color", gradient.sample(sample_offset))

func _set_material_use_outline_color_as_final_color(value: bool) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("use_outline_color_as_final_color", value)

func _on_outline_end() -> void:
	_set_material_outline_color(Color(1, 1, 1, 0))
	#_set_material_use_outline_color_as_final_color(false)
	_is_playing = false

func _set_material_outline_strength_factor(value: float) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("outline_strength_factor", value)

func _set_material_max_outline_strength(value: float) -> void:
	var material: ShaderMaterial = target.material
	material.set_shader_parameter("max_outline_strength", value)

func _can_outline() -> bool:
	var currently_tween_outlining: bool = _cur_tween and _cur_tween.is_running()
	if currently_tween_outlining:
		if _allow_outline_override:
			_cur_tween.kill()
			return true
		else:
			return false

	var currently_instant_outlining: bool = not instant_outline_timer.is_stopped()
	if currently_instant_outlining:
		if _allow_outline_override:
			instant_outline_timer.stop()
			return true
		else:
			return false
	
	return true
