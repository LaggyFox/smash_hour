extends PanelContainer

func _ready() -> void:
	hide()
	Events.achieved_kill_count.connect(func() -> void:
		show()
	)
