extends RefCounted
class_name Scaler

var _cur_tween: Tween

func tween_scale(target: CanvasItem, scale_resource: ScaleResource) -> void:
	assert(scale_resource, "scale resource is null")
	var sr := scale_resource
	assert(0 < sr.scale_time_ratio and sr.scale_time_ratio < 1, "invalid scale time ratio")

	if _cur_tween and _cur_tween.is_running() and not sr.allow_multiple_scales:
		return

	_cur_tween = target.create_tween().set_trans(sr.transition_type).set_ease(sr.ease_type)
	_cur_tween.tween_property(target, "scale", sr.amount, sr.duration * sr.scale_time_ratio).from(sr.from)
	_cur_tween.tween_property(target, "scale", Vector2.ONE, sr.duration * (1 - sr.scale_time_ratio)).from(sr.amount)

func is_running() -> bool:
	if not _cur_tween: 
		return false
	return _cur_tween.is_running()

static func add_scale_to_existing_tween(tween: Tween, target: CanvasItem, scale_resource: ScaleResource) -> void:
	assert(false, "currently not in use, need to decide if it is needed and see how to implement it")
	assert(scale_resource, "scale resource is null")
	var sr := scale_resource
	assert(0 < sr.scale_time_ratio and sr.scale_time_ratio < 1, "invalid scale time ratio")

	tween.tween_property(target, "scale", sr.amount, sr.duration * sr.scale_time_ratio).from_current()
	tween.tween_property(target, "scale", Vector2.ONE, sr.duration * (1 - sr.scale_time_ratio)).from(sr.amount)
