extends Area2D
class_name MaskCollectible

@export var mask_type: MaskState.MaskType

var _can_collect: bool = true

func _ready() -> void:
	body_entered.connect(_on_collect.unbind(1))
	area_entered.connect(_on_collect.unbind(1))

func _on_collect() -> void:
	if not _can_collect: return
	_can_collect = false
	MaskState.collect_mask(mask_type)
	queue_free()
