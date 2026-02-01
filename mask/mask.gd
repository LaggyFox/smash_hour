extends CharacterBody2D
class_name Mask

@export var speed: float = 1000.0
@export var acceleration: float = 3000.0
@export var rotation_speed_degrees: float = 360
@export var infected_scene: PackedScene = load("res://npcs/car_crasher.tscn")
@export var infect_sound: SoundResource = load("res://sound/default_sound_resource.tres")
@export var throw_sound: SoundResource = load("res://sound/default_sound_resource.tres")

@onready var infect_area: Area2D = $InfectArea

const PANIC_AREA_SCENE: PackedScene = preload("uid://d0hi1jooh4ioo")

var direction: Vector2 = Vector2.LEFT
var _can_infect: bool = true

func _ready() -> void:
	infect_area.area_entered.connect(_infect_victim)
	throw_sound.play(global_position)

func _physics_process(delta: float) -> void:
	rotation_degrees += rotation_speed_degrees * delta
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	move_and_slide()

	if get_slide_collision_count() > 0:
		queue_free() # todo animation before free

func _infect_victim(area: Area2D) -> void:
	if not _can_infect: return
	_can_infect = false
	infect_sound.play(global_position)
	var victim: Node2D = area.owner
	var victim_pos: Vector2 = victim.global_position
	var car_direction: float = MainInstances.player.global_position.direction_to(victim_pos).x
	var infected_instance: Node2D = Spawn.instantiate_scene_deferred(infected_scene, victim_pos)
	if infected_instance is CarCrasher:
		var car_crasher := infected_instance as CarCrasher
		car_crasher.direction = car_direction
	Spawn.instantiate_scene_deferred(PANIC_AREA_SCENE, global_position)
	Events.human_infected.emit()

	area.owner.queue_free()
	queue_free()
