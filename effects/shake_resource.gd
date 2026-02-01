extends Resource
class_name ShakeResource

@export var allow_multiple_shakes: bool = true
@export var duration: float = 0.2
@export var amount: Vector2 = Vector2(1.5, 1.5)
@export var transition_type: Tween.TransitionType = Tween.TRANS_EXPO
@export var ease_type: Tween.EaseType = Tween.EASE_OUT