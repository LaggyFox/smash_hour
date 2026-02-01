extends OutlineResource
class_name InstantOutlineResource

@export var can_be_overridden: bool = true
@export var outline_color: Color = Color.WHITE
@export var outline_duration: float = 9999

func duration() -> float:
	return outline_duration