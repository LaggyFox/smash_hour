extends CharacterBody2D
class_name Player

@export var speed: float = 500.0
@export var acceleration: float = 3000.0
@export var friction: float = 3000.0

@export_group("mask_scenes")
@export var car_crasher_mask_scene: PackedScene = load("res://mask/car_crasher_mask.tscn")
@export var terrorist_mask_scene: PackedScene = load("res://mask/terrorist_mask.tscn")
@export var daft_punk_mask_scene: PackedScene = load("res://mask/daft_punk_mask.tscn")

@export_group("infected_human_scnees")
@export var puncher_scene: PackedScene = load("res://npcs/puncher.tscn")
@export var car_crasher_scene: PackedScene = load("res://npcs/car_crasher.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var look_direction: float = 1.0 :
	set(value):
		if is_equal_approx(value, 0): return
		look_direction = signf(value)

func _enter_tree() -> void:
	MainInstances.player = self

func _exit_tree() -> void:
	MainInstances.player = null

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	var final_acceleration: float = friction if not direction.is_zero_approx() else acceleration

	velocity.x = move_toward(velocity.x, speed * direction.x, final_acceleration * delta)
	velocity.y = move_toward(velocity.y, speed * direction.y, final_acceleration * delta)

	look_direction = direction.x
	Utils.flip_if_needed(self, look_direction)

	move_and_slide()

	if Input.is_action_just_pressed("throw_mask"):
		_handle_throw_mask()

	if velocity.is_equal_approx(Vector2.ZERO):
		animation_player.play("idle")
	else:
		animation_player.play("walk")

func _handle_throw_mask() -> void:
	var mask_type: MaskState.MaskType = MaskState.get_mask_type()
	if MaskState.get_mask_amount(mask_type) <= 0: 
		return
	MaskState.use_mask(mask_type)
	var throw_mask_direction: Vector2 = global_position.direction_to(get_global_mouse_position())

	var mask_scene: PackedScene = car_crasher_mask_scene
	match mask_type:
		MaskState.MaskType.CAR_CRUSHER:
			mask_scene = car_crasher_mask_scene
		MaskState.MaskType.TERRORIST:
			mask_scene = terrorist_mask_scene
		MaskState.MaskType.DAFT_PUNK:
			mask_scene = daft_punk_mask_scene

	var mask: Mask = Spawn.instantiate_scene(mask_scene, global_position)
	mask.direction = throw_mask_direction