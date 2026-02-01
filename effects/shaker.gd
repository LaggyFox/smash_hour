extends RefCounted
class_name Shaker

var _cur_tween: Tween

func tween_shake(target: CanvasItem, shake_resource: ShakeResource, shake_property: String = "position") -> void:
	assert(shake_resource, "shake resource is null")
	var sr: ShakeResource = shake_resource

	if _cur_tween and _cur_tween.is_running():
		if not sr.allow_multiple_shakes: return
		_cur_tween.kill()

	_cur_tween = target.create_tween().set_trans(sr.transition_type).set_ease(sr.ease_type)
	_cur_tween.tween_method(_shake.bind(target, shake_property), sr.amount, Vector2(0, 0), sr.duration)

func _shake(amount: Vector2, target: CanvasItem, shake_property: String) -> void:
	target[shake_property] = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * amount

func stop() -> void:
	if _cur_tween:
		_cur_tween.kill()

func is_shaking() -> bool:
	return _cur_tween and _cur_tween.is_running()