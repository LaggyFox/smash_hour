extends Control
class_name KillsCounter

@export var percentage_to_win: float = 0.8

var _total_humans_in_level: int
var _kills_to_win: int
var _kills: int = 0

@onready var label: Label = %CountLabel

func _ready() -> void:
	_total_humans_in_level = get_tree().get_node_count_in_group("humans")
	_kills_to_win = floori(percentage_to_win * _total_humans_in_level)

	for human: Human in get_tree().get_nodes_in_group("humans"):
		human.died.connect(_on_human_died)

	Events.human_infected.connect(_on_human_died)
	update_label()

func _on_human_died() -> void:
	_kills += 1
	update_label()
	if _kills == _kills_to_win:
		Events.achieved_kill_count.emit()

func update_label() -> void:
	label.text = str(_kills) + "/" + str(_kills_to_win)