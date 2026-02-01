extends Camera2D
class_name CharacterCamera

@export var default_camera_shake_resource: CameraShakeResource = load("uid://d50y88a6pgtq")

var _shaker: Shaker = Shaker.new()
var _target : RemoteTransform2D : set = set_target

const FRAME_HORIZONTAL_MARGIN = 0 # 28 # used in retro action rpg tutorial for some reason, for now 0 makes it do nothing
const FRAME_VERTICAL_MARGIN = 0 # 6

func _process(_delta: float) -> void:
	if not _shaker.is_shaking():
		position_smoothing_enabled = true
	else:
		position_smoothing_enabled = false

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Events.request_camera_shake_with_resource.connect(shake_camera)
	Events.request_camera_shake.connect(shake_camera)
	Events.request_camera_target.connect(set_target)
	Events.request_camera_limits.connect(update_limits)

func set_target(value: RemoteTransform2D) -> void:
	position_smoothing_enabled = false
	if _target is RemoteTransform2D:
		_target.remote_path = ""
	_target = value
	_target.remote_path = get_path()
	reset_physics_interpolation()
	position_smoothing_enabled = true
	
func shake_camera(camera_shake_resource: CameraShakeResource = default_camera_shake_resource) -> void:
	position_smoothing_enabled = false
	assert(camera_shake_resource, "camera shake resource is null")
	assert(camera_shake_resource.shake_resource, "shake resource is null")
	_shaker.tween_shake(self, camera_shake_resource.shake_resource, "offset")
	if camera_shake_resource.time_freeze_resource:
		Pauser.freeze_time(camera_shake_resource.time_freeze_resource)

func update_limits(camera_limits: CameraLimits) -> void:
	limit_left = int(camera_limits.position.x) - FRAME_HORIZONTAL_MARGIN
	limit_right = int(camera_limits.position.x + camera_limits.size.x) + FRAME_HORIZONTAL_MARGIN
	limit_top = int(camera_limits.position.y) - FRAME_VERTICAL_MARGIN
	limit_bottom = int(camera_limits.position.y + camera_limits.size.y) + FRAME_VERTICAL_MARGIN