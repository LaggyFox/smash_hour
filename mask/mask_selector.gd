extends HBoxContainer
class_name MaskSelector

@export var select_color: Color

func _ready() -> void:
	MaskState.focused_different_mask.connect(change_focused_mask)

func change_focused_mask(mask_index: int) -> void:
	for child in get_children():
		if child is not MaskButton: continue
		var mask_child: MaskButton = child as MaskButton
		mask_child.modulate = Color.WHITE

	var mask_button := get_child(mask_index) as MaskButton
	mask_button.modulate = select_color
