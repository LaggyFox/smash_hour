extends Node

signal request_camera_shake

signal request_camera_shake_with_resource(camera_shake_resource: CameraShakeResource)

signal request_camera_target(target: RemoteTransform2D)

signal request_camera_limits(camera_limits: CameraLimits)

signal achieved_kill_count

signal human_infected