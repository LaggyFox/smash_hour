extends Node

func in_rangef(x: float, a: float, b: float) -> bool:
	return a <= x and x <= b

func in_rangei(x: int, a: int, b: int) -> bool:
	return a <= x and x <= b

## flips a node if needed depending on the given direction
## this method is useful for flipping character bodies, since assigning scale.x = -1 creates issues
func flip_if_needed(node: Node2D, direction: float) -> void:
	var base_scale: float = absf(node.scale.y)
	if direction == 0: 
		return
	if direction < 0:
		node.scale.y = -base_scale
		node.rotation = PI
	else:
		node.scale.y = base_scale
		node.rotation = 0

func disable_flipping(node: Node2D) -> void:
	node.scale.y = 1
	node.rotation = 0

func disable_collision(collision: Node2D) -> void:
	assert(collision is CollisionShape2D or collision is CollisionPolygon2D, "not a collision shape")
	collision.set_deferred("disabled", true)

func enable_collision(collision: Node2D) -> void:
	assert(collision is CollisionShape2D or collision is CollisionPolygon2D, "not a collision shape")
	collision.set_deferred("disabled", false)

func disable_multiple_area_collisions(areas: Array[Area2D]) -> void:
	for area: Area2D in areas:
		set_area_collisions(area, false)

func enable_multiple_area_collisions(areas: Array[Area2D]) -> void:
	for area: Area2D in areas:
		set_area_collisions(area, true)

func disable_area_collisions(area: Area2D) -> void:
	set_area_collisions(area, false)

func enable_area_collisions(area: Area2D) -> void:
	set_area_collisions(area, true)

func set_area_collisions(area: Area2D, enable: bool) -> void:
	for child in area.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", not enable)


func flip_collision_if_needed(collision_shape: CollisionShape2D, direction: float) -> void:
	collision_shape.position.x = abs(collision_shape.position.x) * signf(direction)

# returns the animation time
# NOTE: has a side effect that causes it to play the animation as well, should only be used in the _ready method
func get_animation_length(animation_player: AnimationPlayer, animation_name: String) -> float:
	animation_player.play(animation_name)
	return animation_player.current_animation_length

func get_sign(value: float) -> int:
	return 1 if value > 0 else -1

func safely_disconnect_from_signal(target_signal: Signal, callable: Callable) -> void:
	if target_signal.is_connected(callable):
		target_signal.disconnect(callable)

## can only be used if the callable instance is saved somewhere and used repeatedly, or isn't manipulated in any way
## like with the bind() method
func connect_to_signal_if_not_connected(target_signal: Signal, callable: Callable, flags: int = 0) -> void:
	if not target_signal.is_connected(callable):
		target_signal.connect(callable, flags)

func vec2_move_toward(from: Vector2, to: Vector2, acceleration: Vector2, delta: float) -> Vector2:
	var result: Vector2
	result.x = move_toward(from.x, to.x, acceleration.x * delta)
	result.y = move_toward(from.y, to.y, acceleration.y * delta)
	return result

func is_round_number(value: float) -> bool:
	return is_equal_approx(value, floorf(value))

func smoothstep_lerp_angle(from: float, to: float, total_time: float, current_time: float) -> float:
	var interp_value: float = smoothstep(0, total_time, current_time)
	var rotation: float = lerp_angle(from, to, interp_value)
	return rotation

func enable_one_collision_only(collisions: Array, enabled_collision: Node2D) -> void:
	assert(enabled_collision is CollisionShape2D or enabled_collision is CollisionPolygon2D, "not a collision shape")
	for collision: Node2D in collisions:
		assert(collision is CollisionShape2D or collision is CollisionPolygon2D, "not a collision shape")
		if collision != enabled_collision:
			disable_collision(collision)
			
	enable_collision(enabled_collision)

func directional_input_8() -> Vector2:
	var input := Vector2.ZERO
	input.x = signf(Input.get_action_strength("right") - Input.get_action_strength("left"))
	input.y = signf(Input.get_action_strength("down") - Input.get_action_strength("up"))
	return input.normalized()

func snap_to_direction(v: Vector2, directions: Array[Vector2]) -> Vector2:
	if v.is_equal_approx(Vector2.ZERO): return Vector2.ZERO
	v = v.normalized()
	var min_angle: float = INF
	var nearest_axis: Vector2 = Vector2()

	for direction: Vector2 in directions:
		direction = direction.normalized()
		var cur_angle: float = absf(v.angle_to(direction))
		if cur_angle < min_angle:
			min_angle = cur_angle
			nearest_axis = direction

	return nearest_axis

func snap_to_16_directions(v: Vector2) -> Vector2:
	return snap_to_direction(v, Direction.directions_16)

func snap_to_8_direction(v: Vector2) -> Vector2:
	const directions: Array[Vector2] = [ Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN, Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]
	return snap_to_direction(v, directions)

func snap_to_4_direction(v: Vector2) -> Vector2:
	const directions: Array[Vector2] = [ Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	return snap_to_direction(v, directions)

func is_perpendicular_vector(v: Vector2) -> bool:
	v = v.normalized()
	var is_perpendicular: bool = \
	v.is_equal_approx(Vector2.RIGHT) or v.is_equal_approx(Vector2.LEFT) \
	or v.is_equal_approx(Vector2.UP) or v.is_equal_approx(Vector2.DOWN) 
	return is_perpendicular

func is_navigation_map_ready(nav_agent: NavigationAgent2D) -> bool:
	var map_rid: RID = nav_agent.get_navigation_map()
	return NavigationServer2D.map_get_iteration_id(map_rid) > 0

func has_line_of_sight(from: Vector2, to: Vector2, collision_mask: int = PhysicalLayers.WORLD) -> bool:
	var space_state := get_tree().root.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(from, to, collision_mask)
	var has_los: bool = space_state.intersect_ray(query).is_empty()
	return has_los

func coin_flip() -> bool:
	return randi_range(0, 1) == 1

func steer(from: Vector2, to: Vector2, steer_speed: float, delta: float) -> Vector2:
	var steering_direction: float = sign(from.cross(to))
	var steering_angle: float = steering_direction * delta * deg_to_rad(steer_speed)
	var result := from.rotated(steering_angle)

	var diff_is_too_small_and_may_cause_jitters := rad_to_deg(absf(result.angle_to(to))) <= 10
	if diff_is_too_small_and_may_cause_jitters:
		result = to

	return result

## When a canvas item is freed, it can't be used in triggers. Use this method to disable it instead
func disable_canvas_item(canvas_item: CanvasItem) -> void:
	canvas_item.hide()
	canvas_item.process_mode = Node.PROCESS_MODE_DISABLED

func enable_canvas_item(canvas_item: CanvasItem) -> void:
	canvas_item.show()
	canvas_item.process_mode = Node.PROCESS_MODE_INHERIT

## Returns the resource's string uid
## Can be used for persistency
func get_resource_uid(resource: Resource) -> String:
	assert(not resource.resource_path.is_empty(), "the resource path is empty, don't try accessing it during _init()")
	var id_int: int = ResourceLoader.get_resource_uid(resource.resource_path)
	assert(id_int > -1, "resource has no uid!")
	var id: String = ResourceUID.id_to_text(id_int)
	return id

func resource_has_uid(resource: Resource) -> bool:
	return ResourceLoader.get_resource_uid(resource.resource_path) != -1

func get_closest_human(pos: Vector2, skip_zero_distance: bool = false) -> Human:
	var min_dist: float = INF
	var closest_human: Human = null
	for human: Human in get_tree().get_nodes_in_group("humans"):
		if not human._alive: continue
		
		var dist: float = pos.distance_squared_to(human.global_position)
		
		if dist < min_dist:
			if is_zero_approx(dist) and skip_zero_distance:
				continue
			
			min_dist = dist 
			closest_human = human
			
	return closest_human
