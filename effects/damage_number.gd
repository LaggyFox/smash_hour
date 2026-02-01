extends Node2D
class_name DamageNumber

@onready var label: Label = $Label

@export var damage_number_resource: DamageNumberResource = load("uid://dn6rabbhbsk7w")

const gravity: float = 700
const max_speed: float = 1000
const max_velocity_x: float = 30
const min_velocity_y: float = -150
const max_velocity_y: float = -150
const time_to_full_scale: float = 0.3
const disappear_time: float = 0.55
const disappear_delay_time: float = 0.25
const tween_duration = disappear_time + disappear_delay_time
const scale_down_time_delay: float = time_to_full_scale + 0.1
const scale_down_time: float = 0.25

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void: 
	hide()

func _process(delta: float) -> void:
	if not visible: return
	velocity.y = move_toward(velocity.y, max_speed, gravity * delta)
	position += velocity * delta

func display_damage(damage: int, dnr: DamageNumberResource = null) -> void:
	if not dnr: dnr = damage_number_resource
	show()
	velocity.y = randf_range(min_velocity_y, max_velocity_y)
	label.text = str(damage)
	var tween: Tween = create_tween()
	velocity.x = randf_range(-max_velocity_x, max_velocity_x)
	label.pivot_offset = label.size / 2.0

	label.scale = Vector2(0, 0)
	tween.set_parallel(true)
	tween.tween_property(label, "modulate:a", 0, disappear_time). \
	set_ease(Tween.EaseType.EASE_IN_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC).set_delay(disappear_delay_time)
	tween.tween_property(label, "scale", Vector2(dnr.max_scale, dnr.max_scale), time_to_full_scale).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)

	if dnr.color_gradient:
		tween.tween_method(_set_damage_number_color.bind(dnr.color_gradient), 0.0, 1.0, tween_duration)\
		.set_ease(dnr.color_ease_type).set_trans(dnr.color_transition_type)
	
	# uncomment for scaling down
	#tween.tween_property(label, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_CUBIC).set_delay(scale_down_time_delay)
	await tween.finished
	queue_free()

func _set_damage_number_color(sample_offset: float, gradient: Gradient) -> void:
	var current_color: Color = gradient.sample(sample_offset)
	label.self_modulate = current_color