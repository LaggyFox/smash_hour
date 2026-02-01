class_name  ExplosionHandler extends Node

@export var camera_shake_resource: CameraShakeResource = load("res://camera/shakes/default_camera_shake_resource.tres")
@export var explosion_scene : PackedScene = preload("res://effects/big_explosion.tscn")

func explode(position : Vector2) -> void:
	var explosion_instance: Node2D = Spawn.instantiate_scene_deferred(explosion_scene, position)
	
	var anim_player : AnimationPlayer = explosion_instance.get_node("AnimationPlayer")	
	anim_player.play("explode") 	
	Events.request_camera_shake_with_resource.emit(camera_shake_resource)
	await anim_player.animation_finished
	
	explosion_instance.queue_free()
	get_parent().queue_free()
