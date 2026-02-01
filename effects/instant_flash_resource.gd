extends FlashResource
class_name InstantFlashResource

@export var can_be_overridden: bool = true
@export var instant_color: Color = Color.WHITE
@export var instant_duration: float = 0.2

func duration() -> float:
	return instant_duration