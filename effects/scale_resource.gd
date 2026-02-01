extends Resource
class_name ScaleResource

@export var allow_multiple_scales: bool = true
@export var duration: float = 0.2
@export var amount: Vector2 = Vector2(1.5, 1.5)
@export var from: Vector2 = Vector2(1, 1)
@export_range(0.0, 1.0) var scale_time_ratio: float = 0.5
@export var transition_type: Tween.TransitionType = Tween.TRANS_EXPO
@export var ease_type: Tween.EaseType = Tween.EASE_OUT