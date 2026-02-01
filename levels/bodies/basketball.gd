extends RigidBody2D

@onready var bounce_audio : AudioStreamPlayer2D= $AudioStreamPlayer2D

func _ready() -> void:
	# Connect the collision signal to this script
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node) -> void:
	# Only play sound if the ball is moving fast enough
	if linear_velocity.length() > 30:
		bounce_audio.pitch_scale = randf_range(0.9, 1.1)
		bounce_audio.play()