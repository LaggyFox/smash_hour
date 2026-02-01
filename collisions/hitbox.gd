extends Area2D
class_name Hitbox

#@export var knockback_resource: RelativeKnockbackResource = load()
@export var damage: int = 1
@export var knockback_resource: KnockbackResource = load("res://collisions/default_knockback_resource.tres")
@export var flash_resource: FlashResource = load("res://effects/resources/red_hit_flash_resource.tres")
@export var scale_resource: ScaleResource = load("res://effects/resources/normal_hit_scale_resource.tres")
@export var shake_resource: ShakeResource = load("res://effects/resources/normal_hit_shake_resource.tres")
@export var camera_shake_resource: CameraShakeResource
@export var hit_sound: SoundResource = load("res://sound/default_sound_resource.tres")

signal hit_hurtbox(hurted_box: Hurtbox, hit_to_hurt_direction: Vector2)
#signal block_hit_hurtbox(blocked_hurt_box: Hurtbox, direction: float)

#var direction: float = 1 :
	#set(value):
		#if value == 0: return
		#direction = signf(value)

var active: bool = true :
	set(value):
		active = value
		Utils.set_area_collisions(self, active)

var is_changing_direction: bool = false

func _ready() -> void:
	area_entered.connect(_on_hit_hurtbox)

func _on_hit_hurtbox(hurted_box: Hurtbox) -> void:
	var hitbox_owner: Node2D = owner
	var hurtbox_owner: Node2D = hurted_box.owner
	var hit_to_hurt_direction: Vector2 = hitbox_owner.global_position.direction_to(hurtbox_owner.global_position)
	hit_sound.play(global_position)
	hurted_box.got_hurt.emit(self, hit_to_hurt_direction)
	hit_hurtbox.emit(hurted_box, hit_to_hurt_direction)
	if camera_shake_resource:
		Events.request_camera_shake_with_resource.emit(camera_shake_resource)
