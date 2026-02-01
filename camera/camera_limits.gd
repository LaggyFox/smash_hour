extends Control
class_name CameraLimits

func _ready() -> void:
	await get_tree().process_frame # avoids setting the camera limits if the level changes immediately
	Events.request_camera_limits.emit.call_deferred(self)
	hide()
