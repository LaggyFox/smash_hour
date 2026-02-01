class_name MaskButton extends Button

@export var mask_sprite: Texture2D
@export var mask_type: MaskState.MaskType

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = %Label

func _ready() -> void:
	texture_rect.texture = mask_sprite
	MaskState.mask_changed.connect(on_mask_changed)
	update_amount(MaskState.amounts[mask_type])

func on_mask_changed(changed_mask_type: MaskState.MaskType, amount: int) -> void:
	if changed_mask_type == mask_type: 
		update_amount(amount)

func update_amount(amount: int) -> void:
	label.text = str(amount)