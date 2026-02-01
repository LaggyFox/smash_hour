extends Timer
class_name ScriptTimer

## A timer whose parameters can be initialized in a script

func _init(
	init_parent: Node, init_wait_time: float = 1, timeout_callback: Callable = Callable(), 
	init_oneshot: bool = true, init_autostart: bool = false) -> void:

	wait_time = init_wait_time
	one_shot = init_oneshot
	autostart = init_autostart
	if not timeout_callback.is_null():
		timeout.connect(timeout_callback)

	init_parent.add_child(self)

func start_rand(from: float, to: float) -> void:
	start(randf_range(from, to))

func increase_current_wait_time(additional_time: float) -> void:
	start(time_left + additional_time)