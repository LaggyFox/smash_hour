extends Node2D
class_name Propane

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var explosion_handler: ExplosionHandler = $ExplosionHandler

var _can_explode: bool = true

func _ready() -> void:
	hurtbox.got_hurt.connect(_explode)

func _explode(_hitting_box: Hitbox, _direction: Vector2) -> void:
	hide()
	if not _can_explode: return
	_can_explode = false
	explosion_handler.explode(global_position)