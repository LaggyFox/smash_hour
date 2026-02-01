extends Area2D

@export var lifetime: float = 5.0

@onready var timer: ScriptTimer = ScriptTimer.new(self, lifetime, _on_lifetime_expired, true, true)

func _on_lifetime_expired() -> void:
	queue_free()