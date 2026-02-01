extends CharacterBody2D
class_name Human

signal died

@export var friction: float = 2200.0
@export var invincibility_time_after_hit: float = 0.3
@export var death_flash_resource: FlashResource
@export var num_blood_splatter_repeats: int

@export var walk_acceleration: float = 10.0
@export var walk_speed: float = 10.0

@export var panic_acceleration: float = 400.0
@export var panic_speed: float = 600.0
@export var death_modulate: Color

enum PanicAreaReaction {
	RUN_FROM_CENTER,
	RUN_RANDOMLY
}

@export var panic_area_reaction_mode: PanicAreaReaction = PanicAreaReaction.RUN_FROM_CENTER
@export var change_direction_when_hitting_walls_on_panic: bool = true
@export var die_sound: SoundResource = load("res://sound/default_sound_resource.tres")


@export var daft_punk_attract_speed: float = 1500
@export var daft_punk_attract_acceleration: float = 3000

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var sprite: Sprite2D = %Sprite2D
@onready var sprite_transform: Node2D = %SpriteTransform
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var hitpoints: int = 5

@onready var shaker: Shaker = Shaker.new()
@onready var flasher: Flasher = Flasher.new().set_target(sprite)
@onready var scaler: Scaler = Scaler.new()


@onready var invincibility_timer: ScriptTimer = ScriptTimer.new(
	self, invincibility_time_after_hit, disable_invincible)

@onready var state_chart: StateChart = $StateChart

@onready var knockback_hitbox: Hitbox = $KnockbackHitbox
@onready var panic_area_detector: Area2D = $PanicAreaDetector

@onready var attract_area: Area2D = $AttractArea

var move_direction: Vector2 = Vector2.LEFT

var change_direction_cooldown_timer: ScriptTimer = ScriptTimer.new(self, 1.0)

const BLOOD_SPLATTER_SCENE = preload("res://effects/sprites/blood_particles.tscn")

const HIT_PANIC_AREA_SCENE = preload("uid://fuiar01an14i")

const BLOOD_POOL_AREA = preload("res://effects/blood_pool.tscn")

var _alive: bool = true

func _ready() -> void:
	add_child(flasher)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	hurtbox.got_hurt.connect(_on_hurt)
	state_chart.set_expression_property("alive", true)
	Utils.disable_area_collisions(knockback_hitbox)

func _on_mouse_entered() -> void:
	if not MainInstances.mouse_hovered_object:
		MainInstances.mouse_hovered_object = self
		#prints("hovering over", name)

func _on_mouse_exited() -> void:
	if MainInstances.mouse_hovered_object == self:
		MainInstances.mouse_hovered_object = null

func _physics_process(delta: float) -> void:
	if panic_area_detector.has_overlapping_areas():
		state_chart.send_event("entered_panic_area")
	if attract_area.has_overlapping_areas():
		var attract_area_center: Vector2 = attract_area.get_overlapping_areas()[0].global_position
		var attract_area_direction: Vector2 = global_position.direction_to(attract_area_center)
		velocity = velocity.move_toward(daft_punk_attract_speed * attract_area_direction, daft_punk_attract_acceleration * delta)

func _on_hurt(hitting_box: Hitbox, _hit_to_hurt_direction: Vector2) -> void:
	if not _alive: return
	Spawn.instantiate_scene_deferred(HIT_PANIC_AREA_SCENE, global_position)
	var blood_pool: Node2D = Spawn.instantiate_scene(BLOOD_POOL_AREA, global_position)
	blood_pool.rotation = Vector2.from_angle(randf() * TAU).angle()
	var blood_splatter: BloodParticles = Spawn.instantiate_scene(BLOOD_SPLATTER_SCENE, global_position)
	var hitbox_owner: Node2D = hitting_box.owner
	var hit_to_hurt_direction: Vector2 = hitbox_owner.global_position.direction_to(global_position)
	blood_splatter.play(1, hit_to_hurt_direction)
	
	velocity = hitting_box.knockback_resource.compute_knockback_velocity(hitting_box, hurtbox)
	scaler.tween_scale(sprite_transform, hitting_box.scale_resource)
	hitpoints -= hitting_box.damage
	if hitpoints <= 0:
		_alive = false
		physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		invincibility_timer.stop()
		state_chart.send_event("died")
		state_chart.set_expression_property("alive", false)
		hurtbox.invincible = true
		shaker.stop()
		die_sound.play(global_position)
		animation_player.play("die")
		z_index = 0
		if Utils.coin_flip():
			Utils.flip_if_needed(self, -1)
		died.emit()
		#var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		#tween.tween_property(self, "modulate", death_modulate, 1.0)
		#flasher.flash(death_flash_resource)
		#await animation_player.animation_finished
		#hide()
		#queue_free()
		return
	else:
		shaker.tween_shake(sprite_transform, hitting_box.shake_resource)
		flasher.flash(hitting_box.flash_resource)

	enable_invincible()
	state_chart.send_event("hurt")

func enable_invincible() -> void:
	hurtbox.invincible = true
	invincibility_timer.start()

func disable_invincible() -> void:
	hurtbox.invincible = false

func _on_idle_state_entered() -> void:
	animation_player.play("idle")

func _on_walking_state_entered() -> void:
	move_direction = Vector2.from_angle(randf() * TAU).normalized()
	animation_player.play("walk")

func _on_walking_state_physics_processing(delta: float) -> void:
	velocity = velocity.move_toward(walk_speed * move_direction, walk_acceleration * delta)
	move_and_slide()

func _on_panicking_state_entered() -> void:
	move_direction = Vector2.from_angle(randf() * TAU).normalized()

	if panic_area_reaction_mode == PanicAreaReaction.RUN_FROM_CENTER and panic_area_detector.has_overlapping_areas():
		var first_panic_area: Area2D = panic_area_detector.get_overlapping_areas()[0]
		move_direction = first_panic_area.global_position.direction_to(global_position)

	animation_player.play("walk")

func _on_panicking_state_exited() -> void:
	reset_physics_interpolation()

func _on_panicking_state_physics_processing(delta: float) -> void:
	velocity = velocity.move_toward(panic_speed * move_direction, panic_acceleration * delta)
	move_and_slide()

	if change_direction_when_hitting_walls_on_panic and change_direction_cooldown_timer.is_stopped() and get_slide_collision_count() > 0:
		change_direction_cooldown_timer.start()
		move_direction = move_direction.bounce(get_wall_normal())
		velocity = velocity.length() * 0.5 * move_direction

func _on_hurt_state_entered() -> void:
	Utils.enable_area_collisions(knockback_hitbox)

func _on_hurt_state_exited() -> void:
	Utils.disable_area_collisions(knockback_hitbox)

func _on_hurt_state_physics_processing(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()

	if velocity.is_zero_approx():
		state_chart.send_event("hurt_expired")
