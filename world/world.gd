class_name World
extends Node2D

@export var next_level: PackedScene
var _changing_scene: bool = false

func _ready() -> void:
	#Pauser.pause_game()
	await ScreenTransition.to_transparent()
	#Pauser.unpause_game()

func _process(_delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("restart_level"):
		restart_level()
	if OS.is_debug_build() and Input.is_action_just_pressed("complete_level_debug") and OS.is_debug_build():
		on_level_complete()
	if OS.is_debug_build() and Input.is_action_just_pressed("quit") and OS.is_debug_build():
		get_tree().quit()

func on_level_complete() -> void:
	if _changing_scene: return
	_changing_scene = true
	await ScreenTransition.to_black()
	if next_level:
		get_tree().change_scene_to_packed(next_level)
	else:
		# todo create a victory screen
		get_tree().change_scene_to_file("res://victory_screen.tscn")

func restart_level() -> void:
	if _changing_scene: return
	_changing_scene = true
	await ScreenTransition.to_black()
	get_tree().reload_current_scene()
