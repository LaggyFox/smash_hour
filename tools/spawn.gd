extends Node

## Spawn scenes helper methods.

func instantiate_scene(scene: PackedScene, position: Vector2, rotation: float = 0) -> Node2D:
	var instance: Node2D = scene.instantiate()
	instance.global_position = position
	instance.rotation = rotation
	_get_current_scene().add_child(instance)
	return instance

## adds the scene to the tree at the end of the current frame
## useful for adding physical bodies to the scene
func instantiate_scene_deferred(scene: PackedScene, position: Vector2, rotation: float = 0) -> Node2D:
	var instance: Node2D = scene.instantiate()
	instance.global_position = position
	instance.rotation = rotation
	_get_current_scene().add_child.call_deferred(instance)
	return instance

func instantiate_child_scene(parent: Node, scene: PackedScene, offset: Vector2 = Vector2.ZERO, rotation: float = 0) -> Node2D:
	assert(parent, "parent can't be null")
	var instance: Node2D = scene.instantiate()
	instance.position = offset
	instance.rotation = rotation
	parent.add_child(instance)
	return instance

func instantiate_control_child_scene(parent: Node, scene: PackedScene) -> Control:
	assert(parent, "parent can't be null")
	var instance: Control = scene.instantiate()
	parent.add_child(instance)
	return instance

## use this to get the current scene.
## right now just returns the main scene, but in the future we might want to spawn objects under a level
## that is under the main scene.
func _get_current_scene() -> Node:
	return get_tree().current_scene
