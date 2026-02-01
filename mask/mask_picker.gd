extends Node

enum MaskType {
	PUNCHER,
	CAR_CRUSHER
}

var masks: Array[MaskType] = [MaskType.PUNCHER, MaskType.CAR_CRUSHER]
var amounts: Array[int] = [1, 1]

var current_mask_idx: int = 0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("mask_1"):
		current_mask_idx = 0
	if Input.is_action_just_pressed("mask_2"):
		current_mask_idx = 1
	#if Input.is_action_just_pressed("mask_3"):
		#current_mask_idx = 1
	#if Input.is_action_just_pressed("mask_4"):
		#current_mask_idx = 1
