extends Node

enum MaskType {
	CAR_CRUSHER = 0,
	TERRORIST = 1,
	DAFT_PUNK = 2,
}

signal mask_changed(mask_type: MaskType, amount: int)
signal focused_different_mask(mask_index: int)

var masks: Array[MaskType] = [MaskType.CAR_CRUSHER, MaskType.TERRORIST, MaskType.DAFT_PUNK]
var amounts: Array[int] = [0, 0, 0]
var current_mask_idx: int = 0

func reset_mask_amounts() -> void:
	for i in range(amounts.size()):
		amounts[i] = 0

func _physics_process(_delta: float) -> void:
	for i in range(4):
		_handle_mask_press(i)

func _handle_mask_press(index: int) -> void:
	if Input.is_action_just_pressed("mask_" + str(index)) and masks.size() > index:
		var is_different_mask: bool = current_mask_idx != index
		current_mask_idx = index
		if is_different_mask:
			focused_different_mask.emit(index)

func get_mask_amount(mask_type: MaskState.MaskType) -> int:
	return amounts[mask_type]

func collect_mask(mask_type: MaskState.MaskType) -> void:
	amounts[mask_type] += 1
	mask_changed.emit(mask_type, amounts[mask_type])

func use_mask(mask_type: MaskState.MaskType) -> void:
	amounts[mask_type] -= 1
	mask_changed.emit(mask_type, amounts[mask_type])

func get_mask_type() -> MaskType:
	return masks[current_mask_idx]