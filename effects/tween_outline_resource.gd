extends OutlineResource
class_name TweenOutlineResource

@export var can_be_overridden: bool = true
@export var loop: bool = false
## if true, the outline color will be used as the final color, except The alpha of the original color will be multiplied by the outline color.
@export var use_outline_color_as_final_color: bool = false
@export var tween_duration: float = 0.1
@export_range(0, 1) var max_outline_strength: float = 1
@export var outline_strength_factor: float = 1
@export var transition_type: Tween.TransitionType = Tween.TRANS_EXPO
@export var ease_type: Tween.EaseType = Tween.EASE_OUT
@export var color_gradient: Gradient

func duration() -> float:
	return tween_duration